import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordPage({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailCtrl = TextEditingController();
  final _tokenCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();
  final _emailFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  bool _tokenSent = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _emailCtrl.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _tokenCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendToken() async {
    if (!_emailFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    if (!SupabaseService.isConfigured) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Konfigurasi Supabase belum tersedia.';
      });
      return;
    }

    try {
      await SupabaseService.sendPasswordResetToken(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _tokenSent = true;
        _successMessage =
            'Token reset sudah dikirim ke email. Masukkan token dan password baru.';
      });
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal mengirim token. Periksa email dan koneksi.';
      });
    }
  }

  Future<void> _resetPassword() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      await SupabaseService.resetPasswordWithToken(
        email: _emailCtrl.text.trim(),
        token: _tokenCtrl.text.trim(),
        newPassword: _passwordCtrl.text,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password berhasil direset. Silakan login kembali.'),
        ),
      );
      Navigator.of(context).pop();
    } on AuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Reset password gagal. Periksa token dan coba lagi.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textColor = isDark ? AppColors.textDark : AppColors.textLight;
    final secondaryColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;
    final primaryColor =
        isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Lupa Password',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_reset_rounded,
                  color: primaryColor,
                  size: 34,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Reset password dengan token email',
                style: TextStyle(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Masukkan email akunmu. Setelah token diterima, isi token dan password baru.',
                style: TextStyle(
                  color: secondaryColor,
                  fontSize: 13.5,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 26),
              Form(
                key: _emailFormKey,
                child: TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                  enabled: !_tokenSent,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!value.contains('@')) return 'Email tidak valid';
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 14),
              if (!_tokenSent)
                CustomButton(
                  label: 'Kirim Token Reset',
                  onPressed: _sendToken,
                  isLoading: _isLoading,
                )
              else
                Form(
                  key: _resetFormKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _tokenCtrl,
                        keyboardType: TextInputType.number,
                        style: TextStyle(color: textColor),
                        decoration: const InputDecoration(
                          labelText: 'Token Reset',
                          prefixIcon: Icon(Icons.pin_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Token tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscurePassword,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: const Icon(Icons.lock_outlined),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password baru tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPasswordCtrl,
                        obscureText: _obscureConfirmPassword,
                        style: TextStyle(color: textColor),
                        decoration: InputDecoration(
                          labelText: 'Konfirmasi Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscureConfirmPassword =
                                  !_obscureConfirmPassword,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordCtrl.text) {
                            return 'Konfirmasi password tidak sama';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        label: 'Reset Password',
                        onPressed: _resetPassword,
                        isLoading: _isLoading,
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                setState(() {
                                  _tokenSent = false;
                                  _tokenCtrl.clear();
                                  _passwordCtrl.clear();
                                  _confirmPasswordCtrl.clear();
                                  _errorMessage = null;
                                  _successMessage = null;
                                });
                              },
                        child: const Text('Ganti email'),
                      ),
                    ],
                  ),
                ),
              if (_successMessage != null) ...[
                const SizedBox(height: 14),
                _MessageBox(
                  message: _successMessage!,
                  color: primaryColor,
                  icon: Icons.check_circle_outline,
                ),
              ],
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                _MessageBox(
                  message: _errorMessage!,
                  color:
                      isDark ? AppColors.badSleepDark : AppColors.badSleepLight,
                  icon: Icons.error_outline,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _MessageBox extends StatelessWidget {
  final String message;
  final Color color;
  final IconData icon;

  const _MessageBox({
    required this.message,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
