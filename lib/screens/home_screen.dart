import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E5F5), // Light purple
              Color(0xFFE8F5E8), // Light blue-green
              Color(0xFFFCE4EC), // Light pink
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
            child: Column(
              children: [
                // Top spacing
                const Spacer(flex: 2),

                // Logo and Title Section
                Column(
                  children: [
                    // App Logo/Icon
                    Container(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.width * 0.3,
                      constraints: const BoxConstraints(
                        minWidth: 100,
                        maxWidth: 150,
                        minHeight: 100,
                        maxHeight: 150,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF1976D2), // Darker Blue
                            Color(0xFF9C27B0), // Purple
                            Color(0xFFE91E63), // Pink
                          ],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            offset: const Offset(0, 8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.local_hospital,
                        size: MediaQuery.of(context).size.width * 0.15,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // App Name with Gradient Text
                    ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [
                          Color(0xFF1976D2), // Darker Blue
                          Color(0xFF9C27B0), // Purple
                          Color(0xFFE91E63), // Pink
                        ],
                      ).createShader(bounds),
                      child: Text(
                        'راحتي للرعاية الصحية',
                        style: TextStyle(
                          fontSize: (MediaQuery.of(context).size.width * 0.09)
                              .clamp(24.0, 40.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Welcome message
                    Text(
                      'مرحباً بك في رفيقك الصحي',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF424242),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    // Subtitle
                    Text(
                      'ابدأ بإنشاء حساب أو تسجيل الدخول',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width * 0.04,
                        color: Color(0xFF757575),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // Buttons Section
                Column(
                  children: [
                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF1976D2), // Darker Blue
                              Color(0xFF9C27B0), // Purple
                              Color(0xFFE91E63), // Pink
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(
                                0xFF9C27B0,
                              ).withValues(alpha: 0.3),
                              offset: const Offset(0, 4),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'تسجيل الدخول',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.07,
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFF9C27B0),
                            width: 2,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.9),
                        ),
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              Color(0xFF1976D2), // Darker Blue
                              Color(0xFF9C27B0), // Purple
                              Color(0xFFE91E63), // Pink
                            ],
                          ).createShader(bounds),
                          child: Text(
                            'إنشاء حساب',
                            style: TextStyle(
                              fontSize:
                                  MediaQuery.of(context).size.width * 0.04,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Features preview
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF9C27B0).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildFeatureItem(Icons.luggage, 'النقل'),
                          _buildFeatureItem(Icons.schedule, 'المواعيد'),
                          _buildFeatureItem(
                            Icons.medical_services,
                            'الاستشارات',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 1),

                // Footer text
                Text(
                  '© 2024 راحتي للرعاية الصحية. جميع الحقوق محفوظة.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF757575).withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: const Color(0xFF9C27B0), size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF757575),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
