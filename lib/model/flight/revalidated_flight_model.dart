import 'package:alzajeltravel/model/flight/flight_offer_model.dart';

class FareRule {
  final String category;
  final String rule;

  FareRule({
    required this.category,
    required this.rule,
  });

  factory FareRule.fromJson(Map<String, dynamic> json) {
    final raw = (json['rule_det'] ?? '') as String;
    // نحول <br> إلى سطر جديد
    final clean = raw.replaceAll('<br>', '\n');
    return FareRule(
      category: (json['Category'] ?? '').toString(),
      rule: clean,
    );
  }
}

class RevalidatedFlightModel {
  final FlightOfferModel offer;
  final bool isRefundable;
  final bool isPassportMandatory;
  final int firstNameCharacterLimit;
  final int lastNameCharacterLimit;
  final int paxNameCharacterLimit;
  final List<FareRule> fareRules;

  RevalidatedFlightModel({
    required this.offer,
    required this.isRefundable,
    required this.isPassportMandatory,
    required this.firstNameCharacterLimit,
    required this.lastNameCharacterLimit,
    required this.paxNameCharacterLimit,
    required this.fareRules,
  });

  /// json هنا هو الرد الكامل من /flight/revalidate
  factory RevalidatedFlightModel.fromResponseJson(Map<String, dynamic> json) {
    // بعض الأحيان في root: fareRules
    // وأحياناً: fareRule أو selected.fareRule
    final rulesRaw = json['fareRules'] ??
        json['fareRule'] ??
        json['selected']?['fareRule'] ??
        [];

    final rulesJson = (rulesRaw is List) ? rulesRaw : <dynamic>[];

    // بيانات إعادة التحقق الفعلية
    final revalidateJsonRaw = json['revalidate'] ?? json['selected']?['revalidateData'];
    final revalidateJson = (revalidateJsonRaw ?? <String, dynamic>{}) as Map<String, dynamic>;

    return RevalidatedFlightModel(
      offer: FlightOfferModel.fromJson(revalidateJson),
      isRefundable: (revalidateJson['isRefundable'] ?? false) as bool,
      isPassportMandatory: (revalidateJson['isPassportMandatory'] ?? false) as bool,
      firstNameCharacterLimit: (revalidateJson['firstNameCharacterLimit'] ?? 0) as int,
      lastNameCharacterLimit: (revalidateJson['lastNameCharacterLimit'] ?? 0) as int,
      paxNameCharacterLimit: (revalidateJson['paxNameCharacterLimit'] ?? 0) as int,
      fareRules: rulesJson
          .map((e) => FareRule.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
