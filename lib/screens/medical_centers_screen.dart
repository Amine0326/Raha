import 'package:flutter/material.dart';
import '../models/medical_center_models.dart';
import '../widgets/medical_center_widgets.dart';

class MedicalCentersScreen extends StatefulWidget {
  const MedicalCentersScreen({super.key});

  @override
  State<MedicalCentersScreen> createState() => _MedicalCentersScreenState();
}

class _MedicalCentersScreenState extends State<MedicalCentersScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MedicalCenter> _allCenters = [];
  List<MedicalCenter> _filteredCenters = [];

  SearchFilters _filters = SearchFilters();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _allCenters = MedicalCenter.getDummyMedicalCenters();
    _filteredCenters = _allCenters;
  }

  void _filterCenters() {
    setState(() {
      _filteredCenters = _allCenters.where((center) {
        // Search text filter
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch =
            searchText.isEmpty ||
            center.name.toLowerCase().contains(searchText) ||
            center.city.toLowerCase().contains(searchText) ||
            center.specialties.any((s) => s.toLowerCase().contains(searchText));

        // Always match specialty for simplified version
        final matchesSpecialty = true;

        // Availability filter
        final matchesAvailability =
            _filters.availableOnly != true || center.isAvailable;

        return matchesSearch && matchesSpecialty && matchesAvailability;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'المراكز الطبية',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1976D2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                MedicalCenterSearchBar(
                  controller: _searchController,
                  onChanged: (value) => _filterCenters(),
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
                    'تم العثور على ${_filteredCenters.length} مركز طبي',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredCenters.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredCenters.length,
                            itemBuilder: (context, index) {
                              return MedicalCenterCard(
                                center: _filteredCenters[index],
                                onTap: () =>
                                    _onCenterTap(_filteredCenters[index]),
                              );
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

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Color(0xFF9E9E9E)),
          SizedBox(height: 16),
          Text(
            'لم يتم العثور على نتائج',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'جرب تغيير معايير البحث أو التصفية',
            style: TextStyle(fontSize: 14, color: Color(0xFF757575)),
          ),
        ],
      ),
    );
  }

  void _onCenterTap(MedicalCenter center) {
    // TODO: Navigate to center details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم النقر على: ${center.name}'),
        backgroundColor: const Color(0xFF1976D2),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
