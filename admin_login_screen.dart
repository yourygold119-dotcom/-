/// نموذج المستخدم في تطبيق يوراء
class UserModel {
  final String id;
  // البيانات الظاهرة للجمهور
  String username; // الاسم المستعار
  String? avatarUrl;

  // البيانات الحقيقية والسرية (تظهر فقط في غرفة الحكم للأونر)
  final String realName;
  final String phoneNumber;
  final String email;

  // الصلاحيات وحالة الحساب
  // ملاحظة أمنية: isOwner يجب أن تُضبط من السيرفر فقط (Firebase Custom Claims)
  // ولا يجوز أبداً تعديلها من داخل التطبيق
  final bool isOwner;
  bool isBanned;
  int warningCount;

  static const int maxWarnings = 3; // عدد التحذيرات قبل الحظر التلقائي

  UserModel({
    required this.id,
    required this.username,
    required this.realName,
    required this.phoneNumber,
    required this.email,
    this.avatarUrl,
    this.isOwner = false,
    this.isBanned = false,
    this.warningCount = 0,
  });

  bool get isAutoBanned => warningCount >= maxWarnings;

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'realName': realName,
        'phoneNumber': phoneNumber,
        'email': email,
        'avatarUrl': avatarUrl,
        'isOwner': isOwner,
        'isBanned': isBanned,
        'warningCount': warningCount,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        username: json['username'],
        realName: json['realName'],
        phoneNumber: json['phoneNumber'],
        email: json['email'],
        avatarUrl: json['avatarUrl'],
        isOwner: json['isOwner'] ?? false,
        isBanned: json['isBanned'] ?? false,
        warningCount: json['warningCount'] ?? 0,
      );
}
