
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/enums.dart';

class AirportModel {
  final String code;
  final Map<String, dynamic> name;
  final Map<String, dynamic> body;
  final String? image;
  final LocationType? type;

  const AirportModel({
    required this.code,
    required this.name,
    required this.body,
    this.image,
    this.type,
  });

  factory AirportModel.fromJson(Map<String, dynamic> json) => AirportModel(
    code: json['code'],
    name: json['name'],
    body: json['body'],
    image: json['image'],
    type: json['type'] == 'city' ? LocationType.city : json['type'] == 'airport' ? LocationType.airport : null,
  );

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'body': body,
    'image': image,
    'type': type == LocationType.city ? 'city' : type == LocationType.airport ? 'airport' : null,
  };

  @override
  String toString() => '$code — $name (${body[AppVars.lang]})';
} 
