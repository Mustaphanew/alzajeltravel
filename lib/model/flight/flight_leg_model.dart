// lib/model/flight/flight_leg_model.dart
import 'flight_segment_model.dart';

class FlightLegModel {
  /// سيجمنتات هذا الاتجاه (ذهاب أو عودة)
  final List<FlightSegmentModel> segments;

  /// عدد التوقفات (stops) من الـ API
  final int stops;

  final String totalJourneyDurationText;
  final String totalLayoverDurationText;
  final String totalDurationText;

  FlightLegModel({
    required this.segments,
    required this.stops,
    required this.totalJourneyDurationText,
    required this.totalLayoverDurationText,
    required this.totalDurationText,
  });

  // ========= convenience getters =========

  FlightSegmentModel get firstSegment => segments.first;
  FlightSegmentModel get lastSegment => segments.last;

  String get fromCode => firstSegment.fromCode;
  String get fromName => firstSegment.fromName;
  DateTime get departureDateTime => firstSegment.departureDateTime;

  String get toCode => lastSegment.toCode;
  String get toName => lastSegment.toName;
  DateTime get arrivalDateTime => lastSegment.arrivalDateTime;

  static String _s(dynamic v) => v == null ? '' : v.toString();

  static int _intOrZero(dynamic v) {
    if (v is int) return v;
    if (v is String && v.trim().isNotEmpty) {
      return int.tryParse(v.trim()) ?? 0;
    }
    return 0;
  }

  factory FlightLegModel.fromJson(Map<String, dynamic> odJson) {
    final segList = (odJson['flightSegment'] as List)
        .cast<Map<String, dynamic>>()
        .map(FlightSegmentModel.fromJson)
        .toList();

    return FlightLegModel(
      segments: segList,
      stops: _intOrZero(odJson['stops']),
      totalJourneyDurationText: _s(odJson['totalJourneyDurationText']),
      totalLayoverDurationText: _s(odJson['totalLayoverDurationText']),
      totalDurationText: _s(odJson['totalDurationText']),
    );
  }
}
