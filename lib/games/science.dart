// 📄 lib/games/science.dart
import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScienceGameScreen extends StatefulWidget {
  const ScienceGameScreen({Key? key}) : super(key: key);

  @override
  _ScienceGameScreenState createState() => _ScienceGameScreenState();
}

class _ScienceGameScreenState extends State<ScienceGameScreen> {
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

  // أسئلة العلوم: يمكنك إضافة مراحل وأسئلة إضافية
  final List<List<Map<String, dynamic>>> stages = [
    [
      {
        'question': 'ما هو الكوكب الأقرب إلى الشمس؟',
        'options': ['عطارد', 'الأرض', 'الزهرة', 'المريخ'],
        'answer': 'عطارد',
      },
      {
        'question': 'ما هو العضو المسؤول عن ضخ الدم في جسم الإنسان؟',
        'options': ['القلب', 'الرئة', 'الكبد', 'المعدة'],
        'answer': 'القلب',
      },
      {
        'question': 'ما هي حالة الماء عند تجميده؟',
        'options': ['صلب', 'سائل', 'غاز', 'بخار'],
        'answer': 'صلب',
      },
      {
        'question': 'أي من هذه الحيوانات يُصنف من البرمائيات؟',
        'options': ['الضفدع', 'الكلب', 'الجمل', 'الدجاجة'],
        'answer': 'الضفدع',
      },
      {
        'question': 'ما هو الغاز اللازم لعملية التنفس؟',
        'options': ['الأكسجين', 'ثاني أكسيد الكربون', 'الهيدروجين', 'النيتروجين'],
        'answer': 'الأكسجين',
      },
      {
        'question': 'أي من هذه النباتات يُزرع بكثرة في عمان؟',
        'options': ['النخيل', 'القمح', 'الشعير', 'الأرز'],
        'answer': 'النخيل',
      },
      {
        'question': 'ما هي الوحدة الأساسية لقياس الطول؟',
        'options': ['المتر', 'الكيلوغرام', 'اللتر', 'الثانية'],
        'answer': 'المتر',
      },
      {
        'question': 'ما هو المصدر الرئيسي للطاقة على الأرض؟',
        'options': ['الشمس', 'الماء', 'الرياح', 'الفحم'],
        'answer': 'الشمس',
      },
      {
        'question': 'ما اسم أكبر كوكب في المجموعة الشمسية؟',
        'options': ['المشتري', 'المريخ', 'الأرض', 'زحل'],
        'answer': 'المشتري',
      },
      {
        'question': 'ما اسم العملية التي تصنع بها النباتات غذاءها؟',
        'options': ['التركيب الضوئي', 'التنفس', 'التمثيل الغذائي', 'النمو'],
        'answer': 'التركيب الضوئي',
      },
      {
        'question': 'أي جزء من النبات مسؤول عن امتصاص الماء؟',
        'options': ['الجذور', 'الساق', 'الأوراق', 'الزهرة'],
        'answer': 'الجذور',
      },
      {
        'question': 'أي من هذه الحيوانات مهددة بالانقراض في عمان؟',
        'options': ['المها العربي', 'الجمل', 'الحصان', 'الماعز'],
        'answer': 'المها العربي',
      },
      {
        'question': 'ما اسم الجهاز الذي يستخدمه الطبيب لسماع دقات القلب؟',
        'options': ['سماعة الطبيب', 'الترمومتر', 'المجهر', 'الميزان'],
        'answer': 'سماعة الطبيب',
      },
      {
        'question': 'ما هو أكبر أعضاء جسم الإنسان؟',
        'options': ['الجلد', 'الكبد', 'القلب', 'المعدة'],
        'answer': 'الجلد',
      },
      {
        'question': 'ما اسم المادة الصلبة التي تغطي الأسنان؟',
        'options': ['المينا', 'اللب', 'العاج', 'العظم'],
        'answer': 'المينا',
      },
      {
        'question': 'ما اسم الكوكب الأحمر؟',
        'options': ['المريخ', 'الزهرة', 'عطارد', 'الأرض'],
        'answer': 'المريخ',
      },
      {
        'question': 'ما هو الحيوان الذي يُصنع منه الحرير الطبيعي؟',
        'options': ['دودة القز', 'النحلة', 'الفراشة', 'الصرصور'],
        'answer': 'دودة القز',
      },
      {
        'question': 'ما اسم الجهاز المسؤول عن إخراج الفضلات من الجسم؟',
        'options': ['الجهاز البولي', 'الجهاز التنفسي', 'الجهاز الهضمي', 'الجهاز العصبي'],
        'answer': 'الجهاز البولي',
      },
      {
        'question': 'أي من هذه الظواهر ينتج عنها ضوء وصوت؟',
        'options': ['البرق', 'المطر', 'الندى', 'الصقيع'],
        'answer': 'البرق',
      },
      {
        'question': 'ما اسم العملية التي يتحول فيها الماء من سائل إلى بخار؟',
        'options': ['التبخر', 'التكاثف', 'التجمد', 'الترسيب'],
        'answer': 'التبخر',
      },
      {
        'question': 'ما اسم العظم الأكبر في جسم الإنسان؟',
        'options': ['عظم الفخذ', 'عظم الذراع', 'عظم الساق', 'عظم الكتف'],
        'answer': 'عظم الفخذ',
      },
      {
        'question': 'أي من هذه الكائنات يستطيع تغيير لونه؟',
        'options': ['الحرباء', 'الأرنب', 'القطة', 'الكلب'],
        'answer': 'الحرباء',
      },
      {
        'question': 'أي كوكب يدور حوله قمر اسمه "تيتان"؟',
        'options': ['زحل', 'المريخ', 'الأرض', 'المشتري'],
        'answer': 'زحل',
      },
      {
        'question': 'ما هو السائل الذي ينقل الغذاء والأكسجين في الجسم؟',
        'options': ['الدم', 'الماء', 'اللعاب', 'العصارة'],
        'answer': 'الدم',
      },
      {
        'question': 'ما هو اسم المادة التي تعطي النباتات لونها الأخضر؟',
        'options': ['اليخضور (الكلوروفيل)', 'الماء', 'الأكسجين', 'الكالسيوم'],
        'answer': 'اليخضور (الكلوروفيل)',
      },
      {
        'question': 'ما هو أصغر عظمة في جسم الإنسان؟',
        'options': ['عظمة الركاب', 'عظمة الفخذ', 'عظمة الكتف', 'عظمة الساق'],
        'answer': 'عظمة الركاب',
      },
      {
        'question': 'أي نوع من الصخور يستخدمه العمانيون للبناء التقليدي؟',
        'options': ['الحجر الجيري', 'الجرانيت', 'الصوان', 'الحجر الرملي'],
        'answer': 'الحجر الجيري',
      },
      {
        'question': 'أي نوع من الطيور يهاجر عبر عمان سنوياً؟',
        'options': ['طائر اللقلق', 'الدجاج', 'العصفور', 'البومة'],
        'answer': 'طائر اللقلق',
      },
      {
        'question': 'ما هو الحيوان الذي يبيض ولا يلد؟',
        'options': ['الطيور', 'القطة', 'الحصان', 'الأرنب'],
        'answer': 'الطيور',
      },
      {
        'question': 'أي حاسة تستخدمها الأسماك لاكتشاف التيارات المائية؟',
        'options': ['الخط الجانبي', 'العين', 'الأذن', 'الفم'],
        'answer': 'الخط الجانبي',
      },
      {
        'question': 'ما اسم الطبقة التي تحمي الأرض من الأشعة الضارة؟',
        'options': ['طبقة الأوزون', 'طبقة التروبوسفير', 'طبقة الستراتوسفير', 'طبقة القشرة'],
        'answer': 'طبقة الأوزون',
      },
      {
        'question': 'أي حيوان يُعد من الزواحف؟',
        'options': ['السحلية', 'الأرنب', 'الدجاجة', 'القطة'],
        'answer': 'السحلية',
      },
      {
        'question': 'ما هو الغاز الأكثر وجودًا في الهواء الجوي؟',
        'options': ['النيتروجين', 'الأكسجين', 'ثاني أكسيد الكربون', 'الهيدروجين'],
        'answer': 'النيتروجين',
      },
      {
        'question': 'ما اسم العملية التي تتحول فيها اليرقة إلى فراشة؟',
        'options': ['التحول', 'التنفس', 'الانقسام', 'التبخر'],
        'answer': 'التحول',
      },
      {
        'question': 'أي من الأجهزة التالية يستخدم لتكبير الأشياء الصغيرة؟',
        'options': ['المجهر', 'المسطرة', 'الميزان', 'التلسكوب'],
        'answer': 'المجهر',
      },
      {
        'question': 'أي عضو مسؤول عن التذوق؟',
        'options': ['اللسان', 'الأنف', 'العين', 'الأذن'],
        'answer': 'اللسان',
      },
      {
        'question': 'أي طاقة نستفيد منها من حركة الرياح؟',
        'options': ['طاقة الرياح', 'الطاقة الشمسية', 'الطاقة الحرارية', 'الطاقة النووية'],
        'answer': 'طاقة الرياح',
      },
      {
        'question': 'أي من التالي مصدر طاقة متجدد؟',
        'options': ['الشمس', 'الفحم', 'النفط', 'الغاز'],
        'answer': 'الشمس',
      },
      {
        'question': 'أي جهاز يستخدمه الطلاب للقياس في التجارب؟',
        'options': ['المسطرة', 'المطرقة', 'القلم', 'الفرشاة'],
        'answer': 'المسطرة',
      },
      {
        'question': 'أي نوع من الحواس يستخدمه الخفاش للصيد؟',
        'options': ['السمع', 'البصر', 'الشم', 'اللمس'],
        'answer': 'السمع',
      },
      {
        'question': 'أي من هذه الحيوانات من الثدييات؟',
        'options': ['الدلفين', 'التمساح', 'العصفور', 'السلاحف'],
        'answer': 'الدلفين',
      },
      {
        'question': 'أي جهاز مسؤول عن التحكم في الجسم؟',
        'options': ['الجهاز العصبي', 'الجهاز الهضمي', 'الجهاز التنفسي', 'الجهاز البولي'],
        'answer': 'الجهاز العصبي',
      },
      {
        'question': 'أي معدن يوجد بكثرة في جبال عمان؟',
        'options': ['النحاس', 'الذهب', 'الفضة', 'الحديد'],
        'answer': 'النحاس',
      },
      {
        'question': 'أي من هذه الكواكب ليس له أقمار؟',
        'options': ['عطارد', 'الأرض', 'زحل', 'المريخ'],
        'answer': 'عطارد',
      },
      {
        'question': 'أي نوع من الأشجار يُزرع لصد الرياح في عمان؟',
        'options': ['النخيل', 'الأثل', 'الزيتون', 'البرتقال'],
        'answer': 'الأثل',
      },
      {
        'question': 'أي من هذه الأجهزة يقيس درجة الحرارة؟',
        'options': ['الترمومتر', 'المسطرة', 'الساعة', 'الميزان'],
        'answer': 'الترمومتر',
      },
      {
        'question': 'ما اسم العملية التي تحافظ على نوع الكائن الحي؟',
        'options': ['التكاثر', 'التنفس', 'الهضم', 'النمو'],
        'answer': 'التكاثر',
      },
      {
        'question': 'أي جزء من العين مسؤول عن الرؤية؟',
        'options': ['الشبكية', 'العدسة', 'القرنية', 'القزحية'],
        'answer': 'الشبكية',
      },
      {
        'question': 'أي من هذه الصخور يستخدم في صناعة الطوب في عمان؟',
        'options': ['الحجر الجيري', 'الجرانيت', 'الكوارتز', 'الصوان'],
        'answer': 'الحجر الجيري',
      },
      {
        'question': 'ما اسم أكبر بحر في العالم؟',
        'options': ['بحر العرب', 'البحر المتوسط', 'بحر قزوين', 'البحر الأحمر'],
        'answer': 'بحر العرب',
      },
      {
        'question': 'أي جهاز يستعمله الطلاب لمشاهدة الأجسام البعيدة؟',
        'options': ['التلسكوب', 'المسطرة', 'المجهر', 'القلم'],
        'answer': 'التلسكوب',
      },
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
    countdown = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        timer--;
        if (timer == 0 && !showAnswer) checkAnswer(null);
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
    setState(() {
      _stars = List.generate(20, (_) => _StarData(
        left: rand.nextDouble() * (w - 24),
        top: rand.nextDouble() * (h - 100),
        size: 12 + rand.nextDouble() * 8,
        opacity: 1,
      ));
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() => _stars.clear());
    });
  }

