import 'package:get/get.dart';
import 'langs/en.dart';
import 'langs/ar.dart';

class Translation implements Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    "en": en,
    "ar": ar,
  };
}
