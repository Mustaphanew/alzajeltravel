import 'package:alzajeltravel/utils/enums.dart';

class FlightSearchParams {
  final String from;
  final String to;
  final String departureDate; // yyyy-MM-dd
  final String? returnDate;   // yyyy-MM-dd (nullable)
  final String journeyType;   // journeyType.apiValue
  final int adt;
  final int chd;
  final int inf;
  final String cabin;
  final String nonstop; // "0" or "1"

  const FlightSearchParams({
    required this.from,
    required this.to,
    required this.departureDate,
    this.returnDate,
    required this.journeyType,
    required this.adt,
    required this.chd,
    required this.inf,
    required this.cabin,
    this.nonstop = "0",
  });

  Map<String, dynamic> toJson() => {
        "from": from,
        "to": to,
        "departure_date": departureDate,
        "return_date": returnDate,
        "journey_type": journeyType,
        "adt": adt,
        "chd": chd,
        "inf": inf,
        "cabin": cabin,
        "nonstop": nonstop,
      };

  factory FlightSearchParams.fromJson(Map<String, dynamic> json) {
    return FlightSearchParams(
      from: (json["from"] ?? "") as String,
      to: (json["to"] ?? "") as String,
      departureDate: (json["departure_date"] ?? "") as String,
      returnDate: json["return_date"] as String?,
      journeyType: (json["journey_type"] ?? "") as String,
      adt: (json["adt"] ?? 0) as int,
      chd: (json["chd"] ?? 0) as int,
      inf: (json["inf"] ?? 0) as int,
      cabin: (json["cabin"] ?? "") as String,
      nonstop: (json["nonstop"] ?? "0") as String,
    );
  }

  FlightSearchParams copyWith({
    String? from,
    String? to,
    String? departureDate,
    String? returnDate,
    String? journeyType,
    int? adt,
    int? chd,
    int? inf,
    String? cabin,
    String? nonstop,
  }) {
    return FlightSearchParams(
      from: from ?? this.from,
      to: to ?? this.to,
      departureDate: departureDate ?? this.departureDate,
      returnDate: returnDate ?? this.returnDate,
      journeyType: journeyType ?? this.journeyType,
      adt: adt ?? this.adt,
      chd: chd ?? this.chd,
      inf: inf ?? this.inf,
      cabin: cabin ?? this.cabin,
      nonstop: nonstop ?? this.nonstop,
    );
  }

  JourneyType? get journeyEnum {
    // إذا تحتاجها لاحقًا
    // عدل mapping حسب apiValue عندك
    if (journeyType == JourneyType.oneWay.apiValue) return JourneyType.oneWay;
    if (journeyType == JourneyType.roundTrip.apiValue) return JourneyType.roundTrip;
    if (journeyType == JourneyType.multiCity.apiValue) return JourneyType.multiCity;
    return null;
  }
}
