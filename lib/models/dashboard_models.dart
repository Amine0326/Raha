// Data models for Rahati Healthcare Dashboard
// These models use dummy data and can be easily replaced with API integration

class UserProfile {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String currentLocation;
  final String profileImageUrl;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.currentLocation,
    this.profileImageUrl = '',
  });

  // Dummy data for testing
  static UserProfile getDummyUser() {
    return UserProfile(
      id: '1',
      name: 'أحمد بن علي',
      email: 'ahmed.benali@example.com',
      phone: '+213555123456',
      currentLocation: 'الجزائر العاصمة، الجزائر',
    );
  }
}

class DashboardStats {
  final int upcomingAppointments;
  final int activeBookings;
  final int completedConsultations;
  final int pendingRequests;

  DashboardStats({
    required this.upcomingAppointments,
    required this.activeBookings,
    required this.completedConsultations,
    required this.pendingRequests,
  });

  // Dummy data for testing
  static DashboardStats getDummyStats() {
    return DashboardStats(
      upcomingAppointments: 2,
      activeBookings: 1,
      completedConsultations: 5,
      pendingRequests: 3,
    );
  }
}

class ServiceItem {
  final String id;
  final String title;
  final String description;
  final String iconPath;
  final String route;
  final bool isAvailable;

  ServiceItem({
    required this.id,
    required this.title,
    required this.description,
    required this.iconPath,
    required this.route,
    this.isAvailable = true,
  });

  // Dummy services data
  static List<ServiceItem> getDummyServices() {
    return [
      ServiceItem(
        id: '1',
        title: 'حجز مركز العلاج',
        description: 'ابحث واحجز في أفضل المراكز الطبية والمستشفيات المتخصصة',
        iconPath: 'hospital',
        route: '/medical-centers',
      ),
      ServiceItem(
        id: '2',
        title: 'أماكن الإقامة القريبة',
        description: 'ابحث عن أماكن إقامة مريحة بالقرب من مراكز العلاج',
        iconPath: 'home',
        route: '/accommodations',
      ),
      ServiceItem(
        id: '3',
        title: 'المساعدة في النقل',
        description: 'احجز وسائل نقل آمنة ومريحة للوصول إلى المرافق الطبية',
        iconPath: 'car',
        route: '/transport',
      ),
      ServiceItem(
        id: '4',
        title: 'حجز استشارة',
        description: 'احجز موعد استشارة مع أفضل مقدمي الرعاية الصحية',
        iconPath: 'doctor',
        route: '/consultation',
      ),
    ];
  }
}

class RecentActivity {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final ActivityType type;
  final ActivityStatus status;

  RecentActivity({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.type,
    required this.status,
  });

  // Dummy recent activities
  static List<RecentActivity> getDummyActivities() {
    return [
      RecentActivity(
        id: '1',
        title: 'تم تأكيد حجز الإقامة',
        description: 'فندق الراحة - غرفة مفردة لمدة 3 ليالي',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        type: ActivityType.accommodation,
        status: ActivityStatus.confirmed,
      ),
      RecentActivity(
        id: '2',
        title: 'موعد استشارة قادم',
        description: 'د. فاطمة بن عيسى - استشارة قلب غداً الساعة 10:00 ص',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        type: ActivityType.consultation,
        status: ActivityStatus.upcoming,
      ),
      RecentActivity(
        id: '3',
        title: 'طلب نقل جديد',
        description: 'من المطار إلى المستشفى - في انتظار التأكيد',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        type: ActivityType.transport,
        status: ActivityStatus.pending,
      ),
    ];
  }
}

enum ActivityType { accommodation, transport, consultation, support }

enum ActivityStatus { pending, confirmed, upcoming, completed, cancelled }

class EmergencyContact {
  final String name;
  final String phone;
  final String type;

  EmergencyContact({
    required this.name,
    required this.phone,
    required this.type,
  });

  // Dummy emergency contacts
  static List<EmergencyContact> getDummyContacts() {
    return [
      EmergencyContact(
        name: 'الدعم الفني',
        phone: '+213800123456',
        type: 'support',
      ),
      EmergencyContact(name: 'الطوارئ الطبية', phone: '14', type: 'medical'),
    ];
  }
}
