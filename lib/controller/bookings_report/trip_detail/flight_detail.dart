import 'dart:convert';

import 'package:get/get.dart';
import 'package:alzajeltravel/model/flight/revalidated_flight_model.dart';
import 'package:alzajeltravel/model/flight/flight_offer_model.dart';
import 'package:alzajeltravel/model/flight/flight_leg_model.dart';
import 'package:alzajeltravel/model/flight/flight_segment_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class FlightDetail {
  static final RegExp _brExp = RegExp(r'<br\s*/?>', caseSensitive: false);

  static String _s(dynamic v) => v == null ? '' : v.toString();

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

  // static int? _intOrNull(dynamic v) {
  //   if (v is int) return v;
  //   if (v is num) return v.toInt();
  //   if (v is String && v.trim().isNotEmpty) return int.tryParse(v.trim());
  //   return null;
  // }

  static double _double(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String && v.trim().isNotEmpty) return double.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static DateTime? _tryDt(dynamic v) {
    final raw = _s(v).trim();
    if (raw.isEmpty || raw.toLowerCase() == 'null') return null;

    // يدعم: "2026-01-31 23:59:59" بتحويلها إلى ISO
    final fixed = raw.contains('T') ? raw : raw.replaceFirst(' ', 'T');
    return DateTime.tryParse(fixed);
  }

  static String _formatMinutes(int minutes) {
    if (minutes <= 0) return '0m';
    final h = minutes ~/ 60;
    final m = minutes % 60;
    if (h <= 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  static List<List<String>> _splitLegsSegments(dynamic raw) {
    final s = _s(raw).trim();
    if (s.isEmpty) return const [];

    final legs = s.split(_brExp);
    return legs.map((leg) {
      final t = leg.trim();
      if (t.isEmpty) return <String>[];
      return t.split('~').map((e) => e.trim()).toList();
    }).toList();
  }

  static String _get2D(List<List<String>> data, int leg, int idx) {
    if (leg < 0 || leg >= data.length) return '';
    final row = data[leg];
    if (idx < 0 || idx >= row.length) return '';
    return row[idx];
  }

  static int _legLen(List<List<String>> data, int leg) {
    if (leg < 0 || leg >= data.length) return 0;
    return data[leg].length;
  }

  static String _cleanBaggage(String raw) {
    final s = raw.trim();
    if (s.isEmpty) return '';
    if (s.toLowerCase() == 'array') return '';

    final match = RegExp(r'^(\d+)\s*([A-Za-z/]+)').firstMatch(s);
    if (match == null) return s;

    final numPart = match.group(1)!;
    final unitRaw = match.group(2)!.toLowerCase();

    if (unitRaw.contains('piece')) return '$numPart ${'Piece'.tr}';
    if (unitRaw.contains('kilogram') || unitRaw == 'kg') return '$numPart ${'KG'.tr}';

    return '$numPart ${match.group(2)!}';
  }

  static List<String> _baggagePerSegment(dynamic rawBaggage, int totalSegments) {
    if (totalSegments <= 0) return const [];

    final raw = _s(rawBaggage).trim();
    if (raw.isEmpty) return List<String>.filled(totalSegments, '');

    final parts = raw.split(_brExp);
    final flat = <String>[];
    for (final p in parts) {
      flat.addAll(p.split('~'));
    }

    final cleaned = flat.map(_cleanBaggage).toList();

    // لو كلها Array/فارغة
    final anyNonEmpty = cleaned.any((e) => e.trim().isNotEmpty);
    if (!anyNonEmpty) return List<String>.filled(totalSegments, '');

    // قيمة واحدة: كررها لكل السيجمنتات
    final firstNonEmpty = cleaned.firstWhere((e) => e.trim().isNotEmpty, orElse: () => '');
    if (cleaned.length == 1 || (cleaned.length > 1 && cleaned.where((e) => e.trim().isNotEmpty).length == 1)) {
      return List<String>.filled(totalSegments, firstNonEmpty);
    }

    // تطابق كامل
    if (cleaned.length == totalSegments) return cleaned;

    // mismatch: قص/كمّل بآخر قيمة
    final out = <String>[];
    for (int i = 0; i < totalSegments; i++) {
      if (i < cleaned.length) {
        out.add(cleaned[i]);
      } else {
        out.add(cleaned.last);
      }
    }
    return out;
  }

  static List<FareRule> _parseFareRules(dynamic raw) {
    if (raw == null) return const [];

    // ممكن يكون String JSON
    if (raw is String) {
      final s = raw.trim();
      if (s.isEmpty || s.toLowerCase() == 'null') return const [];
      try {
        final decoded = jsonDecode(s);
        if (decoded is List) {
          return decoded
              .whereType<Map<String, dynamic>>()
              .map(FareRule.fromJson)
              .toList();
        }
      } catch (_) {
        return const [];
      }
    }

    // أو List بالفعل
    if (raw is List) {
      return raw
          .whereType<Map<String, dynamic>>()
          .map(FareRule.fromJson)
          .toList();
    }

    return const [];
  }

  static RevalidatedFlightModel flightDetail(Map<String, dynamic> flight) {
    // ====== تفكيك الحقول إلى legs/segments ======
    final depCodes = _splitLegsSegments(flight['departure_airportcode']);
    final depNames = _splitLegsSegments(flight['departure_airportname']);
    final arrCodes = _splitLegsSegments(flight['arrival_airportcode']);
    final arrNames = _splitLegsSegments(flight['arrival_airportname']);

    final depDTs = _splitLegsSegments(flight['DepartureDateTime']);
    final arrDTs = _splitLegsSegments(flight['ArrivalDateTime']);

    final flightNums = _splitLegsSegments(flight['FlightNumber']);
    final marketingCodes = _splitLegsSegments(flight['MarketingAirlineCode']);

    final equip = _splitLegsSegments(flight['OperatingAirline_Equipment']);
    final cabinText = _splitLegsSegments(flight['CabinClassText']);
    final cabinCode = _splitLegsSegments(flight['CabinClassCode']);
    final journeyDur = _splitLegsSegments(flight['JourneyDuration']);

    // عدد الـ legs = أكبر عدد legs موجود
    int legsCount = 0;
    for (final f in [
      depCodes, arrCodes, depDTs, arrDTs, flightNums, marketingCodes,
      equip, cabinText, cabinCode, journeyDur, depNames, arrNames,
    ]) {
      if (f.length > legsCount) legsCount = f.length;
    }

    final legs = <FlightLegModel>[];

    for (int l = 0; l < legsCount; l++) {
      // عدد السيجمنتات لهذا الـ leg = أكبر طول داخل هذا الـ leg
      int segCount = 0;
      for (final f in [
        depCodes, arrCodes, depDTs, arrDTs, flightNums, marketingCodes,
        equip, cabinText, cabinCode, journeyDur, depNames, arrNames,
      ]) {
        final len = _legLen(f, l);
        if (len > segCount) segCount = len;
      }

      final segs = <FlightSegmentModel>[];

      for (int s = 0; s < segCount; s++) {
        final dep = _tryDt(_get2D(depDTs, l, s)) ?? DateTime.fromMillisecondsSinceEpoch(0);
        final arr = _tryDt(_get2D(arrDTs, l, s)) ?? DateTime.fromMillisecondsSinceEpoch(0);

        // journey minutes: من JourneyDuration لو موجودة وإلا من فرق الوقت
        int? jMin;
        final rawJ = _get2D(journeyDur, l, s).trim();
        final parsedJ = int.tryParse(rawJ);
        if (parsedJ != null && parsedJ > 0) {
          jMin = parsedJ;
        } else {
          final diff = arr.difference(dep).inMinutes;
          if (diff > 0) jMin = diff;
        }

        final jText = (jMin != null) ? _formatMinutes(jMin) : null;

        // layover قبل هذا السيجمنت
        int? layMin;
        String? layText;
        if (s > 0 && segs.isNotEmpty) {
          final prevArr = segs[s - 1].arrivalDateTime;
          final diff = dep.difference(prevArr).inMinutes;
          if (diff > 0) {
            layMin = diff;
            layText = _formatMinutes(diff);
          }
        }

        final fallbackBooking = _s(flight['class']).trim();

        segs.add(
          FlightSegmentModel(
            marketingAirlineCode: _get2D(marketingCodes, l, s),
            marketingAirlineNumber: _get2D(flightNums, l, s),
            fromCode: _get2D(depCodes, l, s),
            fromName: _get2D(depNames, l, s),
            departureDateTime: dep,
            toCode: _get2D(arrCodes, l, s),
            toName: _get2D(arrNames, l, s),
            arrivalDateTime: arr,
            equipmentNumber: _get2D(equip, l, s),
            cabinClassText: _get2D(cabinText, l, s),
            bookingClassCode: (() {
              final c = _get2D(cabinCode, l, s);
              return c.isNotEmpty ? c : fallbackBooking;
            })(),
            journeyMinutes: jMin,
            journeyText: jText,
            layoverMinutes: layMin,
            layoverText: layText,
            seatsRemaining: '',
          ),
        );
      }

      final journeyTotal = segs.fold<int>(0, (sum, e) => sum + (e.journeyMinutes ?? 0));
      final layoverTotal = segs.fold<int>(0, (sum, e) => sum + (e.layoverMinutes ?? 0));
      final total = journeyTotal + layoverTotal;

      legs.add(
        FlightLegModel(
          segments: segs,
          stops: segs.isEmpty ? 0 : (segs.length - 1),
          totalJourneyDurationText: _formatMinutes(journeyTotal),
          totalLayoverDurationText: _formatMinutes(layoverTotal),
          totalDurationText: _formatMinutes(total),
        ),
      );
    }

    // ====== Flatten segments ======
    final allSegments = <FlightSegmentModel>[];
    for (final leg in legs) {
      allSegments.addAll(leg.segments);
    }

    // حماية بسيطة لو response ناقص
    if (allSegments.isEmpty) {
      final emptyOffer = FlightOfferModel(
        id: _s(flight['booking_id']).isNotEmpty ? _s(flight['booking_id']) : _s(flight['id']),
        airlineCode: '',
        airlineName: '',
        airlineNumber: '',
        isRefundable: _bool(flight['refundable']),
        legs: const [],
        segments: const [],
        marketingAirlineCodes: const [],
        fromCode: '',
        fromName: '',
        toCode: '',
        toName: '',
        departureDateTime: DateTime.fromMillisecondsSinceEpoch(0),
        arrivalDateTime: DateTime.fromMillisecondsSinceEpoch(0),
        stops: 0,
        totalDurationText: '',
        totalAmount: _double(flight['total_fare']),
        currency: _s(flight['currency_code']),
        cabinClassText: '',
        bookingClassCode: '',
        equipmentNumber: '',
        seatsRemaining: '',
        baggageInfo: null,
        baggagePerSegment: const [],
      );

      return RevalidatedFlightModel(
        offer: emptyOffer,
        isRefundable: emptyOffer.isRefundable,
        isPassportMandatory: _bool(flight['is_passport_mandatory']),
        firstNameCharacterLimit: 0,
        lastNameCharacterLimit: 0,
        paxNameCharacterLimit: 0,
        fareRules: _parseFareRules(flight['fare_rules']),
        timeLimit: _tryDt(flight['ticket_deadline']),
      );
    }

    final firstSeg = allSegments.first;
    final lastSeg = allSegments.last;

    // marketing airline codes unique
    final seen = <String>{};
    final marketingUnique = <String>[];
    for (final seg in allSegments) {
      if (seg.marketingAirlineCode.isNotEmpty && seen.add(seg.marketingAirlineCode)) {
        marketingUnique.add(seg.marketingAirlineCode);
      }
    }

    // baggage
    final baggagePerSegment = _baggagePerSegment(flight['baggage'], allSegments.length);
    final nonEmptyBags = baggagePerSegment.where((b) => b.trim().isNotEmpty).toList();
    final baggageInfo = nonEmptyBags.isNotEmpty ? nonEmptyBags.join(', ') : null;

    // airline
    final airlineCode = firstSeg.marketingAirlineCode;
    final airlineName = (AirlineRepo.searchByCode(airlineCode) != null)
        ? AirlineRepo.searchByCode(airlineCode)!.name[AppVars.lang]
        : '';

    final offerId = _s(flight['booking_id']).isNotEmpty
        ? _s(flight['booking_id'])
        : (_s(flight['flight_session']).isNotEmpty ? _s(flight['flight_session']) : _s(flight['id']));

    final offer = FlightOfferModel(
      id: offerId,
      airlineCode: airlineCode,
      airlineName: airlineName,
      airlineNumber: firstSeg.marketingAirlineNumber,
      isRefundable: _bool(flight['refundable']),
      legs: legs,
      segments: allSegments,
      marketingAirlineCodes: marketingUnique,
      fromCode: firstSeg.fromCode,
      fromName: firstSeg.fromName,
      toCode: lastSeg.toCode,
      toName: lastSeg.toName,
      departureDateTime: firstSeg.departureDateTime,
      arrivalDateTime: lastSeg.arrivalDateTime,
      stops: legs.fold<int>(0, (sum, e) => sum + e.stops),
      totalDurationText: legs.isNotEmpty ? legs.first.totalDurationText : '',
      totalAmount: _double(flight['total_fare']),
      currency: _s(flight['currency_code']),
      cabinClassText: firstSeg.cabinClassText,
      bookingClassCode: firstSeg.bookingClassCode,
      equipmentNumber: firstSeg.equipmentNumber,
      seatsRemaining: '',
      baggageInfo: baggageInfo,
      baggagePerSegment: baggagePerSegment,
    );

    return RevalidatedFlightModel(
      offer: offer,
      isRefundable: offer.isRefundable,
      isPassportMandatory: _bool(flight['is_passport_mandatory']),
      firstNameCharacterLimit: 0,
      lastNameCharacterLimit: 0,
      paxNameCharacterLimit: 0,
      fareRules: _parseFareRules(flight['fare_rules']),
      timeLimit: _tryDt(flight['ticket_deadline']),
    );
  }
}
