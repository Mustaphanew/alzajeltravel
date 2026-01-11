import 'package:alzajeltravel/controller/search_flight_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/model/country_model.dart';
import 'package:jiffy/jiffy.dart';

/// =================================================================
/// PassportController
/// =================================================================
/// هذا الكنترولر مسؤول عن:
/// 1) إدارة حقول نموذج جواز سفر "مسافر واحد"
/// 2) ربط TextEditingController مع PassportModel
/// 3) استقبال بيانات من ماسح الـ MRZ (CameraScanPassport)
/// 4) توفير دوال لإعادة التهيئة / المسح / التحديث
///
/// ملاحظة مهمة:
/// - تستخدمه شاشة جواز السفر لكل مسافر (Adult/Child/Infant)
/// - لكل مسافر يكون عندك PassportController مستقل (tag مختلف في GetX).
class PassportController extends GetxController {
  /// مفتاح الـ Form للتحقق من الحقول (validate)
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  /// الموديل الذي يحتوي على جميع بيانات جواز السفر
  PassportModel model = PassportModel();
  final SearchFlightController searchFlightController = Get.find();
  DateTime lastDateInSearch = DateTime.now();

  // -----------------------------------------------------------------
  // TextEditingControllers للحقول النصية التي يحررها المستخدم
  // -----------------------------------------------------------------
  late final TextEditingController givenNamesCtr;     // GIVEN NAMES
  late final TextEditingController surnamesCtr;       // SURNAMES
  late final TextEditingController documentNumberCtr; // DOCUMENT NUMBER
  late final TextEditingController optionalDataCtr;   // OPTIONAL DATA (لو احتجته)

  @override
  void onInit() {
    super.onInit();

    if (searchFlightController.forms.isNotEmpty && searchFlightController.forms[0].returnDatePickerController.selectedDate != null) {
      lastDateInSearch = searchFlightController.forms[0].returnDatePickerController.selectedDate!;
    } else if (searchFlightController.forms.isNotEmpty && searchFlightController.forms[0].departureDatePickerController.selectedDate != null) {
      lastDateInSearch = searchFlightController.forms[0].departureDatePickerController.selectedDate!;
    }


    // 1) تهيئة الـ TextEditingController من قيم الموديل (إن وجدت)
    givenNamesCtr     = TextEditingController(text: model.givenNames ?? '');
    surnamesCtr       = TextEditingController(text: model.surnames ?? '');
    documentNumberCtr = TextEditingController(text: model.documentNumber ?? '');
    optionalDataCtr   = TextEditingController(text: model.optionalData ?? '');

    // 2) ربط التغييرات بالموديل
    _bind(givenNamesCtr, (text) {
      model.givenNames = _clean(text);
    });

    _bind(surnamesCtr, (text) {
      model.surnames = _clean(text);
    });

    _bind(documentNumberCtr, (text) {
      // مثال بسيط لتنظيف رقم الجواز: نحذف المسافات ونحوّل لأحرف كبيرة
      final t = _clean(text);
      model.documentNumber = t?.toUpperCase();
    });

    _bind(optionalDataCtr, (text) {
      model.optionalData = _clean(text);
    });
  }

  /// ربط TextEditingController بتحديث الموديل واستدعاء update()
  void _bind(TextEditingController controller, void Function(String) assign) {
    controller.addListener(() {
      assign(controller.text);
      update(); // لتحديث الواجهة التي تستخدم GetBuilder<PassportController>
    });
  }

  /// تنظيف نص: إزالة الفراغات في البداية والنهاية وإرجاع null لو فاضي
  String? _clean(String? value) {
    final t = value?.trim();
    if (t == null || t.isEmpty) return null;
    return t;
  }

  // =================================================================
  // تحديث الحقول غير النصية (الجنس، التواريخ، الدول)
  // =================================================================

  /// تغيير الجنس (Sex.male / Sex.female)
  void setSex(Sex? sex) {
    model.sex = sex;
    update();
  }

  /// تغيير تاريخ الميلاد (يستدعى من DateDropdownRow)
  void setDateOfBirth(DateTime? date) {
    model.dateOfBirth = date;
    update();
  }

  /// تغيير تاريخ انتهاء الجواز
  void setDateOfExpiry(DateTime? date) {
    model.dateOfExpiry = date;
    update();
  }

  /// تعيين دولة الجنسية (CountryPicker يرجع CountryModel)
  void setNationality(CountryModel country) {
    model.nationality = country;
    // set issuing country if null
    model.issuingCountry ??= country; 
    update();
  }

  /// تعيين دولة جهة الإصدار (CountryPicker يرجع CountryModel)
  void setIssuingCountry(CountryModel country) {
    model.issuingCountry = country;
    update();
  }

  // =================================================================
  // اختيار تاريخ انتهاء الجواز عبر showDatePicker (لو ما زلت تحتاجه)
  // =================================================================

  /// دالة مساعدة لفتح DatePicker لتاريخ الانتهاء
  Future<void> pickExpiryDate(BuildContext context) async {
    // lastDateInSearch afer 6 months
    final minExpiryDate =
    Jiffy.parseFromDateTime(lastDateInSearch)
        .add(months: 6)
        .dateTime;

    // لو ما فيه تاريخ سابق، نخلي الافتراضي بعد 5 سنوات
    DateTime? initial = model.dateOfExpiry ?? DateTime(minExpiryDate.year + 5, minExpiryDate.month, minExpiryDate.day);

    final picked = await showDatePicker(
      context: context,
      firstDate: minExpiryDate,
      lastDate: DateTime(minExpiryDate.year + 50, 12, 31),
      initialDate: initial.isBefore(minExpiryDate) ? minExpiryDate : initial,
      helpText: 'Select Date of Expiry'.tr,
    );

    if (picked != null) {
      setDateOfExpiry(picked);
    }
  }

  // =================================================================
  // التعامل مع ماسح الـ MRZ
  // =================================================================

  /// فتح شاشة الماسح CameraScanPassport
  /// تعيد PassportModel عبر Get.back(result: model)
  ///
  /// ملاحظة:
  /// - PassportScanController هناك يقوم بتحويل MRZ إلى PassportModel
  /// - هنا فقط نطبّق هذا الـ model على الفورم (applyModel)
  Future<void> openScanner() async {
    // final result = await Get.to<PassportModel>(
    //   () => const CameraScanPassport(),
    // );

    // if (result != null) {
    //   applyModel(result);
    // }
  }

  /// تطبيق موديل جديد (بعد المسح أو بعد جلب بيانات من API)
  ///
  /// - يحدّث model
  /// - يحدّث TextEditingControllers
  /// - يطلب من GetBuilder إعادة البناء
  void applyModel(PassportModel newModel) {
    model = newModel;

    // تحديث الحقول النصية من الموديل الجديد
    givenNamesCtr.text     = model.givenNames ?? '';
    surnamesCtr.text       = model.surnames ?? '';
    documentNumberCtr.text = model.documentNumber ?? '';
    optionalDataCtr.text   = model.optionalData ?? '';

    update();
  }

  /// إعادة تعيين جميع القيم إلى حالة فارغة
  void clearAll() {
    applyModel(PassportModel());
  }

  /// عرض الموديل على شكل JSON جميل (للديباج)
  String prettyJson() => model.toPrettyJson();

  @override
  void onClose() {
    givenNamesCtr.dispose();
    surnamesCtr.dispose();
    documentNumberCtr.dispose();
    optionalDataCtr.dispose();
    super.onClose();
  }
}
