import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transport_models.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<TransportService> _allServices = [];
  List<TransportService> _filteredServices = [];
  ServiceLevel? _selectedServiceLevel;
  VehicleType? _selectedVehicleType;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _loadData();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadData() {
    _allServices = TransportService.getDummyTransportServices();
    _filteredServices = _allServices;
  }

  void _filterServices() {
    setState(() {
      _filteredServices = _allServices.where((service) {
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch =
            searchText.isEmpty ||
            service.name.toLowerCase().contains(searchText) ||
            service.serviceAreas.any(
              (area) => area.toLowerCase().contains(searchText),
            ) ||
            service.features.any(
              (feature) => feature.toLowerCase().contains(searchText),
            );

        final matchesServiceLevel =
            _selectedServiceLevel == null ||
            service.serviceLevel == _selectedServiceLevel;
        final matchesVehicleType =
            _selectedVehicleType == null ||
            service.vehicleType == _selectedVehicleType;

        return matchesSearch && matchesServiceLevel && matchesVehicleType;
      }).toList();
    });
  }

  String _getServiceLevelText(ServiceLevel level) {
    switch (level) {
      case ServiceLevel.standard:
        return 'ستاندرد';
      case ServiceLevel.premium:
        return 'بريميوم';
      case ServiceLevel.vip:
        return 'VIP';
      case ServiceLevel.diamond:
        return 'دايموند';
      case ServiceLevel.urgent:
        return 'طوارئ';
    }
  }

  String _getVehicleTypeText(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return 'سيدان';
      case VehicleType.suv:
        return 'دفع رباعي';
      case VehicleType.van:
        return 'فان';
      case VehicleType.minibus:
        return 'حافلة صغيرة';
      case VehicleType.ambulance:
        return 'إسعاف';
      case VehicleType.luxury:
        return 'فاخر';
    }
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return Icons.directions_car;
      case VehicleType.suv:
        return Icons.directions_car_filled;
      case VehicleType.van:
        return Icons.airport_shuttle;
      case VehicleType.minibus:
        return Icons.directions_bus;
      case VehicleType.ambulance:
        return Icons.local_hospital;
      case VehicleType.luxury:
        return Icons.car_rental;
    }
  }

  Color _getServiceLevelColor(ServiceLevel level) {
    switch (level) {
      case ServiceLevel.standard:
        return const Color(0xFF4CAF50);
      case ServiceLevel.premium:
        return const Color(0xFF2196F3);
      case ServiceLevel.vip:
        return const Color(0xFF9C27B0);
      case ServiceLevel.diamond:
        return const Color(0xFFFFD700);
      case ServiceLevel.urgent:
        return const Color(0xFFFF5722);
    }
  }

  LinearGradient _getServiceLevelGradient(ServiceLevel level) {
    switch (level) {
      case ServiceLevel.standard:
        return const LinearGradient(
          colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
        );
      case ServiceLevel.premium:
        return const LinearGradient(
          colors: [Color(0xFF2196F3), Color(0xFF42A5F5)],
        );
      case ServiceLevel.vip:
        return const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFBA68C8)],
        );
      case ServiceLevel.diamond:
        return const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFF176)],
        );
      case ServiceLevel.urgent:
        return const LinearGradient(
          colors: [Color(0xFFFF5722), Color(0xFFFF7043)],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return Scaffold(
          backgroundColor: AppTheme.getBackgroundColor(isDark),
          body: SafeArea(
            child: Column(
              children: [
                // Modern Header
                _buildModernHeader(context, isDark),

                // Service Level Tabs
                _buildServiceLevelTabs(context, isDark),

                // Search and Filters
                _buildSearchAndFilters(context, isDark),

                // Services List
                Expanded(child: _buildServicesList(context, isDark)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModernHeader(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.getPrimaryColor(isDark),
            AppTheme.getPrimaryColor(isDark).withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
          SizedBox(width: screenWidth * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'خدمات النقل الطبي',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: screenWidth * 0.055,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenWidth * 0.01),
                Text(
                  'اختر الخدمة المناسبة لاحتياجاتك',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: screenWidth * 0.035,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
            ),
            child: Icon(
              Icons.local_taxi,
              color: Colors.white,
              size: screenWidth * 0.06,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceLevelTabs(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      height: screenWidth * 0.15,
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.getPrimaryColor(isDark),
        labelColor: AppTheme.getPrimaryColor(isDark),
        unselectedLabelColor: AppTheme.getHintColor(isDark),
        onTap: (index) {
          setState(() {
            switch (index) {
              case 0:
                _selectedServiceLevel = null;
                break;
              case 1:
                _selectedServiceLevel = ServiceLevel.standard;
                break;
              case 2:
                _selectedServiceLevel = ServiceLevel.premium;
                break;
              case 3:
                _selectedServiceLevel = ServiceLevel.vip;
                break;
              case 4:
                _selectedServiceLevel = ServiceLevel.diamond;
                break;
              case 5:
                _selectedServiceLevel = ServiceLevel.urgent;
                break;
            }
            _filterServices();
          });
        },
        tabs: [
          Tab(text: 'الكل'),
          Tab(text: 'ستاندرد'),
          Tab(text: 'بريميوم'),
          Tab(text: 'VIP'),
          Tab(text: 'دايموند'),
          Tab(text: 'طوارئ'),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple header
          Text(
            'اختر نوع المركبة',
            style: TextStyle(
              color: AppTheme.getOnSurfaceColor(isDark),
              fontSize: screenWidth * 0.04,
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: screenWidth * 0.03),

          // Vehicle Type Filter
          SizedBox(
            height: screenWidth * 0.12,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildVehicleTypeChip(
                  context,
                  isDark,
                  null,
                  'الكل',
                  Icons.apps,
                ),
                _buildVehicleTypeChip(
                  context,
                  isDark,
                  VehicleType.sedan,
                  'سيارات',
                  Icons.directions_car,
                ),
                _buildVehicleTypeChip(
                  context,
                  isDark,
                  VehicleType.van,
                  'فانات',
                  Icons.airport_shuttle,
                ),
                _buildVehicleTypeChip(
                  context,
                  isDark,
                  VehicleType.ambulance,
                  'إسعاف',
                  Icons.local_hospital,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleTypeChip(
    BuildContext context,
    bool isDark,
    VehicleType? type,
    String label,
    IconData icon,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSelected = _selectedVehicleType == type;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedVehicleType = type;
          _filterServices();
        });
      },
      child: Container(
        margin: EdgeInsets.only(right: screenWidth * 0.02),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.02,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.getPrimaryColor(isDark)
              : AppTheme.getCardColor(isDark),
          borderRadius: BorderRadius.circular(screenWidth * 0.06),
          border: Border.all(
            color: isSelected
                ? AppTheme.getPrimaryColor(isDark)
                : AppTheme.getHintColor(isDark).withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppTheme.getHintColor(isDark),
              size: screenWidth * 0.04,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AppTheme.getOnSurfaceColor(isDark),
                fontSize: screenWidth * 0.03,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServicesList(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (_filteredServices.isEmpty) {
      return _buildEmptyState(context, isDark);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results count
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.03),
            child: Text(
              'تم العثور على ${_filteredServices.length} خدمة نقل',
              style: TextStyle(
                color: AppTheme.getOnSurfaceColor(isDark),
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Services list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredServices.length,
              itemBuilder: (context, index) {
                return _buildServiceCard(
                  context,
                  isDark,
                  _filteredServices[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: screenWidth * 0.2,
            color: AppTheme.getHintColor(isDark),
          ),
          SizedBox(height: screenWidth * 0.05),
          Text(
            'لم يتم العثور على خدمات نقل',
            style: TextStyle(
              fontSize: screenWidth * 0.045,
              fontWeight: FontWeight.w600,
              color: AppTheme.getOnSurfaceColor(isDark),
            ),
          ),
          SizedBox(height: screenWidth * 0.02),
          Text(
            'جرب تغيير كلمات البحث أو الفلاتر',
            style: TextStyle(
              fontSize: screenWidth * 0.035,
              color: AppTheme.getHintColor(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(
    BuildContext context,
    bool isDark,
    TransportService service,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final serviceColor = _getServiceLevelColor(service.serviceLevel);
    final serviceGradient = _getServiceLevelGradient(service.serviceLevel);

    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: AppTheme.getCardColor(isDark),
        borderRadius: BorderRadius.circular(screenWidth * 0.04),
        boxShadow: [
          BoxShadow(
            color: serviceColor.withValues(alpha: 0.2),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              gradient: serviceGradient,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(screenWidth * 0.04),
                topRight: Radius.circular(screenWidth * 0.04),
              ),
            ),
            child: Row(
              children: [
                // Vehicle icon
                Container(
                  padding: EdgeInsets.all(screenWidth * 0.03),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                  ),
                  child: Icon(
                    _getVehicleIcon(service.vehicleType),
                    color: Colors.white,
                    size: screenWidth * 0.06,
                  ),
                ),

                SizedBox(width: screenWidth * 0.03),

                // Service info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: screenWidth * 0.01),
                      Text(
                        'السائق: ${service.driverName}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: screenWidth * 0.032,
                        ),
                      ),
                    ],
                  ),
                ),

                // Service level badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.03,
                    vertical: screenWidth * 0.01,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(screenWidth * 0.02),
                  ),
                  child: Text(
                    _getServiceLevelText(service.serviceLevel),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: screenWidth * 0.028,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content section - Clean and focused
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                Text(
                  service.description,
                  style: TextStyle(
                    color: AppTheme.getOnSurfaceColor(isDark),
                    fontSize: screenWidth * 0.038,
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                SizedBox(height: screenWidth * 0.04),

                // Key info row
                Row(
                  children: [
                    // Vehicle type
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        isDark,
                        'النوع',
                        _getVehicleTypeText(service.vehicleType),
                        _getVehicleIcon(service.vehicleType),
                        serviceColor,
                      ),
                    ),

                    SizedBox(width: screenWidth * 0.04),

                    // Capacity
                    Expanded(
                      child: _buildInfoItem(
                        context,
                        isDark,
                        'السعة',
                        '${service.capacity} مقاعد',
                        Icons.people,
                        serviceColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenWidth * 0.04),

                // Price and booking section
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'السعر',
                            style: TextStyle(
                              color: AppTheme.getHintColor(isDark),
                              fontSize: screenWidth * 0.032,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screenWidth * 0.01),
                          Text(
                            '${service.baseFare.toInt()} دج',
                            style: TextStyle(
                              color: serviceColor,
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Booking button
                    ElevatedButton(
                      onPressed: () => _onServiceTap(service),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: serviceColor,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.08,
                          vertical: screenWidth * 0.035,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            screenWidth * 0.03,
                          ),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        'احجز الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context,
    bool isDark,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      padding: EdgeInsets.all(screenWidth * 0.03),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: screenWidth * 0.06),
          SizedBox(height: screenWidth * 0.02),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.getHintColor(isDark),
              fontSize: screenWidth * 0.028,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: screenWidth * 0.01),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.getOnSurfaceColor(isDark),
              fontSize: screenWidth * 0.035,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _onServiceTap(TransportService service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حجز ${service.name} - قريباً'),
        backgroundColor: _getServiceLevelColor(service.serviceLevel),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
