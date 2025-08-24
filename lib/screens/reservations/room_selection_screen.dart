import 'package:flutter/material.dart';
import '../../services/apiservice.dart';
import '../../theme/app_theme.dart';
import '../../models/room_models.dart' as room_models;
import 'meal_selection_screen.dart';

class RoomSelectionScreen extends StatefulWidget {
  final int appointmentId;
  final int centerId;
  const RoomSelectionScreen({super.key, required this.appointmentId, required this.centerId});

  @override
  State<RoomSelectionScreen> createState() => _RoomSelectionScreenState();
}

class _RoomSelectionScreenState extends State<RoomSelectionScreen> {
  final ApiService _api = ApiService();

  List<room_models.Room> _rooms = [];
  int? _selectedRoomId;

  DateTime? _checkIn;
  DateTime? _checkOut;
  int _guests = 1;
  final TextEditingController _specialCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _loading = true);
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: const Color(0xFFD32F2F)),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
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

  void _continue() {
    if (_selectedRoomId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى اختيار الغرفة.')));
      return;
    }
    if (_checkIn == null || _checkOut == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('يرجى تحديد تاريخ الوصول والمغادرة.')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MealSelectionScreen(
          appointmentId: widget.appointmentId,
          roomId: _selectedRoomId!,
          checkIn: _checkIn!,
          checkOut: _checkOut!,
          guests: _guests,
          specialRequests: _specialCtrl.text.trim().isEmpty ? null : _specialCtrl.text.trim(),
        ),
      ),
    );
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
        title: const Text('حجز موعد - الخطوة 3 (الغرفة)'),
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
                      'جاري تحميل الغرف...',
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
                                  'اختر الغرفة',
                                  style: TextStyle(
                                    color: AppTheme.getOnSurfaceColor(isDark),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'اختر الغرفة المناسبة لإقامتك',
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
                                'الغرف المتاحة',
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
                              value: _selectedRoomId,
                              items: _rooms
                                  .map((r) => DropdownMenuItem<int>(
                                        value: r.id,
                                        child: Text('${r.type} - رقم ${r.roomNumber} (${r.formattedPrice})'),
                                      ))
                                  .toList(),
                              onChanged: (v) => setState(() => _selectedRoomId = v),
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
                        onPressed: _continue,
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(
                          'متابعة لاختيار الوجبة',
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

