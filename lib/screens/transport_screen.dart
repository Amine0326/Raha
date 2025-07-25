import 'package:flutter/material.dart';
import '../models/transport_models.dart';

class TransportScreen extends StatefulWidget {
  const TransportScreen({super.key});

  @override
  State<TransportScreen> createState() => _TransportScreenState();
}

class _TransportScreenState extends State<TransportScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<TransportService> _allServices = [];
  List<TransportService> _filteredServices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _allServices = TransportService.getDummyTransportServices();
    _filteredServices = _allServices;
  }

  void _filterServices() {
    setState(() {
      _filteredServices = _allServices.where((service) {
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            service.name.toLowerCase().contains(searchText) ||
            service.serviceAreas.any((area) => area.toLowerCase().contains(searchText)) ||
            service.features.any((feature) => feature.toLowerCase().contains(searchText));

        return matchesSearch;
      }).toList();
    });
  }

  String _getTransportTypeText(TransportType type) {
    switch (type) {
      case TransportType.private:
        return 'خاص';
      case TransportType.taxi:
        return 'تاكسي';
      case TransportType.bus:
        return 'حافلة';
      case TransportType.shared:
        return 'مشترك';
    }
  }

  String _getVehicleTypeText(VehicleType type) {
    switch (type) {
      case VehicleType.sedan:
        return 'سيدان';
      case VehicleType.suv:
        return 'دفع رباعي';
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
      case VehicleType.minibus:
        return Icons.directions_bus;
      case VehicleType.ambulance:
        return Icons.local_hospital;
      case VehicleType.luxury:
        return Icons.car_rental;
    }
  }

  Color _getServiceTypeColor(TransportType type) {
    switch (type) {
      case TransportType.private:
        return const Color(0xFF2196F3);
      case TransportType.taxi:
        return const Color(0xFFFFB300);
      case TransportType.bus:
        return const Color(0xFF4CAF50);
      case TransportType.shared:
        return const Color(0xFF9C27B0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // Cool gray background
      appBar: AppBar(
        title: const Text(
          'خدمات النقل',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1565C0), // Deep blue
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Dynamic header section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0), // Deep blue
                  Color(0xFF42A5F5), // Light blue
                  Color(0xFF29B6F6), // Sky blue
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                // Search bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 0,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFF757575),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) => _filterServices(),
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن خدمة نقل أو منطقة...',
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: Color(0xFF757575),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Transport info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'وسائل نقل آمنة ومريحة للوصول إلى مراكز العلاج',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Results section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم العثور على ${_filteredServices.length} خدمة نقل',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1565C0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredServices.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredServices.length,
                            itemBuilder: (context, index) {
                              return _buildTransportCard(_filteredServices[index]);
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(TransportService service) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _getServiceTypeColor(service.type).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with gradient
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  _getServiceTypeColor(service.type),
                  _getServiceTypeColor(service.type).withOpacity(0.8),
                ],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getVehicleIcon(service.vehicleType),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'السائق: ${service.driverName}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating and availability
                Column(
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          size: 14,
                          color: Color(0xFFFFD700),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '${service.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: service.isAvailable 
                            ? const Color(0xFF4CAF50) 
                            : const Color(0xFFFF5722),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        service.isAvailable ? 'متاح' : 'مشغول',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle info and capacity
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getServiceTypeColor(service.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getVehicleTypeText(service.vehicleType),
                        style: TextStyle(
                          fontSize: 11,
                          color: _getServiceTypeColor(service.type),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF757575).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${service.capacity} مقاعد',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (service.isEmergencyService)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5722).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'طوارئ',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFFFF5722),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    if (service.isMedicalEquipped)
                      Container(
                        margin: const EdgeInsets.only(left: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'مجهز طبياً',
                          style: TextStyle(
                            fontSize: 10,
                            color: Color(0xFF4CAF50),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                // Service areas
                Text(
                  'مناطق الخدمة: ${service.serviceAreas.join(' • ')}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                // Features
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: service.features.take(3).map((feature) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getServiceTypeColor(service.type).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 10,
                          color: _getServiceTypeColor(service.type),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                // Book button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _onServiceTap(service),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getServiceTypeColor(service.type),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'احجز الآن',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car_outlined,
            size: 80,
            color: Color(0xFFBDBDBD),
          ),
          SizedBox(height: 16),
          Text(
            'لم يتم العثور على خدمات نقل',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1565C0),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'جرب تغيير كلمات البحث',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  void _onServiceTap(TransportService service) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حجز ${service.name} - قريباً'),
        backgroundColor: _getServiceTypeColor(service.type),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
