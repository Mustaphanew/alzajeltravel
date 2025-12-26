// lib/model/flight/flight_segment_model.dart


class FlightSegmentModel {
  final String marketingAirlineCode;
  final String marketingAirlineNumber;

  final String fromCode;
  final String fromName;
  final DateTime departureDateTime;

  final String toCode;
  final String toName;
  final DateTime arrivalDateTime;

  final String equipmentNumber;
  final String cabinClassText;
  final String bookingClassCode;

  final int? journeyMinutes;
  final String? journeyText;

  /// مدة الترانزيت قبل هذا السيجمنت
  final int? layoverMinutes;
  final String? layoverText;

  /// المقاعد المتبقية في هذا السيجمنت
  final String seatsRemaining;

  FlightSegmentModel({
    required this.marketingAirlineCode,
    required this.marketingAirlineNumber,
    required this.fromCode,
    required this.fromName,
    required this.departureDateTime,
    required this.toCode,
    required this.toName,
    required this.arrivalDateTime,
    required this.equipmentNumber,
    required this.cabinClassText,
    required this.bookingClassCode,
    required this.journeyMinutes,
    required this.journeyText,
    required this.layoverMinutes,
    required this.layoverText,
    required this.seatsRemaining,
  });

  // ========= helpers داخل الموديل =========
  static String _s(dynamic v) => v == null ? '' : v.toString();

  static int? _intOrNull(dynamic v) {
    if (v is int) return v;
    if (v is String && v.trim().isNotEmpty) {
      return int.tryParse(v.trim());
    }
    return null;
  }

  static String? _nonEmptyOrNull(dynamic v) {
    final s = _s(v).trim();
    return s.isEmpty ? null : s;
  }

  factory FlightSegmentModel.fromJson(Map<String, dynamic> seg) {
    return FlightSegmentModel(
      marketingAirlineCode: _s(seg['marketingAirlineCode']),
      marketingAirlineNumber: _s(seg['marketingAirlineNumber']),
      fromCode: _s(seg['departureAirportCode']),
      fromName: _s(seg['departureAirportName']),
      departureDateTime: DateTime.parse(_s(seg['departureDateTime'])),
      toCode: _s(seg['arrivalAirportCode']),
      toName: _s(seg['arrivalAirportName']),
      arrivalDateTime: DateTime.parse(_s(seg['arrivalDateTime'])),
      equipmentNumber: _s(seg['equipmentNumber']),
      cabinClassText: _s(seg['cabinClassText']),
      bookingClassCode: _s(seg['bookingClassCode']),
      journeyMinutes: _intOrNull(seg['journeyDuration']),
      journeyText: _nonEmptyOrNull(seg['journeyDurationText']),
      layoverMinutes: _intOrNull(seg['layoverDuration']),
      layoverText: _nonEmptyOrNull(seg['layoverDurationText']),
      seatsRemaining: _s(seg['seatsRemaining']),
    );
  }
}
