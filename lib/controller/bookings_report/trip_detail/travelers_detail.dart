import 'package:alzajeltravel/model/passport/traveler_review/traveler_review_model.dart';
import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/utils/enums.dart';

class TravelersDetail {
  static final RegExp _brExp = RegExp(r'<br\s*/?>', caseSensitive: false);

  static String _s(dynamic v) => v == null ? '' : v.toString();

  static List<String> _splitBr(dynamic v) {
    final s = _s(v).trim();
    if (s.isEmpty) return [];
    return s.split(_brExp).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    final s = _s(v).trim();
    if (s.isEmpty) return 0.0;
    return double.tryParse(s) ?? 0.0;
  }

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    final s = _s(v).trim();
    if (s.isEmpty) return 0;
    return int.tryParse(s) ?? 0;
  }

  static String? _normalizeSex(dynamic v) {
    final s = _s(v).trim().toLowerCase();
    // عندك غالباً "M" / "F" أو "male/female"
    if (s == 'm' || s == 'male') return 'm';
    if (s == 'f' || s == 'female') return 'f';
    return null;
  }

  static String _paxCodeFromPassenger(dynamic paxType) {
    final s = _s(paxType).trim().toLowerCase();
    if (s == 'adult' || s == 'adt') return 'ADT';
    if (s == 'child' || s == 'cnn' || s == 'chd') return 'CNN';
    if (s == 'infant' || s == 'inf') return 'INF';
    return 'ADT';
  }

  static AgeGroup _ageGroupFromPaxCode(String paxCode) {
    final c = paxCode.trim().toUpperCase();
    if (c == 'INF') return AgeGroup.infant;
    if (c == 'CNN' || c == 'CHD') return AgeGroup.child;
    return AgeGroup.adult; // ADT
  }

  /// يبني قائمة Pax Codes بطول عدد المسافرين حسب flight.pass_type + flight.pass_quantity
  /// مثال: ADT<br>CNN<br>INF مع 2<br>1<br>1 => [ADT, ADT, CNN, INF]
  static List<String> _expandPaxCodes(Map<String, dynamic> flight) {
    final types = _splitBr(flight['pass_type']);
    final qtys = _splitBr(flight['pass_quantity']);

    final result = <String>[];

    if (types.isNotEmpty) {
      for (int i = 0; i < types.length; i++) {
        final code = types[i].trim();
        int q = 0;

        if (i < qtys.length) {
          q = _toInt(qtys[i]);
        }

        // fallback لو pass_quantity ناقصة/فاضية
        if (q <= 0) {
          if (code == 'ADT') q = _toInt(flight['adult_flight']);
          if (code == 'CNN') q = _toInt(flight['child_flight']);
          if (code == 'INF') q = _toInt(flight['infant_flight']);
        }

        for (int k = 0; k < q; k++) {
          result.add(code);
        }
      }
    }

    return result;
  }

  static Map<String, double> _mapFareByType(Map<String, dynamic> flight, String key) {
    final types = _splitBr(flight['pass_type']);
    final vals = _splitBr(flight[key]);

    final map = <String, double>{};
    for (int i = 0; i < types.length; i++) {
      final code = types[i].trim();
      final v = (i < vals.length) ? _toDouble(vals[i]) : 0.0;
      map[code] = v;
    }
    return map;
  }

  static List<String> _ticketNumbersFromFlight(Map<String, dynamic> flight) {
    return _splitBr(flight['eTicketNumber']);
  }

  static List<TravelerReviewModel> travelersDetail(
    Map<String, dynamic> flight,
    List<dynamic> passengers,
  ) {
    final paxQueue = _expandPaxCodes(flight); // ADT/ADT/CNN/INF...
    final baseByType = _mapFareByType(flight, 'pass_basefare_amount');
    final taxByType = _mapFareByType(flight, 'pass_tax_amount');

    final flightTickets = _ticketNumbersFromFlight(flight);

    final travelers = <TravelerReviewModel>[];

    for (int i = 0; i < passengers.length; i++) {
      final p = (passengers[i] as Map).cast<String, dynamic>();

      // نحدد paxCode حسب ترتيب pass_type/quantity (الأكثر موثوقية)
      final paxCode = (i < paxQueue.length && paxQueue[i].trim().isNotEmpty)
          ? paxQueue[i].trim()
          : _paxCodeFromPassenger(p['pax_type']);

      final ageGroup = _ageGroupFromPaxCode(paxCode);

      // الأسعار: passenger أولاً، لو فاضية نرجع لـ flight حسب paxCode
      final baseFromPassenger = _toDouble(p['Base_Amount']);
      final taxFromPassenger = _toDouble(p['Tax_Total']);

      final baseFare = baseFromPassenger > 0 ? baseFromPassenger : (baseByType[paxCode] ?? 0.0);
      final taxTotal = taxFromPassenger > 0 ? taxFromPassenger : (taxByType[paxCode] ?? 0.0);

      // ticket number: من passenger وإلا من flight.eTicketNumber بنفس index
      final ticketNumber = _s(p['eTicketNumber']).trim().isNotEmpty
          ? _s(p['eTicketNumber']).trim()
          : (i < flightTickets.length ? flightTickets[i].trim() : null);

      final passport = PassportModel.fromJson({
        'documentNumber': _s(p['passport_no']).trim(),
        'givenNames': _s(p['first_name']).trim(),
        'surnames': _s(p['last_name']).trim(),
        'dateOfBirth': _s(p['dob']).trim(),
        'sex': _normalizeSex(p['gender']),
        'dateOfExpiry': _s(p['expiry_date']).trim(),
        'nationality': p['nationality'],
        'issue_country': p['issue_country'],
      });

      travelers.add(
        TravelerReviewModel(
          passport: passport,
          ageGroup: ageGroup, // ✅ الجديد
          baseFare: baseFare,
          taxTotal: taxTotal,
          seat: null,
          ticketNumber: ticketNumber,
        ),
      );
    }

    return travelers;
  }
}
