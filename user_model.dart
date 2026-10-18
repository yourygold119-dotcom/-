import 'dart:convert';
import 'package:crypto/crypto.dart';

/// نتيجة محاولة الدخول
enum AuthStatus { success, wrongCredentials, tooManyAttempts, locked }

class AuthResult {
  final AuthStatus status;
  final String? sessionToken;
  final String message;
  AuthResult(this.status, {this.sessionToken, this.message = ""});
}

/// جلسة الأونر الحالية (رمز مؤقت)
class AdminSession {
  static String? _token;
  static DateTime? _expiresAt;

  static bool get isActive =>
      _token != null && _expiresAt != null && DateTime.now().isBefore(_expiresAt!);

  static void start(String token, {Duration duration = const Duration(hours: 2)}) {
    _token = token;
    _expiresAt = DateTime.now().add(duration);
  }

  static void end() {
    _token = null;
    _expiresAt = null;
  }
}

/// خدمة التحقق من هوية الأونر
///
/// ⚠️ ملاحظة أمنية للإنتاج:
/// هذا التحقق يجب أن يتم على السيرفر (Firebase Auth + Custom Claims).
/// النسخة الحالية محاكاة محلية للتطوير فقط — البصمة المخزنة هنا
/// يجب نقلها إلى متغير بيئة آمن على السيرفر.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // بصمة SHA-256 لكلمة مرور الأونر (نخزن البصمة فقط، وليس النص الصريح)
  // ⚠️ غيّر كلمة المرور فوراً وولّد بصمة جديدة قبل أي نشر
  static const String _ownerPasswordHash =
      "0f25eb1fb7249077a9e87d634b1718cbd6a6c01bc1c3e8db1628e06c13c7a445";

  static const String _ownerEmail = "owner@yuraa.app";

  // الحماية من محاولات التخمين (Brute Force)
  int _failedAttempts = 0;
  DateTime? _lockedUntil;

  static String _hash(String input) =>
      sha256.convert(utf8.encode(input)).toString();

  Future<AuthResult> signInOwner({
    required String email,
    required String password,
  }) async {
    // محاكاة زمن الاستجابة الشبكي
    await Future.delayed(const Duration(milliseconds: 600));

    // فحص القفل المؤقت
    if (_lockedUntil != null && DateTime.now().isBefore(_lockedUntil!)) {
      final remaining = _lockedUntil!.difference(DateTime.now()).inSeconds;
      return AuthResult(AuthStatus.locked,
          message: "محاولات كثيرة خاطئة. حاول بعد $remaining ثانية");
    }

    final emailOk = email.trim().toLowerCase() == _ownerEmail;
    final passOk = _hash(password) == _ownerPasswordHash;

    if (emailOk && passOk) {
      _failedAttempts = 0;
      _lockedUntil = null;
      // في الإنتاج: الرمز يصدره السيرفر (JWT)
      final token =
          "yuraa_${DateTime.now().millisecondsSinceEpoch}_${_hash(email + DateTime.now().toIso8601String()).substring(0, 16)}";
      AdminSession.start(token);
      return AuthResult(AuthStatus.success,
          sessionToken: token, message: "تم تسجيل الدخول لغرفة الحكم");
    }

    _failedAttempts++;
    if (_failedAttempts >= 5) {
      _lockedUntil = DateTime.now().add(const Duration(seconds: 30));
      _failedAttempts = 0;
      return AuthResult(AuthStatus.tooManyAttempts,
          message: "5 محاولات خاطئة — تم القفل لمدة 30 ثانية");
    }
    return AuthResult(AuthStatus.wrongCredentials,
        message: "البريد الإلكتروني أو كلمة المرور غير صحيحة");
  }

  void signOut() => AdminSession.end();

  /// بوابة أمنية: لا يسمح بأي إجراء إداري بدون جلسة صالحة
  bool get hasActiveAdminSession => AdminSession.isActive;
}
