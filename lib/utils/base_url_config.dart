import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// مصدر الرابط الأساسي (`baseUrl`) للتطبيق.
///
/// الاعتماد على متغيّر Dart يتم حقنه **وقت البناء** عبر:
/// ```
/// --dart-define=FLAVOR=prod
/// ```
///
/// - **dev** (الافتراضي عند التطوير / `flutter run` العادي):
///   يُستخدم رابط ثابت في الكود [_devBaseUrl] — عدّله يدوياً عند الحاجة.
///
/// - **prod** (عند `flutter build appbundle --dart-define=FLAVOR=prod`):
///   يُجلب الرابط من **Firebase Remote Config** مفتاح [_rcKey]
///   ليمكن تغييره من الـ Console بدون رفع تحديث جديد لمتجر Google Play.
///
/// ملاحظات:
/// - [init] آمنة وإدارة الأخطاء كاملة فيها: عند فشل الشبكة/Firebase
///   يُستخدم [_prodFallback] تلقائياً لضمان استمرار عمل التطبيق.
/// - يُمكن استدعاء [refresh] لاحقاً لسحب قيمة جديدة من Remote Config.
class BaseUrlConfig {
  const BaseUrlConfig._();

  // ─────────────────────────── Flavor ───────────────────────────

  /// قيمة `FLAVOR` المحقونة وقت الترجمة. تُثبَّت في الـ binary.
  static const String flavor = String.fromEnvironment(
    'FLAVOR',
    defaultValue: 'dev',
  );

  static bool get isProd => flavor == 'prod';
  static bool get isDev => !isProd;

  // ─────────────────────── Dev (ثابت بالكود) ────────────────────

  /// ✏️ عدّل هذا الرابط يدوياً عند التطوير المحلّي إن احتجت.
  static const String _devBaseUrl = 'https://www.skytaap.net';

  // ─────────────── Prod (Firebase Remote Config) ────────────────

  /// اسم المعلمة كما في Firebase Console → Remote Config.
  static const String _rcKey = 'base_url';

  /// يُستخدم قبل أول sync من Remote Config أو عند فشل الاتصال.
  static const String _prodFallback = 'https://www.skytaap.net';

  /// القيمة الفعلية التي يستخدمها باقي التطبيق.
  static String _resolved = isProd ? _prodFallback : _devBaseUrl;

  /// الـ baseUrl الحالي (نطاق خام بدون مسارات، بدون شرطة في النهاية).
  static String get baseUrl => _resolved;

  // ─────────────────────────── Init ─────────────────────────────

  /// تُنفَّذ **مرة واحدة** في `main()` بعد `Firebase.initializeApp`.
  /// لا تلقي أي استثناء: أي فشل يُسجَّل وتُستخدم القيمة الاحتياطية.
  static Future<void> init() async {
    if (isDev) {
      if (kDebugMode) {
        debugPrint(
          '[BaseUrlConfig] flavor=$flavor → static baseUrl=$_resolved',
        );
      }
      return;
    }

    try {
      final rc = FirebaseRemoteConfig.instance;

      await rc.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          // أثناء التطوير لا نقيّد؛ في الإنتاج سحب كل ساعة كحد أقصى.
          minimumFetchInterval:
              kDebugMode ? Duration.zero : const Duration(hours: 1),
        ),
      );

      await rc.setDefaults(const {_rcKey: _prodFallback});

      await rc.fetchAndActivate();

      final fetched = rc.getString(_rcKey).trim();
      if (fetched.isNotEmpty) {
        _resolved = _normalize(fetched);
      }
    } catch (e, s) {
      if (kDebugMode) {
        debugPrint('[BaseUrlConfig] RemoteConfig fetch failed: $e\n$s');
      }
      // نُبقي على _prodFallback.
    }

    if (kDebugMode) {
      debugPrint('[BaseUrlConfig] flavor=$flavor → RC baseUrl=$_resolved');
    }
  }

  /// يسحب قيمة جديدة من Remote Config **فوراً** (مفيد لزر «تحديث»).
  /// يُرجع `true` إذا تغيّر الـ baseUrl بعد السحب.
  static Future<bool> refresh() async {
    if (isDev) return false;
    try {
      final rc = FirebaseRemoteConfig.instance;
      await rc.fetchAndActivate();
      final fetched = rc.getString(_rcKey).trim();
      if (fetched.isEmpty) return false;
      final normalized = _normalize(fetched);
      final changed = normalized != _resolved;
      _resolved = normalized;
      return changed;
    } catch (e) {
      if (kDebugMode) debugPrint('[BaseUrlConfig] refresh failed: $e');
      return false;
    }
  }

  // ─────────────────────────── Helpers ──────────────────────────

  /// يحذف الشرطة الأخيرة (إن وُجدت) لتفادي // عند الدمج مع المسارات.
  static String _normalize(String url) {
    final trimmed = url.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }
}
