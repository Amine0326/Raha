import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/apiservice.dart';
import '../../providers/user_provider.dart';
import '../../models/room_models.dart' as room_models;
import '../../models/meal_models.dart';
import 'reservation_summary_screen.dart';

class ReservationStepperScreen extends StatefulWidget {
  const ReservationStepperScreen({super.key});

  @override
  State<ReservationStepperScreen> createState() => _ReservationStepperScreenState();
}

class _ReservationStepperScreenState extends State<ReservationStepperScreen> {
  final ApiService _api = ApiService();

  int _currentStep = 0;

  // Step 1: details
  DateTime? _appointmentDateTime;
  int _durationDays = 15; // Changed minimum to 15 days
  final TextEditingController _notesCtrl = TextEditingController();

  // Step 2: centers
  List<Map<String, dynamic>> _centers = [];
  int? _selectedCenterId;
  bool _loadingCenters = false;

  // Step 3: rooms
  List<room_models.Room> _rooms = [];
  int? _selectedRoomId;
  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  final TextEditingController _specialCtrl = TextEditingController();
  bool _loadingRooms = false;

  // Step 4: meals
  List<MealPlan> _meals = [];
  int? _selectedMealId;
  bool _loadingMeals = false;

  // Created appointment id
  int? _appointmentId;

  @override
  void dispose() {
    _notesCtrl.dispose();
    _specialCtrl.dispose();
    super.dispose();
  }

