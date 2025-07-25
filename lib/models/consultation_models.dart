// Consultation Models for Rahati Healthcare App
// Designed for medical consultations and appointments

class Doctor {
  final String id;
  final String name;
  final String specialty;
  final String medicalCenter;
  final String location;
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final List<String> languages;
  final List<String> qualifications;
  final int experienceYears;
  final bool isAvailable;
  final ConsultationType consultationType;
  final List<String> availableDays;
  final String phone;
  final String email;
  final ConsultationFee fee;

  Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.medicalCenter,
    required this.location,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.languages,
    required this.qualifications,
    required this.experienceYears,
    required this.isAvailable,
    required this.consultationType,
    required this.availableDays,
    required this.phone,
    required this.email,
    required this.fee,
  });

  // Dummy data for Algerian doctors
  static List<Doctor> getDummyDoctors() {
    return [
      Doctor(
        id: '1',
        name: 'د. أمينة بن صالح',
        specialty: 'أمراض القلب والأوعية الدموية',
        medicalCenter: 'مستشفى مصطفى باشا الجامعي',
        location: 'الجزائر العاصمة',
        rating: 4.9,
        reviewCount: 187,
        imageUrl: 'doctor1.jpg',
        languages: ['العربية', 'الفرنسية', 'الإنجليزية'],
        qualifications: ['دكتوراه في الطب', 'تخصص أمراض القلب', 'عضو الجمعية الأوروبية لأمراض القلب'],
        experienceYears: 15,
        isAvailable: true,
        consultationType: ConsultationType.both,
        availableDays: ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس'],
        phone: '+213021123456',
        email: 'dr.amina@mustaphapacha.dz',
        fee: ConsultationFee.premium,
      ),
      Doctor(
        id: '2',
        name: 'د. محمد الطاهر زيتوني',
        specialty: 'طب الأطفال',
        medicalCenter: 'مستشفى الشهيد محمد بوضياف',
        location: 'الجزائر العاصمة',
        rating: 4.7,
        reviewCount: 156,
        imageUrl: 'doctor2.jpg',
        languages: ['العربية', 'الفرنسية'],
        qualifications: ['دكتوراه في طب الأطفال', 'ماجستير في التغذية العلاجية'],
        experienceYears: 12,
        isAvailable: true,
        consultationType: ConsultationType.inPerson,
        availableDays: ['السبت', 'الأحد', 'الاثنين', 'الثلاثاء'],
        phone: '+213021234567',
        email: 'dr.tahar@boudiaf-hospital.dz',
        fee: ConsultationFee.medium,
      ),
      Doctor(
        id: '3',
        name: 'د. فاطمة الزهراء قاسمي',
        specialty: 'النساء والتوليد',
        medicalCenter: 'العيادة الدولية للجراحة',
        location: 'الجزائر العاصمة',
        rating: 4.8,
        reviewCount: 203,
        imageUrl: 'doctor3.jpg',
        languages: ['العربية', 'الفرنسية', 'الإنجليزية', 'الألمانية'],
        qualifications: ['دكتوراه في النساء والتوليد', 'زمالة في جراحة المناظير'],
        experienceYears: 18,
        isAvailable: true,
        consultationType: ConsultationType.online,
        availableDays: ['الأحد', 'الثلاثاء', 'الخميس', 'السبت'],
        phone: '+213021345678',
        email: 'dr.fatima@international-surgery.dz',
        fee: ConsultationFee.premium,
      ),
      Doctor(
        id: '4',
        name: 'د. عبد الرحمن بوعلام',
        specialty: 'الطب النفسي',
        medicalCenter: 'مركز وهران الطبي',
        location: 'وهران',
        rating: 4.6,
        reviewCount: 134,
        imageUrl: 'doctor4.jpg',
        languages: ['العربية', 'الفرنسية'],
        qualifications: ['دكتوراه في الطب النفسي', 'دبلوم في العلاج النفسي'],
        experienceYears: 10,
        isAvailable: true,
        consultationType: ConsultationType.both,
        availableDays: ['الاثنين', 'الأربعاء', 'الخميس', 'السبت'],
        phone: '+213041456789',
        email: 'dr.abderrahmane@oran-medical.dz',
        fee: ConsultationFee.affordable,
      ),
    ];
  }
}

