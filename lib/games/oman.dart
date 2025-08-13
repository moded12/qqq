// 📄 lib/games/oman.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class OmanGameScreen extends StatefulWidget {
  const OmanGameScreen({Key? key}) : super(key: key);

  @override
  _OmanGameScreenState createState() => _OmanGameScreenState();
}

class _OmanGameScreenState extends State<OmanGameScreen> {
  int currentIndex = 0;
  String? selectedAnswer;
  bool answered = false;
  bool showStars = false;

  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  bool _isBannerAdReady = false;

  final List<Map<String, dynamic>> questions = [
    {
      'question': 'ما اسم الخنجر التقليدي الذي يُلبسه الرجال في عُمان؟',
      'options': ['الجنبيه', 'السيف', 'الخنجر العماني', 'الموس'],
      'answer': 'الخنجر العماني',
    },
    {
      'question': 'ما اسم الرقصة الشعبية المشهورة في سلطنة عُمان؟',
      'options': ['الدبكة', 'العازي', 'العرضة', 'السامري'],
      'answer': 'العازي',
    },
    {
      'question': 'ما اسم الزي التقليدي للنساء في عُمان؟',
      'options': ['الدشداشة', 'الثوب', 'الحجاب', 'العباءة'],
      'answer': 'الثوب',
    },
    {
      'question': 'ما اسم الوجبة العمانية التي تُطهى في حفرة تحت الأرض؟',
      'options': ['الثريد', 'الشوا', 'القبولي', 'الهريس'],
      'answer': 'الشوا',
    },
    {
      'question': 'أي ولاية عُمانية تشتهر بصناعة الفخار التقليدي؟',
      'options': ['نزوى', 'صور', 'صلالة', 'بهلاء'],
      'answer': 'بهلاء',
    },
    {
      'question': 'ما هي أداة الطحن التقليدية في عمان؟',
      'options': ['الرحى', 'المنخل', 'الهاون', 'المبشرة'],
      'answer': 'الرحى',
    },
    {
      'question': 'ما اسم الأكلة الشعبية المصنوعة من التمر والدقيق والسمن؟',
      'options': ['الهريس', 'الحلوى العمانية', 'الثريد', 'العصيدة'],
      'answer': 'العصيدة',
    },
    {
      'question': 'ما اسم القلعة التاريخية الموجودة في ولاية نزوى؟',
      'options': ['قلعة بهلاء', 'قلعة نزوى', 'قلعة الرستاق', 'قلعة صحار'],
      'answer': 'قلعة نزوى',
    },
    {
      'question': 'ما هي الأداة التقليدية التي يستعملها الصيادون في عُمان لصيد الأسماك؟',
      'options': ['الشبكة', 'السنارة', 'الرمح', 'الطعم'],
      'answer': 'الشبكة',
    },
    {
      'question': 'أي ولاية عُمانية تشتهر بصناعة السفن الخشبية؟',
      'options': ['صور', 'نزوى', 'مسقط', 'عبري'],
      'answer': 'صور',
    },
    {
      'question': 'ما اسم الحلوى العمانية المشهورة؟',
      'options': ['الكنافة', 'الحلوى العمانية', 'المعمول', 'الغريبة'],
      'answer': 'الحلوى العمانية',
    },
    {
      'question': 'ما اسم السوق التقليدي الشهير في مسقط؟',
      'options': ['سوق مطرح', 'سوق نزوى', 'سوق الرستاق', 'سوق بهلاء'],
      'answer': 'سوق مطرح',
    },
    {
      'question': 'ما اسم الجبل الأعلى في سلطنة عُمان؟',
      'options': ['جبل الشمس', 'جبل الأخضر', 'جبل حفيت', 'جبل سمحان'],
      'answer': 'جبل الشمس',
    },
    {
      'question': 'ما اسم المنطقة التي تشتهر بزراعة النخيل في عُمان؟',
      'options': ['ظفار', 'الداخلية', 'الباطنة', 'الشرقية'],
      'answer': 'الداخلية',
    },
    {
      'question': 'ما اسم أداة السقي التقليدية في عمان؟',
      'options': ['الدلو', 'الشادوف', 'الفلج', 'البرميل'],
      'answer': 'الفلج',
    },
    {
      'question': 'ما اسم السفينة التقليدية العمانية الكبيرة؟',
      'options': ['الجالبوت', 'الشوعي', 'البغلة', 'الدهو'],
      'answer': 'البغلة',
    },
    {
      'question': 'ما اسم اللباس التقليدي للرجال في عُمان؟',
      'options': ['الثوب', 'الدشداشة', 'القفطان', 'الجلباب'],
      'answer': 'الدشداشة',
    },
    {
      'question': 'ما هو المشروب الشعبي الذي يُقدم للضيوف في عُمان؟',
      'options': ['الشاي', 'القهوة العمانية', 'العصير', 'الحليب'],
      'answer': 'القهوة العمانية',
    },
    {
      'question': 'ما اسم الاحتفال الديني الكبير الذي يحتفل به العمانيون في نهاية رمضان؟',
      'options': ['عيد الفطر', 'عيد الأضحى', 'المولد النبوي', 'ليلة القدر'],
      'answer': 'عيد الفطر',
    },
    {
      'question': 'أي من المدن التالية كانت عاصمة عمان القديمة؟',
      'options': ['نزوى', 'صور', 'مسقط', 'صلالة'],
      'answer': 'نزوى',
    },
    {
      'question': 'ما اسم الشجرة التي تشتهر بها محافظة ظفار وتستخدم في إنتاج اللبان؟',
      'options': ['المرخ', 'النخيل', 'اللبان', 'السدر'],
      'answer': 'اللبان',
    },
    {
      'question': 'ما اسم الكساء التقليدي الذي يوضع على رأس النساء في عمان؟',
      'options': ['اللحاف', 'الشيلة', 'البرقع', 'الحجاب'],
      'answer': 'الشيلة',
    },
    {
      'question': 'ما اسم الحرفة التقليدية لصناعة السعفيات؟',
      'options': ['الفخار', 'النسيج', 'السعفيات', 'النجارة'],
      'answer': 'السعفيات',
    },
    {
      'question': 'أي من الولايات التالية تشتهر باللبان؟',
      'options': ['صحار', 'نزوى', 'صلالة', 'بهلاء'],
      'answer': 'صلالة',
    },
    {
      'question': 'ما اسم العيد الوطني لسلطنة عمان؟',
      'options': ['عيد الاتحاد', 'العيد الوطني', 'عيد النهضة', 'عيد التحرير'],
      'answer': 'العيد الوطني',
    },
    {
      'question': 'ما اسم الوادي المشهور في ولاية وادي بني خالد؟',
      'options': ['وادي الكبير', 'وادي بني خالد', 'وادي شاب', 'وادي دربات'],
      'answer': 'وادي بني خالد',
    },
    {
      'question': 'ما اسم الأداة التقليدية المستخدمة لحمل الماء؟',
      'options': ['الجرّة', 'السطل', 'الدلو', 'القربة'],
      'answer': 'القربة',
    },
    {
      'question': 'ما اسم الوجبة التي تقدم غالبًا في المناسبات الرسمية والأعراس في عمان؟',
      'options': ['الثريد', 'الشوا', 'القبولي', 'المندي'],
      'answer': 'القبولي',
    },
    {
      'question': 'ما اسم المهرجان الذي يقام سنوياً في محافظة ظفار؟',
      'options': ['مهرجان مسقط', 'مهرجان نزوى', 'مهرجان صلالة', 'مهرجان بهلاء'],
      'answer': 'مهرجان صلالة',
    },
    {
      'question': 'ما اسم السفينة العمانية التي شاركت في الرحلات البحرية إلى شرق أفريقيا والهند؟',
      'options': ['الدهو', 'السنبوق', 'الغنجة', 'الشوعي'],
      'answer': 'الغنجة',
    },
    {
      'question': 'ما اسم منطقة استخراج النحاس في عُمان قديماً؟',
      'options': ['صحار', 'نزوى', 'الرستاق', 'عبري'],
      'answer': 'صحار',
    },
    {
      'question': 'ما اسم الزخرفة التي تميز العمارة العمانية التقليدية؟',
      'options': ['المقرنصات', 'الفسيفساء', 'النقوش الهندسية', 'الأرابيسك'],
      'answer': 'النقوش الهندسية',
    },
    {
      'question': 'ما اسم الحرفة التقليدية لصناعة الخوص؟',
      'options': ['النجارة', 'الخوصيات', 'السعفيات', 'الفخار'],
      'answer': 'الخوصيات',
    },
    {
      'question': 'ما اسم السلسلة الجبلية التي تمتد في شمال عُمان؟',
      'options': ['جبال الحجر', 'جبال عسير', 'جبال البحر الأحمر', 'جبال الأطلس'],
      'answer': 'جبال الحجر',
    },
    {
      'question': 'ما اسم الطائر الوطني في عمان؟',
      'options': ['النسر', 'الصقر', 'الحبارى', 'الحمام'],
      'answer': 'الحبارى',
    },
    {
      'question': 'ما اسم النبات الذي يُستخدم في الطب الشعبي العماني؟',
      'options': ['الحبق', 'اللبان', 'الحلبة', 'الكركم'],
      'answer': 'اللبان',
    },
    {
      'question': 'ما اسم السوق التقليدي في ولاية نزوى؟',
      'options': ['سوق مطرح', 'سوق نزوى', 'سوق بهلاء', 'سوق الرستاق'],
      'answer': 'سوق نزوى',
    },
    {
      'question': 'ما اسم البرج الشهير في قلعة بهلاء؟',
      'options': ['برج الريح', 'برج الريامي', 'برج المراقبة', 'برج بهلاء'],
      'answer': 'برج الريح',
    },
    {
      'question': 'ما اسم العيد الذي يحتفل فيه العمانيون في 18 نوفمبر من كل عام؟',
      'options': ['العيد الوطني', 'عيد النهضة', 'عيد الأضحى', 'عيد الفطر'],
      'answer': 'العيد الوطني',
    },
    {
      'question': 'ما اسم القلعة الشهيرة في ولاية الرستاق؟',
      'options': ['قلعة نزوى', 'قلعة بهلاء', 'قلعة الرستاق', 'قلعة صحار'],
      'answer': 'قلعة الرستاق',
    },
    {
      'question': 'ما اسم الأدوات التقليدية لصنع القهوة العمانية؟',
      'options': ['الدلة', 'الإبريق', 'الطاسة', 'الكوب'],
      'answer': 'الدلة',
    },
    {
      'question': 'ما اسم نوع الشعر الشعبي العماني الذي يُلقى في المناسبات؟',
      'options': ['القصيدة', 'العازي', 'الزجل', 'النبطي'],
      'answer': 'العازي',
    },
    {
      'question': 'ما اسم اللباس التقليدي للأطفال الذكور في عمان؟',
      'options': ['القميص', 'الدشداشة', 'الثوب', 'الجلباب'],
      'answer': 'الدشداشة',
    },
    {
      'question': 'ما اسم الوادي الشهير الذي يجري خلال موسم الأمطار في صلالة؟',
      'options': ['وادي دربات', 'وادي بني خالد', 'وادي شاب', 'وادي الكبير'],
      'answer': 'وادي دربات',
    },
    {
      'question': 'ما اسم الأداة التي تستخدم في نقل البضائع على ظهور الحمير قديماً؟',
      'options': ['القفة', 'الخرج', 'الشوال', 'الحقيبة'],
      'answer': 'الخرج',
    },
    {
      'question': 'ما اسم الرقصة التقليدية التي تُستخدم فيها السيوف؟',
      'options': ['العرضة', 'العازي', 'الدبكة', 'السامري'],
      'answer': 'العرضة',
    },
    {
      'question': 'ما اسم الشاطئ الشهير في ولاية صور؟',
      'options': ['شاطئ القرم', 'شاطئ الأشخرة', 'شاطئ صور', 'شاطئ صلالة'],
      'answer': 'شاطئ الأشخرة',
    },
    {
      'question': 'ما اسم النبات الذي يُستخرج منه الدباء المستخدم في الأواني التقليدية؟',
      'options': ['اليقطين', 'الحبق', 'الخيار', 'النعناع'],
      'answer': 'اليقطين',
    },
    {
      'question': 'ما اسم الكتاب التاريخي الذي يوثق حياة العمانيين قديماً؟',
      'options': ['تاريخ عمان', 'معالم تاريخ عمان', 'الفتح المبين', 'رحلة عمان'],
      'answer': 'معالم تاريخ عمان',
    },
    {
      'question': 'ما اسم الولاية التي تشتهر بعيونها المائية الحارة؟',
      'options': ['بهلاء', 'الرستاق', 'نزوى', 'صور'],
      'answer': 'الرستاق',
    },
    {
      'question': 'ما اسم الحرفة التقليدية لصناعة السكاكين؟',
      'options': ['النجارة', 'الحدادة', 'النقش', 'الخراطة'],
      'answer': 'الحدادة',
    },
    {
      'question': 'ما اسم الغطاء التقليدي الذي يوضع على الفم للنساء في بعض مناطق عمان؟',
      'options': ['البرقع', 'النقاب', 'الشيلة', 'اللحاف'],
      'answer': 'البرقع',
    },
    {
      'question': 'ما اسم المأكول الشعبي الذي يُصنع من الأرز واللحم والبهارات؟',
      'options': ['الشوا', 'القبولي', 'الثريد', 'الهريس'],
      'answer': 'القبولي',
    },
    // إضافة المزيد من الأسئلة حسب الحاجة
  ];

  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    MobileAds.instance.initialize();
    _loadBannerAd();
    _loadInterstitialAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final bannerId = Platform.isIOS
        ? 'ca-app-pub-8177765238464378/6200887168'
        : 'ca-app-pub-8177765238464378/2519324267';

