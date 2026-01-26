import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class TranslatorService {
  final OnDeviceTranslator _translator = OnDeviceTranslator(
    sourceLanguage: TranslateLanguage.english,
    targetLanguage: TranslateLanguage.arabic,
  );

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  /// تأكد من تنزيل موديل العربي والإنجليزي (على الجهاز).
  Future<void> ensureModelsDownloaded() async {
    final hasEn = await _modelManager.isModelDownloaded(TranslateLanguage.english.bcpCode);
    final hasAr = await _modelManager.isModelDownloaded(TranslateLanguage.arabic.bcpCode);

    if (!hasEn) {
      await _modelManager.downloadModel(TranslateLanguage.english.bcpCode);
    }
    if (!hasAr) {
      await _modelManager.downloadModel(TranslateLanguage.arabic.bcpCode);
    }
  }

  /// ترجمة نص
  Future<String> translateEnToAr(String text) async {
    if (text.trim().isEmpty) return text;
    // الأفضل تتأكد أن الموديلات نازلة قبل أول ترجمة
    await ensureModelsDownloaded();
    final txt = text.toLowerCase().replaceAll("tkt", "ticket");
    return _translator.translateText(txt); 
  }

  /// مهم: أغلق المترجم لتفادي تسريب موارد
  Future<void> dispose() async {
    await _translator.close();
  }
}
