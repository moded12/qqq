import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';

class ApiService {
  /// Fetch list of apps from the dashboard endpoint (optional).
  static Future<List<dynamic>> getDashboardApps() async {
    final uri = Uri.parse(DASHBOARD_API);

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.trim().isEmpty) return [];

    final decoded = jsonDecode(res.body);

    if (decoded is List) {
      return decoded;
    } else if (decoded is Map<String, dynamic>) {
      for (final key in ['apps_list', 'data', 'apps', 'items', 'results']) {
        final v = decoded[key];
        if (v is List) return v;
      }
      return [decoded];
    }

    return [];
  }

  /// جلب قائمة الصفوف من classes.php?id=...
  static Future<List<dynamic>> getClasses({required int id}) async {
    final uri =
    Uri.parse(CLASSES_API).replace(queryParameters: {'id': id.toString()});

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.trim().isEmpty) return [];

    final decoded = jsonDecode(res.body);

    if (decoded is Map<String, dynamic>) {
      final list = decoded['apps_list'];
      if (list is List) return list;
    } else if (decoded is List) {
      return decoded;
    }

    return [];
  }

  /// يبني Uri من قيمة server. إذا كانت مطلقة تُستخدم كما هي، وإن كانت نسبية تُلحق بـ APP_BASE_URL.
  static Uri _buildUriFromServer(String server) {
    final s = server.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) {
      return Uri.parse(s);
    }
    return Uri.parse('$APP_BASE_URL$s');
  }

  /// جلب قائمة عناصر عامة من endpoint يُعاد فيه المفتاح apps_list/subjects/... إلخ.
  static Future<List<dynamic>> getListFromServer(String server) async {
    final uri = _buildUriFromServer(server);

    final res = await http
        .get(uri, headers: {'Accept': 'application/json'})
        .timeout(const Duration(seconds: 20));

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    if (res.body.trim().isEmpty) return [];

    final decoded = jsonDecode(res.body);

    if (decoded is List) return decoded;

    if (decoded is Map<String, dynamic>) {
      // مفاتيح شائعة محتملة
      const keys = [
        'apps_list',
        'subjects',
        'subjects_list',
        'data',
        'items',
        'results'
      ];
      for (final k in keys) {
        final v = decoded[k];
        if (v is List) return v;
      }
      return [decoded];
    }

    return [];
  }
}