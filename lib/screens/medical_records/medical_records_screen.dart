import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'record_details_screen.dart';

class MedicalRecordsScreen extends StatelessWidget {
  const MedicalRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: RahatiTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Health Records',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            const Text(
              'Your Medical History',
              style: TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Access and manage your health records',
              style: TextStyle(
                color: RahatiTheme.lightTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            
            // Résumé des dossiers
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: RahatiTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildRecordSummary(
                    icon: Icons.folder,
                    count: 12,
                    title: 'Records',
                  ),
                  _buildRecordSummary(
                    icon: Icons.medication,
                    count: 5,
                    title: 'Medications',
                  ),
                  _buildRecordSummary(
                    icon: Icons.science,
                    count: 8,
                    title: 'Lab Tests',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            
            // Dossiers récents
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Records',
                  style: TextStyle(
                    color: RahatiTheme.textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Voir tous les dossiers
                  },
                  child: const Text(
                    'See All',
                    style: TextStyle(
                      color: RahatiTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildRecordItem(
              context,
              title: 'Annual Check-up',
              date: 'May 15, 2023',
              doctor: 'Dr. Sarah Johnson',
              type: 'General',
            ),
            _buildRecordItem(
              context,
              title: 'Blood Test Results',
              date: 'April 28, 2023',
              doctor: 'Dr. Michael Chen',
              type: 'Laboratory',
            ),
            _buildRecordItem(
              context,
              title: 'Cardiology Consultation',
              date: 'March 10, 2023',
              doctor: 'Dr. Robert Smith',
              type: 'Specialist',
            ),
            const SizedBox(height: 30),
            
            // Médicaments actuels
            const Text(
              'Current Medications',
              style: TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildMedicationItem(
              name: 'Amoxicillin',
              dosage: '500mg',
              frequency: 'Twice daily',
              endDate: 'May 25, 2023',
            ),
            _buildMedicationItem(
              name: 'Lisinopril',
              dosage: '10mg',
              frequency: 'Once daily',
              endDate: 'Ongoing',
            ),
            const SizedBox(height: 30),
            
            // Allergies et conditions
            const Text(
              'Allergies & Conditions',
              style: TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _buildAllergyItem(
              name: 'Penicillin',
              severity: 'High',
              color: Colors.red,
            ),
            _buildAllergyItem(
              name: 'Seasonal Allergies',
              severity: 'Moderate',
              color: Colors.orange,
            ),
            _buildAllergyItem(
              name: 'Lactose Intolerance',
              severity: 'Low',
              color: Colors.yellow.shade700,
            ),
            const SizedBox(height: 30),
            
            // Bouton pour ajouter un nouveau dossier
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Ajouter un nouveau dossier
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RahatiTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Upload New Record',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordSummary({
    required IconData icon,
    required int count,
    required String title,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color: RahatiTheme.primaryColor,
            size: 30,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          count.toString(),
          style: const TextStyle(
            color: RahatiTheme.textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: const TextStyle(
            color: RahatiTheme.lightTextColor,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildRecordItem(
    BuildContext context, {
    required String title,
    required String date,
    required String doctor,
    required String type,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => RecordDetailsScreen(
              title: title,
              date: date,
              doctor: doctor,
              type: type,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: RahatiTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.description,
                color: RahatiTheme.primaryColor,
                size: 25,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$doctor • $date',
                    style: const TextStyle(
                      color: RahatiTheme.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: RahatiTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                type,
                style: const TextStyle(
                  color: RahatiTheme.primaryColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicationItem({
    required String name,
    required String dosage,
    required String frequency,
    required String endDate,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.medication,
              color: Colors.green,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: RahatiTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '$dosage • $frequency',
                  style: const TextStyle(
                    color: RahatiTheme.lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'Until: $endDate',
            style: const TextStyle(
              color: RahatiTheme.primaryColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllergyItem({
    required String name,
    required String severity,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.warning,
              color: color,
              size: 25,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: RahatiTheme.textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Severity: $severity',
                  style: const TextStyle(
                    color: RahatiTheme.lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
