import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../theme/theme_provider.dart' as theme_provider;
import 'login_screen.dart';
import '../services/authservice.dart';
import '../services/apiservice.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _companionNameController = TextEditingController();
  final _companionPhoneController = TextEditingController();


  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _companionNameController.dispose();
    _companionPhoneController.dispose();
    super.dispose();
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    if (value.trim().length < 2) {
      return 'يجب أن يكون الاسم على الأقل حرفين';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'يرجى إدخال عنوان بريد إلكتروني صحيح';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.length < 8) {
      return 'يجب أن تكون كلمة المرور على الأقل 8 أحرف';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != _passwordController.text) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length < 10) {
      return 'يرجى إدخال رقم هاتف صحيح';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'العنوان مطلوب';
    }
    if (value.trim().length < 10) {
      return 'يرجى إدخال عنوان كامل';
    }
    return null;
  }

  String? _validateCompanionName(String? value) {
    // Companion name is optional, but if provided, should be valid
    if (value != null && value.isNotEmpty && value.trim().length < 2) {
      return 'يجب أن يكون اسم المرافق على الأقل حرفين';
    }
    return null;
  }

  String? _validateCompanionPhone(String? value) {
    // Companion phone is optional, but if provided, should be valid
    if (value != null && value.isNotEmpty) {
      final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
      if (digitsOnly.length < 10) {
        return 'يرجى إدخال رقم هاتف صحيح للمرافق';
      }
    }
    return null;
  }

  Future<void> _handleSignup() async {
    if (!(_formKey.currentState!.validate() && _acceptTerms)) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('يرجى قبول الشروط والأحكام'),
            backgroundColor: Color(0xFFD32F2F),
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('➡️ بدء عملية إنشاء الحساب');

    try {
      final result = await AuthService().register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        caregiverName: _companionNameController.text.trim(),
        caregiverPhone: _companionPhoneController.text.trim(),
      );

      print('✅ تم إنشاء الحساب للمستخدم: ${result.userId?.toString() ?? 'غير معروف'}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم التسجيل بنجاح!'),
          backgroundColor: const Color(0xFF9C27B0),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // المستخدم أصبح مسجلاً تلقائياً (لدينا توكن)
      Navigator.pushReplacementNamed(context, '/dashboard');
    } on ApiException catch (e) {
      print('🚫 خطأ API أثناء التسجيل: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          backgroundColor: const Color(0xFFD32F2F),
        ),
      );
    } catch (e) {
      print('❗ خطأ غير متوقع أثناء التسجيل: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('حدث خطأ أثناء إنشاء الحساب. يرجى المحاولة لاحقاً.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<theme_provider.ThemeProvider>(
      builder: (context, themeProvider, child) {
        final isDark = themeProvider.isDarkMode;

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              // Navigate back to login screen when back button is pressed
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          },
          child: Scaffold(
            backgroundColor: AppTheme.getBackgroundColor(isDark),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppTheme.getBackgroundColor(isDark),
                          AppTheme.getSurfaceColor(isDark),
                          AppTheme.getCardColor(isDark),
                        ],
                      )
                    : const LinearGradient(
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
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: MediaQuery.of(context).size.width * 0.05,
                    vertical: MediaQuery.of(context).size.height * 0.02,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: MediaQuery.of(context).size.height * 0.85,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.01,
                          ),

                          // Header
                          Center(
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      AppTheme.getAccentGradient(
                                        isDark,
                                      ).createShader(bounds),
                                  child: Text(
                                    'إنشاء حساب',
                                    style: TextStyle(
                                      fontSize:
                                          MediaQuery.of(context).size.width *
                                          0.07,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.005,
                                ),

                                Text(
                                  'انضم إلى راحتي للرعاية الصحية اليوم',
                                  style: TextStyle(
                                    fontSize:
                                        MediaQuery.of(context).size.width *
                                        0.04,
                                    color: AppTheme.getHintColor(isDark),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          // Registration Form
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.of(context).size.width * 0.04,
                              vertical:
                                  MediaQuery.of(context).size.height * 0.02,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.getSurfaceColor(isDark),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(
                                    alpha: isDark ? 0.3 : 0.1,
                                  ),
                                  offset: const Offset(0, 4),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Name Field
                                TextFormField(
                                  controller: _nameController,
                                  textCapitalization: TextCapitalization.words,
                                  validator: _validateName,
                                  decoration: InputDecoration(
                                    labelText: 'الاسم الكامل',
                                    hintText: 'أدخل اسمك الكامل',
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Email Field
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                  decoration: InputDecoration(
                                    labelText: 'عنوان البريد الإلكتروني',
                                    hintText: 'أدخل بريدك الإلكتروني',
                                    prefixIcon: const Icon(
                                      Icons.email_outlined,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Password Field
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  validator: _validatePassword,
                                  decoration: InputDecoration(
                                    labelText: 'كلمة المرور',
                                    hintText: 'أدخل كلمة المرور',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Confirm Password Field
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: !_isConfirmPasswordVisible,
                                  validator: _validateConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: 'تأكيد كلمة المرور',
                                    hintText: 'تأكيد كلمة المرور',
                                    prefixIcon: const Icon(Icons.lock_outline),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _isConfirmPasswordVisible
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _isConfirmPasswordVisible =
                                              !_isConfirmPasswordVisible;
                                        });
                                      },
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Phone Number Field
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhoneNumber,
                                  decoration: InputDecoration(
                                    labelText: 'رقم الهاتف',
                                    hintText: 'أدخل رقم هاتفك',
                                    prefixIcon: const Icon(
                                      Icons.phone_outlined,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Address Field
                                TextFormField(
                                  controller: _addressController,
                                  validator: _validateAddress,
                                  decoration: InputDecoration(
                                    labelText: 'العنوان',
                                    hintText: 'أدخل عنوانك الكامل',
                                    prefixIcon: const Icon(
                                      Icons.location_on_outlined,
                                    ),
                                    alignLabelWithHint: true,
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Companion Name Field
                                TextFormField(
                                  controller: _companionNameController,
                                  textCapitalization: TextCapitalization.words,
                                  validator: _validateCompanionName,
                                  decoration: InputDecoration(
                                    labelText: 'اسم المرافق (اختياري)',
                                    hintText: 'أدخل اسم المرافق',
                                    prefixIcon: const Icon(
                                      Icons.person_add_outlined,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.01,
                                ),

                                // Companion Phone Field
                                TextFormField(
                                  controller: _companionPhoneController,
                                  keyboardType: TextInputType.phone,
                                  validator: _validateCompanionPhone,
                                  decoration: InputDecoration(
                                    labelText: 'رقم هاتف المرافق (اختياري)',
                                    hintText: 'أدخل رقم هاتف المرافق',
                                    prefixIcon: const Icon(
                                      Icons.phone_in_talk_outlined,
                                    ),
                                    filled: true,
                                    fillColor: AppTheme.getCardColor(isDark),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide(
                                        color: AppTheme.getPrimaryColor(isDark),
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height *
                                      0.015,
                                ),

                                // Terms and Conditions Checkbox
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _acceptTerms,
                                      onChanged: (value) {
                                        setState(() {
                                          _acceptTerms = value ?? false;
                                        });
                                      },
                                      activeColor: AppTheme.getPrimaryColor(
                                        isDark,
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _acceptTerms = !_acceptTerms;
                                          });
                                        },
                                        child: RichText(
                                          text: TextSpan(
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: AppTheme.getHintColor(
                                                isDark,
                                              ),
                                            ),
                                            children: [
                                              TextSpan(text: 'أوافق على '),
                                              TextSpan(
                                                text: 'الشروط والأحكام',
                                                style: TextStyle(
                                                  color:
                                                      AppTheme.getPrimaryColor(
                                                        isDark,
                                                      ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(text: ' و '),
                                              TextSpan(
                                                text: 'سياسة الخصوصية',
                                                style: TextStyle(
                                                  color:
                                                      AppTheme.getPrimaryColor(
                                                        isDark,
                                                      ),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.02,
                                ),

                                // Register Button
                                SizedBox(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.getAccentGradient(
                                        isDark,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.getPrimaryColor(
                                            isDark,
                                          ).withValues(alpha: 0.3),
                                          offset: const Offset(0, 4),
                                          blurRadius: 12,
                                        ),
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: _isLoading
                                          ? null
                                          : _handleSignup,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: _isLoading
                                          ? const SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Text(
                                              'إنشاء حساب',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                              ),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.02,
                          ),

                          // Login Link
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'لديك حساب؟ ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.getHintColor(isDark),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: ShaderMask(
                                    shaderCallback: (bounds) =>
                                        AppTheme.getPrimaryGradient(
                                          isDark,
                                        ).createShader(bounds),
                                    child: const Text(
                                      'تسجيل الدخول',
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
