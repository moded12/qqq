// 📄 lib/screens/splash.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/update_service.dart';
import 'home.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _line1Slide;
  late final Animation<Offset> _line3Slide;

  @override
  void initState() {
    super.initState();

    // فحص وجود تحديث بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateService.checkForUpdate(context);
    });

    // إعداد الرسوم المتحركة
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    // السطر الأول ينزل من الأعلى
    _line1Slide = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.4, curve: Curves.easeOutBack),
      ),
    );

    // السطر الثالث يصعد من الأسفل
    _line3Slide = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOutBack),
      ),
    );

    // ابدأ الرسوم
    _controller.forward();

    // الانتقال للشاشة الرئيسية بعد انتهاء العرض
    Timer(const Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // نختار لون النص تبعًا للوضع الداكن أو الفاتح
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.amberAccent : Colors.white;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF04433D),
              Color(0xFF0F655D),
              Color(0xFF178A7F),
              Color(0xff022925),

            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // أيقونة كبيرة
              Icon(
                Icons.menu_book,
                size: 100,
                color: textColor,
              ),
              const SizedBox(height: 30),

              // السطر الأول: ينزل من الأعلى
              SlideTransition(
                position: _line1Slide,
                child: Text(
                  '📘 شروحات وحلول',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // السطر الأوسط ثابت
              Text(
                '🇴🇲 سلطنة عُمان',
                textAlign: TextAlign.center,
                style: GoogleFonts.cairo(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 16),

              // السطر الثالث: يصعد من الأسفل
              SlideTransition(
                position: _line3Slide,
                child: Text(
                  '📚 المنهاج المطور 2025 - 2026',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cairo(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
