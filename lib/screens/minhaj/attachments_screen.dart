import 'package:flutter/material.dart';
import '../../service/api_service.dart';
import '../webview_screen.dart';

class AttachmentsScreen extends StatefulWidget {
  final int lessonId;
  final String headerTitle;
  const AttachmentsScreen({
    super.key,
    required this.lessonId,
    required this.headerTitle,
  });

  @override
  State<AttachmentsScreen> createState() => _AttachmentsScreenState();
}

class _AttachmentsScreenState extends State<AttachmentsScreen> {
  final ApiService api = ApiService();
  bool loading = true;
  String? error;
  List<AttachmentModel> files = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      loading = true;
      error = null;
    });
    try {
      final list = await api.getAttachments(lessonId: widget.lessonId);
      setState(() => files = list);
      // إذا كان هناك مرفق واحد فقط، افتحه مباشرة
      if (list.length == 1) {
        Future.delayed(Duration.zero, () {
          _openAttachment(context, list.first);
        });
      }
    } catch (e) {
      setState(() => error = e.toString());
    }
    setState(() => loading = false);
  }

  void _openAttachment(BuildContext context, AttachmentModel file) {
    if (file.url == null || file.url!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرابط غير متوفر')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewScreen(
          url: file.url!,
          title: file.title ?? 'مرفق',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.headerTitle),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : error != null
          ? Center(child: Text('حدث خطأ: $error'))
          : files.isEmpty
          ? const Center(child: Text('لا توجد مرفقات لهذا الدرس'))
          : ListView.separated(
        padding: const EdgeInsets.all(8),
        itemCount: files.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final file = files[i];
          return ListTile(
            leading: const Icon(Icons.book),
            title: Text(file.title ?? 'مرفق'),
            subtitle: Text(file.url ?? ''),
            onTap: () => _openAttachment(context, file),
          );
        },
      ),
    );
  }
}