import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'groups.dart';

class SubjectsScreen extends StatefulWidget {
  final String classId;
  final String className;

  const SubjectsScreen({
    super.key,
    required this.classId,
    required this.className,
  });

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  List subjects = [];
  bool isLoading = true;
  String expandedSubjectId = '';

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

    fetchSubjects();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> fetchSubjects() async {
    final url = 'https://www.shneler.com/oman/api/subject.php?id=${widget.classId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          subjects = decoded['apps_list'] ?? decoded;
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل المواد');
      }
    } catch (_) {
      setState(() {
        subjects = [];
        isLoading = false;
      });
    }
  }

  void toggleExpand(String subjectId) {
    setState(() {
      expandedSubjectId = expandedSubjectId == subjectId ? '' : subjectId;
    });
    // يمكنك عرض إعلان بيني هنا إذا أردت
    // AdsHelper.showInterstitialAd();
  }

  IconData getSubjectIcon(String name) {
    if (name.contains('عربية')) return Icons.menu_book;
    if (name.contains('إسلام')) return Icons.home;
    if (name.contains('إنجليزي')) return Icons.school;
    if (name.contains('علوم')) return Icons.science;
    if (name.contains('رياضيات')) return Icons.calculate;
    if (name.contains('رقمي')) return Icons.computer;
    if (name.contains('مواطنة') || name.contains('هوية')) return Icons.flag_circle;
    if (name.contains('مهارات')) return Icons.school;
    return Icons.menu_book;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('المواد - ${widget.className}'),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : subjects.isEmpty
            ? const Center(child: Text('لا يوجد مواد لهذا الصف'))
            : ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: subjects.length,
          itemBuilder: (context, index) {
            final item = subjects[index];
            final subjectId = item['id'].toString();
            final isExpanded = subjectId == expandedSubjectId;

            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      getSubjectIcon(item['name'] ?? ''),
                      size: 28,
                      color: accentColor,
                    ),
                    title: Text(
                      item['name'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () => toggleExpand(subjectId),
                  ),
                  if (isExpanded)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _bannerAd?.dispose();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupsScreen(
                                    subjectId: subjectId,
                                    classId: widget.classId,
                                    semester: 0,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  _bannerAd = BannerAd(
                                    adUnitId: 'ca-app-pub-8177765238464378/2290295726',
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
                                  _bannerLoaded = false;
                                });
                              });
                            },
                            child: const Text('الفصل الأول'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _bannerAd?.dispose();
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => GroupsScreen(
                                    subjectId: subjectId,
                                    classId: widget.classId,
                                    semester: 1,
                                  ),
                                ),
                              ).then((_) {
                                setState(() {
                                  _bannerAd = BannerAd(
                                    adUnitId: 'ca-app-pub-8177765238464378/2290295726',
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
                                  _bannerLoaded = false;
                                });
                              });
                            },
                            child: const Text('الفصل الثاني'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _bannerAd != null && _bannerLoaded
            ? Container(
          margin: const EdgeInsets.only(bottom: 18, top: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300, width: 1),
            borderRadius: BorderRadius.circular(12),
            color: theme.cardColor,
          ),
          width: _bannerAd!.size.width.toDouble(),
          height: _bannerAd!.size.height.toDouble(),
          child: AdWidget(ad: _bannerAd!),
        )
            : null,
      ),
    );
  }
}