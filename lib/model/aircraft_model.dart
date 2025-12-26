class AircraftModel {
  final String code;
  final String? name;
  final String? body;
  final String? image;

  const AircraftModel({required this.code, this.name, this.body, this.image});

  factory AircraftModel.fromJson(Map<String, dynamic> json) {
    return AircraftModel(code: json['code'], name: json['name'], body: json['body'], image: json['image']);
  }

  Map<String, dynamic> toJson() {
    return {'code': code, 'name': name, 'body': body, 'image': image};
  }
}
