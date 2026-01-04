// traveler_review_model.dart

import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/model/passport/traveler_review/seat_model.dart';
import 'package:alzajeltravel/utils/enums.dart';
import 'package:get/get.dart';

/// ===================================================================
/// TravelerReviewModel
/// ===================================================================
/// يمثل مسافر واحد في صفحة مراجعة البيانات
class TravelerReviewModel {
  /// بيانات جواز السفر للمسافر
  final PassportModel passport;

  /// ✅ فئة المسافر (Adult / Child / Infant)
  final AgeGroup? ageGroup;

  /// سعر التذكرة الأساسي (بدون إضافات)
  final double baseFare;

  /// إجمالي الضرائب
  final double taxTotal;

  /// المقعد الذي اختاره المسافر (قد يكون null)
  final Seat? seat;

  final String? ticketNumber;

  const TravelerReviewModel({
    required this.passport,
    this.ageGroup,
    required this.baseFare,
    required this.taxTotal,
    this.seat,
    this.ticketNumber,
  });

  /// نسخة جديدة مع إمكانية تعديل بعض الحقول
  TravelerReviewModel copyWith({
    PassportModel? passport,
    AgeGroup? ageGroup,
    double? baseFare,
    double? taxTotal,
    Seat? seat,
    String? ticketNumber,
  }) {
    return TravelerReviewModel(
      passport: passport ?? this.passport,
      ageGroup: ageGroup ?? this.ageGroup,
      baseFare: baseFare ?? this.baseFare,
      taxTotal: taxTotal ?? this.taxTotal,
      seat: seat ?? this.seat,
      ticketNumber: ticketNumber ?? this.ticketNumber,
    );
  }

  /// تكلفة المقعد (0 إذا لم يتم اختيار مقعد)
  double get seatFare => seat?.fare ?? 0.0;

  /// السعر النهائي = التذكرة + الضرائب (بدون المقعد)
  double get totalFare => baseFare + taxTotal;

  /// السعر النهائي = التذكرة + الضرائب + المقعد
  double get totalAll => baseFare + taxTotal + seatFare;

  /// label جاهز للعرض
  String get ageGroupLabel {
    switch (ageGroup) {
      case AgeGroup.infant:
        return 'Infant'.tr;
      case AgeGroup.child:
        return 'Child'.tr;
      case AgeGroup.adult:
      default:
        return 'Adult'.tr;
    }
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'passport': passport.toJson(),
      'ageGroup': _ageGroupToKey(ageGroup),
      'baseFare': baseFare,
      'taxTotal': taxTotal,
      'seatFare': seatFare,
      'totalFare': totalFare,
      'totalAll': totalAll,
      if (seat != null) 'seat': seat!.toJson(),
      'ticketNumber': ticketNumber,
    };
  }

  /// إنشاء الموديل من JSON
  /// يدعم المفاتيح القديمة + الجديدة:
  /// - baseFare / Base_Amount
  /// - taxTotal / Tax_Total
  /// - ticketNumber / eTicketNumber
  factory TravelerReviewModel.fromJson(Map<String, dynamic> json) {
    double d(dynamic v) {
      if (v is num) return v.toDouble();
      final s = (v ?? '').toString().trim();
      if (s.isEmpty) return 0.0;
      return double.tryParse(s) ?? 0.0;
    }

    return TravelerReviewModel(
      passport: PassportModel.fromJson(json['passport'] as Map<String, dynamic>),
      ageGroup: _ageGroupFromAny(json['ageGroup'] ?? json['paxType'] ?? json['pax_type']),
      baseFare: d(json['baseFare'] ?? json['Base_Amount']),
      taxTotal: d(json['taxTotal'] ?? json['Tax_Total']),
      seat: json['seat'] != null ? Seat.fromJson(json['seat'] as Map<String, dynamic>) : null,
      ticketNumber: (json['ticketNumber'] ?? json['eTicketNumber'])?.toString(),
    );
  }

  // ================= helpers =================

  static String _ageGroupToKey(AgeGroup? g) {
    if (g == null) return 'adult';
    switch (g) {
      case AgeGroup.infant:
        return 'infant';
      case AgeGroup.child:
        return 'child';
      case AgeGroup.adult:
      default:
        return 'adult';
    }
  }

  static AgeGroup _ageGroupFromAny(dynamic v) {
    final s = (v ?? '').toString().trim().toLowerCase();
    if (s == 'inf' || s == 'infant') return AgeGroup.infant;
    if (s == 'cnn' || s == 'chd' || s == 'child') return AgeGroup.child;
    if (s == 'adt' || s == 'adult') return AgeGroup.adult;
    return AgeGroup.adult;
  }
}

/// ===================================================================
/// TravelerFareSummary
/// ===================================================================
/// موديل تجميعي يحسب:
/// - عدد البالغين / الأطفال / الرضع
/// - متوسط سعر الواحد لكل فئة (base / tax / totalFare / totalAll)
/// - إجمالي السعر لجميع المسافرين
/// - بالإضافة إلى مجاميع الأسعار لكل فئة (عدد * متوسط)
class TravelerFareSummary {
  // ---------------- عدد المسافرين لكل فئة ----------------
  final int adultCount;
  final int childCount;
  final int infantLapCount;

