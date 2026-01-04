import 'package:alzajeltravel/utils/app_consts.dart';

class AirlineModel {
  final int id;
  final String code; // IATA: TK, QR...
  final Map<String, dynamic> name; // Turkish Airlines
  final String countryCode;
  final String? note; // الوصف

  const AirlineModel({
    required this.id,
    required this.code, 
    required this.name, 
    required this.countryCode,
    this.note, 
    });

  factory AirlineModel.fromJson(Map<String, dynamic> json) {
    return AirlineModel(
      id: json['id'],
      code: json['code'],
      name: json['name'], 
      countryCode: json['country_code'],
      note: json['note'],
      
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "code": code, 
      "name": name, 
      "country_code": countryCode,
      "note": note, 
    };
  }
}
