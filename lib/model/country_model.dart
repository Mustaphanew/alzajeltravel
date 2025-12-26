class CountryModel {
  Map<String, dynamic> name;
  String alpha2;
  String alpha3;
  String dialcode;

  CountryModel({
    required this.name,
    required this.alpha2,
    required this.alpha3,
    required this.dialcode,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    return CountryModel(
      name: json['name'],
      alpha2: json['alpha2'],
      alpha3: json['alpha3'],
      dialcode: json['dialcode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'alpha2': alpha2,
    'alpha3': alpha3,
    'dialcode': dialcode,
  };

}
