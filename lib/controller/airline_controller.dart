import 'package:get/get.dart';
import 'package:alzajeltravel/model/airline_model.dart';
import 'package:alzajeltravel/repo/airline_repo.dart';

class AirlineController extends GetxController {
  final AirlineRepo airlineRepo = AirlineRepo();

  // المسموح بها
  List<AirlineModel> includeItems = [];
  // المستبعدة
  List<AirlineModel> excludeItems = [];

  List<Map<String, dynamic>> results = [];

  Future<List<AirlineModel>> getData(String? filter) async {
    final trimmed = filter?.trim() ?? '';
    final List<Map<String, dynamic>> res = await airlineRepo.search(trimmed);
    results.assignAll(res);
    return results.map((e) {
      return AirlineModel.fromJson(e);
    }).toList();
  }

  // تعيين المسموح (ويُحذف أي تداخل من المستبعد)
  void setInclude(List<AirlineModel> items) {
    includeItems = items;
    excludeItems.removeWhere((x) => includeItems.any((i) => i.id == x.id));
    update();
  }

  // تعيين المستبعد (ويُحذف أي تداخل من المسموح)
  void setExclude(List<AirlineModel> items) {
    excludeItems = items;
    includeItems.removeWhere((x) => excludeItems.any((i) => i.id == x.id));
    update();
  }

  // حذف عنصر من المسموح
  void removeInclude(AirlineModel item) {
    includeItems = List.of(includeItems)..removeWhere((x) => x.id == item.id);
    update();
  }

  // حذف عنصر من المستبعد
  void removeExclude(AirlineModel item) {
    excludeItems = List.of(excludeItems)..removeWhere((x) => x.id == item.id);
    update();
  }

  bool inInclude(AirlineModel a) => includeItems.any((i) => i.id == a.id);
  bool inExclude(AirlineModel a) => excludeItems.any((i) => i.id == a.id);


  /// ترجع اسم شركة الطيران حسب الكود واللغة الحالية للتطبيق
  // String getAirlineName(String code, {bool withCode = true}) {
  //   // نتأكد أن الكود بنفس الحالة (أغلب الأكواد UPPERCASE)
  //   final normalizedCode = code.toUpperCase();

  //   // نحاول نلاقي السطر المطابق للكود
  //   final match = airlineRepo.data.where((airline) => airline['code'] == normalizedCode);
  //   if (match.isEmpty) {
  //     // لو ما وجدنا الشركة، نرجع الكود نفسه كـ fallback
  //     return normalizedCode;
  //   }

  //   final airline = match.first;
  //   final nameField = airline['name'];
  //   final lang = AppVars.lang; // "ar" أو "en"

  //   // لو الاسم مخزّن كنص فقط (احتياط لو في بيانات قديمة)
  //   if (nameField is String) {
  //     return nameField;
  //   }

  //   // لو الاسم Map فيه en / ar
  //   if (nameField is Map) {
  //     // نحاول نرجع حسب لغة التطبيق
  //     if (lang == 'ar' && nameField['ar'] != null) { 
  //       return (nameField['ar'] + (withCode ? " ($normalizedCode)" : "")) as String;
  //     }
  //     if (nameField['en'] != null) {
  //       return (nameField['en'] + (withCode ? " ($normalizedCode)" : "")) as String;
  //     }

  //     // fallback: أول قيمة متوفرة في الـ map
  //     final firstNonNull = nameField.values
  //         .where((v) => v != null)
  //         .cast<String>()
  //         .toList();
  //     if (firstNonNull.isNotEmpty) {
  //       return firstNonNull.first;
  //     }
  //   }

  //   // لو كل شيء فشل، نرجع الكود
  //   return normalizedCode;
  // }
}
