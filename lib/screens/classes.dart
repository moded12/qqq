import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'subjects.dart';
import 'package:url_launcher/url_launcher.dart';

class ClassesScreen extends StatefulWidget {
  const ClassesScreen({super.key});

  @override
  State<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends State<ClassesScreen> {
  List classes = [];
  bool isLoading = true;

  // BannerAd خاص بهذه الصفحة فقط لحل مشكلة AdWidget في أكثر من شجرة
  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
    fetchClasses();
  }

  void _loadBannerAd() {
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
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Future<void> fetchClasses() async {
    const url = 'https://www.shneler.com/oman/api/classes.php?id=1';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        setState(() {
          classes = decoded['apps_list'] ?? decoded;
          isLoading = false;
        });
      } else {
        throw Exception('فشل تحميل الصفوف');
      }
    } catch (_) {
      setState(() {
        isLoading = false;
        classes = [];
      });
    }
  }

  void _launchWebURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _onNavigateToSubjectsScreen(Map item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SubjectsScreen(
          classId: item['id'].toString(),
          className: item['name'] ?? '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.secondary;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الصفوف الدراسية'),
          centerTitle: true,
        ),
        drawer: _buildDrawer(context, theme),
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(color: accentColor),
        )
            : Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: classes.isEmpty
                    ? Center(
                  child: Text(
                    'لا توجد صفوف متاحة',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.disabledColor,
                    ),
                  ),
                )
                    : GridView.builder(
                  itemCount: classes.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 2.8,
                  ),
                  itemBuilder: (context, index) {
                    final item = classes[index];
                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.black12,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => _onNavigateToSubjectsScreen(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(Icons.school_rounded, color: accentColor),
                              Expanded(
                                child: Text(
                                  item['name'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            if (_bannerAd != null && _bannerLoaded)
              Container(
                margin: const EdgeInsets.only(bottom: 18, top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300, width: 1),
                  borderRadius: BorderRadius.circular(12),
                  color: theme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                alignment: Alignment.center,
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [Colors.black87, Colors.black54]
                : [Colors.lightBlue.shade100, Colors.white],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.menu, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'القائمة الجانبية',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(
                context, Icons.home, 'الرئيسية', () => Navigator.pop(context)),
            _buildDrawerItem(context, Icons.apps, 'تطبيقات أخرى',
                    () => _launchWebURL('https://play.google.com/store/apps/details?id=com.shuruhat')),
            _buildDrawerItem(context, Icons.star_rate, 'قيّم التطبيق',
                    () => _launchWebURL('https://play.google.com/store/apps/details?id=com.shuruhat')),
            _buildDrawerItem(context, Icons.privacy_tip, 'سياسة الخصوصية',
                    () => _launchWebURL('https://www.shneler.com/privacy/privacy.om.html')),
            _buildDrawerItem(context, Icons.contact_support, 'تواصل معنا',
                    () => _launchWebURL('https://www.shneler.com/privacy/support/index.html')),
            const Divider(thickness: 1.2),
            _buildDrawerItem(context, Icons.facebook, 'Facebook',
                    () => _launchWebURL('https://www.facebook.com/المعلم-الالكتروني-الشامل-100658468194890')),
            _buildDrawerItem(context, Icons.chat, 'WhatsApp',
                    () => _launchWebURL('https://wa.me/+962799186062')),
            _buildDrawerItem(context, Icons.alternate_email, 'X (Twitter)',
                    () => _launchWebURL('https://twitter.com')),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, IconData icon, String title,
      VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).primaryColorDark),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      onTap: onTap,
    );
  }
}