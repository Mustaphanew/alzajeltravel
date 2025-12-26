import 'package:alzajeltravel/utils/app_consts.dart';

class IntroModel {
  int id;
  String name;
  String body;
  String image;
  String? deletedAt;
  String createdAt;
  String updatedAt;

  IntroModel({
    required this.id,
    required this.name,
    required this.body,
    required this.image,
    this.deletedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory IntroModel.fromJson(Map<String, dynamic> json) {
    return IntroModel(
      id: json['id'],
      name: json['name'],
      body: json['body'],
      image: AppConsts.imageUrl + json['image'],
      deletedAt: json['deleted_at'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'body': body,
      'deleted_at': deletedAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