    _bannerAd = BannerAd(
      adUnitId: bannerId,
      request: const AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() => _isBannerAdReady = true),
        onAdFailedToLoad: (ad, err) => ad.dispose(),
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    final interstitialId = Platform.isIOS
        ? 'ca-app-pub-8177765238464378/9594108317'
        : 'ca-app-pub-8177765238464378/1345294657';

    InterstitialAd.load(
      adUnitId: interstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (err) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAd() {
    if (_interstitialAd != null) {
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          _loadInterstitialAd();
        },
      );
      _interstitialAd!.show();
      _interstitialAd = null;
    }
  }

  void playSound(bool correct) async {
    await _player.play(AssetSource(correct ? 'sounds/correct.mp3' : 'sounds/wrong.mp3'));
    if (correct) triggerStarEffect();
  }

  void triggerStarEffect() {
    setState(() => showStars = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => showStars = false);
    });
  }

  void selectAnswer(String option) {
    if (!answered) {
      final correct = option == questions[currentIndex]['answer'];
      playSound(correct);
      setState(() {
        selectedAnswer = option;
        answered = true;
      });
    }
  }

  void nextQuestion() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        answered = false;
      });
    } else {
      _showInterstitialAd();
      setState(() {
        currentIndex = 0;
        selectedAnswer = null;
        answered = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = questions[currentIndex];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.teal.shade800.withOpacity(0.8),
          elevation: 0,
          title: Text(
            'ألغاز من سلطنة عمان',
            style: GoogleFonts.cairo(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          leading: const BackButton(color: Colors.white),
        ),
        bottomNavigationBar: _isBannerAdReady
            ? SizedBox(
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : null,
        body: SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF80CBC4)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'السؤال ${currentIndex + 1} من ${questions.length}',
                        style: GoogleFonts.cairo(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        question['question'],
                        style: GoogleFonts.cairo(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      ...question['options'].map<Widget>((option) {
                        final isCorrect = option == question['answer'];
                        final isSelected = option == selectedAnswer;
                        Color? bgColor;
                        if (answered) {
                          bgColor = isCorrect
                              ? Colors.green
                              : (isSelected ? Colors.red : Colors.grey.shade300);
                        }
                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: bgColor ?? Colors.teal.shade600,
                              foregroundColor: Colors.white,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: () => selectAnswer(option),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (answered && isSelected && !isCorrect)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 8),
                                    child: Icon(Icons.close, size: 20),
                                  ),
                                Text(option, style: GoogleFonts.cairo(fontSize: 18)),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 32),
                      if (answered)
                        ElevatedButton(
                          onPressed: nextQuestion,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text('التالي', style: GoogleFonts.cairo(fontSize: 18)),
                        ),
                    ],
                  ),
                ),
                if (showStars)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: showStars ? 1 : 0,
                          duration: const Duration(milliseconds: 300),
                          child: AnimatedScale(
                            scale: showStars ? 1.5 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: const Icon(Icons.star, size: 80),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
