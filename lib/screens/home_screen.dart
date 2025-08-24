import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;
import 'accommodations_screen.dart';
import 'transport_screen.dart';

import 'meals_screen.dart';
import 'centers_screen.dart';
import 'rooms_discovery_screen.dart';
import 'profile_screen.dart';
import '../providers/user_provider.dart';
import '../services/authservice.dart';
import 'reservations/reservation_stepper_screen.dart';
import 'my_reservations_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late PageController _pageController;
  late Timer _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoSlide();

    // جلب بيانات المستخدم الحالية بعد الإطار الأول
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final up = Provider.of<UserProvider>(context, listen: false);
        if (up.currentUser == null && !up.isLoading) {
          up.fetchCurrentUser();
        }
      } catch (e) {
        print('⚠️ فشل طلب جلب المستخدم في الشاشة الرئيسية: $e');
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        _currentPage = (_currentPage + 1) % 4; // 4 total banners
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        Future<void> _handleRefreshHome() async {
          try {
            final up = Provider.of<UserProvider>(context, listen: false);
            await up.fetchCurrentUser();
          } catch (e) {
            // تجاهل الأخطاء هنا، سيتم عرضها عبر مزود المستخدم إن لزم
          }
          // يمكن إضافة عمليات تحديث أخرى هنا لاحقاً
        }

        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          body: SafeArea(
            child: RefreshIndicator(
              onRefresh: _handleRefreshHome,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.02,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header with profile and settings
                      _buildHeader(context, isDark),

                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.025,
                      ),

                      // Welcome section
                      _buildWelcomeSection(context, isDark),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      // Hero Banners section
                      _buildHeroBannersSection(context, isDark),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.03),

                      // Simple Info Section
                      _buildInfoSection(context, isDark),

                      SizedBox(height: MediaQuery.of(context).size.height * 0.02),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // زر الحجز السريع كزر طافٍ
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Debug logout button - remove this after testing
              FloatingActionButton(
                heroTag: "debug_logout",
                mini: true,
                backgroundColor: Colors.red,
                onPressed: () {
                  print('🔴 DEBUG: تم الضغط على زر تسجيل الخروج التجريبي');
                  _testLogout(context);
                },
                child: const Icon(Icons.logout, color: Colors.white),
              ),
              const SizedBox(height: 8),
              _buildReservationFab(context, isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final avatarSize = screenWidth * 0.12;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Profile section
        Expanded(
          child: GestureDetector(
            onTap: () => _showProfileBottomSheet(context, isDark),
            child: Row(
              children: [
                Container(
                  width: avatarSize,
                  height: avatarSize,
                  decoration: BoxDecoration(
                    gradient: AppTheme.getPrimaryGradient(isDark),
                    borderRadius: BorderRadius.circular(avatarSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.getPrimaryColor(
                          isDark,
                        ).withValues(alpha: 0.3),
                        offset: const Offset(0, 4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'م',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: avatarSize * 0.4,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: screenWidth * 0.03),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحباً',
                        style: TextStyle(
                          color: AppTheme.getHintColor(isDark),
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                      Consumer<UserProvider>(
                        builder: (context, userProvider, _) {
                          final String name = userProvider.currentUser?.name ?? '—';
                          return Text(
                            name,
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: screenWidth * 0.045,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Settings only
        IconButton(
          onPressed: () {
            _showSettingsBottomSheet(context, isDark);
          },
          icon: Icon(
            Icons.settings_outlined,
            color: AppTheme.getOnSurfaceColor(isDark),
            size: screenWidth * 0.06,
          ),
          padding: EdgeInsets.all(screenWidth * 0.02),
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أهلاً وسهلاً بك في راحتي',
          style: TextStyle(
            color: AppTheme.getOnSurfaceColor(isDark),
            fontSize: MediaQuery.of(context).size.width * 0.06,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
        ),
        SizedBox(height: MediaQuery.of(context).size.width * 0.02),
        Text(
          'نحن هنا لنوفر لك أفضل خدمات الرعاية الصحية',
          style: TextStyle(
            color: AppTheme.getHintColor(isDark),
            fontSize: MediaQuery.of(context).size.width * 0.04,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesSection(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Appointment Reservation at the top
        _buildAppointmentCard(context, isDark),

        SizedBox(height: MediaQuery.of(context).size.height * 0.04),

        // Services section header
        _buildSectionHeader(
          context,
          isDark,
          'تصفح خدماتنا',
          Icons.explore_rounded,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.025),

        // Services list (excluding appointment)
        _buildServicesList(context, isDark),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    bool isDark,
    String title,
    IconData icon,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(screenWidth * 0.025),
          decoration: BoxDecoration(
            gradient: AppTheme.getPrimaryGradient(isDark),
            borderRadius: BorderRadius.circular(screenWidth * 0.03),
            boxShadow: [
              BoxShadow(
                color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.3),
                offset: const Offset(0, 4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Icon(icon, color: Colors.white, size: screenWidth * 0.05),
        ),
        SizedBox(width: screenWidth * 0.03),
        Text(
          title,
          style: TextStyle(
            color: AppTheme.getOnSurfaceColor(isDark),
            fontSize: screenWidth * 0.05,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildModernServiceCard(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    String imagePath,
    Color accentColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: screenHeight * 0.25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          child: Stack(
            children: [
              // Background image with parallax effect
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              // Modern gradient overlay - reduced opacity
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.4), // Reduced from 0.7
                        Colors.black.withValues(alpha: 0.2), // Reduced from 0.3
                        accentColor.withValues(alpha: 0.5), // Reduced from 0.8
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Content positioned at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    screenWidth * 0.058, // Increased from 0.05
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.012,
                            ), // Increased spacing
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.95,
                                ), // Increased opacity
                                fontSize:
                                    screenWidth * 0.042, // Increased from 0.035
                                height: 1.4,
                                fontWeight: FontWeight.w500, // Added weight
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),

                      // Modern floating icon
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.035),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.04,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        _startReservationFlow(context);
      },
      child: Container(
        height: screenHeight * 0.25,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF667EEA),
              const Color(0xFF764BA2),
            ], // Changed to purple gradient
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF667EEA).withValues(alpha: 0.4),
              offset: const Offset(0, 8),
              blurRadius: 24,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/consultation.jpg'),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              // Gradient overlay - reduced opacity
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        const Color(
                          0xFF2D3748,
                        ).withValues(alpha: 0.0), // Reduced from 0.7
                        const Color(
                          0xFF4A5568,
                        ).withValues(alpha: 0.2), // Reduced from 0.5
                        const Color(0xFF667EEA).withValues(
                          alpha: 0.3,
                        ), // Changed color and reduced opacity
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Content positioned at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.06),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenWidth * 0.03,
                                vertical: screenWidth * 0.01,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.02,
                                ),
                              ),
                              child: Text(
                                'حجز فوري',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.015),
                            Text(
                              'احجز موعدك الطبي',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    screenWidth * 0.065, // Increased from 0.055
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: screenHeight * 0.012,
                            ), // Increased spacing
                            Text(
                              'استشارة طبية فورية مع أفضل الأطباء المتخصصين في جميع التخصصات الطبية',
                              style: TextStyle(
                                color: Colors.white.withValues(
                                  alpha: 0.95,
                                ), // Increased opacity
                                fontSize:
                                    screenWidth * 0.04, // Increased from 0.035
                                height: 1.4,
                                fontWeight: FontWeight.w500, // Added weight
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                              maxLines: 3, // Increased from 2
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.04),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.04,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Icon(
                          Icons.calendar_today_rounded,
                          color: Colors.white,
                          size: screenWidth * 0.08,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, bool isDark) {
    final services = [
      {
        'title': 'الإقامة',
        'subtitle': 'غرف مريحة ومجهزة بأحدث التقنيات مع خدمة على مدار الساعة',
        'image': 'assets/room.jpg',
        'color': const Color(0xFF82AAFF),
        'icon': Icons.hotel_rounded,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccommodationsScreen()),
        ),
      },
      {
        'title': 'التغذية',
        'subtitle': 'وجبات صحية متوازنة معدة خصيصاً لاحتياجاتك الطبية',
        'image': 'assets/food.jpg',
        'color': const Color(0xFFC792EA),
        'icon': Icons.restaurant_rounded,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MealsScreen()),
        ),
      },
      {
        'title': 'النقل',
        'subtitle': 'خدمة نقل آمنة ومريحة مع سائقين مدربين ومركبات مجهزة طبياً',
        'image': 'assets/transportation.jpg',
        'color': const Color(0xFFFF5370),
        'icon': Icons.directions_car_rounded,
        'onTap': () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransportScreen()),
        ),
      },
    ];

    return Column(
      children: services
          .map(
            (service) => Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height * 0.02,
              ),
              child: _buildModernServiceCard(
                context,
                isDark,
                service['title'] as String,
                service['subtitle'] as String,
                service['image'] as String,
                service['color'] as Color,
                service['icon'] as IconData,
                service['onTap'] as VoidCallback,
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildHeroBannersSection(BuildContext context, bool isDark) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Hero Banners with PageView
        SizedBox(
          height: screenHeight * 0.25,
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            children: [
              _buildHeroBanner(
                context,
                isDark,
                'احجز موعدك الطبي',
                'استشارة طبية فورية مع أفضل الأطباء المتخصصين في جميع التخصصات الطبية',
                'assets/consultation.jpg',
                const Color(0xFF667EEA),
                Icons.calendar_today_rounded,
                () {
                  _startReservationFlow(context);
                },
              ),
              _buildHeroBanner(
                context,
                isDark,
                'الإقامة',
                'غرف مريحة ومجهزة بأحدث التقنيات مع خدمة على مدار الساعة',
                'assets/room.jpg',
                const Color(0xFF82AAFF),
                Icons.hotel_rounded,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccommodationsScreen(),
                  ),
                ),
              ),
              _buildHeroBanner(
                context,
                isDark,
                'التغذية',
                'وجبات صحية متوازنة معدة خصيصاً لاحتياجاتك الطبية',
                'assets/food.jpg',
                const Color(0xFFC792EA),
                Icons.restaurant_rounded,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MealsScreen()),
                ),
              ),
              _buildHeroBanner(
                context,
                isDark,
                'النقل',
                'خدمة نقل آمنة ومريحة مع سائقين مدربين ومركبات مجهزة طبياً',
                'assets/transportation.jpg',
                const Color(0xFFFF5370),
                Icons.directions_car_rounded,
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TransportScreen(),
                  ),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: MediaQuery.of(context).size.height * 0.02),

        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(4, (index) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? AppTheme.getPrimaryColor(isDark)
                    : AppTheme.getHintColor(isDark).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildHeroBanner(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    String imagePath,
    Color accentColor,
    IconData icon,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
              offset: const Offset(0, 4),
              blurRadius: 16,
            ),
            BoxShadow(
              color: accentColor.withValues(alpha: 0.3),
              offset: const Offset(0, 8),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(screenWidth * 0.05),
          child: Stack(
            children: [
              // Background image
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),

              // Gradient overlay - reduced opacity
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.black.withValues(alpha: 0.2),
                        accentColor.withValues(alpha: 0.5),
                      ],
                      stops: const [0.0, 0.6, 1.0],
                    ),
                  ),
                ),
              ),

              // Content positioned at bottom
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: EdgeInsets.all(screenWidth * 0.05),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.058,
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withValues(alpha: 0.3),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.008),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontSize: screenWidth * 0.035,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withValues(alpha: 0.2),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(screenWidth * 0.035),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.04,
                          ),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              offset: const Offset(0, 4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: Colors.white,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final explorationItems = [
      {
        'title': 'استكشف مراكزنا الطبية',
        'subtitle': '15+ مركز متخصص • أحدث التقنيات العالمية',
        'description':
            'اكتشف مراكزنا المجهزة بأحدث المعدات الطبية والتقنيات المتطورة',
        'icon': Icons.explore_rounded,
        'secondaryIcon': Icons.local_hospital_rounded,
        'color': const Color(0xFF667EEA),
        'gradient': [const Color(0xFF667EEA), const Color(0xFF764BA2)],
        'stats': '15+ مراكز',
        'badge': 'متطور',
      },
      {
        'title': 'استكشف غرفنا المميزة',
        'subtitle': '200+ غرفة فاخرة • خدمة 5 نجوم',
        'description': 'تجول في غرفنا المصممة خصيصاً لراحتك وشفائك السريع',
        'icon': Icons.explore_rounded,
        'secondaryIcon': Icons.hotel_rounded,
        'color': const Color(0xFF4ECDC4),
        'gradient': [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
        'stats': '200+ غرفة',
        'badge': 'فاخر',
      },
      {
        'title': 'استكشف وجباتنا الصحية',
        'subtitle': '50+ وجبة متخصصة • تغذية علاجية',
        'description':
            'اطلع على قوائم طعامنا المعدة من قبل خبراء التغذية العلاجية',
        'icon': Icons.explore_rounded,
        'secondaryIcon': Icons.restaurant_rounded,
        'color': const Color(0xFFFF6B6B),
        'gradient': [const Color(0xFFFF6B6B), const Color(0xFFEE5A24)],
        'stats': '50+ وجبة',
        'badge': 'صحي',
      },
      {
        'title': 'استكشف أسطول النقل',
        'subtitle': '30+ مركبة مجهزة • نقل طبي متخصص',
        'description': 'تعرف على مركباتنا المجهزة طبياً لنقل آمن ومريح',
        'icon': Icons.explore_rounded,
        'secondaryIcon': Icons.directions_car_rounded,
        'color': const Color(0xFF9C27B0),
        'gradient': [const Color(0xFF9C27B0), const Color(0xFF673AB7)],
        'stats': '30+ مركبة',
        'badge': 'آمن',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Modern Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          child: Row(
            children: [
              Container(
                width: 4,
                height: screenWidth * 0.06,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.getPrimaryColor(isDark),
                      AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(width: screenWidth * 0.03),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'استكشف عالمنا الطبي',
                    style: TextStyle(
                      color: AppTheme.getOnSurfaceColor(isDark),
                      fontSize: screenWidth * 0.045,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'رحلة تفاعلية عبر مرافقنا المتطورة',
                    style: TextStyle(
                      color: AppTheme.getHintColor(isDark),
                      fontSize: screenWidth * 0.032,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        SizedBox(height: screenHeight * 0.025),

        // Intelligent Exploration List
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
          itemCount: explorationItems.length,
          itemBuilder: (context, index) {
            final item = explorationItems[index];
            return Padding(
              padding: EdgeInsets.only(bottom: screenHeight * 0.015),
              child: _buildIntelligentExplorationCard(
                context,
                isDark,
                item['title'] as String,
                item['subtitle'] as String,
                item['description'] as String,
                item['icon'] as IconData,
                item['secondaryIcon'] as IconData,
                item['color'] as Color,
                item['gradient'] as List<Color>,
                item['stats'] as String,
                item['badge'] as String,
                index,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildIntelligentExplorationCard(
    BuildContext context,
    bool isDark,
    String title,
    String subtitle,
    String description,
    IconData icon,
    IconData secondaryIcon,
    Color color,
    List<Color> gradient,
    String stats,
    String badge,
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
            offset: const Offset(0, 4),
            blurRadius: 20,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            offset: const Offset(0, 8),
            blurRadius: 30,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        child: Stack(
          children: [
            // Intelligent gradient background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      gradient[0].withValues(alpha: 0.08),
                      gradient[1].withValues(alpha: 0.03),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.6, 1.0],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.all(screenWidth * 0.045),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row
                  Row(
                    children: [
                      // Dual Icon Design
                      Stack(
                        children: [
                          Container(
                            width: screenWidth * 0.15,
                            height: screenWidth * 0.15,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradient,
                              ),
                              borderRadius: BorderRadius.circular(
                                screenWidth * 0.04,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: color.withValues(alpha: 0.4),
                                  offset: const Offset(0, 6),
                                  blurRadius: 16,
                                ),
                              ],
                            ),
                            child: Icon(
                              icon,
                              color: Colors.white,
                              size: screenWidth * 0.065,
                            ),
                          ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: EdgeInsets.all(screenWidth * 0.015),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(
                                  screenWidth * 0.02,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.1),
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Icon(
                                secondaryIcon,
                                color: color,
                                size: screenWidth * 0.035,
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(width: screenWidth * 0.04),

                      // Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: TextStyle(
                                      color: AppTheme.getOnSurfaceColor(isDark),
                                      fontSize: screenWidth * 0.042,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                ),
                                // Smart Badge
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.025,
                                    vertical: screenWidth * 0.01,
                                  ),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(
                                      screenWidth * 0.02,
                                    ),
                                    border: Border.all(
                                      color: color.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    badge,
                                    style: TextStyle(
                                      color: color,
                                      fontSize: screenWidth * 0.028,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: screenWidth * 0.015),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: AppTheme.getHintColor(isDark),
                                fontSize: screenWidth * 0.032,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: screenWidth * 0.03),

                  // Description
                  Text(
                    description,
                    style: TextStyle(
                      color: AppTheme.getHintColor(isDark),
                      fontSize: screenWidth * 0.035,
                      height: 1.4,
                    ),
                  ),

                  SizedBox(height: screenWidth * 0.03),

                  // Bottom Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Stats
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.03,
                          vertical: screenWidth * 0.015,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.025,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.analytics_rounded,
                              color: color,
                              size: screenWidth * 0.035,
                            ),
                            SizedBox(width: screenWidth * 0.015),
                            Text(
                              stats,
                              style: TextStyle(
                                color: color,
                                fontSize: screenWidth * 0.03,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Explore Button
                      GestureDetector(
                        onTap: () => _handleExploreNavigation(context, index),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: screenWidth * 0.02,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: gradient),
                            borderRadius: BorderRadius.circular(
                              screenWidth * 0.03,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: color.withValues(alpha: 0.3),
                                offset: const Offset(0, 4),
                                blurRadius: 12,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'استكشف الآن',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.032,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.015),
                              Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: screenWidth * 0.035,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Intelligent decorative elements
            Positioned(
              top: -15,
              right: -15,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [color.withValues(alpha: 0.15), Colors.transparent],
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleExploreNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Medical Centers
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CentersScreen()),
        );
        break;
      case 1: // Rooms
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RoomsDiscoveryScreen()),
        );
        break;
      case 2: // Meals
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MealsScreen()),
        );
        break;
      case 3: // Transportation
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TransportScreen()),
        );
        break;
    }
  }

  void _showProfileBottomSheet(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.08),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.65,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDark),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screenWidth * 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Enhanced handle bar
              Center(
                child: Container(
                  width: screenWidth * 0.12,
                  height: screenWidth * 0.012,
                  decoration: BoxDecoration(
                    color: AppTheme.getHintColor(isDark).withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.006),
                  ),
                ),
              ),
              SizedBox(height: screenWidth * 0.06),

              // Profile header
              Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.2,
                    height: MediaQuery.of(context).size.width * 0.2,
                    decoration: BoxDecoration(
                      gradient: AppTheme.getPrimaryGradient(isDark),
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'م',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: MediaQuery.of(context).size.width * 0.08,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: MediaQuery.of(context).size.width * 0.04),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Consumer<UserProvider>(
                          builder: (context, userProvider, _) {
                            final name = userProvider.currentUser?.name ?? '—';
                            final role = userProvider.currentUser?.roleInArabic ?? '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: TextStyle(
                                    color: AppTheme.getOnSurfaceColor(isDark),
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  role.isNotEmpty ? role : '—',
                                  style: TextStyle(
                                    color: AppTheme.getHintColor(isDark),
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Profile options
              _buildProfileOption(
                context,
                isDark,
                Icons.person_outline,
                'عرض الملف الشخصي',
                () {
                  Navigator.pop(context); // Close the bottom sheet first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        final user = Provider.of<UserProvider>(context, listen: false).currentUser;
                        return ProfileScreen(user: user);
                      },
                    ),
                  );
                },
              ),
              _buildProfileOption(
                context,
                isDark,
                Icons.medical_information_outlined,
                'السجل الطبي',
                () {
                  Navigator.pop(context); // Close the bottom sheet first
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('هذه الميزة ستكون متاحة قريباً'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              _buildProfileOption(
                context,
                isDark,
                Icons.history,
                'حجوزاتي',
                () {
                  Navigator.pop(context); // Close the bottom sheet first
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MyReservationsScreen(),
                    ),
                  );
                },
              ),
              _buildProfileOption(
                context,
                isDark,
                Icons.logout,
                'تسجيل الخروج',
                () => _handleLogout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(isDark),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        border: Border.all(
          color: AppTheme.getHintColor(isDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.01,
        ),
        leading: Container(
          padding: EdgeInsets.all(screenWidth * 0.025),
          decoration: BoxDecoration(
            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(screenWidth * 0.025),
          ),
          child: Icon(
            icon,
            color: AppTheme.getPrimaryColor(isDark),
            size: screenWidth * 0.05,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: AppTheme.getOnSurfaceColor(isDark),
            fontSize: screenWidth * 0.04,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          color: AppTheme.getHintColor(isDark),
          size: screenWidth * 0.04,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
        ),
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(screenWidth * 0.08),
        ),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDark),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(screenWidth * 0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
              offset: const Offset(0, -4),
              blurRadius: 20,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.06),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.getHintColor(isDark),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text(
                'الإعدادات',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 24),

              // Settings options
              Consumer<theme_provider.ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSettingsOption(
                    context,
                    isDark,
                    Icons.dark_mode_outlined,
                    'وضع المظهر',
                    () => _showThemeDialog(context, themeProvider),
                  );
                },
              ),
              _buildSettingsOption(
                context,
                isDark,
                Icons.language_outlined,
                'اللغة',
                () {},
              ),
              _buildSettingsOption(
                context,
                isDark,
                Icons.help_outline,
                'المساعدة والدعم',
                () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOption(
    BuildContext context,
    bool isDark,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.getPrimaryColor(isDark)),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.getOnSurfaceColor(isDark),
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppTheme.getHintColor(isDark),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  // زر الحجز الطافٍ
  Widget _buildReservationFab(BuildContext context, bool isDark) {
    return FloatingActionButton.extended(
      heroTag: 'fab_reservation',
      backgroundColor: AppTheme.getPrimaryColor(isDark),
      onPressed: () => _startReservationFlow(context),
      icon: ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: Image.asset(
          'assets/consultation.jpg',
          width: 24,
          height: 24,
          fit: BoxFit.cover,
        ),
      ),
      label: const Text('حجز موعد'),
    );
  }

  // بدء تدفق الحجز متعدد الخطوات
  void _startReservationFlow(BuildContext context) {
    final up = Provider.of<UserProvider>(context, listen: false);
    final patientId = up.currentUser?.id;
    if (patientId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذّر تحديد معرف المريض، يرجى تسجيل الدخول أولاً.')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReservationStepperScreen(),
      ),
    );
  }



  void _showThemeDialog(
    BuildContext context,
    theme_provider.ThemeProvider themeProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('اختر وضع المظهر'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<theme_provider.ThemeMode>(
              title: const Text('فاتح'),
              value: theme_provider.ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  themeProvider.forceThemeUpdate();
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<theme_provider.ThemeMode>(
              title: const Text('داكن'),
              value: theme_provider.ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  themeProvider.forceThemeUpdate();
                  Navigator.pop(context);
                }
              },
            ),
            RadioListTile<theme_provider.ThemeMode>(
              title: const Text('تلقائي (النظام)'),
              value: theme_provider.ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                if (value != null) {
                  themeProvider.setThemeMode(value);
                  themeProvider.forceThemeUpdate();
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      print('🚪 DEBUG: بدء عملية تسجيل الخروج...');
      
      // Get references before any async operations
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('🚪 DEBUG: تم الحصول على UserProvider');
      
      // Close the bottom sheet first
      Navigator.pop(context);
      print('🚪 DEBUG: تم إغلاق القائمة السفلية');
      
      // Show confirmation dialog
      print('🚪 DEBUG: عرض نافذة التأكيد...');
      final shouldLogout = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من تسجيل الخروج؟'),
          actions: [
            TextButton(
              onPressed: () {
                print('🚪 DEBUG: تم الضغط على إلغاء');
                Navigator.pop(dialogContext, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                print('🚪 DEBUG: تم الضغط على تأكيد');
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      );

      print('🚪 DEBUG: نتيجة نافذة التأكيد: $shouldLogout');

      if (shouldLogout != true) {
        print('❌ تم إلغاء تسجيل الخروج من قبل المستخدم');
        return;
      }

      print('✅ تأكيد تسجيل الخروج من المستخدم - بدء العملية');

      // Perform logout operations
      await _performLogout(context, userProvider);
      
    } catch (e) {
      print('❌ خطأ في _handleLogout: $e');
      print('❌ تفاصيل الخطأ: ${e.toString()}');
      _showErrorMessage(context, 'حدث خطأ أثناء تسجيل الخروج: $e');
    }
  }

  Future<void> _performLogout(BuildContext context, UserProvider userProvider) async {
    bool loadingDialogShown = false;
    
    try {
      print('🔄 DEBUG: بدء _performLogout');
      print('🔄 DEBUG: context.mounted = ${context.mounted}');
      
      // Show loading dialog
      if (context.mounted) {
        print('🔄 DEBUG: عرض نافذة التحميل...');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('جاري تسجيل الخروج...'),
              ],
            ),
          ),
        );
        loadingDialogShown = true;
        print('🔄 DEBUG: تم عرض نافذة التحميل');
      }

      // Clear user provider first
      print('🧹 DEBUG: مسح بيانات المستخدم...');
      userProvider.clear();
      print('🧹 DEBUG: تم مسح بيانات المستخدم');
      
      // Then logout from auth service
      print('🔐 DEBUG: مسح بيانات الجلسة...');
      final authService = AuthService();
      await authService.logout();
      print('🔐 DEBUG: تم مسح بيانات الجلسة');
      
      // Close loading dialog if shown
      if (loadingDialogShown && context.mounted) {
        print('🔄 DEBUG: إغلاق نافذة التحميل...');
        Navigator.pop(context);
        loadingDialogShown = false;
        print('🔄 DEBUG: تم إغلاق نافذة التحميل');
      }
      
      // Navigate to login screen
      print('🔄 DEBUG: الانتقال إلى شاشة تسجيل الدخول...');
      print('🔄 DEBUG: context.mounted قبل الانتقال = ${context.mounted}');
      
      if (context.mounted) {
        print('🔄 DEBUG: بدء الانتقال...');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
          (route) => false,
        );
        print('✅ DEBUG: تم الانتقال إلى شاشة تسجيل الدخول بنجاح');
      } else {
        print('⚠️ DEBUG: السياق غير متاح للانتقال');
      }
      
    } catch (e) {
      print('❌ DEBUG: خطأ في _performLogout: $e');
      print('❌ DEBUG: تفاصيل الخطأ: ${e.toString()}');
      print('❌ DEBUG: نوع الخطأ: ${e.runtimeType}');
      
      // Close loading dialog if shown
      if (loadingDialogShown && context.mounted) {
        try {
          print('🔄 DEBUG: محاولة إغلاق نافذة التحميل بعد الخطأ...');
          Navigator.pop(context);
          print('🔄 DEBUG: تم إغلاق نافذة التحميل بعد الخطأ');
        } catch (popError) {
          print('⚠️ DEBUG: فشل في إغلاق نافذة التحميل: $popError');
        }
      }
      
      _showErrorMessage(context, 'حدث خطأ أثناء تسجيل الخروج: $e');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    if (context.mounted) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (e) {
        print('⚠️ فشل في عرض رسالة الخطأ: $e');
      }
    }
  }

  // Debug method to test logout directly
  Future<void> _testLogout(BuildContext context) async {
    print('🔴 DEBUG: بدء اختبار تسجيل الخروج المباشر');
    
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      print('🔴 DEBUG: تم الحصول على UserProvider');
      
      // Clear user data
      userProvider.clear();
      print('🔴 DEBUG: تم مسح بيانات المستخدم');
      
      // Clear auth service
      final authService = AuthService();
      await authService.logout();
      print('🔴 DEBUG: تم مسح بيانات المصادقة');
      
      // Navigate to login
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
        print('🔴 DEBUG: تم الانتقال إلى شاشة تسجيل الدخول');
      } else {
        print('🔴 DEBUG: السياق غير متاح للانتقال');
      }
      
    } catch (e) {
      print('🔴 DEBUG: خطأ في اختبار تسجيل الخروج: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في الاختبار: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
