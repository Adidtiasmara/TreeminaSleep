import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';
import 'register_page.dart';
import 'main_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    await Future.delayed(const Duration(milliseconds: 400));

    final user = StorageService.getUser();
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Akun tidak ditemukan. Silakan register terlebih dahulu.';
      });
      return;
    }

    if (user.email.toLowerCase() != _emailCtrl.text.trim().toLowerCase() ||
        user.password != _passwordCtrl.text) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Email atau password salah.';
      });
      return;
    }

    await StorageService.setLoggedIn(true);
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainPage()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark
        ? AppColors.backgroundDark
        : AppColors.backgroundLight;
    final primaryColor = isDark
        ? AppColors.primaryDark
        : AppColors.primaryLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.textSecondaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                // Logo & App Name
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.eco_rounded, color: primaryColor, size: 38),
                ),
                const SizedBox(height: 16),
                Text(
                  'Treemina Sleep',
                  style: TextStyle(
                    color: primaryColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Better Sleep, Better You',
                  style: TextStyle(color: secondaryColor, fontSize: 14),
                ),
                const SizedBox(height: 48),
                // Email field
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Email tidak boleh kosong';
                    if (!v.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                // Password field
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty)
                      return 'Password tidak boleh kosong';
                    return null;
                  },
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (isDark
                                  ? AppColors.badSleepDark
                                  : AppColors.badSleepLight)
                              .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: isDark
                              ? AppColors.badSleepDark
                              : AppColors.badSleepLight,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.badSleepDark
                                  : AppColors.badSleepLight,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                CustomButton(
                  label: 'Login',
                  onPressed: _login,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Belum punya akun? ',
                      style: TextStyle(color: secondaryColor, fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      ),
                      child: Text(
                        'Daftar di sini',
                        style: TextStyle(
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
