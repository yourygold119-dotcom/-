import 'package:google_mlkit_translation/google_mlkit_translation.dart';

/// خدمة الترجمة الفورية على الجهاز (بدون إنترنت)
///
/// تعمل عبر Google ML Kit — أول استخدام تحتاج تحميل حزمة اللغة،
/// ثم تعمل دون اتصال نهائياً.
class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final _modelManager = OnDeviceTranslatorModelManager();

  /// التحقق من توفر حزمة اللغة وتنزيلها عند الحاجة
  Future<bool> ensureModelDownloaded() async {
    const lang = TranslateLanguage.arabic;
    final hasAr = await _modelManager.isModelDownloaded(lang.bcpCode);
    final hasEn = await _modelManager
        .isModelDownloaded(TranslateLanguage.english.bcpCode);
    if (!hasAr) await _modelManager.downloadModel(lang.bcpCode);
    if (!hasEn) {
      await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }
    return true;
  }

  /// ترجمة النص إلى العربية
  Future<String> translateToArabic(String text) async {
    if (text.trim().isEmpty) return "";
    final translator = OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.arabic,
    );
    try {
      return await translator.translateText(text);
    } catch (e) {
      return "تعذرت الترجمة — تأكد من تنزيل حزمة اللغة أول مرة";
    } finally {
      translator.close();
    }
  }

  /// كشف بسيط: هل النص يحتاج ترجمة؟ (محتوى لاتيني)
  bool needsTranslation(String text) {
    final latin = RegExp(r'[a-zA-Z]').allMatches(text).length;
    return latin > 3;
  }
}
