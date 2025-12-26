

class OtherPricesResponse {
  final String? status;
  final OtherPricesData? data;

  OtherPricesResponse({this.status, this.data});

  factory OtherPricesResponse.fromJson(Map<String, dynamic> json) {
    return OtherPricesResponse(
      status: json["status"]?.toString(),
      data: json["data"] is Map<String, dynamic>
          ? OtherPricesData.fromJson(json["data"] as Map<String, dynamic>)
          : null,
    );
  }
}

class OtherPricesData {
  final String? status;
  final List<OtherPriceOffer> offers;

  OtherPricesData({this.status, required this.offers});

  factory OtherPricesData.fromJson(Map<String, dynamic> json) {
    final rawOffers = json["offers"];
    final offersList = (rawOffers is List)
        ? rawOffers
            .whereType<Map>()
            .map((e) => OtherPriceOffer.fromJson(e.cast<String, dynamic>()))
            .toList()
        : <OtherPriceOffer>[];

    return OtherPricesData(
      status: json["status"]?.toString(),
      offers: offersList,
    );
  }
}

class OtherPriceOffer {
  final int? index;
  final String? familyName;
  final double? total;
  final String? currency;
  final String? offerRef;
  final String? bestFareType;
  final String? bookingClass;
  final FamilyFeatures? familyFeatures;

  OtherPriceOffer({
    this.index,
    this.familyName,
    this.total,
    this.currency,
    this.offerRef,
    this.bestFareType,
    this.bookingClass,
    this.familyFeatures,
  });

  factory OtherPriceOffer.fromJson(Map<String, dynamic> json) {
    return OtherPriceOffer(
      index: _asInt(json["index"]),
      familyName: json["familyName"]?.toString(),
      total: _asDouble(json["total"]),
      currency: json["currency"]?.toString(),
      offerRef: json["offerRef"]?.toString(),
      bestFareType: json["bestFareType"]?.toString(),
      bookingClass: json["bookingClass"]?.toString(),
      familyFeatures: json["family_features"] is Map<String, dynamic>
          ? FamilyFeatures.fromJson(json["family_features"] as Map<String, dynamic>)
          : null,
    );
  }

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }

  static double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

class FamilyFeatures {
  final String? rateCategory;
  final String? label;
  final dynamic refundable; // ممكن ترجع null أو bool حسب السيرفر
  final dynamic changeable; // نفس الشي
  final List<dynamic> warnings;
  final List<String> meals;

  FamilyFeatures({
    this.rateCategory,
    this.label,
    this.refundable,
    this.changeable,
    required this.warnings,
    required this.meals,
  });

  factory FamilyFeatures.fromJson(Map<String, dynamic> json) {
    final rawWarnings = json["warnings"];
    final rawMeals = json["meals"];

    return FamilyFeatures(
      rateCategory: json["rateCategory"]?.toString(),
      label: json["label"]?.toString(),
      refundable: json["refundable"],
      changeable: json["changeable"],
      warnings: rawWarnings is List ? rawWarnings : <dynamic>[],
      meals: rawMeals is List
          ? rawMeals.map((e) => e.toString()).toList()
          : <String>[],
    );
  }
}
