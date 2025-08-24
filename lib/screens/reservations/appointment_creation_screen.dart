import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/apiservice.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import 'accommodation_reservation_screen.dart';

class AppointmentCreationScreen extends StatefulWidget {
  final int patientId;
  const AppointmentCreationScreen({super.key, required this.patientId});

  @override
  State<AppointmentCreationScreen> createState() => _AppointmentCreationScreenState();
}

class _AppointmentCreationScreenState extends State<AppointmentCreationScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _centers = [];
  int? _selectedCenterId;
  DateTime? _appointmentDateTime;
  int _durationDays = 15; // Changed minimum to 15 days
  final TextEditingController _notesCtrl = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCenters();
  }

  Future<void> _fetchCenters() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final data = await _api.get('/centers', withAuth: true);
      if (data is List) {
        final fetched = data.map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e as Map)).toList();
        // فلترة المراكز النشطة إن وُجد الحقل is_active
        _centers = fetched.where((c) => c['is_active'] != false).toList();
        setState(() {});
      } else {
        throw ApiException('الاستجابة غير متوقعة من الخادم عند جلب المراكز.');
      }
    } on ApiException catch (e) {
      _error = e.message;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } catch (e) {
      _error = 'حدث خطأ أثناء جلب المراكز.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final firstDate = now;
    final lastDate = now.add(const Duration(days: 365));

    final date = await showDatePicker(
      context: context,
      initialDate: firstDate,
      firstDate: firstDate,
      lastDate: lastDate,
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

    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() => _appointmentDateTime = dt);
  }

  Future<void> _submit() async {
    final up = Provider.of<UserProvider>(context, listen: false);
    final userId = up.currentUser?.id ?? widget.patientId;

    if (_selectedCenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المركز الصحي.')));
      return;
    }
    if (_appointmentDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار تاريخ ووقت الموعد.')));
      return;
    }

    setState(() => _loading = true);
    try {
      final body = {
        'patient_id': userId,
        'center_id': _selectedCenterId,
        'appointment_datetime': _appointmentDateTime!.toIso8601String(),
        // تعديل: مدة الموعد بالأيام
        'appointment_duration': _durationDays,
        'notes': _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      };

      final dynamic data = await _api.post('/appointments', body: body, withAuth: true);

      // استخراج معرف الموعد
      int? appointmentId;
      try {
        if (data is Map) {
          if (data['id'] != null) appointmentId = int.tryParse(data['id'].toString());
          if (appointmentId == null && data['appointment'] is Map) {
            appointmentId = int.tryParse((data['appointment']['id']).toString());
          }
        }
      } catch (_) {}

      if (appointmentId == null) {
        throw ApiException('تعذّر تحديد معرف الموعد الذي تم إنشاؤه.');
      }

      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AccommodationReservationScreen(
            appointmentId: appointmentId!,
            centerId: _selectedCenterId!,
          ),
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
          const SnackBar(content: Text('حدث خطأ أثناء إنشاء الموعد.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد - الخطوة 1'),
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
        child: _loading && _centers.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppTheme.getPrimaryColor(isDark)),
                    const SizedBox(height: 16),
                    Text(
                      'جاري تحميل المراكز...',
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
                              Icons.medical_services,
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
                                  'إنشاء موعد جديد',
                                  style: TextStyle(
                                    color: AppTheme.getOnSurfaceColor(isDark),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'اختر المركز والموعد المناسب',
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

                    // Center Selection
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
                              Icon(Icons.location_on, color: AppTheme.getPrimaryColor(isDark)),
                              const SizedBox(width: 8),
                              Text(
                                'اختر المركز الصحي',
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
                              value: _selectedCenterId,
                              items: _centers
                                  .map((c) => DropdownMenuItem<int>(
                                        value: int.tryParse(c['id'].toString()),
                                        child: Text(c['name']?.toString() ?? '—'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedCenterId = v),
                              decoration: InputDecoration(
                                hintText: 'اختر المركز',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: AppTheme.getSurfaceColor(isDark),
                                contentPadding: const EdgeInsets.all(16),
                                prefixIcon: Icon(Icons.medical_services, color: AppTheme.getPrimaryColor(isDark)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Date and Time Selection
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
                              onTap: _pickDateTime,
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Duration Selection
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Notes
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
                            : const Icon(Icons.arrow_forward_rounded),
                        label: Text(
                          _loading ? 'جاري المعالجة...' : 'متابعة إلى الحجز (الإقامة)',
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

