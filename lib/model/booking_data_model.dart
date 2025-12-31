// booking_data_model.dart

import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';
import 'package:alzajeltravel/utils/enums.dart';




class BookingDataModel {
  final String id;
  final String companyId; // company_Id
  final String customerId; // customer_id
  final String module;
  final BookingStatus status;
  final DateTime createdOn; // created_on
  final DateTime travelDate; // travel_date
  final String bookedBy; // booked_by
  final String bookingId; // booking_id
  final CountryModel? countryCode; // بدون +
  final String mobileNo; // mobile_no
  final String currency;
  final String? pnr;

  const BookingDataModel({
    required this.id,
    required this.companyId,
    required this.customerId,
    required this.module,
    required this.status,
    required this.createdOn,
    required this.travelDate,
    required this.bookedBy,
    required this.bookingId,
    required this.countryCode,
    required this.mobileNo,
    required this.currency,
    this.pnr,
  });

  /// يدعم:
  /// - "2025-12-08 17:28:21"
  /// - "2025-12-08T17:28:21"
  /// - "2025-12-15"
  static DateTime _parseDateTime(dynamic value) {
    final s = (value ?? '').toString().trim();
    if (s.isEmpty) return DateTime.fromMillisecondsSinceEpoch(0);

    // إذا كانت بصيغة: yyyy-MM-dd HH:mm:ss نحولها إلى ISO: yyyy-MM-ddTHH:mm:ss
    final normalized = s.contains(' ') && !s.contains('T') ? s.replaceFirst(' ', 'T') : s;

    final dt = DateTime.tryParse(normalized);
    return dt ?? DateTime.fromMillisecondsSinceEpoch(0);
  }

  static String _cleanCountryCode(dynamic value) {
    final s = (value ?? '').toString().trim();
    // إزالة + وأي رموز غير رقمية
    final digitsOnly = s.replaceAll(RegExp(r'[^0-9]'), '');
    return digitsOnly;
  }

  factory BookingDataModel.fromJson(Map<String, dynamic> json) {
    return BookingDataModel(
      id: (json['id'] ?? '').toString(),
      companyId: (json['company_Id'] ?? '').toString(),
      customerId: (json['customer_id'] ?? '').toString(),
      module: (json['module'] ?? '').toString(),
      status: BookingStatus.fromJson((json['status'] ?? '').toString().toLowerCase()),
      createdOn: _parseDateTime(json['created_on']),
      travelDate: _parseDateTime(json['travel_date']),
      bookedBy: (json['booked_by'] ?? '').toString(),
      bookingId: (json['booking_id'] ?? '').toString(),
      countryCode: CountryRepo.searchByDialcode(json['country_code']),
      mobileNo: (json['mobile_no'] ?? '').toString(),
      currency: (json['currency'] ?? '').toString(),
      pnr: json['pnr'] == null ? null : json['pnr'].toString(),
    );
  }

  /// toMap (بنفس مفاتيح السيرفر قدر الإمكان)
  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "company_Id": companyId,
      "customer_id": customerId,
      "module": module,
      "status": status,
      "created_on": createdOn.toIso8601String(),
      "travel_date": travelDate.toIso8601String(),
      "booked_by": bookedBy,
      "booking_id": bookingId,
      "country_code": countryCode?.dialcode, // بدون +
      "mobile_no": mobileNo,
      "currency": currency,
      "pnr": pnr,
    };
  }

  BookingDataModel copyWith({
    String? id,
    String? companyId,
    String? customerId,
    String? module,
    BookingStatus? status,
    DateTime? createdOn,
    DateTime? travelDate,
    String? bookedBy,
    String? bookingId,
    CountryModel? countryCode,
    String? mobileNo,
    String? currency,
    String? pnr,
  }) {
    return BookingDataModel(
      id: id ?? this.id,
      companyId: companyId ?? this.companyId,
      customerId: customerId ?? this.customerId,
      module: module ?? this.module,
      status: status ?? this.status,
      createdOn: createdOn ?? this.createdOn,
      travelDate: travelDate ?? this.travelDate,
      bookedBy: bookedBy ?? this.bookedBy,
      bookingId: bookingId ?? this.bookingId,
      countryCode: countryCode ?? this.countryCode,
      mobileNo: mobileNo ?? this.mobileNo,
      currency: currency ?? this.currency,
      pnr: pnr ?? this.pnr,
    );
  }

  @override
  String toString() => 'Booking($bookingId, status=$status, travel=$travelDate)';
}
