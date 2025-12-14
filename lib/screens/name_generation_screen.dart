import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/identity_service.dart';

import 'room_screen.dart';
import '../widgets/room_app_bar.dart';

class IdentityGenerationScreen extends StatefulWidget {
  final String roomId;
  final String roomCode;

  const IdentityGenerationScreen({
    super.key,
    required this.roomId,
    required this.roomCode,
  });

  @override
  State<IdentityGenerationScreen> createState() =>
      _IdentityGenerationScreenState();
}

class _IdentityGenerationScreenState extends State<IdentityGenerationScreen>
    with SingleTickerProviderStateMixin {
  final IdentityService _identityService = IdentityService();
  Identity? _identity;
  bool _isLoading = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
        );

    _fetchIdentity();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _fetchIdentity() async {
    await Future.delayed(const Duration(milliseconds: 500));
    final identity = await _identityService.getIdentityForRoom(widget.roomId);
    if (!mounted) return;
    setState(() {
      _identity = identity;
      _isLoading = false;
    });
    _animController.forward();
  }

  void _handleContinue() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            RoomScreen(roomCode: widget.roomCode, roomId: widget.roomId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.limeAccent),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, 
      appBar: RoomAppBar(roomCode: widget.roomCode, roomId: widget.roomId,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDark.withAlpha((255 * .8).round())
                          : AppColors.cardLight,
                      borderRadius: BorderRadius.circular(15.63),
                      border: isDark
                          ? null
                          : Border.all(color: AppColors.cardBorderLight),
                    ),
                    child: Column(
                      children: [
                        Text(
                      "For this room, you are",
                      style: TextStyle(
                            color: isDark
                                ? AppColors.textMuted
                                : AppColors.textSecondaryLight,
                        fontSize: 13.67,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._buildNameWidgets(_identity!.displayName),

                    const SizedBox(height: 6),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        "This is your anonymous identifier, visible only to others in this room.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                              color: isDark
                                  ? AppColors.textLight
                                  : AppColors.textSecondaryLight,
                          fontSize: 13.67,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 31.25),
              GestureDetector(
                onTap: _handleContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                        color: AppColors.limeAccent,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                            color: AppColors.limeAccent.withAlpha(
                              (255 * 0.3).round(),
                            ),
                        blurRadius: 13.67,
                        offset: const Offset(0, 3.91),
                      ),
                    ],
                  ),
                  child: const Text(
                    "Acknowledge and continue",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 17.58,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildNameWidgets(String name) {
    final parts = name.split(' ');

    return parts.map((part) {
      return ShaderMask(
        shaderCallback: (bounds) {
          return const LinearGradient(
            colors: [AppColors.yellowGradient, AppColors.limeGradient],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bounds);
        },
        child: Text(
          part,
          style: const TextStyle(
            fontSize: 58.59,
            fontWeight: FontWeight.w900,
            height: 1.1,
            color: Colors.white,
          ),
        ),
      );
    }).toList();
  }
}
