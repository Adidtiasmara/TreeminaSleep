import 'dart:math';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class NightScape extends StatelessWidget {
  final bool isDark;
  final Widget? child;

  const NightScape({super.key, required this.isDark, this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? const [
                  AppColors.nightTop,
                  Color(0xFF101B3D),
                  AppColors.nightBottom,
                ]
              : const [
                  Color(0xFF064B3D),
                  Color(0xFF0D6B50),
                  Color(0xFFEFF6EC),
                ],
        ),
      ),
      child: CustomPaint(
        painter: _NightScapePainter(isDark: isDark),
        child: child,
      ),
    );
  }
}

class SleepHeroArt extends StatelessWidget {
  final bool isDark;
  final double height;
  final bool awake;

  const SleepHeroArt({
    super.key,
    required this.isDark,
    this.height = 148,
    this.awake = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SleepHeroPainter(isDark: isDark, awake: awake),
      ),
    );
  }
}

class PageBackdrop extends StatelessWidget {
  final bool isDark;
  final Widget child;

  const PageBackdrop({super.key, required this.isDark, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? const [
                        AppColors.backgroundDark,
                        Color(0xFF101D3D),
                        AppColors.backgroundDark,
                      ]
                    : const [
                        AppColors.backgroundLight,
                        Color(0xFFFFFEFB),
                        AppColors.backgroundLight,
                      ],
              ),
            ),
          ),
        ),
        if (isDark)
          const Positioned(
            top: -130,
            right: -120,
            child: _SoftGlow(color: Color(0xFF364C8A), size: 260),
          ),
        if (!isDark)
          const Positioned(
            top: -100,
            right: -110,
            child: _SoftGlow(color: Color(0xFFDDEFE2), size: 230),
          ),
        child,
      ],
    );
  }
}

class SleepyBottomArt extends StatelessWidget {
  final bool isDark;

  const SleepyBottomArt({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      width: double.infinity,
      child: CustomPaint(painter: _SleepyBottomPainter(isDark: isDark)),
    );
  }
}

class _SoftGlow extends StatelessWidget {
  final Color color;
  final double size;

  const _SoftGlow({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(.5), color.withOpacity(0)],
        ),
      ),
    );
  }
}

class _NightScapePainter extends CustomPainter {
  final bool isDark;

  const _NightScapePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final starPaint = Paint()
      ..color = Colors.white.withOpacity(isDark ? 0.88 : 0.78)
      ..style = PaintingStyle.fill;
    final points = [
      Offset(size.width * .10, size.height * .07),
      Offset(size.width * .25, size.height * .14),
      Offset(size.width * .47, size.height * .09),
      Offset(size.width * .67, size.height * .18),
      Offset(size.width * .88, size.height * .10),
      Offset(size.width * .16, size.height * .31),
      Offset(size.width * .80, size.height * .32),
      Offset(size.width * .92, size.height * .45),
    ];
    for (var i = 0; i < points.length; i++) {
      canvas.drawCircle(points[i], i.isEven ? 1.4 : 1.0, starPaint);
    }

    final moonPaint = Paint()..color = const Color(0xFFFFF0B8);
    final moonCenter = Offset(size.width * .28, size.height * .14);
    canvas.drawCircle(moonCenter, size.width * .07, moonPaint);
    canvas.drawCircle(
      moonCenter.translate(size.width * .035, -size.width * .02),
      size.width * .07,
      Paint()..color = isDark ? AppColors.nightTop : const Color(0xFF064B3D),
    );

    _drawHills(canvas, size, 0.72, isDark ? 0xFF182A58 : 0xFF266E59);
    _drawHills(canvas, size, 0.82, isDark ? 0xFF0D1C43 : 0xFF0F4B3C);

