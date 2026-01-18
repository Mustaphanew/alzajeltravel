import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/repo/country_repo.dart';

enum ContactTitle { mr, miss, mrs }

extension ContactTitleApiExt on ContactTitle {
  String get apiValue {
    switch (this) {
      case ContactTitle.mr:
        return 'MR';
      case ContactTitle.miss:
        return 'MISS';
      case ContactTitle.mrs:
        return 'MRS';
    }
  }

  static ContactTitle fromApi(String value) {
    switch (value.toUpperCase()) {
      case 'MR':
        return ContactTitle.mr;
      case 'MISS':
        return ContactTitle.miss;
      case 'MRS':
        return ContactTitle.mrs;
      default:
        return ContactTitle.mr;
    }
  }
}

class ContactModel {
  final ContactTitle title;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final CountryModel phoneCountry;
  final CountryModel nationality;

  const ContactModel({
    required this.title,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.phoneCountry,
    required this.nationality,
  });

  ContactModel copyWith({
    ContactTitle? title,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    CountryModel? phoneCountry,
    CountryModel? nationality,
  }) {
    return ContactModel(
      title: title ?? this.title,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      phoneCountry: phoneCountry ?? this.phoneCountry,
      nationality: nationality ?? this.nationality,
    );
  }

  Map<String, dynamic> toApiJson() {
    final first = firstName.trim();
    final last = lastName.trim();
    final emailTrimmed = email.trim();
    final phoneTrimmed = phone.trim();

    final dial = phoneCountry.dialcode; // "967"
    final alpha2 = nationality.alpha2;  // "YE"
    final enName = nationality.name['en'] ?? ''; // "Yemen"

    return {
      'title': title.apiValue,
      'first_name': first.toUpperCase(),
      'last_name': last.toUpperCase(),
      'email': emailTrimmed,
      'phone': phoneTrimmed,
      'country_code': '+$dial',
      'nationality': '${alpha2}_$enName',
    };
  }

  /// لو احتجت ترجع تبني ContactModel من JSON راجع من الـ API
  factory ContactModel.fromApiJson(Map<String, dynamic> json) {
    final titleStr = (json['title'] ?? '').toString();
    final dialStr =
        (json['country_code'] ?? '').toString().replaceAll('+', '');
    final nationalityStr = (json['nationality'] ?? '').toString();

    // نتوقع شكل "YE_Yemen"
    final parts = nationalityStr.split('_');
    final alpha2 = parts.isNotEmpty ? parts.first : '';

    // ✅ استخدام CountryRepo مباشرة
    final phoneCountry =
        CountryRepo.searchByDialcode(dialcode: dialStr) ??
        CountryRepo.searchByAlpha(alpha2)!; // fallback بسيط لو حبيت

    final nationalityCountry =
        CountryRepo.searchByAlpha(alpha2) ??
        phoneCountry;

    return ContactModel(
      title: ContactTitleApiExt.fromApi(titleStr),
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
      phoneCountry: phoneCountry,
      nationality: nationalityCountry,
    );
  }
}
