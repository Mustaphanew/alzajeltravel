import 'package:alzajeltravel/utils/enums.dart';

/// ===================================================================
/// TravelerConfig
/// ===================================================================
/// هذا الموديل يمثّل "مسافر واحد" في شاشة جوازات السفر.
///
/// - index:
///   رقم المسافر في القائمة (1, 2, 3, ...)
///
/// - ageGroup:
///   نوع المسافر حسب الفئة العمرية:
///   Adult / Child / Infant (من enum AgeGroup)
///
/// - tag:
///   اسم مميّز نستخدمه كـ tag في GetX لكل مسافر
///   حتى يكون لكل مسافر PassportController مستقل.
class TravelerConfig {
  /// رقم المسافر (للعرض فقط: Traveler 1, Traveler 2, ...)
  final int index;

  /// نوع المسافر: Adult / Child / Infant
  final AgeGroup ageGroup;

  /// tag مميّز نستخدمه مع GetBuilder/PassportController
  final String tag;

  const TravelerConfig({
    required this.index,
    required this.ageGroup,
    required this.tag,
  });
}
