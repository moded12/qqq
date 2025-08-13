import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:photo_view/photo_view.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ViewMaterialScreen extends StatefulWidget {
  final String title;
  final String fileType;
  final List<String> fileLinks;

  const ViewMaterialScreen({
    super.key,
    required this.title,
    required this.fileType,
    required this.fileLinks,
  });

  @override
  State<ViewMaterialScreen> createState() => _ViewMaterialScreenState();
}

class _ViewMaterialScreenState extends State<ViewMaterialScreen> {
  bool isLoading = true;
  bool hasError = false;

  late final String url;
  late final String type;
  WebViewController? webController;
  VideoPlayerController? videoController;
  ChewieController? chewieController;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  @override
  void initState() {
    super.initState();
    url = widget.fileLinks.first;
    type = widget.fileType;

    // Banner initialization (ضع وحدة إعلانك الفعلية هنا)
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-8177765238464378/2290295726',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _bannerLoaded = true);
        },
        onAdFailedToLoad: (ad, err) {
          ad.dispose();
        },
      ),
    )..load();

    _initialize();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    videoController?.dispose();
    chewieController?.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      if (type == 'video') {
        videoController = VideoPlayerController.networkUrl(Uri.parse(url));
        await videoController!.initialize();
        chewieController = ChewieController(
          videoPlayerController: videoController!,
          autoPlay: true,
          looping: false,
        );
        if (mounted) setState(() => isLoading = false);
      } else if (_isImageUrl(url)) {
        if (mounted) setState(() => isLoading = false);
      } else {
        final viewerUrl = _isPdfUrl(url)
            ? 'https://docs.google.com/gview?embedded=true&url=$url'
            : _getOfficeViewerUrl(url) ?? url;

        webController = WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageFinished: (_) {
                setState(() => isLoading = false);
              },
              onWebResourceError: (_) {
                hasError = true;
                setState(() => isLoading = false);
              },
            ),
          )
          ..loadRequest(Uri.parse(viewerUrl));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    }
  }

  bool _isImageUrl(String url) {
    final lower = url.toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.gif') ||
        lower.endsWith('.webp');
  }

  bool _isPdfUrl(String url) {
    return url.toLowerCase().endsWith('.pdf');
  }

  String? _getOfficeViewerUrl(String url) {
    final lower = url.toLowerCase();
    if (lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.xls') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.ppt') ||
        lower.endsWith('.pptx')) {
      return 'https://view.officeapps.live.com/op/embed.aspx?src=$url';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final iconColor = isDark ? Colors.orangeAccent : Colors.blueAccent;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _buildContent(iconColor),
                  if (isLoading)
                    Container(
                      color: Colors.black.withOpacity(0.2),
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
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
                ),
                width: _bannerAd!.size.width.toDouble(),
                height: _bannerAd!.size.height.toDouble(),
                child: AdWidget(ad: _bannerAd!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color iconColor) {
    if (hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: iconColor, size: 48),
            const SizedBox(height: 12),
            const Text("لا يمكن عرض الملف. جرب فتحه في المتصفح مباشرة."),
          ],
        ),
      );
    }

    if (_isImageUrl(url)) {
      return PhotoView(
        imageProvider: NetworkImage(url),
        backgroundDecoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
      );
    }

    if (type == 'video') {
      return chewieController != null
          ? Chewie(controller: chewieController!)
          : const Center(child: Text('فشل تشغيل الفيديو'));
    }

    if (webController != null) {
      return WebViewWidget(controller: webController!);
    }

    return const Center(child: Text('لا يمكن عرض الملف'));
  }
}