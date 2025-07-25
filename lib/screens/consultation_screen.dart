import 'package:flutter/material.dart';
import '../models/consultation_models.dart';

class ConsultationScreen extends StatefulWidget {
  const ConsultationScreen({super.key});

  @override
  State<ConsultationScreen> createState() => _ConsultationScreenState();
}

class _ConsultationScreenState extends State<ConsultationScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Doctor> _allDoctors = [];
  List<Doctor> _filteredDoctors = [];
  List<MedicalSpecialty> _specialties = [];
  String? _selectedSpecialty;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _allDoctors = Doctor.getDummyDoctors();
    _filteredDoctors = _allDoctors;
    _specialties = MedicalSpecialty.getAllSpecialties();
  }

  void _filterDoctors() {
    setState(() {
      _filteredDoctors = _allDoctors.where((doctor) {
        final searchText = _searchController.text.toLowerCase();
        final matchesSearch = searchText.isEmpty ||
            doctor.name.toLowerCase().contains(searchText) ||
            doctor.specialty.toLowerCase().contains(searchText) ||
            doctor.location.toLowerCase().contains(searchText);

        final matchesSpecialty = _selectedSpecialty == null ||
            doctor.specialty.contains(_selectedSpecialty!);

        return matchesSearch && matchesSpecialty;
      }).toList();
    });
  }

  String _getConsultationTypeText(ConsultationType type) {
    switch (type) {
      case ConsultationType.inPerson:
        return 'حضوري';
      case ConsultationType.online:
        return 'عبر الإنترنت';
      case ConsultationType.both:
        return 'حضوري وعبر الإنترنت';
    }
  }

  String _getFeeRangeText(ConsultationFee fee) {
    switch (fee) {
      case ConsultationFee.affordable:
        return '2000-4000 دج';
      case ConsultationFee.medium:
        return '4000-8000 دج';
      case ConsultationFee.premium:
        return '8000+ دج';
    }
  }

  Color _getFeeColor(ConsultationFee fee) {
    switch (fee) {
      case ConsultationFee.affordable:
        return const Color(0xFF4CAF50);
      case ConsultationFee.medium:
        return const Color(0xFF2196F3);
      case ConsultationFee.premium:
        return const Color(0xFF9C27B0);
    }
  }

  Color _getConsultationTypeColor(ConsultationType type) {
    switch (type) {
      case ConsultationType.inPerson:
        return const Color(0xFF00695C);
      case ConsultationType.online:
        return const Color(0xFF1976D2);
      case ConsultationType.both:
        return const Color(0xFF7B1FA2);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F8E9), // Very light green background
      appBar: AppBar(
        title: const Text(
          'حجز استشارة طبية',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF00695C), // Teal green
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Professional header section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF00695C), // Teal green
                  Color(0xFF26A69A), // Light teal
                ],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
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
                        color: Colors.black.withOpacity(0.08),
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
                          onChanged: (value) => _filterDoctors(),
                          decoration: const InputDecoration(
                            hintText: 'ابحث عن طبيب أو تخصص...',
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
                // Medical consultation info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medical_services_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'احجز استشارة مع أفضل الأطباء المتخصصين',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Specialties filter
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _specialties.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildSpecialtyChip('جميع التخصصات', null),
                        );
                      }
                      final specialty = _specialties[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: _buildSpecialtyChip(specialty.arabicName, specialty.arabicName),
                      );
                    },
                  ),
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
                    'تم العثور على ${_filteredDoctors.length} طبيب',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00695C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: _filteredDoctors.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: _filteredDoctors.length,
                            itemBuilder: (context, index) {
                              return _buildDoctorCard(_filteredDoctors[index]);
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

  Widget _buildSpecialtyChip(String text, String? value) {
    final isSelected = _selectedSpecialty == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSpecialty = value;
        });
        _filterDoctors();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? const Color(0xFF00695C) : Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00695C).withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Doctor header
            Row(
              children: [
                // Doctor avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF26A69A),
                        Color(0xFF00695C),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                // Doctor info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00695C),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.specialty,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF757575),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 14,
                            color: Color(0xFF757575),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              doctor.location,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF757575),
                              ),
                            ),
                          ),
                        ],
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
                          size: 16,
                          color: Color(0xFFFFB300),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor.rating}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF00695C),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: doctor.isAvailable 
                            ? const Color(0xFF4CAF50) 
                            : const Color(0xFFFF5722),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        doctor.isAvailable ? 'متاح' : 'مشغول',
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
            const SizedBox(height: 16),
            // Experience and consultation type
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00695C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${doctor.experienceYears} سنة خبرة',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF00695C),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getConsultationTypeColor(doctor.consultationType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getConsultationTypeText(doctor.consultationType),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getConsultationTypeColor(doctor.consultationType),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getFeeColor(doctor.fee).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _getFeeRangeText(doctor.fee),
                    style: TextStyle(
                      fontSize: 11,
                      color: _getFeeColor(doctor.fee),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Languages
            Text(
              'اللغات: ${doctor.languages.join(' • ')}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF757575),
              ),
            ),
            const SizedBox(height: 16),
            // Book button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _onDoctorTap(doctor),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00695C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'احجز استشارة',
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
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Color(0xFFA5D6A7),
          ),
          SizedBox(height: 16),
          Text(
            'لم يتم العثور على أطباء',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF00695C),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'جرب تغيير التخصص أو كلمات البحث',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }

  void _onDoctorTap(Doctor doctor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('حجز استشارة مع ${doctor.name} - قريباً'),
        backgroundColor: const Color(0xFF00695C),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
