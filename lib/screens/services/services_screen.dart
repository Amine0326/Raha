import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'service_details_screen.dart';

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: RahatiTheme.primaryColor,
        elevation: 0,
        title: const Text(
          'Our Services',
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            const Text(
              'Healthcare Services',
              style: TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a service to continue',
              style: TextStyle(
                color: RahatiTheme.lightTextColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 25),
            
            // Services médicaux
            _buildServiceCategory(
              context,
              title: 'Medical Services',
              services: [
                ServiceItem(
                  title: 'Doctor Consultation',
                  icon: Icons.medical_services,
                  color: Colors.blue.shade100,
                  description: 'Consult with our qualified doctors',
                ),
                ServiceItem(
                  title: 'Lab Tests',
                  icon: Icons.science,
                  color: Colors.purple.shade100,
                  description: 'Book laboratory tests and screenings',
                ),
                ServiceItem(
                  title: 'Medications',
                  icon: Icons.medication,
                  color: Colors.green.shade100,
                  description: 'Order prescribed medications',
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Services de bien-être
            _buildServiceCategory(
              context,
              title: 'Wellness Services',
              services: [
                ServiceItem(
                  title: 'Mental Health',
                  icon: Icons.psychology,
                  color: Colors.orange.shade100,
                  description: 'Counseling and therapy sessions',
                ),
                ServiceItem(
                  title: 'Nutrition',
                  icon: Icons.restaurant_menu,
                  color: Colors.teal.shade100,
                  description: 'Dietary advice and meal planning',
                ),
                ServiceItem(
                  title: 'Fitness',
                  icon: Icons.fitness_center,
                  color: Colors.red.shade100,
                  description: 'Exercise programs and physical therapy',
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Services spécialisés
            _buildServiceCategory(
              context,
              title: 'Specialized Care',
              services: [
                ServiceItem(
                  title: 'Pediatrics',
                  icon: Icons.child_care,
                  color: Colors.pink.shade100,
                  description: 'Healthcare for infants and children',
                ),
                ServiceItem(
                  title: 'Geriatrics',
                  icon: Icons.elderly,
                  color: Colors.brown.shade100,
                  description: 'Specialized care for elderly patients',
                ),
                ServiceItem(
                  title: 'Chronic Disease Management',
                  icon: Icons.monitor_heart,
                  color: Colors.indigo.shade100,
                  description: 'Ongoing care for chronic conditions',
                ),
              ],
            ),
            const SizedBox(height: 25),
            
            // Services d'urgence
            _buildServiceCategory(
              context,
              title: 'Emergency Services',
              services: [
                ServiceItem(
                  title: 'Ambulance',
                  icon: Icons.emergency,
                  color: Colors.red.shade100,
                  description: 'Emergency medical transportation',
                ),
                ServiceItem(
                  title: 'Urgent Care',
                  icon: Icons.local_hospital,
                  color: Colors.amber.shade100,
                  description: 'Immediate care for non-life-threatening conditions',
                ),
                ServiceItem(
                  title: 'Telemedicine',
                  icon: Icons.video_call,
                  color: Colors.cyan.shade100,
                  description: 'Virtual consultations with healthcare providers',
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCategory(
    BuildContext context, {
    required String title,
    required List<ServiceItem> services,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: RahatiTheme.textColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: services.length,
          itemBuilder: (context, index) {
            final service = services[index];
            return _buildServiceCard(
              context,
              title: service.title,
              icon: service.icon,
              color: service.color,
              description: service.description,
            );
          },
        ),
      ],
    );
  }

  Widget _buildServiceCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required String description,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ServiceDetailsScreen(
              title: title,
              icon: icon,
              color: color,
              description: description,
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
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 30,
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
                    description,
                    style: const TextStyle(
                      color: RahatiTheme.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: RahatiTheme.lightTextColor,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class ServiceItem {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  ServiceItem({
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });
}