enum ConsultationType {
  inPerson,   // حضوري
  online,     // عبر الإنترنت
  both,       // كلاهما
}

enum ConsultationFee {
  affordable, // 2000-4000 دج
  medium,     // 4000-8000 دج
  premium,    // 8000+ دج
}

class Consultation {
  final String id;
  final String patientName;
  final String patientPhone;
  final String patientEmail;
  final String doctorId;
  final DateTime appointmentDateTime;
  final ConsultationType type;
  final String symptoms;
  final String medicalHistory;
  final ConsultationStatus status;
  final DateTime createdAt;
  final double fee;
  final String? meetingLink; // For online consultations
  final String? notes;

  Consultation({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.patientEmail,
    required this.doctorId,
    required this.appointmentDateTime,
    required this.type,
    required this.symptoms,
    required this.medicalHistory,
    required this.status,
    required this.createdAt,
    required this.fee,
    this.meetingLink,
    this.notes,
  });
}

enum ConsultationStatus {
  pending,    // في الانتظار
  confirmed,  // مؤكد
  inProgress, // جاري
  completed,  // مكتمل
  cancelled,  // ملغي
  rescheduled, // مؤجل
}

class ConsultationFilters {
  final String? specialty;
  final String? location;
  final ConsultationType? type;
  final ConsultationFee? feeRange;
  final double? minRating;
  final bool? availableOnly;
  final List<String>? languages;

  ConsultationFilters({
    this.specialty,
    this.location,
    this.type,
    this.feeRange,
    this.minRating,
    this.availableOnly,
    this.languages,
  });

  ConsultationFilters copyWith({
    String? specialty,
    String? location,
    ConsultationType? type,
    ConsultationFee? feeRange,
    double? minRating,
    bool? availableOnly,
    List<String>? languages,
  }) {
    return ConsultationFilters(
      specialty: specialty ?? this.specialty,
      location: location ?? this.location,
      type: type ?? this.type,
      feeRange: feeRange ?? this.feeRange,
      minRating: minRating ?? this.minRating,
      availableOnly: availableOnly ?? this.availableOnly,
      languages: languages ?? this.languages,
    );
  }
}

class MedicalSpecialty {
  final String id;
  final String name;
  final String arabicName;
  final String description;
  final String iconPath;

  MedicalSpecialty({
    required this.id,
    required this.name,
    required this.arabicName,
    required this.description,
    required this.iconPath,
  });

  static List<MedicalSpecialty> getAllSpecialties() {
    return [
      MedicalSpecialty(
        id: '1',
        name: 'Cardiology',
        arabicName: 'أمراض القلب',
        description: 'تشخيص وعلاج أمراض القلب والأوعية الدموية',
        iconPath: 'heart',
      ),
      MedicalSpecialty(
        id: '2',
        name: 'Pediatrics',
        arabicName: 'طب الأطفال',
        description: 'الرعاية الطبية للأطفال والمراهقين',
        iconPath: 'child',
      ),
      MedicalSpecialty(
        id: '3',
        name: 'Gynecology',
        arabicName: 'النساء والتوليد',
        description: 'صحة المرأة والحمل والولادة',
        iconPath: 'woman',
      ),
      MedicalSpecialty(
        id: '4',
        name: 'Psychiatry',
        arabicName: 'الطب النفسي',
        description: 'تشخيص وعلاج الاضطرابات النفسية',
        iconPath: 'brain',
      ),
      MedicalSpecialty(
        id: '5',
        name: 'Orthopedics',
        arabicName: 'جراحة العظام',
        description: 'علاج إصابات وأمراض العظام والمفاصل',
        iconPath: 'bone',
      ),
    ];
  }
}
