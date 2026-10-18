import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/video_item.dart';

/// فيديوهات تجريبية حقيقية (روابط عامة للاختبار)
const _demoVideos = [
  VideoItem(
    id: "v1",
    username: "@مصمم_يوراء",
    caption: "أول فيديو تجريبي على تطبيق يوراء! ✨ #يوراء #SuperApp",
    videoUrl:
        "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4",
    musicTrack: "Upbeat Pop 2026",
    likes: 1240,
  ),
  VideoItem(
    id: "v2",
    username: "@المطور_الذكي",
    caption: "كيف تبني تطبيقك الخاص بدون تعقيد 🚀",
    videoUrl:
        "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4",
    musicTrack: "Chill LoFi Beat",
    likes: 850,
  ),
  VideoItem(
    id: "v3",
    username: "@مستكشف_العالم",
    caption: "جولة في أجمل الأماكن الطبيعية 🌿",
    videoUrl:
        "https://storage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4",
    likes: 3400,
  ),
];

class ShortsScreen extends StatefulWidget {
  const ShortsScreen({super.key});
  @override
  State<ShortsScreen> createState() => _ShortsScreenState();
}

class _ShortsScreenState extends State<ShortsScreen> {
  bool _isCleanAudioMode = false;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // التصفح الرأسي الحقيقي — كل فيديو يشتغل/يتوقف حسب ظهوره
          PageView.builder(
            scrollDirection: Axis.vertical,
            itemCount: _demoVideos.length,
            onPageChanged: (i) => setState(() => _currentIndex = i),
            itemBuilder: (context, index) => _VideoPlayerItem(
              video: _demoVideos[index],
              isActive: index == _currentIndex,
              cleanMode: _isCleanAudioMode,
            ),
          ),
          // زر الوضع النقي (كتم الموسيقى)
          Positioned(
            top: 12,
            right: 16,
            child: GestureDetector(
              onTap: () => setState(() => _isCleanAudioMode = !_isCleanAudioMode),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isCleanAudioMode ? Colors.green[700] : Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white30),
                ),
                child: Row(
                  children: [
                    Icon(
                      _isCleanAudioMode ? Icons.music_off : Icons.music_note,
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isCleanAudioMode ? "وضع نقي" : "موسيقى",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// عنصر الفيديو الواحد — مشغل حقيقي مع تتبع النشاط
class _VideoPlayerItem extends StatefulWidget {
  final VideoItem video;
  final bool isActive;
  final bool cleanMode;
  const _VideoPlayerItem({
    required this.video,
    required this.isActive,
    required this.cleanMode,
  });

  @override
  State<_VideoPlayerItem> createState() => _VideoPlayerItemState();
}

class _VideoPlayerItemState extends State<_VideoPlayerItem> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _pausedByTap = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.video.videoUrl))
      ..setLooping(true)
      ..initialize().then((_) {
        if (mounted) setState(() => _initialized = true);
      });
  }

  @override
  void didUpdateWidget(covariant _VideoPlayerItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    // تشغيل الفيديو الظاهر وإيقاف غير الظاهر تلقائياً
    if (widget.isActive && !_pausedByTap) {
      _controller.play();
    } else {
      _controller.pause();
    }
    // الوضع النقي: كتم الصوت فعلياً
    _controller.setVolume(widget.cleanMode ? 0.0 : 1.0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    return GestureDetector(
      onTap: () {
        setState(() => _pausedByTap = !_pausedByTap);
        _pausedByTap ? _controller.pause() : _controller.play();
      },
      child: Stack(
        fit: StackFit.expand, // ✅ الإصلاح: StackFit.expand
        children: [
          // الفيديو الحقيقي
          _initialized
              ? Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                )
              : const Center(
                  child:
                      CircularProgressIndicator(color: Colors.amber)),
          if (_pausedByTap)
            const Center(
              child: Icon(Icons.play_arrow, size: 80, color: Colors.white70),
            ),
          // تفاصيل الفيديو
          Positioned(
            bottom: 20,
            left: 15,
            right: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(video.username,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 8),
                Text(video.caption,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 14)),
                if (video.musicTrack != null && !widget.cleanMode) ...[
                  const SizedBox(height: 6),
                  Row(children: [
                    const Icon(Icons.music_note,
                        color: Colors.white54, size: 14),
                    Text(" ${video.musicTrack}",
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ]),
                ],
              ],
            ),
          ),
          // أزرار التفاعل
          Positioned(
            bottom: 40,
            right: 15,
            child: Column(children: [
              IconButton(
                icon: Icon(
                  video.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: video.isLiked ? Colors.red : Colors.white,
                  size: 35,
                ),
                onPressed: () => setState(() {
                  video.isLiked = !video.isLiked;
                  video.likes += video.isLiked ? 1 : -1;
                }),
              ),
              Text("${video.likes}",
                  style: const TextStyle(color: Colors.white, fontSize: 12)),
              const SizedBox(height: 20),
              IconButton(
                  icon: const Icon(Icons.comment, color: Colors.white, size: 32),
                  onPressed: () {}),
              const SizedBox(height: 20),
              IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 32),
                  onPressed: () {}),
            ]),
          ),
        ],
      ),
    );
  }
}
