import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;
import '../models/user_models.dart';
import '../providers/user_provider.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  const ProfileScreen({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        final User? profile = user ?? Provider.of<UserProvider>(context).currentUser;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          appBar: AppBar(
            title: Text(
              'الملف الشخصي',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.getOnSurfaceColor(isDark),
              ),
            ),
            backgroundColor: AppTheme.getSurfaceColor(isDark),
            elevation: 0,
          ),
          body: RefreshIndicator(
            onRefresh: () async {
              try {
                await Provider.of<UserProvider>(context, listen: false).fetchCurrentUser();
              } catch (_) {}
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Header
                  _buildProfileHeader(isDark, profile),
                  const SizedBox(height: 24),

                  // Personal Information Section
                  _buildSectionTitle('المعلومات الشخصية', isDark),
                  const SizedBox(height: 12),
                  _buildPersonalInfoCard(isDark, profile),
                  const SizedBox(height: 24),

                  // Contact Information Section
                  _buildSectionTitle('معلومات الاتصال', isDark),
                  const SizedBox(height: 12),
                  _buildContactInfoCard(isDark, profile),
                  const SizedBox(height: 24),

                  // Caregiver Information Section
                  _buildSectionTitle('معلومات مقدم الرعاية', isDark),
                  const SizedBox(height: 12),
                  _buildCaregiverInfoCard(isDark, profile),
                  const SizedBox(height: 24),

                  // Account Information Section
                  _buildSectionTitle('معلومات الحساب', isDark),
                  const SizedBox(height: 12),
                  _buildAccountInfoCard(isDark, profile),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProfileHeader(bool isDark, User? user) {
    final String name = user?.name ?? '—';
    final String role = user?.roleInArabic ?? '—';
    final bool verified = user?.isEmailVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.getPrimaryGradient(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: verified
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: verified
                          ? Colors.green.withValues(alpha: 0.5)
                          : Colors.orange.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    verified ? 'تم التحقق' : 'لم يتم التحقق',
                    style: TextStyle(
                      fontSize: 12,
                      color: verified
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppTheme.getOnBackgroundColor(isDark),
      ),
    );
  }

  Widget _buildPersonalInfoCard(bool isDark, User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'الاسم الكامل',
            value: user?.name ?? '—',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.badge_outlined,
            label: 'رقم المعرف',
            value: user != null ? '#${user.id}' : '—',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'العنوان',
            value: user?.address ?? '—',
            isDark: isDark,
            isMultiline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoCard(bool isDark, User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.email_outlined,
            label: 'البريد الإلكتروني',
            value: user?.email ?? '—',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'رقم الهاتف',
            value: user?.phone ?? '—',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildCaregiverInfoCard(bool isDark, User? user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.person_outline,
            label: 'اسم مقدم الرعاية',
            value: user?.caregiverName ?? '—',
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.phone_outlined,
            label: 'هاتف مقدم الرعاية',
            value: user?.caregiverPhone ?? '—',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfoCard(bool isDark, User? user) {
    final createdDate = user?.formattedCreatedDate ?? '—';
    final isVerified = user?.isEmailVerified ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'تاريخ إنشاء الحساب',
            value: createdDate,
            isDark: isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            icon: Icons.verified_user_outlined,
            label: 'حالة التحقق',
            value: isVerified
                ? 'تم التحقق من البريد الإلكتروني'
                : 'لم يتم التحقق من البريد الإلكتروني',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    bool isMultiline = false,
  }) {
    return Row(
      crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.getPrimaryColor(isDark),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.getHintColor(isDark),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
