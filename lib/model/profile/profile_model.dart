import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';

class ProfileModel {
  final String companyRegistrationNumber;
  final String name;
  final String email;
  final String agencyNumber;
  final String phone;
  final CountryModel? country;
  final String address;
  final String website;
  final String? branchCode;
  final String status;

  // Balances (read-only)
  final double? remainingBalance;

  const ProfileModel({
    required this.companyRegistrationNumber,
    required this.name,
    required this.email,
    required this.agencyNumber,
    required this.phone,
    required this.country,
    required this.address,
    required this.website,
    this.branchCode,
    required this.status,
    this.remainingBalance,
  });

  static String _readString(Map<String, dynamic> map, List<String> keys) {
    for (final k in keys) {
      final v = map[k];
      if (v != null) return v.toString();
    }
    return '';
  }

  static double _readMoney(Map<String, dynamic> map, List<String> keys) {
    final raw = _readString(map, keys);
    final cleaned = raw
        .trim()
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .replaceAll('\u00A0', '');
    return double.tryParse(cleaned) ?? 0.0;
  }

  static CountryModel? _readCountry(String code) {
    return CountryRepo.searchByAlpha(code);
  }

  factory ProfileModel.fromJson(Map<String, dynamic> map) {
    return ProfileModel(
      companyRegistrationNumber: _readString(map, [
        'companyRegistrationNumber',
        'Company Registration Number',
        'رقم تسجيل الشركة',
        'رقم تسجيل الشركة:',
      ]),
      name: _readString(map, ['name', 'Name', 'الاسم', 'الاسم:']),
      email: _readString(map, ['email', 'Email', 'البريد الالكتروني', 'البريد الالكتروني:']),
      agencyNumber: _readString(map, ['agencyNumber', 'Agency Number', 'رقم الوكالة', 'رقم الوكالة:']),
      phone: _readString(map, ['phone', 'Phone', 'رقم الهاتف', 'رقم الهاتف:']),
      country: _readCountry(_readString(map, ['country', 'Country', 'البلد', 'البلد:'])),
      address: _readString(map, ['address', 'Address', 'العنوان', 'العنوان:']),
      website: _readString(map, ['website', 'Website', 'الموقع الالكتروني', 'الموقع الالكتروني:']),
      status: _readString(map, ['status', 'Status', 'الحالة', 'الحالة:']),

      remainingBalance: _readMoney(map, ['remainingBalance', 'Remaining Balance', 'الرصيد المتبقي', 'الرصيد المتبقي:']),
      branchCode: _readString(map, ['branchCode', 'Branch Code', 'رقم الفرع', 'رقم الفرع:']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'companyRegistrationNumber': companyRegistrationNumber,
      'name': name,
      'email': email,
      'agencyNumber': agencyNumber,
      'phone': phone,
      'country': country?.alpha2,
      'address': address,
      'website': website,
      'branchCode': branchCode,
      'status': status,

      // balances are read-only (normally you do not send them for update)
      'remainingBalance': remainingBalance,
    };
  }

  bool get isApproved => status.toLowerCase() == 'approved';
}
