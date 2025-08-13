import 'dart:async';
import 'dart:math';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class IntelligenceMemoryGameScreen extends StatefulWidget {
  const IntelligenceMemoryGameScreen({Key? key}) : super(key: key);

  @override
  State<IntelligenceMemoryGameScreen> createState() => _IntelligenceMemoryGameScreenState();
}

class _IntelligenceMemoryGameScreenState extends State<IntelligenceMemoryGameScreen> with TickerProviderStateMixin {
  late List<_CardModel> _cards;
  _CardModel? _first;
  bool _waiting = false;
  int _moves = 0;
  int _matches = 0;
  int _level = 1;
  int _time = 0;
  Timer? _timer;
  int _bestTime = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // AdMob variables
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;

  static const List<int> _levelPairs = [6, 8, 10, 12, 14, 16];

  @override
  void initState() {
    super.initState();
    _initializeCards();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void _initializeCards() {
    final icons = [
      Icons.extension, Icons.memory, Icons.psychology, Icons.lightbulb,
      Icons.code, Icons.calculate, Icons.science, Icons.school,
      Icons.rocket_launch, Icons.stars, Icons.savings, Icons.cake,
      Icons.favorite, Icons.gesture, Icons.brush, Icons.bubble_chart,
      Icons.emoji_emotions, Icons.ac_unit, Icons.language, Icons.work,
      Icons.wifi, Icons.casino, Icons.pets, Icons.sports_esports,
    ];
    final count = _levelPairs[min(_level - 1, _levelPairs.length - 1)];
    final usedIcons = icons.take(count).toList();
    _cards = [];
    for (var icon in usedIcons) {
      _cards.add(_CardModel(icon, AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350),
      )));
      _cards.add(_CardModel(icon, AnimationController(
        vsync: this, duration: const Duration(milliseconds: 350),
      )));
    }
    _cards.shuffle(Random());
    _moves = 0;
    _matches = 0;
    _first = null;
    _waiting = false;
    _startTimer();
    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _time = 0;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _time++);
    });
  }

  Future<void> _playCorrectSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/correct.mp3'), volume: 0.8);
    } catch (_) {}
  }

  Future<void> _playWrongSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/wrong.mp3'), volume: 0.8);
    } catch (_) {}
  }

  void _onTap(_CardModel card) {
    if (_waiting || card.revealed || card.matched) return;
    card.controller.forward();
    setState(() => card.revealed = true);
    if (_first == null) {
      _first = card;
    } else {
      _waiting = true;
      _moves++;
      if (_first!.icon == card.icon) {
        Future.delayed(const Duration(milliseconds: 350), () async {
          setState(() {
            _first!.matched = true;
            card.matched = true;
            _matches++;
          });
          await _playCorrectSound();
          _resetTurn();
        });
      } else {
        _playWrongSound();
        Future.delayed(const Duration(milliseconds: 700), () {
          _first!.controller.reverse();
          card.controller.reverse();
          setState(() {
            _first!.revealed = false;
            card.revealed = false;
          });
          _resetTurn();
        });
      }
    }
  }

  void _resetTurn() {
    _first = null;
    _waiting = false;
    if (_matches == _cards.length ~/ 2) {
      _timer?.cancel();
      if (_bestTime == 0 || _time < _bestTime) _bestTime = _time;
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    final lastLevel = _level >= _levelPairs.length;
    _showInterstitialAd(); // Show ad when finishing level
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.deepPurple.shade50,
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 32),
            const SizedBox(width: 12),
            const Text('مبروك!', textDirection: TextDirection.rtl),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('أنهيت المستوى $_level في $_moves حركة خلال $_time ثانية.', style: GoogleFonts.cairo()),
            if (_bestTime > 0)
              Text('أفضل وقت: $_bestTime ثانية', style: GoogleFonts.cairo(fontSize: 16)),
            const SizedBox(height: 12),
            !lastLevel
                ? Text('جاهز لتحدي المستوى التالي؟', style: GoogleFonts.cairo(fontSize: 16))
                : Text('لقد أنهيت جميع المستويات! العب مجدداً وحسّن رقمك 👑', style: GoogleFonts.cairo(fontSize: 16, color: Colors.green)),
          ],
        ),
        actions: [
          if (!lastLevel)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _level++;
                });
                _disposeCards();
                _initializeCards();
              },
              child: Text('المستوى التالي', style: GoogleFonts.cairo()),
            ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _level = 1;
                _bestTime = 0;
              });
              _disposeCards();
              _initializeCards();
            },
            child: Text('إعادة من البداية', style: GoogleFonts.cairo()),
          ),
        ],
      ),
    );
  }

  void _disposeCards() {
    for (final card in _cards) {
      card.controller.dispose();
    }
  }

  // Banner Ad
  void _loadBannerAd() {
    final id = Platform.isIOS
        ? 'ca-app-pub-8177765238464378/6200886168'
        : 'ca-app-pub-8177765238464378/2519324267';
    _bannerAd = BannerAd(
      adUnitId: id,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(onAdLoaded: (_) => setState(() {})),
    )..load();
  }

  // Interstitial Ad
  void _loadInterstitialAd() {
    final id = Platform.isIOS
        ? 'ca-app-pub-8177765238464378/9594108317'
        : 'ca-app-pub-8177765238464378/1345294657';
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialReady = true;
        },
        onAdFailedToLoad: (_) => _isInterstitialReady = false,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_isInterstitialReady && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _isInterstitialReady = false;
      _loadInterstitialAd();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _disposeCards();
    _audioPlayer.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C4EC3), Color(0xFFB57CF7)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26, blurRadius: 10, offset: Offset(0,4)
                  )
                ]
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: Text(
                      'لعبة الذاكرة العقلية',
                      style: GoogleFonts.cairo(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        shadows: [Shadow(color: Colors.black26, blurRadius: 3)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            const Positioned.fill(child: AnimatedBackground()),
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8, left: 16, right: 16),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _InfoChip(label: "المستوى", value: "$_level"),
                        _InfoChip(label: "الحركات", value: "$_moves"),
                        _InfoChip(label: "الوقت", value: "$_time"),
                        IconButton(
                          tooltip: "إعادة اللعب",
                          icon: const Icon(Icons.refresh, color: Colors.deepPurple),
                          onPressed: () {
                            _disposeCards();
                            _initializeCards();
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final int crossAxisCount = (_cards.length <= 12) ? 4 : 5;
                        final double maxWidth = min(constraints.maxWidth * 0.94, 430);
                        return Center(
                          child: SizedBox(
                            width: maxWidth,
                            child: GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1,
                              ),
                              itemCount: _cards.length,
                              itemBuilder: (_, index) {
                                final card = _cards[index];
                                return AnimatedBuilder(
                                  animation: card.controller,
                                  builder: (_, child) {
                                    final value = card.controller.value;
                                    final isFront = value > 0.5;
                                    return GestureDetector(
                                      onTap: () => _onTap(card),
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.rotationY(value * pi),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 250),
                                          decoration: BoxDecoration(
                                            gradient: isFront
                                                ? const LinearGradient(
                                              colors: [Colors.white, Color(0xFFEAD6FF)],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                                : const LinearGradient(
                                              colors: [Color(0xFF8663C7), Color(0xFFB57CF7)],
                                              begin: Alignment.bottomLeft,
                                              end: Alignment.topRight,
                                            ),
                                            borderRadius: BorderRadius.circular(18),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.deepPurple.withOpacity(0.12),
                                                blurRadius: 6,
                                                offset: const Offset(2,3),
                                              ),
                                            ],
                                          ),
                                          child: isFront || card.revealed || card.matched
                                              ? Center(child: Icon(card.icon, color: Colors.deepPurple, size: 38))
                                              : Center(child: Icon(Icons.help_outline, color: Colors.white, size: 32)),
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (_bestTime > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text('أفضل وقت: $_bestTime ثانية', style: GoogleFonts.cairo(fontSize: 16, color: Colors.amber.shade800)),
                    ),
                  const SizedBox(height: 12),
                  // Banner Ad
                  if (_bannerAd != null)
                    SafeArea(
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardModel {
  final IconData icon;
  bool revealed = false;
  bool matched = false;
  final AnimationController controller;
  _CardModel(this.icon, this.controller);
}

class _InfoChip extends StatelessWidget {
  final String label, value;
  const _InfoChip({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 9),
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade100.withOpacity(0.88),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text('$label: $value', style: GoogleFonts.cairo(fontSize: 15, color: Colors.deepPurple.shade700)),
    );
  }
}

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});
  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 13),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: _BgPainter(_controller.value),
        );
      },
    );
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    final colors = [
      Colors.deepPurple.withOpacity(0.18),
      Colors.purpleAccent.withOpacity(0.13),
      Colors.amberAccent.withOpacity(0.09),
    ];
    for (int i = 0; i < 3; i++) {
      final radius = size.width * (0.55 + 0.25 * i) * (1 + 0.07 * sin(t * 2 * pi + i));
      final offset = Offset(
        size.width * (0.5 + 0.25 * sin(t * 2 * pi + i)),
        size.height * (0.45 + 0.18 * cos(t * 2 * pi + i)),
      );
      final paint = Paint()..color = colors[i];
      canvas.drawCircle(offset, radius, paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}