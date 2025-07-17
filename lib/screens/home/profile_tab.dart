import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../medical_records/medical_records_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // En-tête du profil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: RahatiTheme.primaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                // Avatar
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.person,
                      color: RahatiTheme.primaryColor,
                      size: 60,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Nom
                const Text(
                  'John Doe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                // Email
                const Text(
                  'john.doe@example.com',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Bouton d'édition
                ElevatedButton(
                  onPressed: () {
                    // Naviguer vers l'écran d'édition du profil
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: RahatiTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Informations personnelles
          _buildSectionTitle('Personal Information'),
          const SizedBox(height: 15),
          _buildInfoItem(Icons.phone, 'Phone', '+1 234 567 890'),
          _buildInfoItem(Icons.cake, 'Date of Birth', 'January 15, 1985'),
          _buildInfoItem(Icons.bloodtype, 'Blood Type', 'A+'),
          _buildInfoItem(Icons.height, 'Height', '175 cm'),
          _buildInfoItem(Icons.monitor_weight, 'Weight', '70 kg'),
          const SizedBox(height: 30),

          // Paramètres
          _buildSectionTitle('Settings'),
          const SizedBox(height: 15),
          _buildSettingsItem(Icons.notifications, 'Notifications', true),
          _buildSettingsItem(Icons.language, 'Language', false),
          _buildSettingsItem(Icons.dark_mode, 'Dark Mode', false),
          _buildSettingsItem(Icons.security, 'Privacy & Security', false),
          const SizedBox(height: 30),

          // Autres options
          _buildSectionTitle('Other'),
          const SizedBox(height: 15),
          _buildMenuItem(
            Icons.medical_services,
            'Health Records',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MedicalRecordsScreen()),
              );
            },
          ),
          _buildMenuItem(Icons.help, 'Help & Support'),
          _buildMenuItem(Icons.info, 'About Us'),
          _buildMenuItem(Icons.star, 'Rate Us'),
          _buildMenuItem(Icons.logout, 'Logout', isLogout: true),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: RahatiTheme.textColor,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: RahatiTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 16,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: RahatiTheme.lightTextColor,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, bool hasSwitch) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: RahatiTheme.primaryColor,
            size: 20,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: RahatiTheme.textColor,
                fontSize: 16,
              ),
            ),
          ),
          if (hasSwitch)
            Switch(
              value: true,
              onChanged: (value) {},
              activeColor: RahatiTheme.primaryColor,
            )
          else
            const Icon(
              Icons.arrow_forward_ios,
              color: RahatiTheme.lightTextColor,
              size: 16,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, {bool isLogout = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isLogout ? Colors.red : RahatiTheme.primaryColor,
              size: 20,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isLogout ? Colors.red : RahatiTheme.textColor,
                  fontSize: 16,
                ),
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
