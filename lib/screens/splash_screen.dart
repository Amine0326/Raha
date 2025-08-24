import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;
import 'login_screen.dart';
import '../services/authservice.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _auroraController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;

  // Aurora animations
  late Animation<double> _aurora1Animation;
  late Animation<double> _aurora2Animation;
  late Animation<double> _aurora3Animation;
  late Animation<double> _aurora1OpacityAnimation;
  late Animation<double> _aurora2OpacityAnimation;
  late Animation<double> _aurora3OpacityAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimationSequence();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000),
      vsync: this,
    );

    // Aurora animation controller - continuous loop (slower for better visibility)
    _auroraController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );

    // Logo fade animation (0% to 50% of total duration)
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // Logo scale animation (0% to 60% of total duration)
    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.elasticOut),
      ),
    );

    // Logo rotation animation (0% to 60% of total duration)
    _logoRotationAnimation =
        Tween<double>(
          begin: -0.3, // -15 degrees in radians
          end: 0.0,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
          ),
        );

    // Text fade animation (40% to 100% of total duration)
    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // Text slide animation (40% to 100% of total duration)
    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0.5), // Start from below
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    // Aurora animations - flowing from bottom-right to top-left
    _aurora1Animation = Tween<double>(
      begin: 1.5,
      end: -1.0,
    ).animate(CurvedAnimation(parent: _auroraController, curve: Curves.linear));

    _aurora2Animation = Tween<double>(begin: 2.0, end: -0.5).animate(
      CurvedAnimation(
        parent: _auroraController,
        curve: const Interval(0.1, 1.0, curve: Curves.linear),
      ),
    );

    _aurora3Animation = Tween<double>(begin: 1.0, end: -1.5).animate(
      CurvedAnimation(
        parent: _auroraController,
        curve: const Interval(0.2, 1.0, curve: Curves.linear),
      ),
    );

    // Aurora opacity animations for stronger pulsing effect
    _aurora1OpacityAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _auroraController, curve: Curves.easeInOut),
    );

    _aurora2OpacityAnimation = Tween<double>(begin: 0.5, end: 0.9).animate(
      CurvedAnimation(
        parent: _auroraController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOut),
      ),
    );

    _aurora3OpacityAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _auroraController,
        curve: const Interval(0.1, 0.8, curve: Curves.easeInOut),
      ),
    );
  }

  void _startAnimationSequence() {
    // Start animations
    _controller.forward();
    _auroraController.repeat(reverse: true);

    // بعد اكتمال الأنيميشن، إذا كان المستخدم مسجلاً الدخول من قبل نذهب مباشرة للوحة التحكم
    Future.delayed(const Duration(milliseconds: 6000), () async {
      if (!mounted) return;

      final loggedIn = await AuthService().isLoggedIn();
      if (loggedIn) {
        print('🔐 تم العثور على جلسة مستخدم سابقة، الانتقال إلى اللوحة.');
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _auroraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppTheme.getBackgroundColor(isDark),
                            AppTheme.getSurfaceColor(isDark),
                            AppTheme.getCardColor(isDark),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        )
                      : AppTheme.getAccentGradient(isDark),
                ),
              ),

              // Aurora animation (only in dark mode)
              if (isDark) ...[
                AnimatedBuilder(
                  animation: _auroraController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: AuroraPainter(
                        aurora1Position: _aurora1Animation.value,
                        aurora2Position: _aurora2Animation.value,
                        aurora3Position: _aurora3Animation.value,
                        aurora1Opacity: _aurora1OpacityAnimation.value,
                        aurora2Opacity: _aurora2OpacityAnimation.value,
                        aurora3Opacity: _aurora3OpacityAnimation.value,
                      ),
                      size: Size.infinite,
                    );
                  },
                ),
              ],

              // Main content - positioned to avoid aurora interference
              Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Container(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated Logo with rotation
                          FadeTransition(
                            opacity: _logoFadeAnimation,
                            child: ScaleTransition(
                              scale: _logoScaleAnimation,
                              child: RotationTransition(
                                turns: _logoRotationAnimation,
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.25,
                                  height:
                                      MediaQuery.of(context).size.width * 0.25,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: isDark
                                          ? [
                                              AppTheme.getSurfaceColor(isDark),
                                              AppTheme.getCardColor(isDark),
                                            ]
                                          : [
                                              Colors.white,
                                              const Color(0xFFF3E5F5),
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(
                                          alpha: isDark ? 0.7 : 0.3,
                                        ),
                                        offset: const Offset(0, 8),
                                        blurRadius: 25,
                                      ),
                                      BoxShadow(
                                        color: AppTheme.getPrimaryColor(
                                          isDark,
                                        ).withValues(alpha: isDark ? 0.4 : 0.2),
                                        offset: const Offset(0, 4),
                                        blurRadius: 20,
                                        spreadRadius: 3,
                                      ),
                                      // Additional glow for dark mode
                                      if (isDark)
                                        BoxShadow(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          offset: const Offset(0, 0),
                                          blurRadius: 30,
                                          spreadRadius: 5,
                                        ),
                                    ],
                                  ),
                                  child: Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: Image.asset(
                                        'assets/logo.jpg',
                                        width: MediaQuery.of(context).size.width * 0.25,
                                        height: MediaQuery.of(context).size.width * 0.25,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Animated Title with slide-up
                          SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Text(
                                'راحتي للرعاية الصحية',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.08,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.8,
                                      ),
                                      offset: const Offset(0, 2),
                                      blurRadius: 8,
                                    ),
                                    Shadow(
                                      color: AppTheme.getPrimaryColor(
                                        isDark,
                                      ).withValues(alpha: 0.5),
                                      offset: const Offset(0, 0),
                                      blurRadius: 15,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // Animated Subtitle with slide-up
                          SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Text(
                                'صحتك، أولويتنا',
                                style: TextStyle(
                                  fontSize:
                                      MediaQuery.of(context).size.width * 0.04,
                                  color: Colors.white,
                                  fontStyle: FontStyle.italic,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.7,
                                      ),
                                      offset: const Offset(0, 1),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AuroraPainter extends CustomPainter {
  final double aurora1Position;
  final double aurora2Position;
  final double aurora3Position;
  final double aurora1Opacity;
  final double aurora2Opacity;
  final double aurora3Opacity;

  AuroraPainter({
    required this.aurora1Position,
    required this.aurora2Position,
    required this.aurora3Position,
    required this.aurora1Opacity,
    required this.aurora2Opacity,
    required this.aurora3Opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Aurora colors from the app theme with enhanced neon effect
    final blueColor = const Color(0xFF82AAFF);
    final purpleColor = const Color(0xFFC792EA);
    final pinkColor = const Color(0xFFFF5370);

    // Aurora band 1 (Blue) - diagonal flowing band from bottom-right to top-left
    _drawDiagonalAuroraBand(
      canvas,
      size,
      blueColor.withValues(alpha: aurora1Opacity),
      aurora1Position,
      0.08, // thickness factor (thicker for better visibility)
      0.2, // wave intensity
    );

    // Aurora band 2 (Purple) - diagonal flowing band
    _drawDiagonalAuroraBand(
      canvas,
      size,
      purpleColor.withValues(alpha: aurora2Opacity),
      aurora2Position,
      0.06, // thickness factor
      0.15, // wave intensity
    );

    // Aurora band 3 (Pink) - diagonal flowing band
    _drawDiagonalAuroraBand(
      canvas,
      size,
      pinkColor.withValues(alpha: aurora3Opacity),
      aurora3Position,
      0.1, // thickness factor
      0.25, // wave intensity
    );
  }

  void _drawDiagonalAuroraBand(
    Canvas canvas,
    Size size,
    Color color,
    double position,
    double thicknessFactor,
    double waveIntensity,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

    final path = Path();
    final bandThickness = size.height * thicknessFactor;

    // Create diagonal flow from bottom-right to top-left
    final points = <Offset>[];

    // Generate diagonal points with wave effect
    for (double t = 0; t <= 1.0; t += 0.02) {
      // Diagonal line from bottom-right to top-left
      final baseX = size.width * (1 - t) + size.width * position * 0.3;
      final baseY = size.height * t;

      // Add wave effect
      final wave1 =
          math.sin(t * 4 * math.pi + position * 2 * math.pi) *
          size.width *
          waveIntensity;
      final wave2 =
          math.sin(t * 8 * math.pi + position * math.pi) *
          size.width *
          waveIntensity *
          0.5;

      final x = baseX + wave1 + wave2;
      final y = baseY;

      // Only add points that are within screen bounds
      if (x >= -size.width * 0.2 && x <= size.width * 1.2) {
        points.add(Offset(x, y));
      }
    }

    if (points.length > 2) {
      // Create the aurora band path with thickness
      path.moveTo(points.first.dx - bandThickness, points.first.dy);

      // Top edge of the band
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        final perpX = bandThickness * math.cos(math.atan2(1, -1) + math.pi / 2);
        final perpY = bandThickness * math.sin(math.atan2(1, -1) + math.pi / 2);
        path.lineTo(point.dx + perpX, point.dy + perpY);
      }

      // Bottom edge of the band (reverse)
      for (int i = points.length - 1; i >= 0; i--) {
        final point = points[i];
        final perpX = bandThickness * math.cos(math.atan2(1, -1) - math.pi / 2);
        final perpY = bandThickness * math.sin(math.atan2(1, -1) - math.pi / 2);
        path.lineTo(point.dx + perpX, point.dy + perpY);
      }

      path.close();

      // Create enhanced neon gradient effect
      final gradient = LinearGradient(
        begin: Alignment.bottomRight,
        end: Alignment.topLeft,
        colors: [
          color.withValues(alpha: 0.0),
          color.withValues(alpha: 0.8),
          color,
          color.withValues(alpha: 0.8),
          color.withValues(alpha: 0.0),
        ],
        stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      );

      paint.shader = gradient.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

      // Draw multiple layers for enhanced neon effect
      canvas.drawPath(path, paint);

      // Add glow effect
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 25);
      paint.color = color.withValues(alpha: 0.3);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(AuroraPainter oldDelegate) {
    return aurora1Position != oldDelegate.aurora1Position ||
        aurora2Position != oldDelegate.aurora2Position ||
        aurora3Position != oldDelegate.aurora3Position ||
        aurora1Opacity != oldDelegate.aurora1Opacity ||
        aurora2Opacity != oldDelegate.aurora2Opacity ||
        aurora3Opacity != oldDelegate.aurora3Opacity;
  }
}
