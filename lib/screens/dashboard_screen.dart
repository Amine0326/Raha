import 'package:flutter/material.dart';
import '../models/dashboard_models.dart';
import '../widgets/dashboard_widgets.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late UserProfile user;
  late DashboardStats stats;
  late List<ServiceItem> services;
  late List<RecentActivity> recentActivities;
  late List<EmergencyContact> emergencyContacts;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  void _loadDashboardData() {
    user = UserProfile.getDummyUser();
    stats = DashboardStats.getDummyStats();
    services = ServiceItem.getDummyServices();
    recentActivities = RecentActivity.getDummyActivities();
    emergencyContacts = EmergencyContact.getDummyContacts();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'صباح الخير';
    } else if (hour < 17) {
      return 'مساء الخير';
    } else {
      return 'مساء الخير';
    }
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Simulate refresh
            await Future.delayed(const Duration(seconds: 1));
            setState(() {
              _loadDashboardData();
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsSection(),
                const SizedBox(height: 24),
                _buildServicesSection(),
                const SizedBox(height: 24),
                _buildRecentActivitySection(),
                const SizedBox(height: 24),
                _buildEmergencyContactsSection(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1976D2), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}، ${user.name}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getCurrentDate(),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  user.currentLocation,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نظرة سريعة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            StatsCard(
              title: 'المواعيد القادمة',
              value: '${stats.upcomingAppointments}',
              icon: Icons.calendar_today,
              color: const Color(0xFF1976D2),
            ),
            StatsCard(
              title: 'الحجوزات النشطة',
              value: '${stats.activeBookings}',
              icon: Icons.hotel,
              color: const Color(0xFF9C27B0),
            ),
            StatsCard(
              title: 'الاستشارات المكتملة',
              value: '${stats.completedConsultations}',
              icon: Icons.check_circle,
              color: const Color(0xFF4CAF50),
            ),
            StatsCard(
              title: 'الطلبات المعلقة',
              value: '${stats.pendingRequests}',
              icon: Icons.pending,
              color: const Color(0xFFFF9800),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'رحلتك الطبية',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        _buildMedicalJourneyCard(),
      ],
    );
  }

  Widget _buildMedicalJourneyCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFF9C27B0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9C27B0).withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ابدأ رحلتك الطبية',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'خطوة بخطوة نحو العلاج المناسب',
                        style: TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Journey steps preview
            Row(
              children: [
                _buildJourneyStep('1', 'اختر المركز الطبي', true),
                _buildJourneyArrow(),
                _buildJourneyStep('2', 'احجز الإقامة', false),
                _buildJourneyArrow(),
                _buildJourneyStep('3', 'النقل (اختياري)', false),
              ],
            ),
            const SizedBox(height: 24),
            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startMedicalJourney,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF667EEA),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ابدأ الآن',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyStep(String number, String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isActive ? const Color(0xFF667EEA) : Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJourneyArrow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Icon(
        Icons.arrow_forward,
        color: Colors.white.withOpacity(0.7),
        size: 16,
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'النشاط الأخير',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            TextButton(
              onPressed: () {
                // Navigate to full activity history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('عرض جميع الأنشطة - قريباً')),
                );
              },
              child: const Text(
                'عرض الكل',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentActivities.length,
          itemBuilder: (context, index) {
            return ActivityItem(activity: recentActivities[index]);
          },
        ),
      ],
    );
  }

  Widget _buildEmergencyContactsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'جهات الاتصال الطارئة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: emergencyContacts.map((contact) {
            return EmergencyContactButton(
              contact: contact,
              onTap: () => _handleEmergencyContact(contact),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _startMedicalJourney() {
    // Navigate to the new medical journey flow
    Navigator.pushNamed(context, '/medical-journey');
  }

  void _handleServiceTap(ServiceItem service) {
    // Keep for backward compatibility if needed
    if (service.route == '/medical-centers' ||
        service.route == '/accommodations' ||
        service.route == '/transport' ||
        service.route == '/consultation') {
      Navigator.pushNamed(context, service.route);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${service.title} - قريباً'),
          backgroundColor: const Color(0xFF9C27B0),
        ),
      );
    }
  }

  void _handleEmergencyContact(EmergencyContact contact) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الاتصال بـ: ${contact.name} - ${contact.phone}'),
        backgroundColor: const Color(0xFF1976D2),
      ),
    );
    // TODO: Implement actual phone call functionality
    // launch('tel:${contact.phone}');
  }
}
