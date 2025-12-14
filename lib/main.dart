import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'package:rumour/widgets/room_code_input.dart';
import 'package:rumour/screens/room_screen.dart';
import 'package:rumour/screens/name_generation_screen.dart';
import 'package:rumour/services/room_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:hive_flutter/hive_flutter.dart';
import 'services/identity_service.dart' as identity_service;

import 'package:rumour/services/theme_service.dart';
import 'package:rumour/services/notification_service.dart';

import 'package:rumour/widgets/app_card.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('identities');
  await ThemeService.instance.loadTheme();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await NotificationService().initialize();
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance,
      builder: (context, mode, child) {
        return MaterialApp(
          title: 'Rumour',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,
          home: const WelcomeScreen(),
        );
      },
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  String _roomCode = "";
  bool _isLoading = false;
  final RoomService _roomService = RoomService();
  final identity_service.IdentityService _identityService =
      identity_service.IdentityService();

  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final FocusNode _roomCodeFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _roomCodeFocusNode.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _roomService.createRoom();
      final roomId = result['id']!;
      final code = result['code']!;

      if (!mounted) return;

      setState(() {
        _roomCode = code;
        _isLoading = false;
      });

      final hasIdentity = _identityService.identityExists(roomId);

      if (hasIdentity) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoomScreen(roomCode: code, roomId: roomId),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                IdentityGenerationScreen(roomId: roomId, roomCode: code),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  void _handleJoin() async {
    if (_roomCode.length != 6) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roomId = await _roomService.joinOrCreateRoom(_roomCode);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      final hasIdentity = _identityService.identityExists(roomId);

      if (hasIdentity) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RoomScreen(roomCode: _roomCode, roomId: roomId),
          ),
        );
      } else {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                IdentityGenerationScreen(roomId: roomId, roomCode: _roomCode),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 42.0),
                        child: Center(
                          child: ClipOval(
                            child: Image.asset(
                              'assets/images/app_logo.png',
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(
                                    Icons.flash_on,
                                    size: 32,
                                    color: AppColors.limeAccent,
                                  ),
                            ),
                          ),
                        ),
                      ),

                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24.0,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Join A Room",
                                  style: Theme.of(context)
                                      .textTheme
                                      .displayLarge
                                      ?.copyWith(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Text(
                                    "Enter the code to join the anon chat room",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(height: 32),

                                GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_roomCodeFocusNode);
                                  },
                                  child: AppCard(
                                    child: Column(
                                      children: [
                                        RoomCodeInput(
                                          focusNode: _roomCodeFocusNode,
                                          onChanged: (value) {
                                            setState(() {
                                              _roomCode = value;
                                            });
                                          },
                                          onCompleted: (value) {
                                            setState(() {
                                              _roomCode = value;
                                            });
                                            _handleJoin();
                                          },
                                        ),
                                        const SizedBox(height: 24),
                                        GestureDetector(
                                          onTap:
                                              _isLoading || _roomCode.length < 6
                                              ? null
                                              : _handleJoin,
                                          child: Opacity(
                                            opacity: _roomCode.length == 6
                                                ? 1.0
                                                : 0.5,
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 16,
                                                  ),
                                              decoration:
                                                  AppTheme.glowButtonDecoration,
                                              child: _isLoading
                                                  ? const Center(
                                                      child: SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                      ),
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          "ENTER ROOM",
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .labelLarge
                                                              ?.copyWith(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          width: 8,
                                                        ),
                                                        Image.asset(
                                                          'assets/images/vector.png',
                                                          height: 18,
                                                          color: Colors.black,
                                                          errorBuilder:
                                                              (
                                                                c,
                                                                e,
                                                                s,
                                                              ) => const Icon(
                                                                Icons
                                                                    .arrow_forward_rounded,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              ),
                                                        ),
                                                      ],
                                                    ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                GestureDetector(
                                  onTap: _isLoading ? null : _handleCreate,
                                  child: Opacity(
                                    opacity: _isLoading ? 0.5 : 1.0,
                                    child: RichText(
                                      text: TextSpan(
                                        text: "Don't have a code? ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? AppColors.textMuted
                                                  : AppColors
                                                        .textSecondaryLight,
                                            ),
                                        children: [
                                          TextSpan(
                                            text: "Create one",
                                            style: TextStyle(
                                              color:
                                                  Theme.of(
                                                        context,
                                                      ).brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.bold,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  onPressed: () {
                    ThemeService.instance.toggleTheme();
                  },
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
