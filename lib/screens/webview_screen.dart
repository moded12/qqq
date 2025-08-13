import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';

class WebViewScreen extends StatefulWidget {
  final String url;
  final String title;
  const WebViewScreen({super.key, required this.url, required this.title});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  double _progress = 0;
  late final String absUrl;
  late final String ext;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    absUrl = _toAbsoluteUrl(widget.url);
    ext = _getFileExtension(absUrl);

    if (_isVideo(ext)) {
      _videoController = VideoPlayerController.networkUrl(Uri.parse(absUrl));
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
      );
    }
    if (_isAudio(ext)) {
      _audioPlayer = AudioPlayer()..play(UrlSource(absUrl));
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _chewieController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  String _toAbsoluteUrl(String url) {
    final s = url.trim();
    if (s.startsWith('http://') || s.startsWith('https://')) return s;
    return 'https://www.shneler.com/uae-e-learning/service/$s';
  }

  String _getFileExtension(String url) {
    final path = Uri.parse(url).path.toLowerCase();
    // لو الرابط فيه php?id=.. أو لا يوجد نقطة، رجّع ''
    if (!path.contains('.') || path.contains('.php')) return '';
    return path.split('.').last;
  }

  bool _isImage(String ext) => ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp', 'svg'].contains(ext);
  bool _isPdf(String ext) => ext == 'pdf';
  bool _isOffice(String ext) => ['doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx'].contains(ext);
  bool _isVideo(String ext) => ['mp4', 'mov', 'webm', 'mkv', 'avi', 'flv'].contains(ext);
  bool _isAudio(String ext) => ['mp3', 'aac', 'wav', 'ogg', 'm4a'].contains(ext);
  // هنا فقط ملفات نصية صريحة (لا تحاول اكتشاف html أو php كملف نصي)
  bool _isText(String ext) => ['txt', 'csv', 'json', 'xml'].contains(ext);

  Future<void> _openExternally() async {
    final uri = Uri.parse(absUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذّر فتح الرابط خارجيًا')));
      }
    }
  }

  Widget _buildFileViewer() {
    // صور
    if (_isImage(ext)) {
      return InteractiveViewer(
        child: Center(child: Image.network(absUrl, fit: BoxFit.contain)),
      );
    }
    // PDF
    if (_isPdf(ext)) {
      final pdfUrl = 'https://drive.google.com/viewerng/viewer?embedded=true&hl=ar&url=${Uri.encodeComponent(absUrl)}';
      return _webView(pdfUrl);
    }
    // Office
    if (_isOffice(ext)) {
      final officeUrl = 'https://view.officeapps.live.com/op/embed.aspx?src=${Uri.encodeComponent(absUrl)}';
      return _webView(officeUrl);
    }
    // فيديو
    if (_isVideo(ext)) {
      if (_videoController == null || _chewieController == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return Chewie(controller: _chewieController!);
    }
    // صوت
    if (_isAudio(ext)) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.audiotrack, size: 64),
            Text('تشغيل صوتي'),
            ElevatedButton.icon(
              icon: const Icon(Icons.open_in_browser),
              label: const Text('فتح خارجيًا'),
              onPressed: _openExternally,
            ),
          ],
        ),
      );
    }
    // ملفات نصية فقط (txt, csv, json, xml) - لا تحاول أبداً جلب php/html كملف نصي
    if (_isText(ext)) {
      return FutureBuilder(
        future: _fetchText(absUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('تعذّر جلب الملف النصي: ${snapshot.error}'));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Text(snapshot.data ?? '', style: const TextStyle(fontFamily: 'monospace')),
          );
        },
      );
    }
    // كل ما عدا ذلك (أي رابط php أو رابط مباشر وليس له امتداد معروف) افتحه كـ WebView
    return _webView(absUrl);
  }

  Widget _webView(String url) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (p) => setState(() => _progress = p / 100),
          onPageStarted: (_) {},
          onPageFinished: (_) => setState(() => _progress = 0),
          onWebResourceError: (error) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('تعذر تحميل الصفحة: ${error.description}')),
              );
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
    return WebViewWidget(controller: controller);
  }

  Future<String> _fetchText(String url) async {
    final uri = Uri.parse(url);
    final httpClient = HttpClient();
    final req = await httpClient.getUrl(uri);
    final res = await req.close();
    final data = await res.transform(const Utf8Decoder()).join();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() {}),
            tooltip: 'تحديث',
          ),
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            onPressed: _openExternally,
            tooltip: 'فتح خارجيًا',
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildFileViewer(),
          if (_progress > 0 && _progress < 1)
            LinearProgressIndicator(value: _progress),
        ],
      ),
    );
  }
}