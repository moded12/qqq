// 📄 lib/main.dart

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shuruhat_new/screens/splash.dart';
import 'package:shuruhat_new/theme/app_theme.dart';
import 'package:shuruhat_new/theme/theme_notifier.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // تهيئة Google Mobile Ads SDK
  await MobileAds.instance.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // الحصول على السمة الحالية من الموفر
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'عُمان بوابة الطالب الذكي',
      theme: themeNotifier.currentTheme,
      // تبدأ دائمًا بشاشة السبلاش
      home: const SplashScreen(),
    );
  }
}
