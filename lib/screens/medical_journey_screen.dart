import 'package:flutter/material.dart';
import '../models/medical_center_models.dart';
import '../models/accommodation_models.dart';
import '../models/transport_models.dart';

class MedicalJourneyScreen extends StatefulWidget {
  const MedicalJourneyScreen({super.key});

  @override
  State<MedicalJourneyScreen> createState() => _MedicalJourneyScreenState();
}

class _MedicalJourneyScreenState extends State<MedicalJourneyScreen> {
  int _currentStep = 0;
  MedicalCenter? _selectedMedicalCenter;
  Accommodation? _selectedAccommodation;
  TransportService? _selectedTransport;
  
  List<MedicalCenter> _medicalCenters = [];
  List<Accommodation> _nearbyAccommodations = [];
  List<TransportService> _transportServices = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _medicalCenters = MedicalCenter.getDummyMedicalCenters();
    _transportServices = TransportService.getDummyTransportServices();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _selectMedicalCenter(MedicalCenter center) {
    setState(() {
      _selectedMedicalCenter = center;
    });
    _findNearbyAccommodations();
    _nextStep();
  }

  void _findNearbyAccommodations() {
    if (_selectedMedicalCenter == null) return;
    
    setState(() {
      _nearbyAccommodations = Accommodation.getDummyAccommodations()
          .where((acc) => acc.city == _selectedMedicalCenter!.city)
          .toList();
      
      // Sort by distance
      _nearbyAccommodations.sort((a, b) => 
        a.distanceToHospital.compareTo(b.distanceToHospital));
    });
  }

  void _selectAccommodation(Accommodation accommodation) {
    setState(() {
      _selectedAccommodation = accommodation;
    });
    _nextStep();
  }

  void _selectTransport(TransportService transport) {
    setState(() {
      _selectedTransport = transport;
    });
    _completeJourney();
  }

  void _skipTransport() {
    _completeJourney();
  }

  void _completeJourney() {
    // Show completion dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تم إكمال رحلتك الطبية!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('المركز الطبي: ${_selectedMedicalCenter?.name}'),
            if (_selectedAccommodation != null)
              Text('مكان الإقامة: ${_selectedAccommodation?.name}'),
            if (_selectedTransport != null)
              Text('وسيلة النقل: ${_selectedTransport?.name}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to dashboard
            },
            child: const Text('موافق'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'رحلتك الطبية',
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
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
            ),
            child: _buildProgressIndicator(),
          ),
          // Content
          Expanded(
            child: _buildCurrentStepContent(),
          ),
          // Navigation buttons
          if (_currentStep > 0) _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      children: [
        _buildProgressStep(0, 'اختر المركز الطبي', Icons.local_hospital),
        _buildProgressLine(0),
        _buildProgressStep(1, 'احجز الإقامة', Icons.hotel),
        _buildProgressLine(1),
        _buildProgressStep(2, 'النقل (اختياري)', Icons.directions_car),
      ],
    );
  }

  Widget _buildProgressStep(int step, String title, IconData icon) {
    final isActive = step <= _currentStep;
    final isCompleted = step < _currentStep;
    
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isActive ? const Color(0xFF667EEA) : Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.white : Colors.white70,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLine(int step) {
    final isCompleted = step < _currentStep;
    
    return Container(
      width: 30,
      height: 2,
      margin: const EdgeInsets.only(bottom: 30),
      color: isCompleted ? Colors.white : Colors.white.withOpacity(0.3),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildMedicalCenterSelection();
      case 1:
        return _buildAccommodationSelection();
      case 2:
        return _buildTransportSelection();
      default:
        return Container();
    }
  }

  Widget _buildMedicalCenterSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'اختر المركز الطبي',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر المركز الطبي الذي ستتلقى فيه العلاج',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _medicalCenters.length,
              itemBuilder: (context, index) {
                return _buildMedicalCenterCard(_medicalCenters[index]);
              },
            ),
          ),
        ],
      ),
    );
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
            Text('${center.city}, ${center.wilaya}'),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFB800), size: 16),
                const SizedBox(width: 4),
                Text('${center.rating} (${center.reviewCount} تقييم)'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectMedicalCenter(center),
      ),
    );
  }

  Widget _buildAccommodationSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'أماكن الإقامة القريبة من ${_selectedMedicalCenter?.name}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر مكان إقامة مريح بالقرب من المركز الطبي',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _nearbyAccommodations.length,
              itemBuilder: (context, index) {
                return _buildAccommodationCard(_nearbyAccommodations[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccommodationCard(Accommodation accommodation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        '${accommodation.distanceToHospital} كم من المستشفى',
                        style: const TextStyle(
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
                    Text('${accommodation.rating}'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _selectAccommodation(accommodation),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF667EEA),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'اختر هذا المكان',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransportSelection() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'وسائل النقل (اختياري)',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'اختر وسيلة نقل أو تخط هذه الخطوة',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _skipTransport,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF9CA3AF),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'تخط هذه الخطوة',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'أو اختر وسيلة نقل:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: _transportServices.length,
              itemBuilder: (context, index) {
                return _buildTransportCard(_transportServices[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportCard(TransportService transport) {
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
        title: Text(transport.name),
        subtitle: Text('السائق: ${transport.driverName}'),
        trailing: ElevatedButton(
          onPressed: () => _selectTransport(transport),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF667EEA),
          ),
          child: const Text(
            'اختر',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Color(0xFF667EEA)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'السابق',
                style: TextStyle(
                  color: Color(0xFF667EEA),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
