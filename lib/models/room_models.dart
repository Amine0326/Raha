// Room Models for Rahati Healthcare App
// Designed for room discovery and booking functionality

class Room {
  final int id;
  final int centerId;
  final String roomNumber;
  final String type;
  final String description;
  final double pricePerNight;
  final int capacity;
  final bool isAccessible;
  final bool isAvailable;
  final String createdAt;
  final String updatedAt;
  final MedicalCenter center;

  Room({
    required this.id,
    required this.centerId,
    required this.roomNumber,
    required this.type,
    required this.description,
    required this.pricePerNight,
    required this.capacity,
    required this.isAccessible,
    required this.isAvailable,
    required this.createdAt,
    required this.updatedAt,
    required this.center,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'],
      centerId: json['center_id'],
      roomNumber: json['room_number'],
      type: json['type'],
      description: json['description'],
      pricePerNight: double.parse(json['price_per_night']),
      capacity: json['capacity'],
      isAccessible: json['is_accessible'],
      isAvailable: json['is_available'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      center: MedicalCenter.fromJson(json['center']),
    );
  }

  // Get dummy rooms data in Arabic
  static List<Room> getDummyRooms() {
    return [
      Room(
        id: 1,
        centerId: 1,
        roomNumber: "101",
        type: "فردية",
        description: "غرفة فردية مريحة مع حمام خاص ومكيف هواء",
        pricePerNight: 8500.00,
        capacity: 1,
        isAccessible: true,
        isAvailable: true,
        createdAt: "2025-07-25T14:43:11.000000Z",
        updatedAt: "2025-07-25T14:43:11.000000Z",
        center: MedicalCenter(
          id: 1,
          name: "مركز الراحة لإعادة التأهيل",
          description:
              "مؤسسة متخصصة في إعادة التأهيل الجسدي والنفسي لكافة الفئات العمرية.",
          address: "طريق بئر خادم، الجزائر العاصمة، الجزائر",
          phone: "+213661223344",
          email: "contact@reha.dz",
          website: "https://reha.dz",
          latitude: 36.7166670,
          longitude: 3.0500000,
          isActive: true,
        ),
      ),
      Room(
        id: 2,
        centerId: 1,
        roomNumber: "102",
        type: "مزدوجة",
        description: "غرفة مزدوجة واسعة مع سريرين منفصلين وإطلالة جميلة",
        pricePerNight: 12000.00,
        capacity: 2,
        isAccessible: true,
        isAvailable: true,
        createdAt: "2025-07-25T14:43:13.000000Z",
        updatedAt: "2025-07-25T14:43:13.000000Z",
        center: MedicalCenter(
          id: 1,
          name: "مركز الراحة لإعادة التأهيل",
          description:
              "مؤسسة متخصصة في إعادة التأهيل الجسدي والنفسي لكافة الفئات العمرية.",
          address: "طريق بئر خادم، الجزائر العاصمة، الجزائر",
          phone: "+213661223344",
          email: "contact@reha.dz",
          website: "https://reha.dz",
          latitude: 36.7166670,
          longitude: 3.0500000,
          isActive: true,
        ),
      ),
      Room(
        id: 3,
        centerId: 2,
        roomNumber: "201",
        type: "فردية",
        description: "غرفة فردية عادية مع حمام خاص",
        pricePerNight: 7500.00,
        capacity: 1,
        isAccessible: false,
        isAvailable: true,
        createdAt: "2025-07-25T14:43:14.000000Z",
        updatedAt: "2025-07-25T14:43:14.000000Z",
        center: MedicalCenter(
          id: 2,
          name: "مركز راحتي للصحة والعافية",
          description:
              "مركز رائد في الجزائر يقدم خدمات متكاملة للصحة النفسية والجسدية.",
          address: "شارع العقيد عميروش، الجزائر العاصمة، الجزائر",
          phone: "+213550112233",
          email: "info@rahati.dz",
          website: "https://rahati.dz",
          latitude: 36.7527780,
          longitude: 3.0422220,
          isActive: true,
        ),
      ),
      Room(
        id: 4,
        centerId: 2,
        roomNumber: "202",
        type: "جناح ملكي",
        description: "جناح ملكي فاخر مع جميع وسائل الراحة والخدمات المميزة",
        pricePerNight: 25000.00,
        capacity: 4,
        isAccessible: true,
        isAvailable: false,
        createdAt: "2025-07-25T14:43:16.000000Z",
        updatedAt: "2025-07-25T14:43:16.000000Z",
        center: MedicalCenter(
          id: 2,
          name: "مركز راحتي للصحة والعافية",
          description:
              "مركز رائد في الجزائر يقدم خدمات متكاملة للصحة النفسية والجسدية.",
          address: "شارع العقيد عميروش، الجزائر العاصمة، الجزائر",
          phone: "+213550112233",
          email: "info@rahati.dz",
          website: "https://rahati.dz",
          latitude: 36.7527780,
          longitude: 3.0422220,
          isActive: true,
        ),
      ),
      Room(
        id: 5,
        centerId: 3,
        roomNumber: "301",
        type: "عناية مركزة",
        description: "غرفة عناية مركزة مجهزة بأحدث الأجهزة الطبية",
        pricePerNight: 30000.00,
        capacity: 1,
        isAccessible: true,
        isAvailable: true,
        createdAt: "2025-07-25T14:43:17.000000Z",
        updatedAt: "2025-07-25T14:43:17.000000Z",
        center: MedicalCenter(
          id: 3,
          name: "مركز الشفاء الطبي المتخصص",
          description:
              "مركز طبي حديث يوفر خدمات التشخيص والعلاج بأحدث التقنيات الطبية.",
          address: "حي بن عكنون، الجزائر العاصمة، الجزائر",
          phone: "+213770445566",
          email: "info@shifa.dz",
          website: "https://shifa.dz",
          latitude: 36.7755560,
          longitude: 3.0333330,
          isActive: true,
        ),
      ),
    ];
  }

  String get formattedPrice => "${pricePerNight.toStringAsFixed(0)} دج";

  String get availabilityText => isAvailable ? "متاحة" : "محجوزة";

  String get accessibilityText => isAccessible
      ? "مناسبة لذوي الاحتياجات الخاصة"
      : "غير مناسبة لذوي الاحتياجات الخاصة";
}

class MedicalCenter {
  final int id;
  final String name;
  final String description;
  final String address;
  final String phone;
  final String email;
  final String website;
  final double latitude;
  final double longitude;
  final bool isActive;

  MedicalCenter({
    required this.id,
    required this.name,
    required this.description,
    required this.address,
    required this.phone,
    required this.email,
    required this.website,
    required this.latitude,
    required this.longitude,
    required this.isActive,
  });

  factory MedicalCenter.fromJson(Map<String, dynamic> json) {
    return MedicalCenter(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      latitude: double.parse(json['latitude']),
      longitude: double.parse(json['longitude']),
      isActive: json['is_active'],
    );
  }
}

enum RoomType {
  single, // فردية
  double, // مزدوجة
  suite, // جناح ملكي
  icu, // عناية مركزة
}

enum PriceRange {
  budget, // أقل من 10000 دج
  medium, // 10000-20000 دج
  premium, // أكثر من 20000 دج
}

class RoomFilters {
  String searchQuery;
  bool? isAvailable;
  int? capacity;
  int? centerId;

  RoomFilters({
    this.searchQuery = '',
    this.isAvailable,
    this.capacity,
    this.centerId,
  });

  void reset() {
    searchQuery = '';
    isAvailable = null;
    capacity = null;
    centerId = null;
  }
}
