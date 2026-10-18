import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';

/// طبقة البيانات الموحدة لتطبيق يوراء
///
/// ⚠️ للإنتاج: استبدل هذا الملف بربط Firebase/Firestore أو Supabase.
/// التصميم الحالي (ChangeNotifier + دوال async) يسمح بالاستبدال
/// دون تغيير أي شاشة من الشاشات.
class DatabaseService extends ChangeNotifier {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  // ---------- المستخدمون ----------
  final List<UserModel> users = [
    UserModel(
      id: "usr_101",
      username: "صقر الفضاء",
      realName: "محمود إبراهيم",
      phoneNumber: "+201112223344",
      email: "mahmoud@gmail.com",
      warningCount: 1,
    ),
    UserModel(
      id: "usr_102",
      username: "نسمة ربيع",
      realName: "سارة أحمد",
      phoneNumber: "+201009988776",
      email: "sara@yahoo.com",
    ),
    UserModel(
      id: "usr_103",
      username: "سفير_الهدوء",
      realName: "أحمد محمد",
      phoneNumber: "+201000000000",
      email: "ahmed@example.com",
    ),
  ];

  // ---------- المنشورات ----------
  final List<PostModel> posts = [
    PostModel(
      id: "p1",
      username: "سفير_الهدوء",
      contentText: "أهلاً بالجميع في التطبيق الفائق يوراء! تجربة فريدة وأمان تام 🚀✨",
      likesCount: 42,
      commentsCount: 5,
    ),
    PostModel(
      id: "p2",
      username: "صقر_الفضاء",
      contentText: "قمت للتو بتجربة فلاتر الكاميرا الجديدة وتصوير فيديو بها، النتيجة مذهلة! 🎬🔥",
      imageUrl: "https://example.com/post_image.jpg",
      likesCount: 128,
      commentsCount: 19,
    ),
  ];

  UserModel? getUserById(String id) {
    try {
      return users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addPost(String username, String content) async {
    posts.insert(
      0,
      PostModel(
        id: "p_${DateTime.now().millisecondsSinceEpoch}",
        username: username,
        contentText: content,
        likesCount: 0,
        commentsCount: 0,
      ),
    );
    notifyListeners();
  }

  // ---------- إجراءات غرفة الحكم ----------
  // كل الإجراءات تتطلب جلسة أونر صالحة (تُفحص في الشاشات عبر AuthService)

  /// إرسال تحذير — 3 تحذيرات = حظر تلقائي نهائي
  Future<void> issueWarning(String userId) async {
    final user = getUserById(userId);
    if (user == null || user.isBanned) return;
    user.warningCount++;
    if (user.warningCount >= UserModel.maxWarnings) {
      user.isBanned = true; // حظر تلقائي
    }
    notifyListeners();
  }

  /// مسح الحساب وحظره نهائياً
  Future<void> banUser(String userId) async {
    final user = getUserById(userId);
    if (user == null) return;
    user.isBanned = true;
    notifyListeners();
  }

  /// إلغاء الحظر (مع تصفير التحذيرات)
  Future<void> unbanUser(String userId) async {
    final user = getUserById(userId);
    if (user == null) return;
    user.isBanned = false;
    user.warningCount = 0;
    notifyListeners();
  }

  int get bannedCount => users.where((u) => u.isBanned).length;
}
