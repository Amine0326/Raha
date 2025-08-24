import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../models/meal_models.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;
import '../widgets/meal_details_bottom_sheet.dart';
import '../services/apiservice.dart';

class MealsScreen extends StatefulWidget {
  const MealsScreen({super.key});

  @override
  State<MealsScreen> createState() => _MealsScreenState();
}

class _MealsScreenState extends State<MealsScreen>
    with TickerProviderStateMixin {
  late TextEditingController _searchController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = false;
  String? _error;

  List<MealPlan> _allMeals = [];
  List<MealPlan> _filteredMeals = [];
  List<MealCategory> _categories = [];
  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _loadData();
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _loadData() {
    _categories = MealCategory.getCategories();
    _fetchMeals();
  }


  Future<void> _fetchMeals() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await ApiService().get('/meal-options', withAuth: true);
      if (data is List) {
        final meals = data
            .map<MealPlan>((e) => MealPlan.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        setState(() {
          _allMeals = meals;
        });
        _filterMeals();
        if (kDebugMode) {
          print('🍽️ تم جلب الوجبات (${meals.length}) من الخادم.');
        }
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب الوجبات.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
      if (kDebugMode) {
        print('🚫 خطأ أثناء جلب الوجبات: $e');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ غير متوقع أثناء جلب الوجبات. يرجى المحاولة لاحقاً.';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('حدث خطأ غير متوقع أثناء جلب الوجبات. يرجى المحاولة لاحقاً.'),
              backgroundColor: Color(0xFFD32F2F)),
        );
      }
      if (kDebugMode) {
        print('❗ استثناء غير متوقع أثناء جلب الوجبات: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _filterMeals() {
    setState(() {
      _filteredMeals = _allMeals.where((meal) {
        final matchesCategory =
            _selectedCategory == 'الكل' ||
            (_selectedCategory == 'قياسي' && meal.category == 'Standard') ||
            (_selectedCategory == 'نباتي' && meal.category == 'Vegetarian') ||
            (_selectedCategory == 'نباتي صرف' && meal.category == 'Vegan') ||
            (_selectedCategory == 'خالي من الجلوتين' &&
                meal.category == 'Gluten-Free');
        final matchesSearch =
            _searchQuery.isEmpty ||
            meal.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            meal.description.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchesCategory && matchesSearch;
      }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _filterMeals();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _filterMeals();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                children: [
                  _buildHeader(context, isDark),
                  _buildSearchBar(context, isDark),
                  _buildCategoryFilter(context, isDark),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _fetchMeals,
                      child: _buildMealsList(context, isDark),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive sizing
    final isTablet = screenWidth > 600;
    final headerHeight = isTablet ? 140.0 : screenHeight * 0.15;
    final headerPadding = isTablet ? 24.0 : screenWidth * 0.05;
    final titleFontSize = isTablet ? 32.0 : screenWidth * 0.07;
    final subtitleFontSize = isTablet ? 18.0 : screenWidth * 0.04;
    final iconSize = isTablet ? 32.0 : screenWidth * 0.07;

    return Container(
      height: headerHeight,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF667eea),
            const Color(0xFF764ba2),
            const Color(0xFFC792EA),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC792EA).withValues(alpha: 0.3),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background pattern
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 2.0,
                  colors: [
                    Colors.white.withValues(alpha: 0.1),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.05),
                  ],
                ),
              ),
            ),
          ),

          // Content
          Padding(
            padding: EdgeInsets.all(headerPadding),
            child: Row(
              children: [
                // Back button with modern styling
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: iconSize,
                    ),
                  ),
                ),

                SizedBox(width: screenWidth * 0.04),

                // Title section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'خدمة التغذية',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1.0,
                          shadows: [
                            Shadow(
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              color: Colors.black.withValues(alpha: 0.3),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'اختر خطة الوجبات المناسبة لك',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: subtitleFontSize,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Icon with modern styling
                Container(
                  padding: EdgeInsets.all(isTablet ? 16 : screenWidth * 0.04),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        offset: const Offset(0, 8),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.restaurant_menu_rounded,
                    color: Colors.white,
                    size: iconSize,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : screenWidth * 0.05,
        vertical: isTablet ? 8 : screenWidth * 0.02,
      ),
      height: isTablet ? 52 : screenWidth * 0.13,
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(
          isTablet ? 26 : screenWidth * 0.065,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
        border: Border.all(
          color: _searchQuery.isNotEmpty
              ? const Color(0xFFC792EA).withValues(alpha: 0.4)
              : const Color(0xFFC792EA).withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Search icon
          Padding(
            padding: EdgeInsets.only(
              right: isTablet ? 16 : screenWidth * 0.04,
              left: isTablet ? 8 : screenWidth * 0.02,
            ),
            child: Icon(
              Icons.search_rounded,
              color: _searchQuery.isNotEmpty
                  ? const Color(0xFFC792EA)
                  : AppTheme.getHintColor(isDark),
              size: isTablet ? 22 : screenWidth * 0.055,
            ),
          ),

          // Text field
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: isTablet ? 16 : screenWidth * 0.04,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'ابحث في الوجبات...',
                hintStyle: TextStyle(
                  color: AppTheme.getHintColor(isDark),
                  fontSize: isTablet ? 16 : screenWidth * 0.04,
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 12 : screenWidth * 0.03,
                  vertical: 0,
                ),
              ),
            ),
          ),

          // Clear button
          if (_searchQuery.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(
                left: isTablet ? 12 : screenWidth * 0.03,
                right: isTablet ? 8 : screenWidth * 0.02,
              ),
              child: GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: Container(
                  padding: EdgeInsets.all(isTablet ? 6 : screenWidth * 0.015),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC792EA).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(
                      isTablet ? 12 : screenWidth * 0.03,
                    ),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: const Color(0xFFC792EA),
                    size: isTablet ? 18 : screenWidth * 0.045,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Container(
      height: isTablet ? 60 : screenWidth * 0.14,
      margin: EdgeInsets.only(
        bottom: isTablet ? 20 : screenWidth * 0.04,
        top: isTablet ? 8 : screenWidth * 0.02,
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 32 : screenWidth * 0.05,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category.name;

          return GestureDetector(
            onTap: () => _onCategorySelected(category.name),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: EdgeInsets.only(
                right: isTablet ? 16 : screenWidth * 0.03,
              ),
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 20 : screenWidth * 0.05,
                vertical: isTablet ? 12 : screenWidth * 0.03,
              ),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFF667eea),
                          const Color(0xFFC792EA),
                        ],
                      )
                    : null,
                color: isSelected ? null : AppTheme.getCardColor(isDark),
                borderRadius: BorderRadius.circular(
                  isTablet ? 16 : screenWidth * 0.04,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFFC792EA).withValues(alpha: 0.4)
                        : Colors.black.withValues(alpha: isDark ? 0.08 : 0.04),
                    offset: isSelected
                        ? const Offset(0, 8)
                        : const Offset(0, 4),
                    blurRadius: isSelected ? 20 : 12,
                    spreadRadius: 0,
                  ),
                ],
                border: isSelected
                    ? null
                    : Border.all(
                        color: const Color(0xFFC792EA).withValues(alpha: 0.1),
                        width: 1,
                      ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    category.icon,
                    style: TextStyle(
                      fontSize: isTablet ? 20 : screenWidth * 0.045,
                    ),
                  ),
                  SizedBox(width: isTablet ? 8 : screenWidth * 0.02),
                  Text(
                    category.name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : AppTheme.getOnSurfaceColor(isDark),
                      fontSize: isTablet ? 15 : screenWidth * 0.037,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w600,
                      letterSpacing: isSelected ? 0.5 : 0.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMealsList(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.getHintColor(isDark),
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.getHintColor(isDark),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchMeals,
                icon: const Icon(Icons.refresh),
                label: const Text('إعادة المحاولة'),
              )
            ],
          ),
        ),
      );
    }

    if (_filteredMeals.isEmpty) {
      return Center(
        child: Container(
          padding: EdgeInsets.all(isTablet ? 40 : screenWidth * 0.08),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(isTablet ? 24 : screenWidth * 0.06),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFC792EA).withValues(alpha: 0.1),
                      const Color(0xFFB794F6).withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(
                    isTablet ? 24 : screenWidth * 0.06,
                  ),
                ),
                child: Icon(
                  Icons.restaurant_menu_outlined,
                  size: isTablet ? 64 : screenWidth * 0.16,
                  color: const Color(0xFFC792EA),
                ),
              ),
              SizedBox(height: isTablet ? 24 : screenWidth * 0.06),
              Text(
                'لا توجد وجبات مطابقة للبحث',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: isTablet ? 20 : screenWidth * 0.05,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: isTablet ? 12 : screenWidth * 0.03),
              Text(
                'جرب البحث بكلمات مختلفة أو اختر فئة أخرى',
                style: TextStyle(
                  color: AppTheme.getHintColor(isDark),
                  fontSize: isTablet ? 16 : screenWidth * 0.04,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32 : screenWidth * 0.05,
        vertical: isTablet ? 16 : screenWidth * 0.02,
      ),
      itemCount: _filteredMeals.length,
      itemBuilder: (context, index) {
        return _buildMealCard(context, isDark, _filteredMeals[index], index);
      },
    );
  }

  Widget _buildMealCard(
    BuildContext context,
    bool isDark,
    MealPlan meal,
    int index,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final isTablet = screenWidth > 600;
    final cardMargin = isTablet ? 16.0 : screenWidth * 0.04;
    final cardRadius = isTablet ? 24.0 : screenWidth * 0.06;
    final contentPadding = isTablet ? 24.0 : screenWidth * 0.05;
    final titleFontSize = isTablet ? 22.0 : screenWidth * 0.05;
    final descriptionFontSize = isTablet ? 15.0 : screenWidth * 0.037;
    final tagFontSize = isTablet ? 13.0 : screenWidth * 0.032;
    final priceFontSize = isTablet ? 18.0 : screenWidth * 0.045;

    return GestureDetector(
      onTap: () => MealDetailsBottomSheet.show(context, meal),
      child: Container(
        margin: EdgeInsets.only(bottom: cardMargin),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.getCardColor(isDark),
              AppTheme.getCardColor(isDark).withValues(alpha: 0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(cardRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.06),
              offset: const Offset(0, 16),
              blurRadius: 40,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: const Color(0xFFC792EA).withValues(alpha: 0.12),
              offset: const Offset(0, 8),
              blurRadius: 24,
              spreadRadius: 0,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.8),
              offset: const Offset(0, 1),
              blurRadius: 0,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: const Color(0xFFC792EA).withValues(alpha: 0.08),
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(cardRadius),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Content section with improved spacing
              Padding(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and price row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            meal.name,
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.8,
                              height: 1.2,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isTablet ? 16 : screenWidth * 0.04,
                            vertical: isTablet ? 10 : screenWidth * 0.025,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                const Color(0xFF667eea),
                                const Color(0xFFC792EA),
                                const Color(0xFFB794F6),
                              ],
                              stops: const [0.0, 0.6, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(
                              isTablet ? 16 : screenWidth * 0.04,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(
                                  0xFFC792EA,
                                ).withValues(alpha: 0.4),
                                offset: const Offset(0, 8),
                                blurRadius: 20,
                                spreadRadius: 0,
                              ),
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.2),
                                offset: const Offset(0, 1),
                                blurRadius: 0,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.payments_rounded,
                                color: Colors.white,
                                size: isTablet ? 16 : screenWidth * 0.035,
                              ),
                              SizedBox(
                                width: isTablet ? 6 : screenWidth * 0.015,
                              ),
                              Text(
                                meal.priceFormatted,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: priceFontSize,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.5,
                                  shadows: [
                                    Shadow(
                                      offset: const Offset(0, 1),
                                      blurRadius: 2,
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isTablet ? 16 : screenWidth * 0.04),

                    // Description with better readability
                    Text(
                      meal.description,
                      style: TextStyle(
                        color: AppTheme.getHintColor(isDark),
                        fontSize: descriptionFontSize,
                        height: 1.6,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (meal.dietaryTags.isNotEmpty) ...[
                      SizedBox(height: isTablet ? 20 : screenWidth * 0.05),

                      // Modern dietary tags
                      Wrap(
                        spacing: isTablet ? 10 : screenWidth * 0.025,
                        runSpacing: isTablet ? 10 : screenWidth * 0.025,
                        children: meal.dietaryTags
                            .map(
                              (tag) => Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isTablet
                                      ? 16
                                      : screenWidth * 0.04,
                                  vertical: isTablet ? 8 : screenWidth * 0.02,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      const Color(
                                        0xFFC792EA,
                                      ).withValues(alpha: 0.12),
                                      const Color(
                                        0xFFB794F6,
                                      ).withValues(alpha: 0.12),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    isTablet ? 16 : screenWidth * 0.04,
                                  ),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFC792EA,
                                    ).withValues(alpha: 0.25),
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.eco_rounded,
                                      size: isTablet ? 16 : screenWidth * 0.04,
                                      color: const Color(0xFFC792EA),
                                    ),
                                    SizedBox(
                                      width: isTablet ? 6 : screenWidth * 0.015,
                                    ),
                                    Text(
                                      tag,
                                      style: TextStyle(
                                        color: const Color(0xFFC792EA),
                                        fontSize: tagFontSize,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
