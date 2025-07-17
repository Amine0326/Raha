import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../payment/payment_screen.dart';

class ServiceDetailsScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String description;

  const ServiceDetailsScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: RahatiTheme.primaryColor,
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête avec icône
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: RahatiTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      icon,
                      color: color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenu principal
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'About This Service',
                    style: TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed euismod, nunc vel tincidunt lacinia, nisl nisl aliquam nisl, vel aliquam nisl nisl sit amet nisl. Sed euismod, nunc vel tincidunt lacinia, nisl nisl aliquam nisl, vel aliquam nisl nisl sit amet nisl.',
                    style: TextStyle(
                      color: RahatiTheme.lightTextColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Avantages
                  const Text(
                    'Benefits',
                    style: TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildBenefitItem(
                    icon: Icons.check_circle,
                    text: 'Professional healthcare providers',
                  ),
                  _buildBenefitItem(
                    icon: Icons.check_circle,
                    text: 'Convenient scheduling options',
                  ),
                  _buildBenefitItem(
                    icon: Icons.check_circle,
                    text: 'Affordable pricing plans',
                  ),
                  _buildBenefitItem(
                    icon: Icons.check_circle,
                    text: 'Follow-up care included',
                  ),
                  const SizedBox(height: 25),
                  
                  // Options de service
                  const Text(
                    'Service Options',
                    style: TextStyle(
                      color: RahatiTheme.textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildServiceOption(
                    title: 'Basic Package',
                    price: '\$50',
                    features: ['Initial consultation', 'Basic assessment', 'Digital report'],
                  ),
                  const SizedBox(height: 15),
                  _buildServiceOption(
                    title: 'Standard Package',
                    price: '\$100',
                    features: ['Comprehensive consultation', 'Detailed assessment', 'Digital report', 'One follow-up session'],
                    isRecommended: true,
                  ),
                  const SizedBox(height: 15),
                  _buildServiceOption(
                    title: 'Premium Package',
                    price: '\$150',
                    features: ['Extended consultation', 'Complete assessment', 'Digital report', 'Three follow-up sessions', 'Priority scheduling'],
                  ),
                  const SizedBox(height: 30),
                  
                  // Bouton de réservation
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PaymentScreen(
                              serviceName: title,
                              amount: 100.0,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: RahatiTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        'Book Now',
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
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({required IconData icon, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            color: RahatiTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceOption({
    required String title,
    required String price,
    required List<String> features,
    bool isRecommended = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isRecommended ? RahatiTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isRecommended ? RahatiTheme.primaryColor : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isRecommended ? RahatiTheme.primaryColor : RahatiTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                price,
                style: TextStyle(
                  color: isRecommended ? RahatiTheme.primaryColor : RahatiTheme.textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (isRecommended)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: RahatiTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Recommended',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 10),
          ...features.map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  color: isRecommended ? RahatiTheme.primaryColor : Colors.grey,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  feature,
                  style: TextStyle(
                    color: isRecommended ? RahatiTheme.textColor : RahatiTheme.lightTextColor,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
