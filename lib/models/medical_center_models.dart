// Data models for Medical Centers and Booking System
// Designed for Algerian healthcare context

class MedicalCenter {
  final String id;
  final String name;
  final String address;
  final String city;
  final String wilaya; // Algerian province
  final double rating;
  final int reviewCount;
  final List<String> specialties;
  final List<String> imageUrls;
  final String phone;
  final String email;
  final bool isAvailable;
  final double latitude;
  final double longitude;
  final String description;
  final List<String> facilities;
  final PriceRange priceRange;

  MedicalCenter({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.wilaya,
    required this.rating,
    required this.reviewCount,
    required this.specialties,
    required this.imageUrls,
    required this.phone,
    required this.email,
    required this.isAvailable,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.facilities,
    required this.priceRange,
  });

  // Dummy data for Algerian medical centers
  static List<MedicalCenter> getDummyMedicalCenters() {
    return [
      MedicalCenter(
        id: '1',
        name: 'مستشفى مصطفى باشا الجامعي',
        address: 'شارع الدكتور سعدان، الجزائر العاصمة',
        city: 'الجزائر العاصمة',
        wilaya: 'الجزائر',
        rating: 4.5,
        reviewCount: 324,
        specialties: ['أمراض القلب', 'الجراحة العامة', 'طب الأطفال', 'النساء والتوليد'],
        imageUrls: ['hospital1.jpg'],
        phone: '+213021234567',
        email: 'info@mustaphapacha.dz',
        isAvailable: true,
        latitude: 36.7538,
        longitude: 3.0588,
        description: 'مستشفى جامعي متخصص يقدم خدمات طبية متقدمة في جميع التخصصات',
        facilities: ['غرف عمليات متطورة', 'وحدة عناية مركزة', 'مختبر تحاليل', 'أشعة طبية'],
        priceRange: PriceRange.medium,
      ),
      MedicalCenter(
        id: '2',
        name: 'مستشفى الشهيد محمد بوضياف',
        address: 'حي بن عكنون، الجزائر العاصمة',
        city: 'الجزائر العاصمة',
        wilaya: 'الجزائر',
        rating: 4.2,
        reviewCount: 198,
        specialties: ['طب العيون', 'الأنف والأذن والحنجرة', 'الجلدية', 'الطب النفسي'],
        imageUrls: ['hospital2.jpg'],
        phone: '+213021345678',
        email: 'contact@boudiaf-hospital.dz',
        isAvailable: true,
        latitude: 36.7755,
        longitude: 3.0512,
        description: 'مركز طبي حديث متخصص في الرعاية الصحية الشاملة',
        facilities: ['عيادات خارجية', 'صيدلية', 'كافتيريا', 'موقف سيارات'],
        priceRange: PriceRange.affordable,
      ),
      MedicalCenter(
        id: '3',
        name: 'العيادة الدولية للجراحة',
        address: 'شارع ديدوش مراد، الجزائر العاصمة',
        city: 'الجزائر العاصمة',
        wilaya: 'الجزائر',
        rating: 4.8,
        reviewCount: 156,
        specialties: ['جراحة التجميل', 'جراحة العظام', 'جراحة المخ والأعصاب'],
        imageUrls: ['clinic1.jpg'],
        phone: '+213021456789',
        email: 'info@international-surgery.dz',
        isAvailable: true,
        latitude: 36.7372,
        longitude: 3.0865,
        description: 'عيادة متخصصة في الجراحات المتقدمة بأحدث التقنيات الطبية',
        facilities: ['غرف عمليات مجهزة', 'استشفاء قصير المدى', 'خدمة إسعاف'],
        priceRange: PriceRange.premium,
      ),
      MedicalCenter(
        id: '4',
        name: 'مركز وهران الطبي',
        address: 'حي المقري، وهران',
        city: 'وهران',
        wilaya: 'وهران',
        rating: 4.3,
        reviewCount: 267,
        specialties: ['أمراض الكلى', 'الغدد الصماء', 'الروماتيزم', 'التغذية العلاجية'],
        imageUrls: ['center1.jpg'],
        phone: '+213041234567',
        email: 'contact@oran-medical.dz',
        isAvailable: true,
        latitude: 35.6976,
        longitude: -0.6337,
        description: 'مركز طبي شامل يخدم منطقة الغرب الجزائري',
        facilities: ['مختبر متطور', 'وحدة غسيل كلى', 'علاج طبيعي', 'تغذية علاجية'],
        priceRange: PriceRange.medium,
      ),
    ];
  }
}

