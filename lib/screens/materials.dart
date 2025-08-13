import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'view_material_screen.dart';

class MaterialsScreen extends StatefulWidget {
  final String groupId;
  final String subjectId;
  final String classId;
  final int semester;

  const MaterialsScreen({
    super.key,
    required this.groupId,
    required this.subjectId,
    required this.classId,
    required this.semester,
  });

  @override
  State<MaterialsScreen> createState() => _MaterialsScreenState();
}

class _MaterialsScreenState extends State<MaterialsScreen> {
  List materials = [];
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

    fetchMaterials();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> fetchMaterials() async {
    final url =
        'https://www.shneler.com/oman/api/materials.php?id=${widget.groupId}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          materials = decoded['apps_list'] ?? decoded;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل في تحميل المواد')),
        );
      }
    } catch (_) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحميل المواد')),
      );
    }
  }

  Future<void> openMaterialAttachments(
      BuildContext context, String materialId, String title) async {
    final url =
        'https://www.shneler.com/oman/api/shrohat/view.php?material_id=$materialId';
    try {
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['success'] == true && (data['data'] as List).isNotEmpty) {
        final firstType = data['data'][0]['type'];
        final urls = List<String>.from(
            (data['data'] as List).map((item) => item['url'].toString()));

        _bannerAd?.dispose(); // حرر البنر قبل الانتقال
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ViewMaterialScreen(
              title: title,
              fileType: firstType,
              fileLinks: urls,
            ),
          ),
        ).then((_) {
          // عند العودة، أعد تحميل البنر
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
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'لا يوجد مرفقات')),
        );
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء تحميل المرفقات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('المواضيع التعليمية'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : materials.isEmpty
                  ? const Center(child: Text('لا يوجد مواضيع تعليمية'))
                  : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: materials.length,
                itemBuilder: (context, index) {
                  final mat = materials[index];
                  final title = mat['name'] ?? 'بدون عنوان';
                  final materialId = mat['id'].toString();

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: accentColor.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      leading: CircleAvatar(
                        radius: 22,
                        backgroundColor: accentColor.withOpacity(0.1),
                        child: Icon(Icons.menu_book, color: accentColor),
                      ),
                      title: Text(
                        title,
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios,
                          color: isDark ? Colors.white70 : Colors.grey),
                      onTap: () =>
                          openMaterialAttachments(context, materialId, title),
                    ),
                  );
                },
              ),
            ),
          ],
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