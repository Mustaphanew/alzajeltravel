// lib/model/flight/trip_detail/booking_detail.dart

import 'package:alzajeltravel/model/booking_data_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';

class BookingDetail {
  static String _s(dynamic v) => v == null ? '' : v.toString();

  static String _cleanCountryCode(dynamic value) {
    final s = _s(value).trim();
    // إزالة + وأي رموز غير رقمية
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// تدخل هنا فقط: response['booking']
  static BookingDataModel bookingDetail(Map<String, dynamic> bookingJson) {
    // نستخدم المودل الأصلي كما هو
    final model = BookingDataModel.fromJson(bookingJson);

    // fallback للـ country_code لو CountryRepo لا يطابق "+967"
    if (model.countryCode == null) {
      final raw = bookingJson['country_code'];
      final cleaned = _cleanCountryCode(raw);

      if (cleaned.isNotEmpty) {
        final found = CountryRepo.searchByDialcode(cleaned);
        if (found != null) {
          return model.copyWith(countryCode: found);
        }
      }
    }

    return model;
  }
}
