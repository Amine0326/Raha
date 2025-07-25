import 'package:flutter/material.dart';
import '../models/accommodation_models.dart';
import '../models/medical_center_models.dart';

class AccommodationsScreen extends StatefulWidget {
  const AccommodationsScreen({super.key});

  @override
  State<AccommodationsScreen> createState() => _AccommodationsScreenState();
}

class _AccommodationsScreenState extends State<AccommodationsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Accommodation> _allAccommodations = [];
  List<Accommodation> _nearbyAccommodations = [];
  List<MedicalCenter> _medicalCenters = [];
  MedicalCenter? _selectedMedicalCenter;
  bool _showAccommodations = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _allAccommodations = Accommodation.getDummyAccommodations();
    _medicalCenters = MedicalCenter.getDummyMedicalCenters();
  }

  void _findNearbyAccommodations() {
    if (_selectedMedicalCenter == null) return;

    setState(() {
      // Sort accommodations by distance to selected medical center
      _nearbyAccommodations = _allAccommodations.map((accommodation) {
        // Calculate distance (simplified - in real app would use GPS coordinates)
        double distance = _calculateDistance(
          accommodation,
          _selectedMedicalCenter!,
        );
        return accommodation;
      }).toList();

      // Sort by distance (closest first)
      _nearbyAccommodations.sort(
        (a, b) => _calculateDistance(
          a,
          _selectedMedicalCenter!,
        ).compareTo(_calculateDistance(b, _selectedMedicalCenter!)),
      );

      _showAccommodations = true;
    });
  }

  double _calculateDistance(Accommodation accommodation, MedicalCenter center) {
    // Simplified distance calculation based on city match
    if (accommodation.city == center.city) {
      return accommodation.distanceToHospital; // Use existing distance
    }
    return 10.0 +
        accommodation.distanceToHospital; // Add penalty for different city
  }

  String _getAccommodationTypeText(AccommodationType type) {
    switch (type) {
      case AccommodationType.hotel:
        return 'فندق';
      case AccommodationType.apartment:
        return 'شقة مفروشة';
      case AccommodationType.guesthouse:
        return 'بيت ضيافة';
      case AccommodationType.hostel:
        return 'نزل';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'أماكن الإقامة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF667EEA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _showAccommodations ? _buildAccommodationsList() : _buildMedicalCenterSelection(),
    );
  }

  Widget _buildMedicalCenterSelection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'اختر مركز العلاج',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'سنعرض لك أماكن الإقامة القريبة من المركز الذي تختاره',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Search bar for medical centers
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'ابحث عن مركز طبي...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF667EEA)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild for search
              },
            ),
          ),
          const SizedBox(height: 20),
          // Medical centers list
          const Text(
            'المراكز الطبية المتاحة:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 16),
          // Filter medical centers based on search
          ..._getFilteredMedicalCenters().map((center) => _buildMedicalCenterCard(center)),
        ],
      ),
    );
  }

  List<MedicalCenter> _getFilteredMedicalCenters() {
    final searchText = _searchController.text.toLowerCase();
    if (searchText.isEmpty) {
      return _medicalCenters;
    }
    return _medicalCenters.where((center) =>
      center.name.toLowerCase().contains(searchText) ||
      center.city.toLowerCase().contains(searchText)
    ).toList();
  }

  Widget _buildMedicalCenterCard(MedicalCenter center) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF667EEA).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.local_hospital,
            color: Color(0xFF667EEA),
            size: 24,
          ),
        ),
        title: Text(
          center.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${center.city}, ${center.wilaya}',
              style: const TextStyle(
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${center.rating} (${center.reviewCount} تقييم)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF667EEA),
          size: 16,
        ),
        onTap: () {
          setState(() {
            _selectedMedicalCenter = center;
          });
          _findNearbyAccommodations();
        },
      ),
    );
  }

  Widget _buildAccommodationsList() {
    return Column(
      children: [
        // Header with selected medical center
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showAccommodations = false;
                          _selectedMedicalCenter = null;
                        });
                      },
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'أماكن الإقامة القريبة',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.local_hospital,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _selectedMedicalCenter?.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Accommodations list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: _nearbyAccommodations.length,
            itemBuilder: (context, index) {
              return _buildSmartAccommodationCard(_nearbyAccommodations[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSmartAccommodationCard(Accommodation accommodation) {
    final distance = _calculateDistance(accommodation, _selectedMedicalCenter!);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image header
          Container(
            height: 120,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF667EEA).withOpacity(0.8),
                  const Color(0xFF764BA2).withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.hotel,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: distance <= 1.0 ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${distance.toStringAsFixed(1)} كم',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name and type
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            accommodation.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getAccommodationTypeText(accommodation.type),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF667EEA),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${accommodation.rating}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D3748),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Distance info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7FAFC),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.directions_walk,
                        color: distance <= 1.0 ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          distance <= 1.0
                              ? 'قريب جداً من المستشفى - ${distance.toStringAsFixed(1)} كم'
                              : 'على بُعد ${distance.toStringAsFixed(1)} كم من المستشفى',
                          style: TextStyle(
                            color: distance <= 1.0 ? Colors.green : Colors.orange,
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Amenities
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: accommodation.amenities.take(3).map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF667EEA).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        amenity,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF667EEA),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Price and book button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'السعر لليلة الواحدة',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        Text(
                          _getPriceRangeText(accommodation.pricePerNight),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF667EEA),
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () => _onAccommodationTap(accommodation),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF667EEA),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'احجز الآن',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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

  String _getPriceRangeText(PricePerNight price) {
    switch (price) {
      case PricePerNight.affordable:
        return '2000-3000 دج';
      case PricePerNight.medium:
        return '3000-6000 دج';
      case PricePerNight.premium:
        return '6000+ دج';
    }
  }

  void _onAccommodationTap(Accommodation accommodation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حجز ${accommodation.name} - قريباً'),
        backgroundColor: const Color(0xFF667EEA),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
