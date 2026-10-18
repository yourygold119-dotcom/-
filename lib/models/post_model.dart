/// نموذج المنشور الواحد في تايم لاين يوراء
class PostModel {
  final String id;
  final String username; // الاسم المستعار الظاهر للجمهور
  final String contentText;
  final String? imageUrl;
  int likesCount;
  int commentsCount;
  bool isLiked;

  PostModel({
    required this.id,
    required this.username,
    required this.contentText,
    this.imageUrl,
    required this.likesCount,
    required this.commentsCount,
    this.isLiked = false,
  });
}
