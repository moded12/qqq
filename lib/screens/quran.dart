import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  List<dynamic> chapters = [];
  bool isLoading = true;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8177765238464378/2290295726', // غيّرها لوحدة إعلانك
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();

    fetchChapters();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> fetchChapters() async {
    const url = 'https://shneler.com/oman/api/shrohat/quran_chapters_ar.json';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        setState(() {
          chapters = data;
          isLoading = false;
        });
      } else {
        throw Exception("فشل تحميل السور");
      }
    } catch (_) {
      setState(() {
        isLoading = false;
        chapters = [];
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تعذر تحميل السور')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('القرآن الكريم'),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: chapters.length,
          itemBuilder: (context, index) {
            final chapter = chapters[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                  isDark ? Colors.orange : Colors.indigo,
                  child: Text(
                    chapter['id'].toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(
                  chapter['name_arabic'],
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.right,
                ),
                onTap: () {
                  // يمكنك هنا إضافة interstitial Ad (اختياري)
                  // AdsHelper.showInterstitialAd();
                  // لاحقًا: فتح السورة أو تشغيل التلاوة
                },
              ),
            );
          },
        ),
        bottomNavigationBar: _bannerAd != null && _bannerLoaded
            ? SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : null,
      ),
    );
  }
}