// 📄 lib/games/math.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MathGameScreen extends StatefulWidget {
  const MathGameScreen({Key? key}) : super(key: key);

  @override
  _MathGameScreenState createState() => _MathGameScreenState();
}

class _MathGameScreenState extends State<MathGameScreen> {
  int currentStage = 0;
  int currentQuestionIndex = 0;
  int score = 0;
  bool gameFinished = false;
  int timer = 15;
  Timer? countdown;
  int bestScore = 0;

  final AudioPlayer player = AudioPlayer();
  List<_StarData> _stars = [];

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isInterstitialReady = false;

  // أسئلة الرياضيات: (يمكنك إضافة المزيد)
  final List<List<Map<String, dynamic>>> stages = [
    [
      {
        'question': 'كم ناتج 3 + 5 ؟',
        'options': ['7', '8', '9', '6'],
        'answer': '8',
      },
      {
        'question': 'كم ناتج 10 - 4 ؟',
        'options': ['5', '7', '6', '4'],
        'answer': '6',
      },
      {
        'question': 'كم ناتج 12 + 7 ؟',
        'options': ['19', '18', '20', '17'],
        'answer': '19',
      },
      {
        'question': 'كم ناتج 9 - 3 ؟',
        'options': ['5', '7', '6', '8'],
        'answer': '6',
      },
      {
        'question': 'كم ناتج 2 + 2 ؟',
        'options': ['3', '4', '2', '5'],
        'answer': '4',
      },
      {
        'question': 'كم ناتج 15 - 5 ؟',
        'options': ['9', '10', '11', '8'],
        'answer': '10',
      },
      {
        'question': 'كم ناتج 7 + 6 ؟',
        'options': ['14', '12', '13', '15'],
        'answer': '13',
      },
      {
        'question': 'كم ناتج 8 - 2 ؟',
        'options': ['7', '8', '6', '5'],
        'answer': '6',
      },
      {
        'question': 'كم ناتج 4 + 9 ؟',
        'options': ['14', '12', '13', '15'],
        'answer': '13',
      },
      {
        'question': 'كم ناتج 5 + 5 ؟',
        'options': ['10', '11', '9', '12'],
        'answer': '10',
      },
      {
        'question': 'كم ناتج 6 × 2 ؟',
        'options': ['8', '10', '12', '14'],
        'answer': '12',
      },
      {
        'question': 'كم ناتج 15 ÷ 3 ؟',
        'options': ['4', '5', '6', '3'],
        'answer': '5',
      },
      {
        'question': 'كم ناتج 9 + 8 ؟',
        'options': ['16', '17', '15', '18'],
        'answer': '17',
      },
      {
        'question': 'كم ناتج 20 - 7 ؟',
        'options': ['12', '13', '14', '15'],
        'answer': '13',
      },
      {
        'question': 'كم ناتج 3 × 4 ؟',
        'options': ['7', '12', '11', '10'],
        'answer': '12',
      },
      {
        'question': 'كم ناتج 18 ÷ 2 ؟',
        'options': ['9', '8', '7', '10'],
        'answer': '9',
      },
      {
        'question': 'كم ناتج 13 + 7 ؟',
        'options': ['19', '20', '21', '15'],
        'answer': '20',
      },
      {
        'question': 'كم ناتج 11 - 6 ؟',
        'options': ['4', '3', '5', '6'],
        'answer': '5',
      },
      {
        'question': 'كم ناتج 14 + 5 ؟',
        'options': ['18', '19', '20', '21'],
        'answer': '19',
      },
      {
        'question': 'كم ناتج 16 - 8 ؟',
        'options': ['7', '8', '9', '10'],
        'answer': '8',
      },
      {
        'question': 'كم ناتج 2 × 9 ؟',
        'options': ['18', '17', '19', '20'],
        'answer': '18',
      },
      {
        'question': 'كم ناتج 24 ÷ 6 ؟',
        'options': ['3', '4', '5', '6'],
        'answer': '4',
      },
      {
        'question': 'كم ناتج 7 × 3 ؟',
        'options': ['20', '21', '19', '18'],
        'answer': '21',
      },
      {
        'question': 'كم ناتج 25 - 13 ؟',
        'options': ['10', '11', '12', '13'],
        'answer': '12',
      },
      {
        'question': 'ما هو الرقم المفقود: 4, 6, __, 10, 12 ؟',
        'options': ['7', '8', '9', '11'],
        'answer': '8',
      },
      {
        'question': 'أي عدد أكبر: 17 أم 15 ؟',
        'options': ['17', '15', 'متساويان', '16'],
        'answer': '17',
      },
      {
        'question': 'كم ناتج 3 + 7 × 2 ؟',
        'options': ['17', '20', '14', '13'],
        'answer': '17',
      },
      {
        'question': 'كم ناتج 5 × 5 ؟',
        'options': ['20', '25', '15', '10'],
        'answer': '25',
      },
      {
        'question': 'كم ناتج 40 ÷ 8 ؟',
        'options': ['5', '6', '7', '8'],
        'answer': '5',
      },
      {
        'question': 'كم ناتج 6 × 6 ؟',
        'options': ['36', '30', '24', '26'],
        'answer': '36',
      },
      {
        'question': 'كم ناتج 28 - 9 ؟',
        'options': ['17', '18', '19', '20'],
        'answer': '19',
      },
      {
        'question': 'ما هو العدد الذي إذا أضفنا له 5 أصبح 15 ؟',
        'options': ['10', '15', '5', '12'],
        'answer': '10',
      },
      {
        'question': 'ما هو نصف العدد 18 ؟',
        'options': ['8', '9', '10', '7'],
        'answer': '9',
      },
      {
        'question': 'كم ناتج 50 ÷ 5 ؟',
        'options': ['8', '10', '12', '9'],
        'answer': '10',
      },
      {
        'question': 'أي عدد أصغر: 14 أم 17 ؟',
        'options': ['14', '17', 'متساويان', '15'],
        'answer': '14',
      },
      {
        'question': 'كم ناتج 100 - 55 ؟',
        'options': ['45', '40', '55', '50'],
        'answer': '45',
      },
      {
        'question': 'كم ناتج 8 × 5 ؟',
        'options': ['40', '45', '48', '35'],
        'answer': '40',
      },
      {
        'question': 'كم ناتج 81 ÷ 9 ؟',
        'options': ['8', '7', '9', '10'],
        'answer': '9',
      },
      {
        'question': 'ما هو العدد التالي: 5، 10، 15، __ ؟',
        'options': ['18', '20', '25', '30'],
        'answer': '20',
      },
      {
        'question': 'كم ناتج 15 × 2 ؟',
        'options': ['30', '25', '28', '20'],
        'answer': '30',
      },
      {
        'question': 'كم ناتج 36 ÷ 6 ؟',
        'options': ['7', '6', '5', '8'],
        'answer': '6',
      },
      {
        'question': 'كم ناتج 12 × 3 ؟',
        'options': ['36', '30', '28', '32'],
        'answer': '36',
      },
      {
        'question': 'كم ناتج 14 × 2 ؟',
        'options': ['28', '24', '22', '20'],
        'answer': '28',
      },
      {
        'question': 'كم ناتج 25 ÷ 5 ؟',
        'options': ['4', '5', '6', '7'],
        'answer': '5',
      },
      {
        'question': 'ما هو العدد الذي إذا ضرب في نفسه يعطي 49 ؟',
        'options': ['7', '8', '9', '6'],
        'answer': '7',
      },
      {
        'question': 'كم ناتج 60 ÷ 10 ؟',
        'options': ['5', '6', '7', '8'],
        'answer': '6',
      },
      {
        'question': 'ما هو العدد المفقود: 9, 18, __, 36, 45 ؟',
        'options': ['27', '24', '21', '28'],
        'answer': '27',
      },
      {
        'question': 'كم ناتج 100 ÷ 4 ؟',
        'options': ['25', '20', '30', '40'],
        'answer': '25',
      },
      {
        'question': 'كم ناتج 17 + 8 ؟',
        'options': ['25', '24', '26', '23'],
        'answer': '25',
      },
      {
        'question': 'كم ناتج 33 - 19 ؟',
        'options': ['14', '15', '13', '16'],
        'answer': '14',
      },
      {
        'question': 'كم ناتج 12 × 5 ؟',
        'options': ['60', '50', '55', '65'],
        'answer': '60',
      },
      {
        'question': 'كم ناتج 56 ÷ 8 ؟',
        'options': ['7', '8', '9', '6'],
        'answer': '7',
      },
      // أضف أسئلة أخرى هنا
    ],
  ];

