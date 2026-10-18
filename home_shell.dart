/// نموذج الفيديو الواحد في قسم الشورتس
class VideoItem {
  final String id;
  final String username;
  final String caption;
  final String videoUrl;
  final String? musicTrack; // اسم المقطع الموسيقي (للوضع النقي)
  int likes;
  bool isLiked;

  VideoItem({
    required this.id,
    required this.username,
    required this.caption,
    required this.videoUrl,
    this.musicTrack,
    required this.likes,
    this.isLiked = false,
  });
}
