import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/database_service.dart';

/// تايم لاين مجتمع يوراء — متصل بطبقة البيانات
class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});
  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final _db = DatabaseService.instance;

  void _openCreatePostDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("إضافة منشور جديد ✍️"),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "ما الذي يدور في ذهنك؟ شارك مجتمع يوراء...",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("إلغاء")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _db.addPost("أنت (اسمك المستعار)", controller.text.trim());
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("تم نشر منشورك في تايم لاين يوراء بنجاح! 🎉")),
                  );
                }
              }
            },
            child: const Text("نشر", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _db,
      builder: (context, _) {
        final posts = _db.posts;
        return Scaffold(
          backgroundColor: Colors.grey[100],
          body: ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) =>
                _PostCard(post: posts[index]),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.amber[800],
            onPressed: _openCreatePostDialog,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        );
      },
    );
  }
}

class _PostCard extends StatefulWidget {
  final PostModel post;
  const _PostCard({required this.post});
  @override
  State<_PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<_PostCard> {
  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: Colors.amber[700],
                child: Text(post.username[0],
                    style: const TextStyle(color: Colors.white)),
              ),
              const SizedBox(width: 10),
              Text(post.username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
            ]),
            const SizedBox(height: 12),
            Text(post.contentText,
                style: const TextStyle(fontSize: 15, color: Colors.black87)),
            const SizedBox(height: 10),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  onPressed: () => setState(() {
                    post.isLiked = !post.isLiked;
                    post.likesCount += post.isLiked ? 1 : -1;
                  }),
                  icon: Icon(
                    post.isLiked
                        ? Icons.local_fire_department
                        : Icons.local_fire_department_outlined,
                    color: post.isLiked ? Colors.orange : Colors.grey,
                  ),
                  label: Text("${post.likesCount} تفاعل",
                      style: const TextStyle(color: Colors.black54)),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.mode_comment_outlined,
                      color: Colors.grey),
                  label: Text("${post.commentsCount} تعليق",
                      style: const TextStyle(color: Colors.black54)),
                ),
                IconButton(
                    icon: const Icon(Icons.share_outlined, color: Colors.grey),
                    onPressed: () {}),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
