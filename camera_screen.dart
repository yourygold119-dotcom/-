import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';

/// لوحة التحكم الشاملة لغرفة الحكم
class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;

    // بوابة أمنية: إن انتهت الجلسة نطرد من الغرفة فوراً
    if (!AuthService.instance.hasActiveAdminSession) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) Navigator.pop(context);
      });
    }

    return AnimatedBuilder(
      animation: db,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("غرفة الحكم - لوحة التحكم الشاملة"),
            backgroundColor: Colors.red[900],
            actions: [
              IconButton(
                tooltip: "تسجيل الخروج",
                icon: const Icon(Icons.logout, color: Colors.white),
                onPressed: () {
                  AuthService.instance.signOut();
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              // ملخص سريع
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.red[50],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _StatChip(
                        label: "إجمالي المستخدمين",
                        value: "${db.users.length}"),
                    _StatChip(
                        label: "محظورون",
                        value: "${db.bannedCount}",
                        color: Colors.red),
                    _StatChip(
                        label: "بتحذيرات",
                        value:
                            "${db.users.where((u) => u.warningCount > 0 && !u.isBanned).length}",
                        color: Colors.orange),
                  ],
                ),
              ),
              // قائمة المستخدمين
              Expanded(
                child: ListView.builder(
                  itemCount: db.users.length,
                  itemBuilder: (context, index) {
                    final user = db.users[index];
                    return _UserAdminCard(user: user);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.label, required this.value, this.color = Colors.black87});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color)),
      Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }
}

class _UserAdminCard extends StatelessWidget {
  final UserModel user;
  const _UserAdminCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService.instance;
    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        side: user.isBanned
            ? const BorderSide(color: Colors.red, width: 2)
            : BorderSide.none,
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: user.isBanned ? Colors.red : Colors.blueAccent,
          child: Text(user.username[0]),
        ),
        title: Row(children: [
          Flexible(child: Text("الاسم المستعار: ${user.username}")),
          if (user.isBanned)
            const Padding(
              padding: EdgeInsets.only(right: 6),
              child: Chip(
                label: Text("محظور",
                    style: TextStyle(fontSize: 10, color: Colors.white)),
                backgroundColor: Colors.red,
                padding: EdgeInsets.zero,
              ),
            ),
        ]),
        subtitle: Text(
          "الاسم الحقيقي: ${user.realName}
الهاتف: ${user.phoneNumber}
البريد: ${user.email}
الإنذارات: ${user.warningCount}/${UserModel.maxWarnings}${user.isAutoBanned && !user.isBanned ? ' — سيتم الحظر تلقائياً' : ''}",
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (value) async {
            switch (value) {
              case 'warning':
                await db.issueWarning(user.id);
                if (context.mounted) {
                  final autoBanned = user.isAutoBanned;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(autoBanned
                          ? "⚠️ وصل ${user.username} لـ ${UserModel.maxWarnings} تحذيرات — تم الحظر التلقائي!"
                          : "تم إرسال تحذير لـ ${user.username} (${user.warningCount}/${UserModel.maxWarnings})"),
                    ),
                  );
                }
                break;
              case 'ban':
                await db.banUser(user.id);
                break;
              case 'unban':
                await db.unbanUser(user.id);
                break;
            }
          },
          itemBuilder: (_) => [
            const PopupMenuItem(
                value: 'warning', child: Text("إرسال تحذير ⚠️")),
            if (user.isBanned)
              const PopupMenuItem(
                  value: 'unban', child: Text("إلغاء الحظر ✅"))
            else
              const PopupMenuItem(
                value: 'ban',
                child: Text("مسح الحساب وحظره نهائياً",
                    style: TextStyle(color: Colors.red)),
              ),
          ],
        ),
      ),
    );
  }
}
