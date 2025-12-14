import 'dart:async';
import 'package:rumour/widgets/room_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rumour/models/message.dart';
import 'package:rumour/services/chat_service.dart';
import 'package:rumour/services/identity_service.dart';
import 'package:rumour/theme/app_colors.dart';
import 'package:rumour/widgets/chat_bubble.dart';

import 'package:rumour/services/presence_service.dart';
import 'package:rumour/services/notification_service.dart';

class RoomScreen extends StatefulWidget {
  final String roomCode;
  final String? roomId;

  const RoomScreen({super.key, required this.roomCode, this.roomId});

  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final IdentityService _identityService = IdentityService();
  final PresenceService _presenceService = PresenceService();

  final ScrollController _scrollController = ScrollController();

  String? _resolvedRoomId;
  String? _myHandle;
  bool _loading = true;
  Timer? _heartbeatTimer;

  List<Message> _messages = [];
  bool _isLoadingMore = false;
  bool _hasMore = true;
  StreamSubscription? _chatSubscription;

  @override
  void initState() {
    super.initState();
    _initRoomAndChat();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    if (_resolvedRoomId != null && _myHandle != null) {
      _presenceService.leaveRoom(_resolvedRoomId!, _myHandle!);
      NotificationService().unsubscribeFromRoom(_resolvedRoomId!);
    }
    _scrollController.dispose();
    _chatSubscription?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreHistory();
    }
  }

  Future<void> _initRoomAndChat() async {
    String rid = widget.roomId ?? "";
    if (rid.isEmpty) {}

    if (widget.roomId != null) {
      final identity = await _identityService.getIdentityForRoom(
        widget.roomId!,
      );
      if (!mounted) return;

      setState(() {
        _resolvedRoomId = widget.roomId;
        _myHandle = identity.handle;
        _loading = false;
      });

      _subscribeToChat();
      _startHeartbeat();
    }
  }

  void _startHeartbeat() {
    if (_resolvedRoomId == null || _myHandle == null) return;

    _presenceService.updatePresence(_resolvedRoomId!, _myHandle!);

    _heartbeatTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (mounted && _resolvedRoomId != null && _myHandle != null) {
        _presenceService.updatePresence(_resolvedRoomId!, _myHandle!);
      }
    });

    NotificationService().subscribeToRoom(_resolvedRoomId!);
  }

  void _subscribeToChat() {
    if (_resolvedRoomId == null || _myHandle == null) return;

    _chatSubscription = _chatService
        .getMessagesStream(_resolvedRoomId!, _myHandle!, limit: 25)
        .listen((newBatch) {
          _mergeStreamMessages(newBatch);
        });
  }

  void _mergeStreamMessages(List<Message> latestMessages) {
    if (latestMessages.isEmpty) return;
    setState(() {
      final existingMap = {for (var m in _messages) m.id: m};

      for (var msg in latestMessages) {
        existingMap[msg.id] = msg;
      }

      final merged = existingMap.values.toList();
      merged.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      _messages = merged;
    });
  }

  Future<void> _loadMoreHistory() async {
    if (_isLoadingMore ||
        !_hasMore ||
        _messages.isEmpty ||
        _resolvedRoomId == null) {
      return;
    }
    setState(() => _isLoadingMore = true);

    final oldestMessage = _messages.last;

    if (oldestMessage.sourceDoc == null) {
      setState(() => _isLoadingMore = false);
      return;
    }

    try {
      final olderBatch = await _chatService.getHistory(
        _resolvedRoomId!,
        _myHandle!,
        oldestMessage.sourceDoc!,
        limit: 25,
      );
      if (olderBatch.isEmpty) {
        setState(() {
          _hasMore = false;
          _isLoadingMore = false;
        });
      } else {
        setState(() {
          _messages.addAll(olderBatch);
          _messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          _isLoadingMore = false;
        });
      }
    } catch (e) {
      debugPrint("Load more error: $e");
      setState(() => _isLoadingMore = false);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _resolvedRoomId == null) return;

    _chatService.sendMessage(_resolvedRoomId!, text);
    _messageController.clear();
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  bool _shouldShowDateHeader(int index) {
    if (index == _messages.length - 1) {
      return true;
    }

    final currentGroup = DateTime(
      _messages[index].timestamp.year,
      _messages[index].timestamp.month,
      _messages[index].timestamp.day,
    );
    final neztMsg = _messages[index + 1];
    final nextGroup = DateTime(
      neztMsg.timestamp.year,
      neztMsg.timestamp.month,
      neztMsg.timestamp.day,
    );

    return currentGroup != nextGroup;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading || _resolvedRoomId == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.limeAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: RoomAppBar(roomCode: widget.roomCode, roomId: _resolvedRoomId!,
      ),
      body: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Center(
                        child: Text(
                          "Start the rumour...",
                          style: TextStyle(
                            color: isDark
                                ? AppColors.mutedText
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        reverse: true,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          final showHeader = _shouldShowDateHeader(index);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (showHeader) _buildDateSeparator(message),
                              _AnimatedChatBubble(
                                key: ValueKey(message.id),
                                child: ChatBubble(message: message),
                              ),
                            ],
                          );
                        },
                        padding: const EdgeInsets.symmetric(vertical: 20),
                      ),
              ),

              _buildInputArea(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSeparator(Message message) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(
      message.timestamp.year,
      message.timestamp.month,
      message.timestamp.day,
    );

    String text;
    if (date == today) {
      text = "Today";
    } else if (date == yesterday) {
      text = "Yesterday";
    } else {
      text = DateFormat('MMMM d, y').format(date);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 4),
        decoration: BoxDecoration(
          color: isDark ? AppColors.backButtonBg : AppColors.cardLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isDark ? AppColors.textMuted : AppColors.textSecondaryLight,
            fontSize: 11.34,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                hintText: "Type a message",
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.hintText.withAlpha((255 * 0.3).round())
                      : AppColors.textSecondaryLight.withAlpha(
                          (255 * 0.6).round(),
                        ),
                  fontWeight: FontWeight.w400,
                  fontSize: 13.23,
                ),
                filled: true,
                fillColor: isDark
                    ? AppColors.cardDark.withAlpha((255 * .8).round())
                    : AppColors.cardLight,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: isDark
                      ? BorderSide.none
                      : const BorderSide(
                          color: AppColors.cardBorderLight,
                          width: 0,
                        ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: isDark
                      ? BorderSide.none
                      : const BorderSide(
                          color: AppColors.cardBorderLight,
                          width: 0,
                        ),
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _sendMessage,
            child: Container(
              padding: const EdgeInsets.only(
                left: 14,
                right: 10,
                top: 12,
                bottom: 12,
              ),
              decoration: const BoxDecoration(
                color: AppColors.limeAccent,
                shape: BoxShape.circle,
              ),
              child: Transform.rotate(
                angle: -0.79,
                child: const Icon(
                  Icons.send_outlined,
                  color: Colors.black,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedChatBubble extends StatefulWidget {
  final Widget child;
  const _AnimatedChatBubble({super.key, required this.child});

  @override
  State<_AnimatedChatBubble> createState() => _AnimatedChatBubbleState();
}

class _AnimatedChatBubbleState extends State<_AnimatedChatBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