  // ---------------- الإجمالي لكل المسافرين ----------------
  /// مجموع totalFare لكل المسافرين (بدون المقاعد)
  final double totalPrice;

  // ---------------- متوسط سعر المسافر الواحد لكل فئة ----------------
  /// متوسط (base + tax) للبالغ الواحد
  final double? adultTotalFare;
  final double? childTotalFare;
  final double? infantLapTotalFare;

  /// متوسط السعر مع المقعد (base + tax + seatFare)
  final double? adultTotalAll;
  final double? childTotalAll;
  final double? infantLapTotalAll;

  /// متوسط الضرائب لكل فئة
  final double? adultTaxTotal;
  final double? childTaxTotal;
  final double? infantLapTaxTotal;

  /// متوسط baseFare لكل فئة
  final double? adultBaseFare;
  final double? childBaseFare;
  final double? infantLapBaseFare;

  const TravelerFareSummary({
    required this.adultCount,
    required this.childCount,
    required this.infantLapCount,
    required this.totalPrice,
    required this.adultTotalFare,
    required this.childTotalFare,
    required this.infantLapTotalFare,
    required this.adultTotalAll,
    required this.childTotalAll,
    required this.infantLapTotalAll,
    required this.adultTaxTotal,
    required this.childTaxTotal,
    required this.infantLapTaxTotal,
    required this.adultBaseFare,
    required this.childBaseFare,
    required this.infantLapBaseFare,
  });

  /// ---------------- مجاميع الأسعار لكل فئة (عدد * متوسط) ----------------

  double get adultsTotalFareAllPassengers => (adultTotalFare ?? 0.0) * adultCount;
  double get childrenTotalFareAllPassengers => (childTotalFare ?? 0.0) * childCount;
  double get infantsTotalFareAllPassengers => (infantLapTotalFare ?? 0.0) * infantLapCount;

  double get adultsTotalAllAllPassengers => (adultTotalAll ?? 0.0) * adultCount;
  double get childrenTotalAllAllPassengers => (childTotalAll ?? 0.0) * childCount;
  double get infantsTotalAllAllPassengers => (infantLapTotalAll ?? 0.0) * infantLapCount;

  double get adultsTotalTaxAllPassengers => (adultTaxTotal ?? 0.0) * adultCount;
  double get childrenTotalTaxAllPassengers => (childTaxTotal ?? 0.0) * childCount;
  double get infantsTotalTaxAllPassengers => (infantLapTaxTotal ?? 0.0) * infantLapCount;

  double get adultsTotalBaseFareAllPassengers => (adultBaseFare ?? 0.0) * adultCount;
  double get childrenTotalBaseFareAllPassengers => (childBaseFare ?? 0.0) * childCount;
  double get infantsTotalBaseFareAllPassengers => (infantLapBaseFare ?? 0.0) * infantLapCount;

  /// المصنع الرئيسي: يبني الـ summary من قائمة المسافرين
  /// ✅ يعتمد على ageGroup بدل passport.age
  factory TravelerFareSummary.fromTravelers(
    List<TravelerReviewModel> travelers,
  ) {
    final List<TravelerReviewModel> adults = [];
    final List<TravelerReviewModel> children = [];
    final List<TravelerReviewModel> infants = [];

    for (final t in travelers) {
      switch (t.ageGroup) {
        case AgeGroup.infant:
          infants.add(t);
          break;
        case AgeGroup.child:
          children.add(t);
          break;
        case AgeGroup.adult:
        default:
          adults.add(t);
          break;
      }
    }

    double? avgTotalFare(List<TravelerReviewModel> group) {
      if (group.isEmpty) return null;
      final sum = group.fold<double>(0.0, (s, t) => s + t.totalFare);
      return sum / group.length;
    }

    double? avgTotalAll(List<TravelerReviewModel> group) {
      if (group.isEmpty) return null;
      final sum = group.fold<double>(0.0, (s, t) => s + t.totalAll);
      return sum / group.length;
    }

    double? avgTaxTotal(List<TravelerReviewModel> group) {
      if (group.isEmpty) return null;
      final sum = group.fold<double>(0.0, (s, t) => s + t.taxTotal);
      return sum / group.length;
    }

    double? avgBaseFare(List<TravelerReviewModel> group) {
      if (group.isEmpty) return null;
      final sum = group.fold<double>(0.0, (s, t) => s + t.baseFare);
      return sum / group.length;
    }

    final totalPrice = travelers.fold<double>(
      0.0,
      (sum, t) => sum + t.totalFare,
    );

    return TravelerFareSummary(
      adultCount: adults.length,
      childCount: children.length,
      infantLapCount: infants.length,
      totalPrice: totalPrice,

      adultTotalFare: avgTotalFare(adults),
      childTotalFare: avgTotalFare(children),
      infantLapTotalFare: avgTotalFare(infants),

      adultTotalAll: avgTotalAll(adults),
      childTotalAll: avgTotalAll(children),
      infantLapTotalAll: avgTotalAll(infants),

      adultTaxTotal: avgTaxTotal(adults),
      childTaxTotal: avgTaxTotal(children),
      infantLapTaxTotal: avgTaxTotal(infants),

      adultBaseFare: avgBaseFare(adults),
      childBaseFare: avgBaseFare(children),
      infantLapBaseFare: avgBaseFare(infants),
    );
  }
}
