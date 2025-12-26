class ClassTypeModel {
  int id;
  String code;
  Map<String, dynamic> name;

  ClassTypeModel({
    required this.id,
    required this.code,
    required this.name,
  });

  factory ClassTypeModel.fromJson(Map<String, dynamic> json) => ClassTypeModel(
        id: json["id"],
        code: json["code"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "code": code,
        "name": name,
      };
}
