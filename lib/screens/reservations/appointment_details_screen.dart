import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/apiservice.dart';
import 'center_selection_screen.dart';

class AppointmentDetailsScreen extends StatefulWidget {
  final int patientId;
  const AppointmentDetailsScreen({super.key, required this.patientId});

  @override
  State<AppointmentDetailsScreen> createState() => _AppointmentDetailsScreenState();
}

class _AppointmentDetailsScreenState extends State<AppointmentDetailsScreen> {
  DateTime? _appointmentDateTime;
  int _durationDays = 15; // Changed minimum to 15 days
  final TextEditingController _notesCtrl = TextEditingController();

  Future<void> _pickDateTime() async {
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

  void _continue() {
    if (_appointmentDateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار تاريخ ووقت الموعد.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CenterSelectionScreen(
          patientId: widget.patientId,
          appointmentDateTime: _appointmentDateTime!,
          durationDays: _durationDays,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        ),
      ),
    );
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
        title: const Text('حجز موعد - الخطوة 1 (التفاصيل)'),
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
                        Icons.calendar_today,
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
                            'تفاصيل الموعد',
                            style: TextStyle(
                              color: AppTheme.getOnSurfaceColor(isDark),
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'حدد تاريخ ووقت الموعد',
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
                  onPressed: _continue,
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: const Text(
                    'متابعة لاختيار المركز',
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

