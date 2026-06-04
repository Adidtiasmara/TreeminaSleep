import 'dart:async';

import 'package:flutter/material.dart';

import '../services/supabase_service.dart';
import '../utils/app_colors.dart';
import '../widgets/sleep_visuals.dart';
import 'login_page.dart';
import 'main_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 1400), _openNextPage);
  }

  void _openNextPage() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            SupabaseService.isLoggedIn ? const MainPage() : const LoginPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;

    return Scaffold(
      body: SizedBox.expand(
        child: NightScape(
          isDark: isDark,
          child: SafeArea(
            child: SizedBox.expand(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    const Spacer(),
                    Icon(
                      Icons.local_florist_outlined,
                      color: primary,
                      size: 76,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Treemina\nSleep',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.96),
                        fontSize: 42,
                        height: 1.04,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Better Sleep,\nBetter You',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(.86),
                        fontSize: 16,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: 42,
                      height: 42,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: primary,
                        backgroundColor: Colors.white.withOpacity(.14),
                      ),
                    ),
                    const SizedBox(height: 34),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
