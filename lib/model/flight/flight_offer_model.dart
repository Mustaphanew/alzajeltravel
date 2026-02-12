// lib/model/flight/flight_offer_model.dart
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/airline_controller.dart';
import 'flight_segment_model.dart';
import 'flight_leg_model.dart';

class FlightOfferModel {
  final String id;

  /// validatingAirlineCode
  final String airlineCode;
  final String airlineName;
  final String airlineNumber;

  /// هل التذكرة قابلة للاسترجاع حسب رد الـ API search / revalidate
  final bool isRefundable;

  /// كل الاتجاهات (ذهاب / عودة)
  final List<FlightLegModel> legs;

  /// جميع السيجمنتات (ذهاب + عودة) بشكل مسطّح (للاستخدام في MoreFlightDetailPage)
  final List<FlightSegmentModel> segments;

  /// كل الأكواد التسويقية بدون تكرار
  final List<String> marketingAirlineCodes;

  // ملخص الرحلة (من أول اتجاه)
  final String fromCode;
  final String fromName;
  final String toCode;
  final String toName;
  final DateTime departureDateTime;
  final DateTime arrivalDateTime;

  /// stops و totalDuration للاتجاه الأول (outbound)
  final int stops;
  final String totalDurationText;

  final double totalAmount;
  final String currency;

  final String cabinClassText;
  final String bookingClassCode;
  final String equipmentNumber;
  final String seatsRemaining;

  /// ملخص نصي للأمتعة لجميع السيجمنتات
  final String? baggageInfo;

  /// الأمتعة لكل سيجمنت (بنفس ترتيب segments)
  final List<String> baggagePerSegment;

  FlightOfferModel({
    required this.id,
    required this.airlineCode,
    required this.airlineName,
    required this.airlineNumber,
    required this.isRefundable,
    required this.legs,
    required this.segments,
    required this.marketingAirlineCodes,
    required this.fromCode,
    required this.fromName,
    required this.toCode,
    required this.toName,
    required this.departureDateTime,
    required this.arrivalDateTime,
    required this.stops,
    required this.totalDurationText,
    required this.totalAmount,
    required this.currency,
    required this.cabinClassText,
    required this.bookingClassCode,
    required this.equipmentNumber,
    required this.seatsRemaining,
    required this.baggageInfo,
    required this.baggagePerSegment,
  });

  AirlineController airlineController = Get.find();

  bool get isRoundTrip => legs.length > 1;

  FlightLegModel get outbound => legs.first;
  FlightLegModel? get inbound => isRoundTrip ? legs[1] : null;

  // ========= helpers خاصة بالـ parsing =========
  static String _s(dynamic v) => v == null ? '' : v.toString();

  static int _intOrZero(dynamic v) {
    if (v is int) return v;
    if (v is String && v.trim().isNotEmpty) {
      return int.tryParse(v.trim()) ?? 0;
    }
    return 0;
  }

  static double _double(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String && v.trim().isNotEmpty) {
      return double.tryParse(v.trim()) ?? 0;
    }
    return 0;
  }

  static bool _bool(dynamic v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    if (v is String) {
      final s = v.toLowerCase().trim();
      if (s == 'true' || s == '1' || s == 'yes') return true;
      if (s == 'false' || s == '0' || s == 'no') return false;
    }
    return false;
  }

  int get totalStops => legs.fold(0, (sum, leg) => sum + leg.stops);
  bool get isOtherPrice => AppFuns.isUpsellEnabledAirline(airlineCode);

  factory FlightOfferModel.fromJson(Map<String, dynamic> json) {
    final airlineController = Get.find<AirlineController>();

    final odList = (json['orginDestinationDetails'] as List).cast<Map<String, dynamic>>();

    // legs
    final legs = odList.map(FlightLegModel.fromJson).toList();

    // جميع السيجمنتات (flatten)
    final allSegments = <FlightSegmentModel>[];
    for (final leg in legs) {
      allSegments.addAll(leg.segments);
    }

    // أول و آخر سيجمنت في الرحلة كلها
    final firstSeg = allSegments.first;
    final lastSeg = allSegments.last;

    // جميع الأكواد التسويقية بدون تكرار
    final seenCodes = <String>{};
    final marketingCodes = <String>[];
    for (final seg in allSegments) {
      if (seg.marketingAirlineCode.isNotEmpty && seenCodes.add(seg.marketingAirlineCode)) {
        marketingCodes.add(seg.marketingAirlineCode);
      }
    }

    // ---------- الأمتعة لكل سيجمنت ----------
    final List<String> baggagePerSegment = [];
    final rawBaggage = json['baggageDetails']?['baggage'];

    if (rawBaggage is List) {
      for (final item in rawBaggage) {
        String cleaned = '';

        if (item is String && item.trim().isNotEmpty) {
          final s = item.trim(); // "2 Piece/s" أو "20 Kilograms"
          final match = RegExp(r'^(\d+)\s+([A-Za-z/]+)').firstMatch(s);
          if (match != null) {
            final numPart = match.group(1)!;
            final unitRaw = match.group(2)!;
            String unitKey;
            if (unitRaw.toLowerCase().contains('piece')) {
              unitKey = 'Piece'.tr;
            } else if (unitRaw.toLowerCase().contains('kilogram')) {
              unitKey = 'KG'.tr;
            } else {
              unitKey = unitRaw;
            }
            cleaned = '$numPart $unitKey';
          }
        }

        baggagePerSegment.add(cleaned);
      }
    }

    // ملخص نصي للأمتعة
    String? baggageInfo;
    final nonEmptyBags = baggagePerSegment.where((b) => b.isNotEmpty).toList();
    if (nonEmptyBags.isNotEmpty) {
      baggageInfo = nonEmptyBags.join(', ');
    } else {
      baggageInfo = null;
    }

    final validatingCode = _s(json['validatingAirlineCode']);

    

    // int countStops(List<FlightLegModel> legs) {
    //   int count = 0;
    //   for (final leg in legs) {
    //     count += leg.stops;
    //   }
    //   return count;
    // }

    

    return FlightOfferModel(
      id: _s(json['id']),
      airlineCode: validatingCode, 
      airlineName: (AirlineRepo.searchByCode(validatingCode) != null) ? AirlineRepo.searchByCode(validatingCode)!.name[AppVars.lang] : "",
      airlineNumber: firstSeg.marketingAirlineNumber,
      isRefundable: _bool(json['isRefundable']),
      legs: legs,
      segments: allSegments,
      marketingAirlineCodes: marketingCodes,
      fromCode: firstSeg.fromCode,
      fromName: firstSeg.fromName,
      toCode: lastSeg.toCode,
      toName: lastSeg.toName, 
      departureDateTime: firstSeg.departureDateTime,
      arrivalDateTime: lastSeg.arrivalDateTime,
      stops: legs.first.stops,
      totalDurationText: legs.first.totalDurationText,
      totalAmount: _double(json['itineraryFares']?['totalFare']?['amount']),
      currency: _s(json['itineraryFares']?['totalFare']?['currency']),
      cabinClassText: firstSeg.cabinClassText,
      bookingClassCode: firstSeg.bookingClassCode,
      equipmentNumber: firstSeg.equipmentNumber,
      seatsRemaining: firstSeg.seatsRemaining,
      baggageInfo: baggageInfo,
      baggagePerSegment: baggagePerSegment,
    );
  }
}
