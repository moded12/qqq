import 'package:flutter/material.dart';
import '../service/api_service.dart';
import '../service/api_service.dart';
import '../config.dart';
import 'subjects_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<dynamic>> _future;

  @override
  void initState() {
    super.initState();
    // ابدأ بعرض الصفوف من id الافتراضي
    _future = ApiService.getClasses(id: DEFAULT_CLASSES_ID);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ApiService.getClasses(id: DEFAULT_CLASSES_ID);
    });
    await _future;
  }

  String? _resolveImageUrl(dynamic raw) {
    if (raw == null) return null;
    final val = raw.toString().trim();
    if (val.isEmpty) return null;
    if (val.startsWith('http://') || val.startsWith('https://')) {
      return val;
    }
    if (val.startsWith('/')) {
      return '$IMG_BASE_URL$val';
    }
    return '$IMG_BASE_URL/$val';
  }

  String _extractTitle(Map<String, dynamic> item) {
    return (item['name'] ??
        item['title'] ??
        item['app_name'] ??
        item['label'] ??
        'بدون عنوان')
        .toString();
  }

  String? _extractSubtitle(Map<String, dynamic> item) {
    final v = item['server'] ??
        item['description'] ??
        item['desc'] ??
        item['subtitle'];
    return v == null ? null : v.toString();
  }

  void _openSubjects(Map<String, dynamic> item) {
    final server = item['server']?.toString().trim();
    if (server == null || server.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('لا يوجد رابط مواد لهذا الصف')),
      );
      return;
    }
    final title = _extractTitle(item);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SubjectsScreen(server: server, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ads = showAds == 1
        ? Container(
      height: 56,
      color: Colors.black12,
      alignment: Alignment.center,
      child: const Text('Ad banner placeholder'),
    )
        : const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الصفوف'),
      ),
      body: Column(
        children: [
          ads,
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<dynamic>>(
                future: _future,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return ListView(
                      children: [
                        const SizedBox(height: 80),
                        Icon(Icons.error_outline, color: Colors.red.shade400, size: 48),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'فشل تحميل البيانات:\n${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh),
                          label: const Text('إعادة المحاولة'),
                        ),
                      ],
                    );
                  }

                  final data = (snapshot.data ?? []).whereType<dynamic>().toList();

                  if (data.isEmpty) {
                    return ListView(
                      children: const [
                        SizedBox(height: 120),
                        Center(child: Text('لا توجد بيانات')),
                      ],
                    );
                  }

                  return ListView.separated(
                    itemCount: data.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final raw = data[index];
                      final item = (raw is Map<String, dynamic>)
                          ? raw
                          : <String, dynamic>{'name': raw.toString()};
                      final title = _extractTitle(item);
                      final subtitle = _extractSubtitle(item);
                      final imageUrl = _resolveImageUrl(
                        item['img'] ?? item['image'] ?? item['thumbnail'] ?? item['icon'],
                      );

                      return ListTile(
                        leading: imageUrl == null
                            ? const CircleAvatar(child: Icon(Icons.school))
                            : ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            imageUrl,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                            const CircleAvatar(child: Icon(Icons.broken_image)),
                          ),
                        ),
                        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: subtitle == null
                            ? null
                            : Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => _openSubjects(item),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}