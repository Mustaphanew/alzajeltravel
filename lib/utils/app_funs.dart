import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:get/get.dart';
import 'app_vars.dart';
import 'package:url_launcher/url_launcher.dart';

class AppFuns {
  static void setUpRebuild() {
    AppVars.appLocale = AppVars.getStorage.read("lang") == null ? Get.deviceLocale : Locale(AppVars.getStorage.read("lang"));
    AppVars.lang = AppVars.appLocale?.languageCode;
    print("lang app: ${AppVars.lang}");
    if (AppVars.getStorage.read("theme_mode") == null) {
      AppVars.appThemeMode = ThemeMode.system;
    } else if (AppVars.getStorage.read("theme_mode") == "light") {
      AppVars.appThemeMode = ThemeMode.light;
    } else if (AppVars.getStorage.read("theme_mode") == "dark") {
      AppVars.appThemeMode = ThemeMode.dark;
    }
  }

  static mySnackBar(String message, String id) {
    return Get.snackbar(
      snackPosition: SnackPosition.BOTTOM,
      "",
      "",
      margin: EdgeInsets.all(15),
      duration: Duration(seconds: 5),
      titleText: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "تنبية!",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: AppConsts.lg),
                ),
                SizedBox(height: 8),
                Text(message, style: TextStyle(height: 1.3)),
              ],
            ),
          ),
          SizedBox(width: 4),
          TextButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppConsts.secondaryColor),
            child: Text("التنزيلات"),
            onPressed: () {},
          ),
        ],
      ),
      messageText: SizedBox(height: 0, width: 0),
      backgroundColor: Colors.white,
    );
  }

  static themeSearch(BuildContext context) {
    return Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: EdgeInsets.only(top: 0, left: 10, right: 10, bottom: 0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4), gapPadding: 0),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConsts.tertiaryColor[300]!),
          borderRadius: BorderRadius.circular(4),
          gapPadding: 0,
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppConsts.primaryColor),
          borderRadius: BorderRadius.circular(4),
          gapPadding: 0,
        ),
        disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4), gapPadding: 0),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          gapPadding: 0,
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.red),
          gapPadding: 0,
        ),
        labelStyle: TextStyle(height: 1),
        hintStyle: TextStyle(height: 1.5, color: AppConsts.tertiaryColor[400]), // height: 2.5
        helperStyle: TextStyle(height: 1.4),
        helperMaxLines: 3,
        fillColor: Colors.white,
        filled: true,
        errorStyle: TextStyle(height: 0.8, color: Colors.red),
      ),
      textTheme: Theme.of(
        context,
      ).textTheme.apply(fontFamily: AppConsts.font, bodyColor: Colors.black, displayColor: Colors.black, fontSizeFactor: 0.8),
      appBarTheme: AppBarTheme(titleSpacing: -8, backgroundColor: AppConsts.secondaryColor),
    );
  }

  String convertArabicToHex(String url) {
    String urlhex = url
        .replaceAll("ا", "%D8%A7")
        .replaceAll("ب", "%D8%A8")
        .replaceAll("ت", "%D8%AA")
        .replaceAll("ث", "%D8%AB")
        .replaceAll("ج", "%D8%AC")
        .replaceAll("ح", "%D8%AD")
        .replaceAll("خ", "%D8%AE")
        .replaceAll("د", "%D8%AF")
        .replaceAll("ذ", "%D8%B0")
        .replaceAll("ر", "%D8%B1")
        .replaceAll("ز", "%D8%B2")
        .replaceAll("س", "%D8%B3")
        .replaceAll("ش", "%D8%B4")
        .replaceAll("ص", "%D8%B5")
        .replaceAll("ض", "%D8%B6")
        .replaceAll("ط", "%D8%B7")
        .replaceAll("ظ", "%D8%B8")
        .replaceAll("ع", "%D8%B9")
        .replaceAll("غ", "%D8%BA")
        .replaceAll("ف", "%D9%81")
        .replaceAll("ق", "%D9%82")
        .replaceAll("ك", "%D9%83")
        .replaceAll("ل", "%D9%84")
        .replaceAll("م", "%D9%85")
        .replaceAll("ن", "%D9%86")
        .replaceAll("ه", "%D9%87")
        .replaceAll("ة", "%D8%A9")
        .replaceAll("و", "%D9%88")
        .replaceAll("ي", "%D9%8A")
        .replaceAll("ؤ", "%D8%A4")
        .replaceAll("ء", "%D8%A1")
        .replaceAll("ئ", "%D8%A6")
        .replaceAll("أ", "%D8%A3")
        .replaceAll("إ", "%D8%A5")
        .replaceAll("آ", "%D8%A2")
        .replaceAll(" ", "%20")
        .replaceAll("َ", "%D9%8E")
        .replaceAll("ً", "%D9%8B")
        .replaceAll("ُ", "%D9%8F")
        .replaceAll("ٌ", "%D9%8C")
        .replaceAll("ِ", "%D9%90")
        .replaceAll("ٍ", "%D9%8D");
    return urlhex;
  }

  String convertHexToArabic(String path) {
    String filterpath = path
        .replaceAll("%D8%A7", "ا")
        .replaceAll("%D8%A8", "ب")
        .replaceAll("%D8%AA", "ت")
        .replaceAll("%D8%AB", "ث")
        .replaceAll("%D8%AC", "ج")
        .replaceAll("%D8%AD", "ح")
        .replaceAll("%D8%AE", "خ")
        .replaceAll("%D8%AF", "د")
        .replaceAll("%D8%B0", "ذ")
        .replaceAll("%D8%B1", "ر")
        .replaceAll("%D8%B2", "ز")
        .replaceAll("%D8%B3", "س")
        .replaceAll("%D8%B4", "ش")
        .replaceAll("%D8%B5", "ص")
        .replaceAll("%D8%B6", "ض")
        .replaceAll("%D8%B7", "ط")
        .replaceAll("%D8%B8", "ظ")
        .replaceAll("%D8%B9", "ع")
        .replaceAll("%D8%BA", "غ")
        .replaceAll("%D9%81", "ف")
        .replaceAll("%D9%82", "ق")
        .replaceAll("%D9%83", "ك")
        .replaceAll("%D9%84", "ل")
        .replaceAll("%D9%85", "م")
        .replaceAll("%D9%86", "ن")
        .replaceAll("%D9%87", "ه")
        .replaceAll("%D8%A9", "ة")
        .replaceAll("%D9%88", "و")
        .replaceAll("%D9%8A", "ي")
        .replaceAll("%D8%A4", "ؤ")
        .replaceAll("%D8%A1", "ء")
        .replaceAll("%D8%A6", "ئ")
        .replaceAll("%D8%A3", "أ")
        .replaceAll("%D8%A5", "إ")
        .replaceAll("%D8%A2", "آ")
        .replaceAll("%20", " ")
        .replaceAll("%D9%8E", "َ")
        .replaceAll("%D9%8B", "ً")
        .replaceAll("%D9%8F", "ُ")
        .replaceAll("%D9%8C", "ٌ")
        .replaceAll("%D9%90", "ِ")
        .replaceAll("%D9%8D", "ٍ");
    return filterpath;
  }

  static String replaceArabicNumbers(String input, {withPeriods = false}) {
    const arabicNumbers = [
      '٠'
      , '١'
      , '٢'
      , '٣'
      , '٤'
      , '٥'
      , '٦'
      , '٧'
      , '٨'
      , '٩'
      , '۲'
      , '۳'
      , '۴'
      , '۵'
      , '۶'
      , '۷'
      , '۸'
      , '۹'
    ];
    const englishNumbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '2', '3', '4', '5', '6', '7', '8', '9'];
    for (int i = 0; i < arabicNumbers.length; i++) {
      input = input.replaceAll(arabicNumbers[i], englishNumbers[i]); 
    }
    if (withPeriods) {
      input = input.replaceAll('ص', 'AM');
      input = input.replaceAll('م', 'PM');
    }
    return input;
  }

  /// يحوّل أي قيمة (bool/String/num) إلى bool بشكل موحّد
  static bool toBool(dynamic v) {
    if (v == null) return false;
    if (v is bool) return v;
    if (v is num) return v != 0; // 1 -> true, 0 -> false
    if (v is String) {
      final s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes' || s == 'y' || s == 'ok') return true;
      if (s == 'false' || s == '0' || s == 'no' || s == 'n') return false;
    }
    // قيمة غير معروفة أو null -> اختَر الافتراضي (false)
    return false;
  }

  static toNum(dynamic v, {num defaultValue = 0, bool stripCommas = false}) {
    if (v == null) return defaultValue;
    if (v is num) return v;
    if (v is String) {
      var s = v.trim();
      if (stripCommas) s = s.replaceAll(',', ''); // اختياري
      final parsed = num.tryParse(s);
      return parsed ?? defaultValue;
    }
    return defaultValue;
  }

  static String priceWithCoin(dynamic price, String coin) {
    final NumberFormat moneyFormat = NumberFormat('#,##0.00', 'en_US');
    if (price == null) return '';
    return '${moneyFormat.format(toNum(price))} $coin';
  }

  static String formatDobPretty(DateTime? date, {String? locale}) {
    if (date == null) return '';
    // مثال: 2025-Jan-01 → نحولها بعدها لحروف صغيرة
    final raw = DateFormat('yyyy-MMM-dd', locale).format(date);
    return AppFuns.replaceArabicNumbers(raw.toLowerCase()); // => 2025-jan-01
  }

  static String cabinNameFromBookingClass(String? bookingClass) {
    final code = (bookingClass ?? '').trim().toUpperCase();
    if (code.isEmpty) return 'Unknown'.tr;

    // Most common mapping (airline-dependent, but widely used as a fallback)
    const first = {'F', 'A'};
    const business = {'J', 'C', 'D', 'I', 'Z', 'P'};
    const premium = {'W', 'R'}; // sometimes airline-specific extras exist
    const economy = {'Y', 'B', 'M', 'H', 'K', 'L', 'Q', 'T', 'V', 'S', 'N', 'O', 'G', 'U', 'E', 'X'};

    if (first.contains(code)) return 'First'.tr;
    if (business.contains(code)) return 'Business'.tr;
    if (premium.contains(code)) return 'Premium'.tr;
    if (economy.contains(code)) return 'Economy'.tr;

    return 'Unknown'.tr;
  }

  static String airlineImgURL(String code) {
    final c = code.trim().toUpperCase();
    return "https://mustaphanew.github.io/airlines/$c.png";
  }

  static String formatBaggageWeight(String baggage) {
    // 20 Kilograms
    try {
      final weight = baggage.trim().split(' ')[0];
      final unit = baggage.trim().split(' ')[1];
      return '$weight ' + unit.tr;
    } catch (e) {
      return baggage;
    }
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static Future<void> openUrl(String url) async {
    final ok = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.inAppBrowserView, // يفتح المتصفح الافتراضي
    ); 
    
    if (!ok) {
      Get.snackbar(
        'Error'.tr,
        'Could not open link'.tr,
      );
    }
  }

  static String getAvatarText(String text) {
    final parts = text.replaceAll('-', ' ').trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final first = parts.first;
    final last = parts.last;
    final firstChar = first.isNotEmpty ? first[0] : '';
    final lastChar = last.isNotEmpty ? last[0] : '';
    if (parts.length == 1) return firstChar.toUpperCase();
    return (firstChar + lastChar).toUpperCase();
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Future<bool> confirmExit({String? title, String? message}) async {
    final result = await Get.dialog<bool>(
      barrierDismissible: false,
      AlertDialog(
        title: Center(child: Text(title ?? "Exit app".tr)),
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            message ?? "Do you want to exit the application?".tr,
            textAlign: TextAlign.center,
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 42),
              foregroundColor: Theme.of(Get.context!).colorScheme.error,
            ),
            onPressed: () => Get.back(result: true),
            child: Text("Ok".tr),
          ),
          const SizedBox(width: 16),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 42),
            ),
            onPressed: () => Get.back(result: false),
            child: Text("Cancel".tr),
          ),
        ],
      ),
    );

    return result == true;
  }



}
