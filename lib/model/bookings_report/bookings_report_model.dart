// bookings_report_model.dart

// NOTE: عدّل مسارات الاستيراد حسب مكان enums عندك في المشروع.
import 'package:alzajeltravel/model/airport_model.dart';
import 'package:alzajeltravel/repo/airport_repo.dart';
import 'package:alzajeltravel/utils/enums.dart';

class BookingsReportResponse {
  final String status;
  final BookingsReportData data;

  const BookingsReportResponse({required this.status, required this.data});

  factory BookingsReportResponse.fromJson(Map<String, dynamic> json) {
    return BookingsReportResponse(
      status: (json['status'] ?? '').toString(),
      data: BookingsReportData.fromJson((json['data'] ?? {}) as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'data': data.toJson(),
      };
}

class BookingsReportData {
  final int agentId;
  final BookingStatus status;
  final int fullDetails;
  final int count;
  final List<BookingReportItem> items;

  const BookingsReportData({
    required this.agentId,
    required this.status,
    required this.fullDetails,
    required this.count,
    required this.items,
  });

  factory BookingsReportData.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];

    return BookingsReportData(
      agentId: _asInt(json['agent_id']),
      status: BookingStatus.fromJson((json['status'] ?? '').toString()),
      fullDetails: _asInt(json['full_details']),
      count: _asInt(json['count']),
      items: rawItems
          .whereType<Map>()
          .map((e) => BookingReportItem.fromJson(e.cast<String, dynamic>()))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'agent_id': agentId,
        'status': status.toJson(),
        'full_details': fullDetails,
        'count': count,
        'items': items.map((e) => e.toJson()).toList(),
      };
}

class BookingReportItem {
  final int insertId;
  final String bookingId;
  final String pnr;

  final BookingStatus reportStatus;
  final BookingStatus centralStatus;
  final BookingStatus flightStatus;

  final DateTime createdAt;
  final DateTime travelDate;

  final String currency;
  final double totalAmount;

  final String tripApi;

  /// Airport code only (between parentheses)
  final AirportModel origin;

  /// Airport code only (between parentheses)
  final AirportModel destination;

  final JourneyType journeyType;

  final DateTime? voidOn;
  final DateTime? cancelOn;

  final int adult;
  final int child;

  // JSON key is "Inf"
  final int inf;

  int get travelersCount => adult + child + inf;

  const BookingReportItem({
    required this.insertId,
    required this.bookingId,
    required this.pnr,
    required this.reportStatus,
    required this.centralStatus,
    required this.flightStatus,
    required this.createdAt,
    required this.travelDate,
    required this.currency,
    required this.totalAmount,
    required this.tripApi,
    required this.origin,
    required this.destination,
    required this.journeyType,
    required this.voidOn,
    required this.cancelOn,
    required this.adult,
    required this.child,
    required this.inf,
  });

  factory BookingReportItem.fromJson(Map<String, dynamic> json) {
    final createdAt = _parseDateTime(json['created_at']);
    final travelDate = _parseDateTime(json['travel_date']);

    return BookingReportItem(
      insertId: _asInt(json['insert_id']),
      bookingId: (json['booking_id'] ?? '').toString(),
      pnr: (json['pnr'] ?? '').toString(),

      reportStatus: BookingStatus.fromJson((json['report_status'] ?? '').toString()),
      centralStatus: BookingStatus.fromJson((json['central_status'] ?? '').toString()),
      flightStatus: BookingStatus.fromJson((json['flight_status'] ?? '').toString()),

      createdAt: createdAt ?? DateTime.fromMillisecondsSinceEpoch(0),
      travelDate: travelDate ?? DateTime.fromMillisecondsSinceEpoch(0),

      currency: (json['currency'] ?? '').toString(),
      totalAmount: _asDouble(json['total_amount']),

      tripApi: (json['trip_api'] ?? '').toString(),

      origin: AirportRepo.searchByCode(_extractAirportCode((json['origin'] ?? '').toString())),
      destination: AirportRepo.searchByCode(_extractAirportCode((json['destination'] ?? '').toString())),

      journeyType: _parseJourneyType((json['journey_type'] ?? '').toString()),

      voidOn: _parseDateTime(json['void_on']),
      cancelOn: _parseDateTime(json['cancel_on']),

      adult: _asInt(json['adult']),
      child: _asInt(json['child']),
      inf: _asInt(json['Inf']),
    );
  }

  Map<String, dynamic> toJson() => {
        'insert_id': insertId,
        'booking_id': bookingId,
        'pnr': pnr,
        'report_status': reportStatus.toJson(),
        'central_status': centralStatus.toJson(),
        'flight_status': flightStatus.toJson(),
        'created_at': createdAt.toIso8601String(),
        'travel_date': travelDate.toIso8601String(),
        'currency': currency,
        'total_amount': totalAmount,
        'trip_api': tripApi,
        'origin': origin,
        'destination': destination,
        'journey_type': journeyType.toJson(),
        'void_on': voidOn?.toIso8601String(),
        'cancel_on': cancelOn?.toIso8601String(),
        'adult': adult,
        'child': child,
        'Inf': inf,
        'travelers_count': travelersCount,
      };
}

/// --------- Helpers ---------

int _asInt(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  return int.tryParse(v.toString().trim()) ?? 0;
}

double _asDouble(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString().trim()) ?? 0.0;
}

/// Handles:
/// - "2025-12-31 17:02:19" (space -> T)
/// - "2026-01-07"
/// - null
DateTime? _parseDateTime(dynamic v) {
  if (v == null) return null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;

  final normalized = (s.contains(' ') && !s.contains('T')) ? s.replaceFirst(' ', 'T') : s;
  return DateTime.tryParse(normalized);
}

/// Extract between parentheses: "(RUH)" -> "RUH"
String _extractAirportCode(String v) {
  final s = v.trim();
  if (s.isEmpty) return s;
  final m = RegExp(r'\(([^)]+)\)').firstMatch(s);
  if (m != null) return (m.group(1) ?? '').trim();
  return s;
}

JourneyType _parseJourneyType(String v) {
  try {
    return JourneyType.fromJson(v);
  } catch (_) {
    return JourneyType.oneWay;
  }
}
