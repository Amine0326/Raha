// Transport Models for Rahati Healthcare App
// Designed for patients needing transportation to medical centers

class TransportService {
  final String id;
  final String name;
  final String driverName;
  final String phone;
  final String email;
  final bool isAvailable;
  final double rating;
  final int reviewCount;
  final List<String> serviceAreas; // Cities/areas they serve
  final TransportType type;
  final VehicleType vehicleType;
  final int capacity;
  final List<String> features;
  final PriceRange priceRange;
  final bool isEmergencyService;
  final bool isMedicalEquipped;

  TransportService({
    required this.id,
    required this.name,
    required this.driverName,
    required this.phone,
    required this.email,
    required this.isAvailable,
    required this.rating,
    required this.reviewCount,
    required this.serviceAreas,
    required this.type,
    required this.vehicleType,
    required this.capacity,
    required this.features,
    required this.priceRange,
    required this.isEmergencyService,
    required this.isMedicalEquipped,
  });

  // Dummy data for Algerian transport services
  static List<TransportService> getDummyTransportServices() {
    return [
      TransportService(
        id: '1',
        name: 'نقل الرحمة الطبي',
        driverName: 'أحمد بن علي',
        phone: '+213555123456',
        email: 'ahmed@mercy-transport.dz',
        isAvailable: true,
        rating: 4.8,
        reviewCount: 156,
        serviceAreas: ['الجزائر العاصمة', 'البليدة', 'تيبازة'],
        type: TransportType.private,
        vehicleType: VehicleType.ambulance,
        capacity: 2,
        features: ['مجهز طبياً', 'أكسجين', 'نقالة', 'مرافق طبي', 'تكييف'],
        priceRange: PriceRange.premium,
        isEmergencyService: true,
        isMedicalEquipped: true,
      ),
      TransportService(
        id: '2',
        name: 'تاكسي المرضى',
        driverName: 'فاطمة زهراء',
        phone: '+213666234567',
        email: 'fatima@patient-taxi.dz',
        isAvailable: true,
        rating: 4.5,
        reviewCount: 89,
        serviceAreas: ['الجزائر العاصمة', 'بومرداس'],
        type: TransportType.taxi,
        vehicleType: VehicleType.sedan,
        capacity: 4,
        features: ['مريح', 'نظيف', 'سائق مدرب', 'أسعار معقولة'],
        priceRange: PriceRange.medium,
        isEmergencyService: false,
        isMedicalEquipped: false,
      ),
      TransportService(
        id: '3',
        name: 'حافلة العائلات الطبية',
        driverName: 'محمد الصالح',
        phone: '+213777345678',
        email: 'mohamed@family-bus.dz',
        isAvailable: true,
        rating: 4.3,
        reviewCount: 67,
        serviceAreas: ['وهران', 'سيدي بلعباس', 'تلمسان'],
        type: TransportType.bus,
        vehicleType: VehicleType.minibus,
        capacity: 12,
        features: ['مساحة واسعة', 'مقاعد مريحة', 'تكييف', 'للعائلات الكبيرة'],
        priceRange: PriceRange.affordable,
        isEmergencyService: false,
        isMedicalEquipped: false,
      ),
      TransportService(
        id: '4',
        name: 'نقل VIP الطبي',
        driverName: 'عبد الرحمن قاسم',
        phone: '+213888456789',
        email: 'abderrahmane@vip-medical.dz',
        isAvailable: true,
        rating: 4.9,
        reviewCount: 234,
        serviceAreas: ['الجزائر العاصمة', 'قسنطينة', 'عنابة'],
        type: TransportType.private,
        vehicleType: VehicleType.luxury,
        capacity: 3,
        features: ['فاخر', 'واي فاي', 'مشروبات', 'خدمة راقية', 'سرية تامة'],
        priceRange: PriceRange.premium,
        isEmergencyService: false,
        isMedicalEquipped: true,
      ),
    ];
  }
}

enum TransportType {
  private,    // خاص
  taxi,       // تاكسي
  bus,        // حافلة
  shared,     // مشترك
}

enum VehicleType {
  sedan,      // سيدان
  suv,        // دفع رباعي
  minibus,    // حافلة صغيرة
  ambulance,  // إسعاف
  luxury,     // فاخر
}

enum PriceRange {
  affordable, // اقتصادي
  medium,     // متوسط
  premium,    // مرتفع
}

class TransportBooking {
  final String id;
  final String passengerName;
  final String passengerPhone;
  final String passengerEmail;
  final String transportServiceId;
  final String pickupLocation;
  final String destination;
  final DateTime pickupDateTime;
  final int numberOfPassengers;
  final String specialRequests;
  final BookingStatus status;
  final DateTime createdAt;
  final double estimatedPrice;
  final bool isRoundTrip;

  TransportBooking({
    required this.id,
    required this.passengerName,
    required this.passengerPhone,
    required this.passengerEmail,
    required this.transportServiceId,
    required this.pickupLocation,
    required this.destination,
    required this.pickupDateTime,
    required this.numberOfPassengers,
    required this.specialRequests,
    required this.status,
    required this.createdAt,
    required this.estimatedPrice,
    required this.isRoundTrip,
  });
}

enum BookingStatus {
  pending,    // في الانتظار
  confirmed,  // مؤكد
  inProgress, // في الطريق
  completed,  // مكتمل
  cancelled,  // ملغي
}

class TransportFilters {
  final String? serviceArea;
  final TransportType? type;
  final VehicleType? vehicleType;
  final PriceRange? priceRange;
  final double? minRating;
  final bool? availableOnly;
  final bool? emergencyOnly;
  final bool? medicalEquippedOnly;

  TransportFilters({
    this.serviceArea,
    this.type,
    this.vehicleType,
    this.priceRange,
    this.minRating,
    this.availableOnly,
    this.emergencyOnly,
    this.medicalEquippedOnly,
  });

  TransportFilters copyWith({
    String? serviceArea,
    TransportType? type,
    VehicleType? vehicleType,
    PriceRange? priceRange,
    double? minRating,
    bool? availableOnly,
    bool? emergencyOnly,
    bool? medicalEquippedOnly,
  }) {
    return TransportFilters(
      serviceArea: serviceArea ?? this.serviceArea,
      type: type ?? this.type,
      vehicleType: vehicleType ?? this.vehicleType,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      availableOnly: availableOnly ?? this.availableOnly,
      emergencyOnly: emergencyOnly ?? this.emergencyOnly,
      medicalEquippedOnly: medicalEquippedOnly ?? this.medicalEquippedOnly,
    );
  }
}
