class MealPlan {
  final int id;
  final String name;
  final String description;
  final double price;
  final bool isVegetarian;
  final bool isVegan;
  final bool isGlutenFree;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  MealPlan({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.isVegetarian,
    required this.isVegan,
    required this.isGlutenFree,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MealPlan.fromJson(Map<String, dynamic> json) {
    return MealPlan(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: double.parse(json['price'].toString()),
      isVegetarian: json['is_vegetarian'] ?? false,
      isVegan: json['is_vegan'] ?? false,
      isGlutenFree: json['is_gluten_free'] ?? false,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'is_vegetarian': isVegetarian,
      'is_vegan': isVegan,
      'is_gluten_free': isGlutenFree,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get priceFormatted => '${price.toStringAsFixed(0)} دج';

  List<String> get dietaryTags {
    List<String> tags = [];
    if (isVegetarian) tags.add('نباتي');
    if (isVegan) tags.add('نباتي صرف');
    if (isGlutenFree) tags.add('خالي من الجلوتين');
    return tags;
  }

  String get category {
    if (isVegan) return 'Vegan';
    if (isVegetarian) return 'Vegetarian';
    if (isGlutenFree) return 'Gluten-Free';
    return 'Standard';
  }

  static List<MealPlan> getDummyMealPlans() {
    return [
      MealPlan(
        id: 1,
        name: 'خطة الوجبات القياسية',
        description:
            'ثلاث وجبات متوازنة يومياً مع تنوع في الأطباق الصحية والمغذية',
        price: 3000.00,
        isVegetarian: false,
        isVegan: false,
        isGlutenFree: false,
        isActive: true,
        createdAt: DateTime.parse('2025-07-25T14:43:17.000000Z'),
        updatedAt: DateTime.parse('2025-07-25T14:43:17.000000Z'),
      ),
      MealPlan(
        id: 2,
        name: 'خطة الوجبات النباتية',
        description: 'ثلاث وجبات نباتية يومياً غنية بالبروتين النباتي والألياف',
        price: 3500.00,
        isVegetarian: true,
        isVegan: false,
        isGlutenFree: false,
        isActive: true,
        createdAt: DateTime.parse('2025-07-25T14:43:19.000000Z'),
        updatedAt: DateTime.parse('2025-07-25T14:43:19.000000Z'),
      ),
      MealPlan(
        id: 3,
        name: 'خطة الوجبات النباتية الصرفة',
        description: 'ثلاث وجبات نباتية صرفة خالية من أي منتجات حيوانية',
        price: 4000.00,
        isVegetarian: true,
        isVegan: true,
        isGlutenFree: false,
        isActive: true,
        createdAt: DateTime.parse('2025-07-25T14:43:21.000000Z'),
        updatedAt: DateTime.parse('2025-07-25T14:43:21.000000Z'),
      ),
      MealPlan(
        id: 4,
        name: 'خطة الوجبات الخالية من الجلوتين',
        description:
            'ثلاث وجبات يومياً خالية تماماً من الجلوتين ومناسبة للحساسية',
        price: 4500.00,
        isVegetarian: false,
        isVegan: false,
        isGlutenFree: true,
        isActive: true,
        createdAt: DateTime.parse('2025-07-25T14:43:22.000000Z'),
        updatedAt: DateTime.parse('2025-07-25T14:43:22.000000Z'),
      ),
    ];
  }
}

class MealCategory {
  final String name;
  final String icon;

  MealCategory({required this.name, required this.icon});

  static List<MealCategory> getCategories() {
    return [
      MealCategory(name: 'الكل', icon: '🍽️'),
      MealCategory(name: 'قياسي', icon: '🥘'),
      MealCategory(name: 'نباتي', icon: '🥗'),
      MealCategory(name: 'نباتي صرف', icon: '🌱'),
      MealCategory(name: 'خالي من الجلوتين', icon: '🌾'),
    ];
  }
}
