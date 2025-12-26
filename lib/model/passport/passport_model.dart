import 'dart:convert';

import 'package:get/get.dart';
// عدّل المسار حسب مشروعك
import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';

/// =============================================================
/// كلاس الجنس Sex
/// =============================================================
/// نستخدمه بدلاً من String عادية حتى يكون هناك قيم محددة:
/// - m  => Male
/// - f  => Female
class Sex {
  /// القيمة المختصرة التي تُرسل للـ API أو تُحفظ في الـ DB
  /// مثال: 'm' أو 'f'
  final String key;

  /// مفتاح الترجمة في ملفات اللغات
  /// مثال: 'male' أو 'female'
  final String translationKey;

  const Sex(this.key, this.translationKey);

  // قيم جاهزة
  static const Sex male = Sex('m', 'male');
  static const Sex female = Sex('f', 'female');

  static const List<Sex> values = [male, female];

  /// تحويل من نص (m/f/M/F) إلى Sex
  static Sex? fromKey(String? value) {
    if (value == null) return null;
    final v = value.toLowerCase();
    if (v == 'm') return male;
    if (v == 'f') return female;
    return null;
  }

  /// النص المترجم حسب اللغة الحالية من GetX
  String get label => translationKey.tr;

  @override
  String toString() => label;
}

/// =============================================================
/// حالة الجواز (ساري / منتهي)
/// =============================================================
class PassportStatus {
  final String key; // 'valid' أو 'expired'
  final String translationKey; // مفتاح الترجمة

  const PassportStatus(this.key, this.translationKey);

  static const PassportStatus valid = PassportStatus('valid', 'Valid');
  static const PassportStatus expired = PassportStatus('expired', 'Expired');

  static const List<PassportStatus> values = [valid, expired];

  /// نحسب الحالة بناءً على تاريخ الانتهاء
  static PassportStatus fromExpiry(DateTime? expiry) {
    if (expiry == null) return expired;
    final now = DateTime.now();

    // نعتبر الجواز ساري حتى نهاية يوم الانتهاء (23:59:59)
    final endOfExpiryDay = DateTime(expiry.year, expiry.month, expiry.day, 23, 59, 59);

    return now.isAfter(endOfExpiryDay) ? expired : valid;
  }

  String get label => translationKey.tr;

  @override
  String toString() => label;
}

/// =============================================================
/// PassportModel
/// =============================================================
/// هذا الموديل يمثل بيانات جواز السفر التي نحتاجها في التطبيق:
/// - بيانات الفورم (الاسم، الجنس، التواريخ ... إلخ)
/// - بيانات الدول (الجنسية / جهة الإصدار) من نوع CountryModel
/// - نص الـ MRZ (للديباج أو الإرسال إن احتجت)
class PassportModel {
  /// نوع الوثيقة من الـ MRZ (عادة P)
  /// يمكن تجاهلها في الفورم لكن نحتفظ بها لو احتجناها لاحقاً
  String? documentCode;

  /// رقم الجواز
  String? documentNumber;

  /// الكنية / اللقب (SURNAMES)
  String? surnames;

  /// الاسم الأول/الأسماء (GIVEN NAMES)
  String? givenNames;

  /// تاريخ الميلاد
  DateTime? dateOfBirth;

  /// الجنس
  Sex? sex;

  /// تاريخ انتهاء الجواز
  DateTime? dateOfExpiry;

  /// بيانات إضافية تأتي من الـ MRZ (إن وُجدت)
  String? optionalData;

  /// دولة الجنسية (دولة حامل الجواز)
  ///
  /// تحتوي على:
  /// - الاسم بالعربي/الإنجليزي
  /// - alpha2 / alpha3
  /// - dialcode (لو احتجته)
  CountryModel? nationality;

  /// دولة جهة إصدار الجواز
  CountryModel? issuingCountry;

  /// النص الكامل للـ MRZ (سطرين TD3) – مفيد للديباج أو الحفظ
  String? mrzText;

  PassportModel({
    this.documentCode,
    this.documentNumber,
    this.surnames,
    this.givenNames,
    this.dateOfBirth,
    this.sex,
    this.dateOfExpiry,
    this.optionalData,
    this.nationality,
    this.issuingCountry,
    this.mrzText,
  });

  /// ===========================================================
  /// خصائص مشتقة (لا تُحفظ في الـ DB، وإنما تُحسب عند الطلب)
  /// ===========================================================

  /// الاسم الكامل لعرضه في الواجهة
  String get fullName => '${givenNames ?? ''} ${surnames ?? ''}'.trim();

  String get ageGroupLabel {
    if (age == null) return '-';
    if (age! <= 1) return 'Infant'.tr;
    if (age! >= 2 && age! <= 11) return 'Child'.tr;
    return 'Adult'.tr;
  }