  bool? wasCorrect;
  String? selectedOption;
  bool showAnswer = false;
  bool showNextButton = false;

  @override
  void initState() {
    super.initState();
    loadBestScore();
    startTimer();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  void startTimer() {
    timer = 15;
    countdown?.cancel();
    countdown = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() {
        timer--;
        if (timer == 0 && !showAnswer) {
          checkAnswer(null);
        }
      });
    });
  }

  void playSound(bool correct) async {
    await player.play(AssetSource(correct ? 'sounds/correct.mp3' : 'sounds/wrong.mp3'));
  }

  void showStars() {
    final rand = Random();
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final newStars = List.generate(20, (index) {
      return _StarData(
        left: rand.nextDouble() * (w - 24),
        top: rand.nextDouble() * (h - 100),
        size: 12.0 + rand.nextDouble() * 8,
        opacity: 1.0,
      );
    });
    setState(() => _stars = newStars);
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _stars = []);
    });
  }

  void checkAnswer(String? option) {
    countdown?.cancel();
    final q = stages[currentStage][currentQuestionIndex];
    final correct = q['answer'];
    setState(() {
      selectedOption = option;
      wasCorrect = option != null && option == correct;
      showAnswer = true;
      showNextButton = true;
    });
    playSound(wasCorrect ?? false);
    if (wasCorrect == true) {
      score++;
      showStars();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < stages[currentStage].length - 1) {
      setState(() {
        currentQuestionIndex++;
        resetQuestion();
      });
      startTimer();
    } else if (currentStage < stages.length - 1) {
      setState(() {
        currentStage++;
        currentQuestionIndex = 0;
        resetQuestion();
      });
      startTimer();
    } else {
      finishGame();
    }
  }

  void resetQuestion() {
    selectedOption = null;
    wasCorrect = null;
    showAnswer = false;
    showNextButton = false;
  }

  Future<void> finishGame() async {
    setState(() => gameFinished = true);
    _showInterstitialAd();
    final prefs = await SharedPreferences.getInstance();
    if (score > bestScore) {
      await prefs.setInt('best_math_score', score);
      setState(() => bestScore = score);
    }
  }

  void restartGame() {
    setState(() {
      currentStage = 0;
      currentQuestionIndex = 0;
      score = 0;
      gameFinished = false;
      resetQuestion();
      _stars = [];
    });
    startTimer();
  }

  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => bestScore = prefs.getInt('best_math_score') ?? 0);
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
    countdown?.cancel();
    player.dispose();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalQ = stages.fold<int>(0, (sum, s) => sum + s.length);
    if (gameFinished) {
      return Scaffold(
        appBar: AppBar(
          title: Text('انتهت اللعبة', style: GoogleFonts.cairo()),
          backgroundColor: Colors.green.shade800,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('🎉 انتهت اللعبة!', style: GoogleFonts.cairo(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Text('درجتك: $score من $totalQ', style: GoogleFonts.cairo(fontSize: 20)),
              Text('أفضل نتيجة: $bestScore', style: GoogleFonts.cairo(fontSize: 18)),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: restartGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
              ),
            ],
          ),
        ),
      );
    }

    final question = stages[currentStage][currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('تحدي الرياضيات', style: GoogleFonts.cairo()),
        backgroundColor: Colors.green.shade800,
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
      ),
      body: Stack(
        children: [
          // تأثير النجوم
          ..._stars.map((s) => Positioned(
            left: s.left,
            top: s.top,
            child: AnimatedOpacity(
              opacity: s.opacity,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.star, color: Colors.amber, size: s.size),
            ),
          )),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('المرحلة ${currentStage + 1}/${stages.length} - السؤال ${currentQuestionIndex + 1}/${stages[currentStage].length}',
                    style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text('⏱ الوقت: $timer ثانية', style: GoogleFonts.cairo(fontSize: 18, color: Colors.red)),
                const SizedBox(height: 20),
                Text(question['question'], style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 30),
                ... (question['options'] as List<String>).map((opt) {
                  Color bg = Colors.grey.shade300;
                  Color fg = Colors.black;
                  if (showAnswer) {
                    if (opt == question['answer']) {
                      bg = Colors.green;
                      fg = Colors.white;
                    } else if (selectedOption == opt) {
                      bg = Colors.redAccent;
                      fg = Colors.white;
                    }
                  }
                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: bg,
                        foregroundColor: fg,
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: showAnswer ? null : () => checkAnswer(opt),
                      child: Text(opt, style: GoogleFonts.cairo(fontSize: 18)),
                    ),
                  );
                }),
                if (showAnswer)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Column(
                      children: [
                        if (wasCorrect == true)
                          Text('إجابة صحيحة! ✔ الإجابة هي: ${question['answer']}', style: GoogleFonts.cairo(fontSize: 18, color: Colors.green)),
                        if (wasCorrect == false) ...[
                          Text('إجابة خاطئة! إجابتك: ${selectedOption ?? ''}', style: GoogleFonts.cairo(fontSize: 18, color: Colors.red)),
                          const SizedBox(height: 6),
                          Text('الإجابة الصحيحة: ${question['answer']}', style: GoogleFonts.cairo(fontSize: 18, color: Colors.green)),
                        ],
                        if (showNextButton)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: ElevatedButton(
                              onPressed: nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green.shade800,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              ),
                              child: Text('التالي', style: GoogleFonts.cairo(fontSize: 17)),
                            ),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (_bannerAd != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: SafeArea(
                child: SizedBox(
                  width: _bannerAd!.size.width.toDouble(),
                  height: _bannerAd!.size.height.toDouble(),
                  child: AdWidget(ad: _bannerAd!),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StarData {
  final double left;
  final double top;
  final double size;
  final double opacity;
  _StarData({required this.left, required this.top, required this.size, required this.opacity});
}
