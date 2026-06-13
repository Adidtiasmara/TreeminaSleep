import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/sleep_visuals.dart';

class AboutAppPage extends StatelessWidget {
  const AboutAppPage({super.key});

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
    final cardColor = isDark ? AppColors.cardDark : AppColors.cardLight;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'About Aplikasi',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 20,
          ),
        ),
      ),
      body: PageBackdrop(
        isDark: isDark,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(isDark ? .9 : 1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.favorite_rounded,
                        color: primaryColor,
                        size: 25,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Treemina Sleep',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Treemina Sleep adalah aplikasi pencatat dan pengelola '
                      'rutinitas tidur yang membantu pengguna mengatur jadwal '
                      'tidur, memantau durasi tidur, dan melihat laporan '
                      'kualitas tidur.',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(isDark ? .9 : 1),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color:
                        isDark ? AppColors.dividerDark : AppColors.dividerLight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isDark ? 0.22 : 0.04),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disusun oleh Kelompok 3',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Dengan bimbingan Edi Purwanto, S.Kep., Ns., M.Ng.',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Serta didukung oleh seluruh anggota Kelompok 3:',
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Muhammad Amrul Haq, Indira Kirania Putri, Devita '
                      'Valentina R., Salman Rifqi Amrulsyah, Annisa Putri '
                      'Riani, Nasywa Khaila Zahrani, Nabila Naya Nirwasita, '
                      'Shela Nala Ristia, Tri Supartini, Intania Salwa Putri, '
                      'Fieka Mahendry Nur A., Naufal Asyrof Al Hazmi, dan '
                      'Fetrisia Adinda Delo.',
                      style: TextStyle(
                        color: secondaryColor,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
            ],
          ),
        ),
      ),
    );
  }
}
