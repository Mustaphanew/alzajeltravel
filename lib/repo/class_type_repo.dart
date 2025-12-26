import 'package:alzajeltravel/model/class_type_model.dart';

class ClassTypeRepo {
  static const List<Map<String, dynamic>> _data = [
    {
      "id": 1,
      "code": "Y",
      "name": {"en": "Economy", "ar": "اقتصادية"},
    },
    {
      "id": 2,
      "code": "W",
      "name": {"en": "Premium Economy", "ar": "اقتصادية مميزة"},
    },
    {
      "id": 3,
      "code": "C",
      "name": {"en": "Business", "ar": "رجال اعمال"},
    },
    {
      "id": 4,
      "code": "F",
      "name": {"en": "First Class", "ar": "الدرجة الاولى"},
    },
  ];

  Future<List<Map<String, dynamic>>> search(String query) async {
    await Future.delayed(const Duration(milliseconds: 500)); // تأخير بسيط
    final q = query.trim().toLowerCase();
    // if (q.isEmpty) return [];
    // البحث بالرمز او الاسم او الوصف
    final res = _data.where((element) {
      final e = ClassTypeModel.fromJson(element);
      return e.name['en'].toString().toLowerCase().contains(q) ||
             e.name['ar'].toString().toLowerCase().contains(q);
    }).toList();
    // حد اقصى (لانقاص الحمل)
    return res.take(100).toList();
  }
}
