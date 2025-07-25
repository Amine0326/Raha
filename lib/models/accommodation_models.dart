// Accommodation Models for Rahati Healthcare App
// Designed for patients needing accommodation near medical centers

class Accommodation {
  final String id;
  final String name;
  final String address;
  final String city;
  final String wilaya;
  final double rating;
  final int reviewCount;
  final List<String> imageUrls;
  final String phone;
  final String email;
  final bool isAvailable;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> amenities;
  final PricePerNight pricePerNight;
  final AccommodationType type;
  final double distanceToHospital; // in km

  Accommodation({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.wilaya,
    required this.rating,
    required this.reviewCount,
    required this.imageUrls,
    required this.phone,
    required this.email,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.amenities,
    required this.pricePerNight,
    required this.type,
    required this.distanceToHospital,
  });

  // Dummy data for Algerian accommodations
  static List<Accommodation> getDummyAccommodations() {
    return [
      Accommodation(
        id: '1',
        name: 'فندق الراحة الطبية',
        address: 'شارع الاستقلال، بالقرب من مستشفى مصطفى باشا',
        city: 'الجزائر العاصمة',
        wilaya: 'الجزائر',
        rating: 4.6,
        reviewCount: 89,
        imageUrls: ['hotel1.jpg'],
        phone: '+213021567890',
        email: 'info@medical-comfort.dz',
        isAvailable: true,
        latitude: 36.7538,
        longitude: 3.0588,
        description: 'فندق مخصص لمرافقي المرضى مع خدمات طبية مساعدة',
        amenities: ['واي فاي مجاني', 'إفطار', 'موقف سيارات', 'خدمة 24 ساعة', 'قريب من المستشفى'],
        pricePerNight: PricePerNight.medium,
        type: AccommodationType.hotel,
        distanceToHospital: 0.3,
      ),
      Accommodation(
        id: '2',
        name: 'شقق الشفاء المفروشة',
        address: 'حي بن عكنون، الجزائر العاصمة',
        city: 'الجزائر العاصمة',
        wilaya: 'الجزائر',
        rating: 4.3,
        reviewCount: 67,
        imageUrls: ['apartment1.jpg'],
        phone: '+213021678901',
        email: 'contact@healing-apartments.dz',
        isAvailable: true,
        latitude: 36.7755,
        longitude: 3.0512,
        description: 'شقق مفروشة مريحة للإقامة الطويلة مع مطبخ مجهز',
        amenities: ['مطبخ مجهز', 'غسالة', 'تلفزيون', 'تكييف', 'أمان 24 ساعة'],
        pricePerNight: PricePerNight.affordable,
        type: AccommodationType.apartment,
        distanceToHospital: 0.8,
      ),
      Accommodation(
        id: '3',
        name: 'بيت الضيافة الطبي',
        address: 'شارع ديدوش مراد، الجزائر العاصمة',
        city: 'الجزائر العاصمة',
        wilaya: 'الجزائر',
        rating: 4.8,
        reviewCount: 124,
        imageUrls: ['guesthouse1.jpg'],
        phone: '+213021789012',
        email: 'info@medical-guesthouse.dz',
        isAvailable: true,
        latitude: 36.7372,
        longitude: 3.0865,
        description: 'بيت ضيافة عائلي مع جو دافئ وخدمة شخصية',
        amenities: ['إفطار منزلي', 'حديقة', 'صالة مشتركة', 'مساعدة طبية', 'نقل مجاني'],
        pricePerNight: PricePerNight.premium,
        type: AccommodationType.guesthouse,
        distanceToHospital: 0.5,
      ),
      Accommodation(
        id: '4',
        name: 'نزل الأمل للعائلات',
        address: 'حي المقري، وهران',
        city: 'وهران',
        wilaya: 'وهران',
        rating: 4.4,
        reviewCount: 156,
        imageUrls: ['hostel1.jpg'],
        phone: '+213041890123',
        email: 'contact@hope-hostel.dz',
        isAvailable: true,
        latitude: 35.6976,
        longitude: -0.6337,
        description: 'نزل اقتصادي مناسب للعائلات مع غرف مشتركة ومنفصلة',
        amenities: ['غرف عائلية', 'مطبخ مشترك', 'غسيل', 'إنترنت', 'منطقة لعب للأطفال'],
        pricePerNight: PricePerNight.affordable,
        type: AccommodationType.hostel,
        distanceToHospital: 1.2,
      ),
    ];
  }
}

enum PricePerNight {
  affordable, // أقل من 3000 دج
  medium,     // 3000-6000 دج
  premium,    // أكثر من 6000 دج
}

enum AccommodationType {
  hotel,      // فندق
  apartment,  // شقة مفروشة
  guesthouse, // بيت ضيافة
  hostel,     // نزل
}

class AccommodationBooking {
  final String id;
  final String guestName;
  final String guestPhone;
  final String guestEmail;
  final String accommodationId;
  final DateTime checkInDate;
  final DateTime checkOutDate;
  final int numberOfGuests;
  final String specialRequests;
  final BookingStatus status;
  final DateTime createdAt;
  final double totalPrice;

  AccommodationBooking({
    required this.id,
    required this.guestName,
    required this.guestPhone,
    required this.guestEmail,
    required this.accommodationId,
    required this.checkInDate,
    required this.checkOutDate,
    required this.numberOfGuests,
    required this.specialRequests,
    required this.status,
    required this.createdAt,
    required this.totalPrice,
  });
}

enum BookingStatus {
  pending,    // في الانتظار
  confirmed,  // مؤكد
  cancelled,  // ملغي
  completed,  // مكتمل
}

class AccommodationFilters {
  final String? city;
  final String? wilaya;
  final AccommodationType? type;
  final PricePerNight? priceRange;
  final double? minRating;
  final double? maxDistance; // km from hospital
  final bool? availableOnly;

  AccommodationFilters({
    this.city,
    this.wilaya,
    this.type,
    this.priceRange,
    this.minRating,
    this.maxDistance,
    this.availableOnly,
  });

  AccommodationFilters copyWith({
    String? city,
    String? wilaya,
    AccommodationType? type,
    PricePerNight? priceRange,
    double? minRating,
    double? maxDistance,
    bool? availableOnly,
  }) {
    return AccommodationFilters(
      city: city ?? this.city,
      wilaya: wilaya ?? this.wilaya,
      type: type ?? this.type,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      maxDistance: maxDistance ?? this.maxDistance,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }
}
