// 📄 lib/services/update_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  // رابط ملف JSON الموجود على الخادم
  static const _updateConfigUrl =
      'https://www.shneler.com/oman/api/shrohat/update.json';

  /// يفحص نسخة التطبيق مقارنةً بالنسخة الأحدث في JSON
  /// ويعرض الحوار مرة واحدة فقط لكل إصدار جديد
  static Future<void> checkForUpdate(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(_updateConfigUrl));
      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      final latestCode = data['latest_version_code'] as int;
      final force = data['force_update'] as bool;
      final url = Platform.isIOS
          ? data['update_url_ios'] as String
          : data['update_url_android'] as String;

      final info = await PackageInfo.fromPlatform();
      final currentCode = int.tryParse(info.buildNumber) ?? 0;

      // إذا الإصدار الأحدث ليس أكبر من الإصدار الحالي، لا شيء لنعرضه
      if (latestCode <= currentCode) return;

      // جلب آخر إصدار عُرض المستخدم عليه
      final prefs = await SharedPreferences.getInstance();
      final shownCode = prefs.getInt('last_update_shown_code') ?? 0;

      // إذا سبق وعُرض الحوار لهذا الإصدار، لا نعيد عرضه
      if (latestCode <= shownCode) return;

      // احفظ هذا الإصدار كـ "مُعرض"
      await prefs.setInt('last_update_shown_code', latestCode);

      // عرض الحوار
      _showUpdateDialog(
        context,
        version: data['latest_version'] as String,
        url: url,
        force: force,
      );
    } catch (_) {
      // تجاهل أي خطأ في الفحص
    }
  }

  static void _showUpdateDialog(
      BuildContext context, {
        required String version,
        required String url,
        required bool force,
      }) {
    showDialog(
      context: context,
      barrierDismissible: !force,
      builder: (_) => AlertDialog(
        title: const Text('تحديث جديد متوفر'),
        content: Text('يرجى التحديث إلى الإصدار $version للاستمرار.'),
        actions: [
          if (!force)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('لاحقاً'),
            ),
          TextButton(
            onPressed: () async {
              await launchUrl(
                Uri.parse(url),
                mode: LaunchMode.externalApplication,
              );
              if (force) {
                // إذا كان التحديث إجباريًا، يمكنك إنهاء التطبيق هنا:
                // SystemNavigator.pop();
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }
}