enum PriceRange {
  affordable, // ميسور التكلفة
  medium,     // متوسط التكلفة
  premium,    // مرتفع التكلفة
}

class MedicalSpecialty {
  final String id;
  final String name;
  final String arabicName;
  final String iconPath;
  final String description;

  MedicalSpecialty({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.iconPath,
    required this.description,
  });

  static List<MedicalSpecialty> getAllSpecialties() {
    return [
      MedicalSpecialty(
        id: '1',
        name: 'Cardiology',
        arabicName: 'أمراض القلب',
        iconPath: 'heart',
        description: 'تشخيص وعلاج أمراض القلب والأوعية الدموية',
      ),
      MedicalSpecialty(
        id: '2',
        name: 'Pediatrics',
        arabicName: 'طب الأطفال',
        iconPath: 'child',
        description: 'الرعاية الطبية للأطفال والمراهقين',
      ),
      MedicalSpecialty(
        id: '3',
        name: 'Orthopedics',
        arabicName: 'جراحة العظام',
        iconPath: 'bone',
        description: 'علاج إصابات وأمراض العظام والمفاصل',
      ),
      MedicalSpecialty(
        id: '4',
        name: 'Ophthalmology',
        arabicName: 'طب العيون',
        iconPath: 'eye',
        description: 'تشخيص وعلاج أمراض العين',
      ),
      MedicalSpecialty(
        id: '5',
        name: 'Dermatology',
        arabicName: 'الجلدية',
        iconPath: 'skin',
        description: 'علاج أمراض الجلد والشعر والأظافر',
      ),
      MedicalSpecialty(
        id: '6',
        name: 'General Surgery',
        arabicName: 'الجراحة العامة',
        iconPath: 'surgery',
        description: 'العمليات الجراحية العامة والطارئة',
      ),
    ];
  }
}

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String medicalCenterId;
  final double rating;
  final int experienceYears;
  final String imageUrl;
  final List<String> languages;
  final bool isAvailable;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.medicalCenterId,
    required this.rating,
    required this.experienceYears,
    required this.imageUrl,
    required this.languages,
    required this.isAvailable,
  });
}

class BookingRequest {
  final String id;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final String medicalCenterId;
  final String specialty;
  final DateTime preferredDate;
  final String preferredTime;
  final String notes;
  final BookingStatus status;
  final DateTime createdAt;

  BookingRequest({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.medicalCenterId,
    required this.specialty,
    required this.preferredDate,
    required this.preferredTime,
    required this.notes,
    required this.status,
    required this.createdAt,
  });
}

enum BookingStatus {
  pending,    // في الانتظار
  confirmed,  // مؤكد
  cancelled,  // ملغي
  completed,  // مكتمل
}

class SearchFilters {
  final String? city;
  final String? wilaya;
  final String? specialty;
  final PriceRange? priceRange;
  final double? minRating;
  final bool? availableOnly;

  SearchFilters({
    this.city,
    this.wilaya,
    this.specialty,
    this.priceRange,
    this.minRating,
    this.availableOnly,
  });

  SearchFilters copyWith({
    String? city,
    String? wilaya,
    String? specialty,
    PriceRange? priceRange,
    double? minRating,
    bool? availableOnly,
  }) {
    return SearchFilters(
      city: city ?? this.city,
      wilaya: wilaya ?? this.wilaya,
      specialty: specialty ?? this.specialty,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      availableOnly: availableOnly ?? this.availableOnly,
    );
  }
}