    final treePaint = Paint()
      ..color = isDark ? const Color(0xFF081934) : const Color(0xFF06362D);
    for (final x in [size.width * .14, size.width * .78, size.width * .88]) {
      final base = size.height * .88;
      final path = Path()
        ..moveTo(x, base - 74)
        ..lineTo(x - 28, base)
        ..lineTo(x + 28, base)
        ..close();
      canvas.drawPath(path, treePaint);
      canvas.drawRect(
        Rect.fromCenter(center: Offset(x, base + 7), width: 8, height: 24),
        treePaint,
      );
    }
  }

  void _drawHills(Canvas canvas, Size size, double y, int color) {
    final paint = Paint()..color = Color(color).withOpacity(isDark ? .88 : .72);
    final path = Path()..moveTo(0, size.height);
    path.lineTo(0, size.height * y);
    path.quadraticBezierTo(
      size.width * .22,
      size.height * (y - .11),
      size.width * .46,
      size.height * y,
    );
    path.quadraticBezierTo(
      size.width * .70,
      size.height * (y + .10),
      size.width,
      size.height * (y - .05),
    );
    path.lineTo(size.width, size.height);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _NightScapePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

class _SleepHeroPainter extends CustomPainter {
  final bool isDark;
  final bool awake;

  const _SleepHeroPainter({required this.isDark, required this.awake});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..isAntiAlias = true;

    paint.color = isDark
        ? const Color(0xFF081633).withOpacity(.52)
        : const Color(0xFFEAF5ED);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .06, h * .12, w * .86, h * .70),
        const Radius.circular(22),
      ),
      paint,
    );

    if (isDark) {
      paint.color = const Color(0xFFFFD875).withOpacity(.9);
      final path = Path()
        ..moveTo(w * .86, h * .04)
        ..lineTo(w * .96, h * .74)
        ..lineTo(w * .73, h * .66)
        ..close();
      canvas.drawPath(path, paint);
    }

    paint.color = isDark ? const Color(0xFF2B3766) : const Color(0xFFD6E4EF);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .18, h * .45, w * .56, h * .26),
        const Radius.circular(14),
      ),
      paint,
    );
    paint.color = const Color(0xFFE8EDF7);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .24, h * .34, w * .23, h * .22),
        const Radius.circular(12),
      ),
      paint,
    );

    paint.color = const Color(0xFFF3B18B);
    canvas.drawCircle(Offset(w * .46, h * .39), h * .085, paint);
    paint.color = const Color(0xFF162747);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * .45, h * .35), radius: h * .095),
      pi,
      pi,
      false,
      paint..strokeWidth = 10,
    );

    final armPaint = Paint()
      ..color = const Color(0xFFF3B18B)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    if (awake) {
      canvas.drawLine(
          Offset(w * .42, h * .45), Offset(w * .31, h * .23), armPaint);
      canvas.drawLine(
          Offset(w * .51, h * .45), Offset(w * .64, h * .24), armPaint);
    } else {
      canvas.drawLine(
          Offset(w * .43, h * .48), Offset(w * .56, h * .53), armPaint);
    }

    paint.color = awake ? const Color(0xFF65B987) : const Color(0xFF244E8D);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .32, h * .45, w * .28, h * .17),
        const Radius.circular(18),
      ),
      paint,
    );

    paint.color = const Color(0xFF335AA4);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .27, h * .55, w * .43, h * .20),
        const Radius.circular(18),
      ),
      paint,
    );

    paint.color = isDark ? const Color(0xFF2B7A5B) : const Color(0xFF4DAE7E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .75, h * .43, w * .04, h * .32),
        const Radius.circular(8),
      ),
      paint,
    );
    canvas.drawOval(Rect.fromLTWH(w * .70, h * .48, w * .08, h * .11), paint);
    canvas.drawOval(Rect.fromLTWH(w * .78, h * .36, w * .08, h * .12), paint);
  }

  @override
  bool shouldRepaint(covariant _SleepHeroPainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.awake != awake;
  }
}

class _SleepyBottomPainter extends CustomPainter {
  final bool isDark;

  const _SleepyBottomPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..isAntiAlias = true;

    paint.color = isDark ? const Color(0xFF111F45) : const Color(0xFFDCEAF0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .06, h * .42, w * .88, h * .42),
        const Radius.circular(24),
      ),
      paint,
    );

    paint.color = isDark ? const Color(0xFF283968) : const Color(0xFFF2F5F6);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .19, h * .22, w * .24, h * .30),
        const Radius.circular(18),
      ),
      paint,
    );

    paint.color = const Color(0xFFF1B28D);
    canvas.drawCircle(Offset(w * .46, h * .34), h * .07, paint);
    paint.color = const Color(0xFF13213E);
    canvas.drawArc(
      Rect.fromCircle(center: Offset(w * .45, h * .31), radius: h * .08),
      3.1,
      3.2,
      false,
      paint..strokeWidth = 8,
    );

    paint.color = isDark ? const Color(0xFF305AA4) : const Color(0xFF2F5C96);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .23, h * .43, w * .55, h * .28),
        const Radius.circular(24),
      ),
      paint,
    );

    paint.color = isDark ? AppColors.primaryDark : AppColors.secondaryLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * .77, h * .38, w * .04, h * .42),
        const Radius.circular(10),
      ),
      paint,
    );
    canvas.drawOval(Rect.fromLTWH(w * .72, h * .42, w * .08, h * .11), paint);
    canvas.drawOval(Rect.fromLTWH(w * .80, h * .27, w * .08, h * .13), paint);

    final textPaint = TextPainter(
      text: TextSpan(
        text: 'zZz',
        style: TextStyle(
          color: isDark
              ? Colors.white.withOpacity(.32)
              : AppColors.primaryLight.withOpacity(.28),
          fontSize: 26,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPaint.paint(canvas, Offset(w * .62, h * .12));
  }

  @override
  bool shouldRepaint(covariant _SleepyBottomPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
