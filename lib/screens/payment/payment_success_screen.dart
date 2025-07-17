import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../home/home_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String serviceName;
  final double amount;

  const PaymentSuccessScreen({
    super.key,
    required this.serviceName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône de succès
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: RahatiTheme.primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: RahatiTheme.primaryColor,
                  size: 60,
                ),
              ),
              const SizedBox(height: 30),
              
              // Message de succès
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  color: RahatiTheme.textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'Your payment of \$${amount.toStringAsFixed(2)} for $serviceName has been processed successfully.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: RahatiTheme.lightTextColor,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 40),
              
              // Détails de la transaction
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    _buildTransactionDetail(
                      title: 'Transaction ID',
                      value: 'TXN-${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 10)}',
                    ),
                    const SizedBox(height: 15),
                    _buildTransactionDetail(
                      title: 'Date',
                      value: _formatDate(DateTime.now()),
                    ),
                    const SizedBox(height: 15),
                    _buildTransactionDetail(
                      title: 'Payment Method',
                      value: 'Credit Card',
                    ),
                    const SizedBox(height: 15),
                    _buildTransactionDetail(
                      title: 'Amount',
                      value: '\$${amount.toStringAsFixed(2)}',
                      isHighlighted: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              
              // Boutons d'action
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomeScreen()),
                      (route) => false,
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
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Naviguer vers l'écran des rendez-vous
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: RahatiTheme.primaryColor,
                    side: const BorderSide(color: RahatiTheme.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'View Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionDetail({
    required String title,
    required String value,
    bool isHighlighted = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: RahatiTheme.lightTextColor,
            fontSize: 16,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isHighlighted ? RahatiTheme.primaryColor : RahatiTheme.textColor,
            fontSize: 16,
            fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
