import 'package:flutter/material.dart';
import '../../services/apiservice.dart';
import '../../theme/app_theme.dart';
import 'room_selection_screen.dart';

class CenterSelectionScreen extends StatefulWidget {
  final int patientId;
  final DateTime appointmentDateTime;
  final int durationDays;
  final String? notes;
  const CenterSelectionScreen({
    super.key,
    required this.patientId,
    required this.appointmentDateTime,
    required this.durationDays,
    this.notes,
  });

  @override
  State<CenterSelectionScreen> createState() => _CenterSelectionScreenState();
}

class _CenterSelectionScreenState extends State<CenterSelectionScreen> {
  final ApiService _api = ApiService();

  List<Map<String, dynamic>> _centers = [];
  int? _selectedCenterId;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _fetchCenters();
  }

  bool _isActive(dynamic v) {
    if (v == null) return true;
    if (v is bool) return v;
    final s = v.toString().toLowerCase();
    return s == 'true' || s == '1' || s == 'yes';
  }

  Future<void> _fetchCenters() async {
    setState(() => _loading = true);
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
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createAppointmentAndContinue() async {
    if (_selectedCenterId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار المركز الصحي.')));
      return;
    }
    try {
      final body = {
        'patient_id': widget.patientId,
        'center_id': _selectedCenterId,
        'appointment_datetime': widget.appointmentDateTime.toIso8601String(),
        // المدة بالأيام حسب الطلب الجديد
        'appointment_duration': widget.durationDays,
        'notes': widget.notes,
      };
      final dynamic data = await _api.post('/appointments', body: body, withAuth: true);
      int? appointmentId;
      if (data is Map) {
        if (data['id'] != null) appointmentId = int.tryParse(data['id'].toString());
        if (appointmentId == null && data['appointment'] is Map) {
          appointmentId = int.tryParse((data['appointment']['id']).toString());
        }
      }
      if (appointmentId == null) {
        throw ApiException('تعذّر تحديد معرف الموعد الذي تم إنشاؤه.');
      }
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => RoomSelectionScreen(
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('حجز موعد - الخطوة 2 (المركز)'),
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
                                  'اختر المركز الصحي',
                                  style: TextStyle(
                                    color: AppTheme.getOnSurfaceColor(isDark),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'اختر المركز المناسب لحجزك',
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
                                'المراكز المتاحة',
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
                                  .map((c) {
                                    final idVal = int.tryParse(c['id']?.toString() ?? '');
                                    final nameVal = (c['name'] ?? '').toString();
                                    return DropdownMenuItem<int>(
                                      value: idVal,
                                      child: Text(nameVal.isEmpty ? '—' : nameVal),
                                    );
                                  })
                                  .where((item) => item.value != null)
                                  .cast<DropdownMenuItem<int>>()
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
                        onPressed: _createAppointmentAndContinue,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'متابعة لاختيار الغرفة',
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

