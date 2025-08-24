import 'package:flutter/material.dart';
import '../../services/apiservice.dart';
import '../../theme/app_theme.dart';
import '../../models/meal_models.dart';
import 'reservation_summary_screen.dart';

class MealSelectionScreen extends StatefulWidget {
  final int appointmentId;
  final int roomId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final String? specialRequests;
  const MealSelectionScreen({
    super.key,
    required this.appointmentId,
    required this.roomId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    this.specialRequests,
  });

  @override
  State<MealSelectionScreen> createState() => _MealSelectionScreenState();
}

class _MealSelectionScreenState extends State<MealSelectionScreen> {
  final ApiService _api = ApiService();
  List<MealPlan> _meals = [];
  int? _selectedMealId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() => _loading = true);
    try {
      final data = await _api.get('/meal-options', withAuth: true);
      if (data is List) {
        final meals = data.map<MealPlan>((e) => MealPlan.fromJson(Map<String, dynamic>.from(e as Map))).toList();
        setState(() {
          _meals = meals.where((m) => m.isActive).toList();
        });
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب الوجبات.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedMealId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الوجبة.')));
      return;
    }

    try {
      final body = {
        'appointment_id': widget.appointmentId,
        'room_id': widget.roomId,
        'check_in_date': widget.checkIn.toIso8601String(),
        'check_out_date': widget.checkOut.toIso8601String(),
        'number_of_guests': widget.guests,
        'meal_option_id': _selectedMealId,
        'special_requests': widget.specialRequests,
      };

      final dynamic data = await _api.post('/accommodations', body: body, withAuth: true);

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationSummaryScreen(reservation: data),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد - الخطوة 4 (الوجبة)'),
        elevation: 0,
        backgroundColor: AppTheme.getSurfaceColor(isDark),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.getSurfaceColor(isDark),
              AppTheme.getBackgroundColor(isDark),
            ],
          ),
        ),
        child: _loading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.getPrimaryColor(isDark)),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحميل الوجبات...',
                      style: TextStyle(color: AppTheme.getHintColor(isDark)),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(isDark),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.restaurant,
                              color: AppTheme.getPrimaryColor(isDark),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'اختر الوجبة',
                                  style: TextStyle(
                                    color: AppTheme.getOnSurfaceColor(isDark),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'اختر الخطة الغذائية المناسبة',
                                  style: TextStyle(
                                    color: AppTheme.getHintColor(isDark),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Meal Selection
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getCardColor(isDark),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.restaurant_menu, color: AppTheme.getPrimaryColor(isDark)),
                              const SizedBox(width: 8),
                              Text(
                                'الوجبات المتاحة',
                                style: TextStyle(
                                  color: AppTheme.getOnSurfaceColor(isDark),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: DropdownButtonFormField<int>(
                              value: _selectedMealId,
                              items: _meals
                                  .map((m) => DropdownMenuItem<int>(
                                        value: m.id,
                                        child: Text('${m.name} (${m.priceFormatted})'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedMealId = v),
                              decoration: InputDecoration(
                                hintText: 'اختر الوجبة',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.getSurfaceColor(isDark),
                                contentPadding: const EdgeInsets.all(16),
                                prefixIcon: Icon(Icons.restaurant, color: AppTheme.getPrimaryColor(isDark)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _submit,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text(
                          'تأكيد وإظهار الملخص',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(isDark),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

