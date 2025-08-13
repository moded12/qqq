// 📄 lib/screens/home.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../ads/ads_helper.dart';
import 'classes.dart';
import 'games.dart';  // Updated import to games_screen.dart
import 'quran.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  int _lastTabIndex = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this)
      ..addListener(() {
        if (_tabController.index != _lastTabIndex) {
          AdsHelper.showInterstitialAd();
          _lastTabIndex = _tabController.index;
        }
      });

    // تحميل الإعلانات مرة واحدة عند انطلاق التطبيق
    AdsHelper.initializeBannerAd();
    AdsHelper.loadInterstitialAd();
    AdsHelper.loadAppOpenAd();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('عُمان بوابة الطالب الذكي'),
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelStyle: GoogleFonts.cairo(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            tabs: const [
              Tab(text: 'حلول وشروحات'),
              Tab(text: 'الألعاب'),
              Tab(text: 'القرآن الكريم'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: const [
            ClassesScreen(),
            GamesScreen(),
            QuranScreen(),
          ],
        ),
        bottomNavigationBar: AdsHelper.bannerAd != null
            ? SizedBox(
          width: AdsHelper.bannerAd!.size.width.toDouble(),
          height: AdsHelper.bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: AdsHelper.bannerAd!),
        )
            : null,
      ),
    );
  }
}
