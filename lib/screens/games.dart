// 📄 lib/screens/games.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../games/math.dart';
import '../games/science.dart';
import '../games/oman.dart';
import '../games/intelligence.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({Key? key}) : super(key: key);

  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _navigateTo(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'الألعاب التعليمية',
            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.deepPurple,
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Text(
                      '🕹️ قائمة الألعاب التعليمية',
                      style: GoogleFonts.cairo(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                        shadows: [
                          const Shadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Game 1: Math
                  ListTile(
                    leading: const Icon(Icons.calculate, color: Colors.blueAccent, size: 32),
                    title: Text('لعبة مهارات الرياضيات', style: GoogleFonts.cairo(fontSize: 20)),
                    tileColor: Colors.blue.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () => _navigateTo(context, const MathGameScreen()),
                  ),
                  const SizedBox(height: 12),

                  // Game 2: Science
                  ListTile(
                    leading: const Icon(Icons.science, color: Colors.redAccent, size: 32),
                    title: Text('لعبة مهارات العلوم', style: GoogleFonts.cairo(fontSize: 20)),
                    tileColor: Colors.red.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () => _navigateTo(context, const ScienceGameScreen()),
                  ),
                  const SizedBox(height: 12),

                  // Game 3: Oman
                  ListTile(
                    leading: const Icon(Icons.flag, color: Colors.green, size: 32),
                    title: Text('لعبة بلدي سلطنة عُمان', style: GoogleFonts.cairo(fontSize: 20)),
                    tileColor: Colors.green.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () => _navigateTo(context, const OmanGameScreen()),
                  ),
                  const SizedBox(height: 24),

                  // Description for Game 4
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.purple.shade200, Colors.purple.shade400],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.memory, size: 48, color: Colors.white),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'لعبة الذاكرة العقلية 🧠\nاختبر ذكاءك وسرّع بديهتك في مطابقة البطاقات.',
                            style: GoogleFonts.almarai(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Game 4: Intelligence Memory
                  ListTile(
                    leading: const Icon(Icons.videogame_asset, color: Colors.purple, size: 32),
                    title: Text('لعبة الذاكرة العقلية', style: GoogleFonts.cairo(fontSize: 20)),
                    tileColor: Colors.purple.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    onTap: () => _navigateTo(context, const IntelligenceMemoryGameScreen()),
                  ),
                ],
              ),
            ),
            if (_bannerAd != null && _bannerLoaded)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }
}