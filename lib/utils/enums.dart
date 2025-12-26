// lib/router/pages.dart
enum Pages {
  root('/'),
  home('home'),
  flight('flight'),
  addPassport('add_passport'),
  booking('booking');

  const Pages(this.raw);
  final String raw;

  /// مسار صالح دائمًا يبدأ بـ /
  String get path => raw.startsWith('/') ? raw : '/$raw';

  /// تحويل آمن من نص (raw) إلى Pages
  static Pages? tryParse(String v) {
    for (final e in Pages.values) {
      if (e.raw == v || e.path == v) return e; // نقبل raw أو path
    }
    return null;
  }

  /// إن كنت تحتاج رمي خطأ صريح بدل null
  static Pages fromRaw(String v) {
    
    return Pages.values.firstWhere((e) {
      return e.raw == v || e.path == v;
    });

  }

}

enum LocationType {
  city('city'),
  airport('airport');

  const LocationType(this.apiValue);
  final String apiValue;

  static LocationType fromJson(String v) => LocationType.values.firstWhere((e) => e.apiValue == v);

  String toJson() => apiValue;
}

enum JourneyType {
  roundTrip('R'),
  oneWay('O'),
  multiCity('M');

  const JourneyType(this.apiValue);
  final String apiValue;

  static JourneyType fromJson(String v) => JourneyType.values.firstWhere((e) => e.apiValue == v);

  String toJson() => apiValue;
}

/// يعبّر عن اتجاه الرحلة داخل الحجز (المسار الكامل)
/// - outbound: اتجاه الذهاب (مثال: DOH -> CAI)
/// - inbound: اتجاه الإياب (مثال: CAI -> DOH)
/// - additional: اتجاه إضافي في حالة تعدد المدن (multi-city)
enum ItineraryDirection {
  outbound('outbound'),
  inbound('inbound'),
  additional('additional');

  const ItineraryDirection(this.apiValue);
  final String apiValue;

  static ItineraryDirection fromJson(String v) => ItineraryDirection.values.firstWhere((e) => e.apiValue == v);

  String toJson() => apiValue;
}

enum AgeGroup {
  adult('adult'),
  child('child'),
  infant('infant');

  const AgeGroup(this.apiValue);
  final String apiValue;

  static AgeGroup fromJson(String v) => AgeGroup.values.firstWhere((e) => e.apiValue == v);

  String toJson() => apiValue;
}
