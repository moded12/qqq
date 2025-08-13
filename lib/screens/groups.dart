import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'materials.dart';

class GroupsScreen extends StatefulWidget {
  final String subjectId;
  final String classId;
  final int semester;

  const GroupsScreen({
    super.key,
    required this.subjectId,
    required this.classId,
    required this.semester,
  });

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  List groups = [];
  bool isLoading = true;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8177765238464378/2290295726', // غيّرها لوحدة إعلانك الحقيقية
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

    fetchGroups();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> fetchGroups() async {
    final url =
        'https://www.shneler.com/oman/api/groups.php?id=${widget.subjectId}&semester=${widget.semester}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          groups = decoded['apps_list'] ?? decoded;
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل المجموعات');
      }
    } catch (_) {
      setState(() {
        groups = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'المجموعات - الفصل ${widget.semester == 0 ? 'الأول' : 'الثاني'}',
          ),
          centerTitle: true,
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : groups.isEmpty
            ? const Center(child: Text('لا توجد مجموعات'))
            : ListView.builder(
          itemCount: groups.length,
          itemBuilder: (context, index) {
            final item = groups[index];
            return Card(
              margin: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.folder, color: accentColor),
                title: Text(
                  item['name'] ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  _bannerAd?.dispose(); // حرر البنر قبل الانتقال
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MaterialsScreen(
                        groupId: item['id'].toString(),
                        subjectId: widget.subjectId,
                        classId: widget.classId,
                        semester: widget.semester,
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      // أعد تحميل البنر عند العودة
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