  /// حساب العمر بالسنوات (إن أمكن)
  int? get age {
    if (dateOfBirth == null) return null;

    final now = DateTime.now();
    int years = now.year - dateOfBirth!.year;

    // إذا لم نكمل عيد الميلاد هذه السنة ننقص سنة
    final hasNotHadBirthdayThisYear = (now.month < dateOfBirth!.month) || (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day);

    if (hasNotHadBirthdayThisYear) {
      years -= 1;
    }

    // حماية من بيانات غير منطقية
    if (years < 0 || years > 150) return null;

    return years;
  }

  /// حالة الجواز (ساري / منتهي)
  PassportStatus get status => PassportStatus.fromExpiry(dateOfExpiry);

  /// ===========================================================
  /// تحويل إلى JSON (لإرسالها إلى الـ API أو للحفظ المحلي)
  /// ===========================================================

  /// تنسيق التاريخ بشكل YYYY-MM-DD
  static String? _formatDate(DateTime? d) {
    if (d == null) return null;
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Map<String, dynamic> toJson() {
    return {
      // بيانات الجواز الأساسية
      'documentCode': documentCode,
      'documentNumber': documentNumber,
      'surnames': surnames,
      'givenNames': givenNames,
      'dateOfBirth': _formatDate(dateOfBirth),
      'sex': sex?.key, // نرسل 'm' أو 'f'
      'dateOfExpiry': _formatDate(dateOfExpiry),
      'optionalData': optionalData,

      // الجنسية – نرسلها ككائن Country (نستفيد من alpha2/alpha3 في الـ API)
      'nationality': nationality?.toJson(),
      'issuingCountry': issuingCountry?.toJson(),

      // نص الـ MRZ الكامل
      'mrzText': mrzText,

      // معلومات مشتقة (اختيارية – مفيدة للديباج فقط)
      'age': age,
      'passportStatus': status.key, // 'valid' أو 'expired'
    };
  }

  /// JSON جميل (مسافة بادئة) مفيد للـ debug في الـ console
  String toPrettyJson() => const JsonEncoder.withIndent('  ').convert(toJson());

  /// ===========================================================
  /// fromJson: عكس toJson
  /// ===========================================================
  factory PassportModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      if (value is DateTime) return value;

      final s = value.toString().trim();
      if (s.isEmpty) return null;

      // الشكل المتوقع الأساسي: YYYY-MM-DD
      final parts = s.split('-');
      if (parts.length == 3) {
        final y = int.tryParse(parts[0]);
        final m = int.tryParse(parts[1]);
        final d = int.tryParse(parts[2]);
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }

      // دعم بسيط للنمط: YYYYMMDD
      if (s.length == 8) {
        final y = int.tryParse(s.substring(0, 4));
        final m = int.tryParse(s.substring(4, 6));
        final d = int.tryParse(s.substring(6, 8));
        if (y != null && m != null && d != null) {
          return DateTime(y, m, d);
        }
      }

      return null;
    }

    String? s(dynamic v) {
      final x = v?.toString().trim();
      return (x == null || x.isEmpty) ? null : x;
    }

    Sex? parseSex(dynamic v) {
      if (v == null) return null;
      // لو أرسلنا 'm' أو 'f'
      final fromKey = Sex.fromKey(v.toString());
      if (fromKey != null) return fromKey;

      // لو أرسلنا 'male' أو 'female' من الـ API
      final lower = v.toString().toLowerCase();
      if (lower == 'male') return Sex.male;
      if (lower == 'female') return Sex.female;

      return null;
    }

    CountryModel? parseCountry(dynamic v) {
      if (v == null) return null;
      if(v is String){
        final alpha2 = v.toString().split("_").first;
        return CountryRepo.searchByAlpha(alpha2);
      }
      if (v is Map<String, dynamic>) {
        // نتوقع نفس شكل CountryModel.toJson()
        return CountryModel.fromJson(v);
      }
      return null;
    }

    return PassportModel(
      documentCode: s(json['documentCode']),
      documentNumber: s(json['documentNumber']),
      surnames: s(json['surnames']),
      givenNames: s(json['givenNames']),
      dateOfBirth: parseDate(json['dateOfBirth']),
      sex: parseSex(json['sex']),
      dateOfExpiry: parseDate(json['dateOfExpiry']),
      optionalData: s(json['optionalData']),
      nationality: parseCountry(json['nationality']),
      issuingCountry: parseCountry(json['issuingCountry']),
      mrzText: s(json['mrzText']) ?? s(json['mrz_text']),
    );
  }

  void clear() {
    documentCode = null;
    documentNumber = null;
    surnames = null;
    givenNames = null;
    dateOfBirth = null;
    sex = null;
    dateOfExpiry = null;
    optionalData = null;
    nationality = null;
    issuingCountry = null;
    mrzText = null;
  }
}