  void checkAnswer(String? option) {
    countdown?.cancel();
    final correct = stages[currentStage][currentQuestionIndex]['answer'];
    setState(() {
      selectedOption = option;
      wasCorrect = option != null && option == correct;
      showAnswer = true;
      showNextButton = true;
    });
    playSound(wasCorrect!);
    if (wasCorrect == true) {
      score++;
      showStars();
    }
  }

  void nextQuestion() {
    if (currentQuestionIndex < stages[currentStage].length - 1) {
      currentQuestionIndex++;
      resetQuestion();
      startTimer();
    } else if (currentStage < stages.length - 1) {
      currentStage++;
      currentQuestionIndex = 0;
      resetQuestion();
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
    if (score > bestScore) await prefs.setInt('best_science_score', score);
    setState(() => bestScore = score);
  }

  Future<void> loadBestScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => bestScore = prefs.getInt('best_science_score') ?? 0);
  }

  void restartGame() {
    setState(() {
      currentStage = 0;
      currentQuestionIndex = 0;
      score = 0;
      gameFinished = false;
      resetQuestion();
      _stars.clear();
    });
    startTimer();
  }

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

  void _loadInterstitialAd() {
    final id = Platform.isIOS
        ? 'ca-app-pub-8177765238464378/9594108317'
        : 'ca-app-pub-8177765238464378/1345294657';
    InterstitialAd.load(
      adUnitId: id,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) { _interstitialAd = ad; _isInterstitialReady = true; },
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
    final question = stages[currentStage][currentQuestionIndex];
    final adHeight = _bannerAd?.size.height.toDouble() ?? 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text('تحدي العلوم', style: GoogleFonts.cairo()),
        backgroundColor: Colors.red.shade800,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      bottomNavigationBar: _bannerAd != null
          ? SafeArea(
        child: SizedBox(
          width: _bannerAd!.size.width.toDouble(),
          height: adHeight,
          child: AdWidget(ad: _bannerAd!),
        ),
      )
          : null,
      body: gameFinished
          ? Center(
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
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text('إعادة المحاولة', style: GoogleFonts.cairo()),
            ),
          ],
        ),
      )
          : Stack(
        children: [
          ..._stars.map((s) => Positioned(
            left: s.left,
            top: s.top,
            child: AnimatedOpacity(
              opacity: s.opacity,
              duration: const Duration(milliseconds: 150),
              child: Icon(Icons.star, color: Colors.amber, size: s.size),
            ),
          )),
          SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 20, 20, adHeight + 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'المرحلة ${currentStage + 1}/${stages.length} - السؤال ${currentQuestionIndex + 1}/${stages[currentStage].length}',
                  style: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text('⏱ الوقت: $timer ثانية', style: GoogleFonts.cairo(fontSize: 18, color: Colors.red)),
                const SizedBox(height: 20),
                Text(
                  question['question'],
                  style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ...question['options'].map<Widget>((opt) {
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
                  Column(
                    children: [
                      if (wasCorrect == true)
                        Text(
                          'إجابة صحيحة! ✔ الإجابة هي: ${question['answer']}',
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      if (wasCorrect == false) ...[
                        Text(
                          'إجابة خاطئة! إجابتك: ${selectedOption}',
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'الإجابة الصحيحة: ${question['answer']}',
                          style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (showNextButton)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: ElevatedButton(
                            onPressed: nextQuestion,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade800,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                            ),
                            child: Text('التالي', style: GoogleFonts.cairo(fontSize: 17)),
                          ),
                        ),
                    ],
                  ),
              ],
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
