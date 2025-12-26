// lib/model/help_center_item.dart
class HelpCenterModel {
  final String name;
  final String url;
  final String? image;
  final String? text;

  const HelpCenterModel({
    required this.name,
    required this.url,
    this.image,
    this.text,
  });

  factory HelpCenterModel.fromJson(Map<String, dynamic> json) {
    return HelpCenterModel(
      name: (json['name'] ?? '').toString(),
      url: (json['url'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
      text: json['text']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'url': url,
    'image': image,
    'text': text,
  };
}