  // Helpers
  bool _isActive(dynamic v) {
    if (v == null) return true;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  Future<void> _pickAppointmentDT() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'اختر التاريخ',
      cancelText: 'إلغاء',
      confirmText: 'تم',
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'اختر الوقت',
      cancelText: 'إلغاء',
      confirmText: 'تم',
    );
    if (time == null) return;
    setState(() {
      _appointmentDateTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
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

  Future<void> _fetchCenters() async {
    setState(() => _loadingCenters = true);
    try {
      final data = await _api.get('/centers', withAuth: true);
      if (data is List) {
        final fetched = data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
        setState(() {
          _centers = fetched.where((c) => _isActive(c['is_active'] ?? c['active'])).toList();
        });
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب المراكز.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingCenters = false);
    }
  }

  Future<void> _fetchRooms() async {
    if (_selectedCenterId == null) return;
    setState(() => _loadingRooms = true);
    try {
      final data = await _api.get('/rooms', withAuth: true);
      if (data is List) {
        final rooms = data
            .map<room_models.Room>((e) => room_models.Room.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        setState(() {
          _rooms = rooms.where((r) => r.centerId == _selectedCenterId && r.isAvailable).toList();
        });
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب الغرف.');
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingRooms = false);
    }
  }

  Future<void> _fetchMeals() async {
    setState(() => _loadingMeals = true);
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
      if (mounted) setState(() => _loadingMeals = false);
    }
  }

  Future<void> _createAppointmentIfNeeded() async {
    if (_appointmentId != null) return;
    final up = Provider.of<UserProvider>(context, listen: false);
    final patientId = up.currentUser?.id;
    if (patientId == null) {
      throw ApiException('تعذّر تحديد معرف المريض، يرجى تسجيل الدخول أولاً.');
    }
    if (_selectedCenterId == null || _appointmentDateTime == null) {
      throw ApiException('يرجى إكمال البيانات أولاً.');
    }
    final durationMinutes = _durationDays * 1440; // تحويل الأيام إلى دقائق لتوافق الخادم
    final body = {
      'patient_id': patientId,
      'center_id': _selectedCenterId,
      'appointment_datetime': _appointmentDateTime!.toIso8601String(),
      'appointment_duration': durationMinutes,
      'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    };
    final data = await _api.post('/appointments', body: body, withAuth: true);
    if (data is Map) {
      int? id;
      if (data['id'] != null) id = int.tryParse(data['id'].toString());
      if (id == null && data['appointment'] is Map) {
        id = int.tryParse((data['appointment']['id']).toString());
      }
      if (id == null) throw ApiException('تعذّر تحديد معرف الموعد الذي تم إنشاؤه.');
      _appointmentId = id;
    } else {
      throw ApiException('استجابة غير متوقعة عند إنشاء الموعد.');
    }
  }

  Future<void> _submitAccommodation() async {
    if (_appointmentId == null) throw ApiException('لا يوجد معرف للموعد.');
    if (_selectedRoomId == null || _checkIn == null || _checkOut == null || _selectedMealId == null) {
      throw ApiException('يرجى إكمال بيانات الحجز.');
    }
    final body = {
      'appointment_id': _appointmentId,
      'room_id': _selectedRoomId,
      'check_in_date': _checkIn!.toIso8601String(),
      'check_out_date': _checkOut!.toIso8601String(),
      'number_of_guests': _guests,
      'meal_option_id': _selectedMealId,
      'special_requests': _specialCtrl.text.trim().isEmpty ? null : _specialCtrl.text.trim(),
    };
    final data = await _api.post('/accommodations', body: body, withAuth: true);
    if (!mounted) return;
    
    // Add center information to the reservation data
    final Map<String, dynamic> reservationData = Map<String, dynamic>.from(data);
    reservationData['center'] = {
      'id': _selectedCenterId,
      'name': _centers.firstWhere((c) => int.tryParse(c['id']?.toString() ?? '') == _selectedCenterId)['name']?.toString() ?? 'المركز الصحي',
    };
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReservationSummaryScreen(reservation: reservationData)),
    );
  }

  void _onStepContinue() async {
    try {
      if (_currentStep == 0) {
        if (_appointmentDateTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار تاريخ ووقت الموعد.')));
          return;
        }
        setState(() => _currentStep = 1);
        if (_centers.isEmpty) await _fetchCenters();
      } else if (_currentStep == 1) {
        if (_selectedCenterId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المركز الصحي.')));
          return;
        }
        // أنشئ الموعد الآن
        await _createAppointmentIfNeeded();
        setState(() => _currentStep = 2);
        await _fetchRooms();
      } else if (_currentStep == 2) {
        if (_selectedRoomId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الغرفة.')));
          return;
        }
        if (_checkIn == null || _checkOut == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تحديد تاريخ الوصول والمغادرة.')));
          return;
        }
        setState(() => _currentStep = 3);
        if (_meals.isEmpty) await _fetchMeals();
      } else if (_currentStep == 3) {
        if (_selectedMealId == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الوجبة.')));
          return;
        }
        await _submitAccommodation();
      }
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    }
  }

  void _onStepCancel() {
    if (_currentStep > 0) setState(() => _currentStep -= 1);
  }

  StepState _stateFor(int index) {
    if (_currentStep > index) return StepState.complete;
    if (_currentStep == index) return StepState.editing;
    return StepState.indexed;
  }

  Widget _buildDetailsStep(bool isDark) {
    return Container(
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
              Icon(Icons.calendar_today, color: AppTheme.getPrimaryColor(isDark)),
              const SizedBox(width: 8),
              Text(
                'تاريخ ووقت الموعد',
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
              onTap: _pickAppointmentDT,
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
                    Icon(Icons.access_time, color: AppTheme.getPrimaryColor(isDark)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _appointmentDateTime == null
                            ? 'اختر التاريخ والوقت'
                            : _appointmentDateTime!.toLocal().toString().substring(0, 16),
                        style: TextStyle(
                          color: _appointmentDateTime == null
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
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.schedule, color: AppTheme.getPrimaryColor(isDark)),
              const SizedBox(width: 8),
              Text(
                'مدة الموعد (بالأيام)',
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
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: _durationDays > 15 ? () => setState(() => _durationDays--) : null,
                      icon: Icon(
                        Icons.remove_circle_outline,
                        color: _durationDays > 15
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
                        '$_durationDays يوم',
                        style: TextStyle(
                          color: AppTheme.getPrimaryColor(isDark),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => setState(() => _durationDays++),
                      icon: Icon(
                        Icons.add_circle_outline,
                        color: AppTheme.getPrimaryColor(isDark),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  'الحد الأدنى: 15 يوم',
                  style: TextStyle(
                    color: AppTheme.getHintColor(isDark),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Icon(Icons.note, color: AppTheme.getPrimaryColor(isDark)),
              const SizedBox(width: 8),
              Text(
                'ملاحظات (اختياري)',
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
              controller: _notesCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'أضف ملاحظات إضافية هنا...',
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
    );
  }

  Widget _buildCentersStep(bool isDark) {
    if (_loadingCenters) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppTheme.getPrimaryColor(isDark)),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل المراكز...',
                style: TextStyle(color: AppTheme.getHintColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }
    
    if (_centers.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.medical_services_outlined, size: 64, color: AppTheme.getHintColor(isDark)),
              const SizedBox(height: 16),
              Text(
                'لا توجد مراكز متاحة حالياً',
                style: TextStyle(color: AppTheme.getHintColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _centers.map((c) {
        final idVal = int.tryParse(c['id']?.toString() ?? '');
        final name = (c['name'] ?? '').toString();
        final address = (c['address'] ?? '').toString();
        final selected = idVal != null && idVal == _selectedCenterId;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: selected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _selectedCenterId = idVal),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1)
                      : AppTheme.getCardColor(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppTheme.getPrimaryColor(isDark)
                        : AppTheme.getDividerColor(isDark),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.getPrimaryColor(isDark)
                            : AppTheme.getSurfaceColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.medical_services,
                        color: selected
                            ? Colors.white
                            : AppTheme.getPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name.isEmpty ? '—' : name,
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            address,
                            style: TextStyle(
                              color: AppTheme.getHintColor(isDark),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRoomsStep(bool isDark) {
    if (_loadingRooms) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppTheme.getPrimaryColor(isDark)),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل الغرف...',
                style: TextStyle(color: AppTheme.getHintColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_rooms.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.hotel_outlined, size: 64, color: AppTheme.getHintColor(isDark)),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد غرف متاحة لهذا المركز حالياً',
                    style: TextStyle(color: AppTheme.getHintColor(isDark)),
                  ),
                ],
              ),
            ),
          ),
        ..._rooms.map((r) {
          final selected = r.id == _selectedRoomId;
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: selected
                      ? AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.2)
                      : Colors.black.withValues(alpha: 0.08),
                  blurRadius: selected ? 12 : 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => setState(() => _selectedRoomId = r.id),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: selected
                        ? AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1)
                        : AppTheme.getCardColor(isDark),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? AppTheme.getPrimaryColor(isDark)
                          : AppTheme.getDividerColor(isDark),
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.getPrimaryColor(isDark)
                              : AppTheme.getSurfaceColor(isDark),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.hotel,
                          color: selected
                              ? Colors.white
                              : AppTheme.getPrimaryColor(isDark),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${r.type} - رقم ${r.roomNumber}',
                              style: TextStyle(
                                color: AppTheme.getOnSurfaceColor(isDark),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'السعر: ${r.formattedPrice} • السعة: ${r.capacity}',
                              style: TextStyle(
                                color: AppTheme.getHintColor(isDark),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (selected)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
        const SizedBox(height: 24),
        Row(
          children: [
            Icon(Icons.date_range, color: AppTheme.getPrimaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              'المدة',
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
        const SizedBox(height: 24),
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
        const SizedBox(height: 24),
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
    );
  }

  Widget _buildMealsStep(bool isDark) {
    if (_loadingMeals) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              CircularProgressIndicator(color: AppTheme.getPrimaryColor(isDark)),
              const SizedBox(height: 16),
              Text(
                'جاري تحميل الوجبات...',
                style: TextStyle(color: AppTheme.getHintColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    if (_meals.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_outlined, size: 64, color: AppTheme.getHintColor(isDark)),
              const SizedBox(height: 16),
              Text(
                'لا توجد وجبات متاحة حالياً',
                style: TextStyle(color: AppTheme.getHintColor(isDark)),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _meals.map((m) {
        final selected = m.id == _selectedMealId;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.2)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: selected ? 12 : 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _selectedMealId = m.id),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1)
                      : AppTheme.getCardColor(isDark),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected
                        ? AppTheme.getPrimaryColor(isDark)
                        : AppTheme.getDividerColor(isDark),
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.getPrimaryColor(isDark)
                            : AppTheme.getSurfaceColor(isDark),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.restaurant,
                        color: selected
                            ? Colors.white
                            : AppTheme.getPrimaryColor(isDark),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            m.name,
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            m.description,
                            style: TextStyle(
                              color: AppTheme.getHintColor(isDark),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'السعر: ${m.priceFormatted}',
                            style: TextStyle(
                              color: AppTheme.getPrimaryColor(isDark),
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (selected)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد (مُرحّل)'),
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
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: _onStepContinue,
          onStepCancel: _onStepCancel,
          controlsBuilder: (context, details) {
            return Container(
              margin: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
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
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.getPrimaryColor(isDark),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentStep == 3 ? 'تأكيد الحجز' : 'متابعة',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  if (_currentStep > 0) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: AppTheme.getPrimaryColor(isDark)),
                        ),
                        child: Text(
                          'رجوع',
                          style: TextStyle(
                            color: AppTheme.getPrimaryColor(isDark),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: Text(
                'تفاصيل الموعد',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              state: _stateFor(0),
              isActive: _currentStep >= 0,
              content: _buildDetailsStep(isDark),
            ),
            Step(
              title: Text(
                'اختيار المركز',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              state: _stateFor(1),
              isActive: _currentStep >= 1,
              content: _buildCentersStep(isDark),
            ),
            Step(
              title: Text(
                'اختيار الغرفة',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              state: _stateFor(2),
              isActive: _currentStep >= 2,
              content: _buildRoomsStep(isDark),
            ),
            Step(
              title: Text(
                'اختيار الوجبة',
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontWeight: FontWeight.bold,
                ),
              ),
              state: _stateFor(3),
              isActive: _currentStep >= 3,
              content: _buildMealsStep(isDark),
            ),
          ],
        ),
      ),
    );
  }
}

