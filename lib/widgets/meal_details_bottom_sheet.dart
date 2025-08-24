import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_models.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;

class MealDetailsBottomSheet extends StatelessWidget {
  final MealPlan meal;

  const MealDetailsBottomSheet({super.key, required this.meal});

  static void show(BuildContext context, MealPlan meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MealDetailsBottomSheet(meal: meal),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;
        
        return Container(
          height: screenHeight * 0.75,
          decoration: BoxDecoration(
            color: AppTheme.getBackgroundColor(isDark),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(screenWidth * 0.08),
              topRight: Radius.circular(screenWidth * 0.08),
            ),
          ),
          child: Column(
            children: [
              _buildHandle(screenWidth),
              _buildHeader(context, isDark, screenWidth),
              Expanded(
                child: _buildContent(context, isDark, screenWidth),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(top: screenWidth * 0.03),
      width: screenWidth * 0.12,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        children: [
          // Meal icon with gradient background
          Container(
            width: screenWidth * 0.15,
            height: screenWidth * 0.15,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFFC792EA),
                  const Color(0xFFB794F6),
                ],
              ),
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: Colors.white,
              size: screenWidth * 0.08,
            ),
          ),
          
          SizedBox(width: screenWidth * 0.04),
          
          // Meal info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal.name,
                  style: TextStyle(
                    color: AppTheme.getOnSurfaceColor(isDark),
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  meal.priceFormatted,
                  style: TextStyle(
                    color: const Color(0xFFC792EA),
                    fontSize: screenWidth * 0.05,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          // Close button
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.close_rounded,
              color: AppTheme.getHintColor(isDark),
              size: screenWidth * 0.06,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark, double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Description section
          _buildDescriptionSection(isDark, screenWidth),
          
          SizedBox(height: screenWidth * 0.06),
          
          // Dietary information section
          if (meal.dietaryTags.isNotEmpty)
            _buildDietarySection(isDark, screenWidth),
          
          SizedBox(height: screenWidth * 0.1),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: const Color(0xFFC792EA),
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                'تفاصيل الخطة',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: screenWidth * 0.04),
          
          Text(
            meal.description,
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: screenWidth * 0.04,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietarySection(bool isDark, double screenWidth) {
    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.08),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.eco_rounded,
                color: Colors.green,
                size: screenWidth * 0.06,
              ),
              SizedBox(width: screenWidth * 0.03),
              Text(
                'النظام الغذائي',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          SizedBox(height: screenWidth * 0.04),
          
          Wrap(
            spacing: screenWidth * 0.02,
            runSpacing: screenWidth * 0.02,
            children: meal.dietaryTags.map((tag) => Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.04,
                vertical: screenWidth * 0.02,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFC792EA).withValues(alpha: 0.2),
                    const Color(0xFFB794F6).withValues(alpha: 0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(screenWidth * 0.03),
                border: Border.all(
                  color: const Color(0xFFC792EA).withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    color: const Color(0xFFC792EA),
                    size: screenWidth * 0.04,
                  ),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    tag,
                    style: TextStyle(
                      color: const Color(0xFFC792EA),
                      fontSize: screenWidth * 0.035,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}
