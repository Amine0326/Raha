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
  final ServiceLevel serviceLevel;
  final VehicleType vehicleType;
  final int capacity;
  final List<String> features;
  final double pricePerKm;
  final double baseFare;
  final bool isEmergencyService;
  final bool isMedicalEquipped;
  final String description;
  final String imageUrl;
  final List<String> amenities;
  final int estimatedArrivalTime; // in minutes

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
    required this.serviceLevel,
    required this.vehicleType,
    required this.capacity,
    required this.features,
    required this.pricePerKm,
    required this.baseFare,
    required this.isEmergencyService,
    required this.isMedicalEquipped,
    required this.description,
    required this.imageUrl,
    required this.amenities,
    required this.estimatedArrivalTime,
  });

  // Clean transport services - exactly what was requested
  static List<TransportService> getDummyTransportServices() {
    return [
      // URGENT TIER - AMBULANCES
      TransportService(
        id: 'urgent_ambulance',
        name: 'إسعاف طوارئ',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 5.0,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.urgent,
        vehicleType: VehicleType.ambulance,
        capacity: 2,
        features: [],
        pricePerKm: 0,
        baseFare: 8000.0,
        isEmergencyService: true,
        isMedicalEquipped: true,
        description:
            'خدمة إسعاف طوارئ مجهزة بالكامل مع طاقم طبي متخصص ومعدات إنقاذ متطورة',
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // DIAMOND TIER - LUXURY CARS
      TransportService(
        id: 'diamond_car',
        name: 'سيارة دايموند',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 5.0,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.diamond,
        vehicleType: VehicleType.luxury,
        capacity: 4,
        features: [],
        pricePerKm: 0,
        baseFare: 5000.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description:
            'أرقى مستوى من الراحة والفخامة مع مقاعد جلدية ونظام ترفيه متطور',
        imageUrl:
            'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // DIAMOND TIER - LUXURY VANS
      TransportService(
        id: 'diamond_van',
        name: 'فان دايموند',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 5.0,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.diamond,
        vehicleType: VehicleType.van,
        capacity: 8,
        features: [],
        pricePerKm: 0,
        baseFare: 6000.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description:
            'فان فاخر للعائلات الكبيرة مع مساحة واسعة ومقاعد قابلة للتعديل',
        imageUrl:
            'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // VIP TIER - CARS
      TransportService(
        id: 'vip_car',
        name: 'سيارة VIP',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 4.8,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.vip,
        vehicleType: VehicleType.sedan,
        capacity: 4,
        features: [],
        pricePerKm: 0,
        baseFare: 3500.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description: 'خدمة VIP راقية مع مقاعد مريحة وتكييف متطور ونظافة عالية',
        imageUrl:
            'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // VIP TIER - VANS
      TransportService(
        id: 'vip_van',
        name: 'فان VIP',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 4.7,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.vip,
        vehicleType: VehicleType.van,
        capacity: 7,
        features: [],
        pricePerKm: 0,
        baseFare: 4000.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description: 'فان VIP مثالي للعائلات مع مساحة واسعة ومقاعد مريحة',
        imageUrl:
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // PREMIUM TIER - CARS
      TransportService(
        id: 'premium_car',
        name: 'سيارة بريميوم',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 4.5,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.premium,
        vehicleType: VehicleType.sedan,
        capacity: 4,
        features: [],
        pricePerKm: 0,
        baseFare: 2500.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description: 'خدمة بريميوم بجودة عالية مع تكييف ممتاز ونظافة مضمونة',
        imageUrl:
            'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // PREMIUM TIER - VANS
      TransportService(
        id: 'premium_van',
        name: 'فان بريميوم',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 4.4,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.premium,
        vehicleType: VehicleType.van,
        capacity: 7,
        features: [],
        pricePerKm: 0,
        baseFare: 3000.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description:
            'فان بريميوم للعائلات مع مساحة كبيرة ومقاعد مريحة وأمان عالي',
        imageUrl:
            'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // STANDARD TIER - CARS
      TransportService(
        id: 'standard_car',
        name: 'سيارة ستاندرد',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 4.2,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.standard,
        vehicleType: VehicleType.sedan,
        capacity: 4,
        features: [],
        pricePerKm: 0,
        baseFare: 1500.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description: 'خدمة نقل ستاندرد موثوقة ونظيفة بأسعار اقتصادية مناسبة',
        imageUrl:
            'https://images.unsplash.com/photo-1494905998402-395d579af36f?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),

      // STANDARD TIER - VANS
      TransportService(
        id: 'standard_van',
        name: 'فان ستاندرد',
        driverName: '',
        phone: '',
        email: '',
        isAvailable: true,
        rating: 4.0,
        reviewCount: 0,
        serviceAreas: [],
        serviceLevel: ServiceLevel.standard,
        vehicleType: VehicleType.van,
        capacity: 8,
        features: [],
        pricePerKm: 0,
        baseFare: 2000.0,
        isEmergencyService: false,
        isMedicalEquipped: false,
        description:
            'فان ستاندرد اقتصادي للعائلات الكبيرة مع مساحة واسعة وأمان جيد',
        imageUrl:
            'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400',
        amenities: [],
        estimatedArrivalTime: 0,
      ),
    ];
  }
}

enum ServiceLevel {
  standard, // ستاندرد
  premium, // بريميوم
  vip, // VIP
  diamond, // دايموند
  urgent, // طوارئ
}

enum VehicleType {
  sedan, // سيدان
  suv, // دفع رباعي
  van, // فان
  minibus, // حافلة صغيرة
  ambulance, // إسعاف
  luxury, // فاخر
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
  pending, // في الانتظار
  confirmed, // مؤكد
  inProgress, // في الطريق
  completed, // مكتمل
  cancelled, // ملغي
}

class TransportFilters {
  final String? serviceArea;
  final ServiceLevel? serviceLevel;
  final VehicleType? vehicleType;
  final double? minRating;
  final double? maxPricePerKm;
  final bool? availableOnly;
  final bool? emergencyOnly;
  final bool? medicalEquippedOnly;

  TransportFilters({
    this.serviceArea,
    this.serviceLevel,
    this.vehicleType,
    this.minRating,
    this.maxPricePerKm,
    this.availableOnly,
    this.emergencyOnly,
    this.medicalEquippedOnly,
  });

  TransportFilters copyWith({
    String? serviceArea,
    ServiceLevel? serviceLevel,
    VehicleType? vehicleType,
    double? minRating,
    double? maxPricePerKm,
    bool? availableOnly,
    bool? emergencyOnly,
    bool? medicalEquippedOnly,
  }) {
    return TransportFilters(
      serviceArea: serviceArea ?? this.serviceArea,
      serviceLevel: serviceLevel ?? this.serviceLevel,
      vehicleType: vehicleType ?? this.vehicleType,
      minRating: minRating ?? this.minRating,
      maxPricePerKm: maxPricePerKm ?? this.maxPricePerKm,
      availableOnly: availableOnly ?? this.availableOnly,
      emergencyOnly: emergencyOnly ?? this.emergencyOnly,
      medicalEquippedOnly: medicalEquippedOnly ?? this.medicalEquippedOnly,
    );
  }
}
