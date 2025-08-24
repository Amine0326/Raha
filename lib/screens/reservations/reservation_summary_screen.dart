import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ReservationSummaryScreen extends StatelessWidget {
  final Map<String, dynamic> reservation;
  const ReservationSummaryScreen({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Debug: Print reservation data structure
    print('Reservation Data Structure:');
    print(reservation.toString());
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملخص الحجز'),
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
            children: [
              // Success Header
              Container(
                padding: const EdgeInsets.all(24),
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'تم الحجز بنجاح! 🎉',
                      style: TextStyle(
                        color: AppTheme.getOnSurfaceColor(isDark),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'تم تأكيد حجزك بنجاح',
                      style: TextStyle(
                        color: AppTheme.getHintColor(isDark),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Reservation Details
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
                        Icon(Icons.receipt_long, color: AppTheme.getPrimaryColor(isDark)),
                        const SizedBox(width: 8),
                        Text(
                          'تفاصيل الحجز',
                          style: TextStyle(
                            color: AppTheme.getOnSurfaceColor(isDark),
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildDetailRow(context, 'رقم الحجز', reservation['id']?.toString(), Icons.confirmation_number),
                    _buildDetailRow(context, 'الموعد', _formatDateTime(reservation['appointment']?['appointment_datetime']), Icons.calendar_today),
                    _buildDetailRow(context, 'المركز', _getCenterName(reservation), Icons.medical_services),
                    _buildDetailRow(context, 'الغرفة', reservation['room']?['room_number']?.toString(), Icons.hotel),
                    _buildDetailRow(context, 'الوصول', _formatDate(reservation['check_in_date']), Icons.login),
                    _buildDetailRow(context, 'المغادرة', _formatDate(reservation['check_out_date']), Icons.logout),
                    _buildDetailRow(context, 'عدد الضيوف', reservation['number_of_guests']?.toString(), Icons.people),
                    _buildDetailRow(context, 'الخطة الغذائية', reservation['meal_option']?['name']?.toString(), Icons.restaurant),
                    _buildDetailRow(context, 'السعر الإجمالي', _formatPrice(reservation['total_price']), Icons.attach_money, isPrice: true),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Action Buttons
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
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  icon: const Icon(Icons.home),
                  label: const Text(
                    'العودة إلى الرئيسية',
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

  Widget _buildDetailRow(BuildContext context, String label, String? value, IconData icon, {bool isPrice = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.getSurfaceColor(Theme.of(context).brightness == Brightness.dark),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.getPrimaryColor(Theme.of(context).brightness == Brightness.dark).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.getPrimaryColor(Theme.of(context).brightness == Brightness.dark),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppTheme.getHintColor(Theme.of(context).brightness == Brightness.dark),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? '—',
                  style: TextStyle(
                    color: AppTheme.getOnSurfaceColor(Theme.of(context).brightness == Brightness.dark),
                    fontSize: 16,
                    fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null) return '—';
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }

  String _formatDate(String? date) {
    if (date == null) return '—';
    try {
      final dt = DateTime.parse(date);
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
  }

  String _formatPrice(dynamic price) {
    if (price == null) return '—';
    final priceStr = price.toString();
    if (priceStr.contains('.')) {
      return '${priceStr} دج';
    }
    return '${priceStr}.00 دج';
  }

  String _getCenterName(Map<String, dynamic> reservation) {
    // Try multiple possible paths for center name
    String? centerName;
    
    // Path 1: reservation['center']['name']
    centerName = reservation['center']?['name']?.toString();
    if (centerName != null && centerName.isNotEmpty && centerName != 'null') return centerName;
    
    // Path 2: reservation['appointment']['center']['name']
    centerName = reservation['appointment']?['center']?['name']?.toString();
    if (centerName != null && centerName.isNotEmpty && centerName != 'null') return centerName;
    
    // Path 3: reservation['medical_center']['name']
    centerName = reservation['medical_center']?['name']?.toString();
    if (centerName != null && centerName.isNotEmpty && centerName != 'null') return centerName;
    
    // Path 4: reservation['center_name']
    centerName = reservation['center_name']?.toString();
    if (centerName != null && centerName.isNotEmpty && centerName != 'null') return centerName;
    
    // Path 5: reservation['appointment']['center_name']
    centerName = reservation['appointment']?['center_name']?.toString();
    if (centerName != null && centerName.isNotEmpty && centerName != 'null') return centerName;
    
    // Default fallback
    return 'المركز الصحي';
  }
}

