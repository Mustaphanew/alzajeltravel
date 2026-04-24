import 'package:alzajeltravel/utils/base_url_config.dart';

/// ثوابت الـ Endpoints المستخدمة في التطبيق.
///
/// التسلسل الهرمي:
///   [baseUrl]     => نطاق السيرفر الخام (يأتي من [BaseUrlConfig])
///   [apiV1]       => بادئة نسخة الـ API  (غيّرها مستقبلاً إلى /api/v2 عند الحاجة)
///   [apiBaseUrl]  => [baseUrl] + [apiV1] ويُمرّر كـ Dio `baseUrl`
///   [login]… الخ  => مسارات نسبية تُلحق تلقائياً بـ [apiBaseUrl]
///
/// لبناء رابط كامل يدوياً (WebView / Print / Share …) استخدم [resolve].
///
/// ملاحظة مهمة: [baseUrl] و [apiBaseUrl] **getters** وليسا `const` لأن
/// الرابط يُحدَّد وقت التشغيل وفق FLAVOR (dev/prod) + Firebase Remote Config.
class AppApis {
  const AppApis._();

  /// نطاق السيرفر الخام بدون أي مسارات.
  ///
  /// - في dev: قيمة ثابتة بالكود داخل [BaseUrlConfig].
  /// - في prod: يُجلب من Firebase Remote Config (مفتاح `base_url`).
  static String get baseUrl => BaseUrlConfig.baseUrl;

  /// بادئة نسخة الـ API الحالية. غيّرها مرة واحدة هنا لتُرقّى كل المسارات.
  static const String apiV1 = '/api/v1';

  /// الـ Base URL الكامل الذي يُمرَّر إلى Dio كـ `BaseOptions.baseUrl`.
  /// مثال: `https://www.skytaap.net/api/v1`.
  static String get apiBaseUrl => '${BaseUrlConfig.baseUrl}$apiV1';

  // ───────────────────────────── Flight ─────────────────────────────
  static const String login = '/flight/agent-login';
  static const String logout = '/flight/agent-logout';
  static const String searchFlight = '/flight/search';
  static const String otherPricesFlight = '/flight/other-prices';
  static const String revalidateFlight = '/flight/revalidate';
  static const String createBookingFlight = '/flight/create-booking';
  static const String preBookFlight = '/flight/pre-book';
  static const String issueFlight = '/flight/issue';
  static const String cancelPnr = '/flight/cancel-pnr';
  static const String voidIssue = '/flight/void';
  static const String bookingsReport = '/flight/reports';
  static const String tripDetail = '/flight/trip/';

  // ──────────────────────────── Passport ────────────────────────────
  /// TODO: استبدل هذا المسار بالـ endpoint الفعلي لمسح الجواز/البطاقة.
  /// يستقبل ملف صورة (multipart/form-data، اسم الحقل: `image`) ويُرجع JSON
  /// متوافق مع PassportModel.fromJson (documentNumber / surnames / givenNames /
  /// dateOfBirth / sex / dateOfExpiry / nationality / issueCountry ...).
  static const String passportScan = '/passport/scan';

  // ──────────────────────────── Helpers ─────────────────────────────

  /// يُعيد الرابط الكامل لمسار نسبي عبر الدمج مع [apiBaseUrl].
  ///
  /// مثال:
  /// ```dart
  /// AppApis.resolve(AppApis.login); // https://www.skytaap.net/api/v1/flight/agent-login
  /// AppApis.resolve('flight/search'); // نفس الناتج مع إضافة /flight/search
  /// ```
  static String resolve(String path) {
    if (path.isEmpty) return apiBaseUrl;
    final normalized = path.startsWith('/') ? path : '/$path';
    return '$apiBaseUrl$normalized';
  }
}
