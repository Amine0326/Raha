import 'package:flutter/material.dart';
import '../../services/apiservice.dart';
import '../../theme/app_theme.dart';
import '../../models/room_models.dart' as room_models;
import '../../models/meal_models.dart';
import 'reservation_summary_screen.dart';

class AccommodationReservationScreen extends StatefulWidget {
  final int appointmentId;
  final int centerId;
  const AccommodationReservationScreen({super.key, required this.appointmentId, required this.centerId});

  @override
  State<AccommodationReservationScreen> createState() => _AccommodationReservationScreenState();
}

class _AccommodationReservationScreenState extends State<AccommodationReservationScreen> {
  final ApiService _api = ApiService();

  List<room_models.Room> _rooms = [];
  room_models.Room? _selectedRoom;

  List<MealPlan> _meals = [];
  MealPlan? _selectedMeal;

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  final TextEditingController _specialCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadMeals();
  }

  Future<void> _loadRooms() async {
    try {
      final data = await _api.get('/rooms', withAuth: true);
      if (data is List) {
        final rooms = data
            .map<room_models.Room>((e) => room_models.Room.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        setState(() {
          _rooms = rooms.where((r) => r.centerId == widget.centerId && r.isAvailable).toList();
        });
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب الغرف.');
      }
    } on ApiException catch (e) {
      _error = e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    }
  }

  Future<void> _loadMeals() async {
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
      _error = e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    }
  }

  Future<void> _pickRange() async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'اختر تاريخ الوصول والمغادرة',
      cancelText: 'إلغاء',
      confirmText: 'تم',
    );
    if (range != null) {
      setState(() {
        _checkIn = range.start;
        _checkOut = range.end;
      });
    }
  }

  Future<void> _submit() async {
    if (_selectedRoom == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الغرفة.')));
      return;
    }
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تحديد تاريخ الوصول والمغادرة.')));
      return;
    }
    if (_selectedMeal == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الوجبة.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final body = {
        'appointment_id': widget.appointmentId,
        'room_id': _selectedRoom!.id,
        'check_in_date': _checkIn!.toIso8601String(),
        'check_out_date': _checkOut!.toIso8601String(),
        'number_of_guests': _guests,
        'meal_option_id': _selectedMeal!.id,
        'special_requests': _specialCtrl.text.trim().isEmpty ? null : _specialCtrl.text.trim(),
      };

      final dynamic data = await _api.post('/accommodations', body: body, withAuth: true);

      if (!mounted) return;
      
      // Add center information to the reservation data
      final Map<String, dynamic> reservationData = Map<String, dynamic>.from(data);
      reservationData['center'] = {
        'id': widget.centerId,
        'name': 'المركز الصحي', // You can fetch the actual center name if needed
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReservationSummaryScreen(reservation: reservationData),
        ),
      );
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء حجز الإقامة.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _specialCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز الإقامة - الخطوة 2'),
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
        child: SingleChildScrollView(
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
                        Icons.hotel,
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
                            'حجز الإقامة',
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'اختر الغرفة والوجبة المناسبة',
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

              // Room Selection
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
                        Icon(Icons.hotel, color: AppTheme.getPrimaryColor(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'اختر الغرفة',
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
                        value: _selectedRoom?.id,
                        items: _rooms
                            .map((r) => DropdownMenuItem<int>(
                                  value: r.id,
                                  child: Text('${r.type} - رقم ${r.roomNumber} (${r.formattedPrice})'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedRoom = _rooms.firstWhere((e) => e.id == v)),
                        decoration: InputDecoration(
                          hintText: 'اختر الغرفة',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.getSurfaceColor(isDark),
                          contentPadding: const EdgeInsets.all(16),
                          prefixIcon: Icon(Icons.hotel, color: AppTheme.getPrimaryColor(isDark)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Date Range Selection
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
                        Icon(Icons.date_range, color: AppTheme.getPrimaryColor(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'اختر المدة',
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
                      child: InkWell(
                        onTap: _pickRange,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceColor(isDark),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppTheme.getDividerColor(isDark),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today, color: AppTheme.getPrimaryColor(isDark)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _checkIn == null || _checkOut == null
                                      ? 'تاريخ الوصول والمغادرة'
                                      : '${_checkIn!.toLocal().toString().substring(0, 10)} → ${_checkOut!.toLocal().toString().substring(0, 10)}',
                                  style: TextStyle(
                                    color: _checkIn == null || _checkOut == null
                                        ? AppTheme.getHintColor(isDark)
                                        : AppTheme.getOnSurfaceColor(isDark),
                                  ),
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: AppTheme.getHintColor(isDark)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Guests Selection
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
                        Icon(Icons.people, color: AppTheme.getPrimaryColor(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'عدد الضيوف',
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
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppTheme.getSurfaceColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _guests > 1 ? () => setState(() => _guests--) : null,
                            icon: Icon(
                              Icons.remove_circle_outline,
                              color: _guests > 1
                                  ? AppTheme.getPrimaryColor(isDark)
                                  : AppTheme.getHintColor(isDark),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$_guests',
                              style: TextStyle(
                                color: AppTheme.getPrimaryColor(isDark),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => setState(() => _guests++),
                            icon: Icon(
                              Icons.add_circle_outline,
                              color: AppTheme.getPrimaryColor(isDark),
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
                        Icon(Icons.restaurant, color: AppTheme.getPrimaryColor(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'اختر الوجبة',
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
                      child: DropdownButtonFormField<MealPlan>(
                        value: _selectedMeal,
                        items: _meals
                            .map((m) => DropdownMenuItem<MealPlan>(
                                  value: m,
                                  child: Text('${m.name} (${m.priceFormatted})'),
                                ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedMeal = v),
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
              const SizedBox(height: 24),

              // Special Requests
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
                        Icon(Icons.note_add, color: AppTheme.getPrimaryColor(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'طلبات خاصة (اختياري)',
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
                      child: TextField(
                        controller: _specialCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: 'أضف طلبات خاصة هنا...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppTheme.getSurfaceColor(isDark),
                          contentPadding: const EdgeInsets.all(16),
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
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(
                    _loading ? 'جاري المعالجة...' : 'تأكيد وإظهار الملخص',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

