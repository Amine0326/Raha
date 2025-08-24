import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/reservation_models.dart';
import '../services/reservation_service.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;

class MyReservationsScreen extends StatefulWidget {
  const MyReservationsScreen({super.key});

  @override
  State<MyReservationsScreen> createState() => _MyReservationsScreenState();
}

class _MyReservationsScreenState extends State<MyReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  List<Reservation> _reservations = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final reservations = await _reservationService.getMyReservations();
      setState(() {
        _reservations = reservations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          appBar: AppBar(
            backgroundColor: AppTheme.getCardColor(isDark),
            elevation: 0,
            title: Text(
              'حجوزاتي',
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back_ios_rounded,
                color: AppTheme.getOnSurfaceColor(isDark),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.refresh_rounded,
                  color: AppTheme.getOnSurfaceColor(isDark),
                ),
                onPressed: _loadReservations,
              ),
            ],
          ),
          body: _buildBody(isDark),
        );
      },
    );
  }

  Widget _buildBody(bool isDark) {
    if (_isLoading) {
      return _buildLoadingState(isDark);
    }

    if (_error != null) {
      return _buildErrorState(isDark);
    }

    if (_reservations.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: _loadReservations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reservations.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _buildReservationCard(_reservations[index], isDark),
          );
        },
      ),
    );
  }

  Widget _buildLoadingState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: AppTheme.getPrimaryColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الحجوزات...',
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: AppTheme.getHintColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ أثناء تحميل الحجوزات',
            style: TextStyle(
              color: AppTheme.getOnSurfaceColor(isDark),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _error ?? 'خطأ غير معروف',
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadReservations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getPrimaryColor(isDark),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hotel_outlined,
            size: 80,
            color: AppTheme.getHintColor(isDark),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد حجوزات',
            style: TextStyle(
              color: AppTheme.getOnSurfaceColor(isDark),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'لم تقم بحجز أي إقامة بعد',
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.getPrimaryColor(isDark),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('احجز الآن'),
          ),
        ],
      ),
    );
  }

  Widget _buildReservationCard(Reservation reservation, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.1),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Header with status
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.getPrimaryColor(isDark),
                    AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حجز رقم #${reservation.id}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                                                 Text(
                           reservation.room.center.name,
                           style: TextStyle(
                             color: Colors.white.withValues(alpha: 0.9),
                             fontSize: 14,
                           ),
                         ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getStatusText(reservation.status),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Room Information
                  _buildInfoRow(
                    isDark,
                    Icons.hotel_rounded,
                    'الغرفة',
                    '${reservation.room.type} - رقم ${reservation.room.roomNumber}',
                  ),
                  const SizedBox(height: 12),

                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: _buildInfoRow(
                          isDark,
                          Icons.calendar_today_rounded,
                          'تاريخ الوصول',
                          dateFormat.format(reservation.checkInDate),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildInfoRow(
                          isDark,
                          Icons.calendar_today_rounded,
                          'تاريخ المغادرة',
                          dateFormat.format(reservation.checkOutDate),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Appointment
                  _buildInfoRow(
                    isDark,
                    Icons.medical_services_rounded,
                    'الموعد الطبي',
                    '${dateFormat.format(reservation.appointment.appointmentDatetime)} - ${timeFormat.format(reservation.appointment.appointmentDatetime)}',
                  ),
                  const SizedBox(height: 12),

                  // Meal Plan
                  _buildInfoRow(
                    isDark,
                    Icons.restaurant_rounded,
                    'خطة الوجبات',
                    reservation.mealOption.name,
                  ),
                  const SizedBox(height: 12),

                  // Guests
                  _buildInfoRow(
                    isDark,
                    Icons.people_rounded,
                    'عدد الضيوف',
                    '${reservation.numberOfGuests} أشخاص',
                  ),
                  const SizedBox(height: 12),

                  // Price
                  _buildInfoRow(
                    isDark,
                    Icons.attach_money_rounded,
                    'السعر الإجمالي',
                    '${reservation.totalPrice} دج',
                    isPrice: true,
                  ),

                  // Special Requests
                  if (reservation.specialRequests != null && reservation.specialRequests!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      isDark,
                      Icons.note_rounded,
                      'طلبات خاصة',
                      reservation.specialRequests!,
                    ),
                  ],

                  const SizedBox(height: 16),

                                     // Action Button
                   SizedBox(
                     width: double.infinity,
                     child: OutlinedButton.icon(
                       onPressed: () => _showReservationDetails(reservation, isDark),
                       icon: const Icon(Icons.info_outline_rounded),
                       label: const Text('عرض التفاصيل'),
                       style: OutlinedButton.styleFrom(
                         foregroundColor: AppTheme.getPrimaryColor(isDark),
                         side: BorderSide(color: AppTheme.getPrimaryColor(isDark)),
                         padding: const EdgeInsets.symmetric(vertical: 12),
                         shape: RoundedRectangleBorder(
                           borderRadius: BorderRadius.circular(8),
                         ),
                       ),
                     ),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(bool isDark, IconData icon, String label, String value, {bool isPrice = false}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: AppTheme.getPrimaryColor(isDark),
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
                  color: AppTheme.getHintColor(isDark),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  color: AppTheme.getOnSurfaceColor(isDark),
                  fontSize: 14,
                  fontWeight: isPrice ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'reserved':
        return 'محجوز';
      case 'cancelled':
        return 'ملغي';
      case 'completed':
        return 'مكتمل';
      case 'pending':
        return 'في الانتظار';
      default:
        return status;
    }
  }

  void _showReservationDetails(Reservation reservation, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: AppTheme.getCardColor(isDark),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.getHintColor(isDark).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'تفاصيل الحجز',
                      style: TextStyle(
                        color: AppTheme.getOnSurfaceColor(isDark),
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                                         // Medical Center Details
                     _buildDetailSection(
                       isDark,
                       'مركز طبي',
                       Icons.local_hospital_rounded,
                       [
                         _buildDetailItem('الاسم', reservation.room.center.name),
                         _buildDetailItem('العنوان', reservation.room.center.address),
                         _buildDetailItem('الهاتف', reservation.room.center.phone),
                         _buildDetailItem('البريد الإلكتروني', reservation.room.center.email),
                       ],
                     ),
                    
                    const SizedBox(height: 20),
                    
                    // Room Details
                    _buildDetailSection(
                      isDark,
                      'تفاصيل الغرفة',
                      Icons.hotel_rounded,
                      [
                        _buildDetailItem('نوع الغرفة', reservation.room.type),
                        _buildDetailItem('رقم الغرفة', reservation.room.roomNumber),
                        _buildDetailItem('السعر لليلة', '${reservation.room.pricePerNight} دج'),
                        _buildDetailItem('السعة', '${reservation.room.capacity} أشخاص'),
                        _buildDetailItem('الوصف', reservation.room.description),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Meal Details
                    _buildDetailSection(
                      isDark,
                      'خطة الوجبات',
                      Icons.restaurant_rounded,
                      [
                        _buildDetailItem('الاسم', reservation.mealOption.name),
                        _buildDetailItem('الوصف', reservation.mealOption.description),
                        _buildDetailItem('السعر', '${reservation.mealOption.price} دج'),
                        _buildDetailItem('نباتي', reservation.mealOption.isVegetarian ? 'نعم' : 'لا'),
                        _buildDetailItem('نباتي صرف', reservation.mealOption.isVegan ? 'نعم' : 'لا'),
                        _buildDetailItem('خالي من الغلوتين', reservation.mealOption.isGlutenFree ? 'نعم' : 'لا'),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Appointment Details
                    _buildDetailSection(
                      isDark,
                      'تفاصيل الموعد',
                      Icons.medical_services_rounded,
                      [
                        _buildDetailItem('التاريخ والوقت', DateFormat('dd/MM/yyyy HH:mm').format(reservation.appointment.appointmentDatetime)),
                        _buildDetailItem('المدة', '${reservation.appointment.appointmentDuration} دقيقة'),
                        _buildDetailItem('الحالة', _getStatusText(reservation.appointment.status)),
                        if (reservation.appointment.notes != null)
                          _buildDetailItem('ملاحظات', reservation.appointment.notes!),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(bool isDark, String title, IconData icon, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppTheme.getPrimaryColor(isDark),
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.getSurfaceColor(isDark),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.getHintColor(isDark).withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }


}
