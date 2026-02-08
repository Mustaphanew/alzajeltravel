import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/widgets/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:alzajeltravel/model/country_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class ProfileController extends GetxController {
  final ProfileModel initialData;

  ProfileController({required this.initialData});

  final formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController companyRegistrationNumberController;
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController agencyNumberController;
  late final TextEditingController phoneController;
  late final TextEditingController countryController; // readOnly
  late final TextEditingController addressController;
  late final TextEditingController websiteController;
  late final TextEditingController branchCodeController;
  late final TextEditingController statusController; // readOnly

  CountryModel? selectedCountry;

  bool isSaving = false;

  @override
  void onInit() {
    super.onInit();

    selectedCountry = initialData.country;

    companyRegistrationNumberController =
        TextEditingController(text: initialData.companyRegistrationNumber);
    nameController = TextEditingController(text: initialData.name);
    emailController = TextEditingController(text: initialData.email);
    agencyNumberController = TextEditingController(text: initialData.agencyNumber);
    phoneController = TextEditingController(text: initialData.phone);

    countryController = TextEditingController(text: _countryDisplay(selectedCountry));
    addressController = TextEditingController(text: initialData.address);
    websiteController = TextEditingController(text: initialData.website);
    branchCodeController = TextEditingController(text: initialData.branchCode);
    statusController = TextEditingController(
      text: initialData.isApproved ? 'Approved'.tr : 'Not Approved'.tr,
    );
  }

  String _countryDisplay(CountryModel? c) {
    if (c == null) return '';
    final lang = AppVars.lang ?? 'en';
    final name = c.name[lang] ?? c.name['en'] ?? '';
    // عرض بسيط ومفهوم
    return name;
  }

  // Validators (بسيطة وواضحة)
  String? validateRequired(String? v, String message) {
    if ((v ?? '').trim().isEmpty) return message.tr;
    return null;
  }

  String? validateEmail(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return 'Email Required'.tr;

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(v)) return 'Invalid Email'.tr;

    return null;
  }

  Future<void> pickCountry() async {
    final result = await Get.to<CountryModel>(
      () => const CountryPicker(showDialCode: true),
    );

    if (result == null) return;

    selectedCountry = result;
    countryController.text = _countryDisplay(result);
    update();
  }

  ProfileModel buildUpdatedModel() {
    return ProfileModel(
      id: "0",
      companyRegistrationNumber: companyRegistrationNumberController.text.trim(),
      name: nameController.text.trim(),
      email: emailController.text.trim(),
      agencyNumber: agencyNumberController.text.trim(),
      phone: phoneController.text.trim(),
      country: selectedCountry,
      address: addressController.text.trim(),
      website: websiteController.text.trim(),
      branchCode: branchCodeController.text.trim(),
      status: initialData.status, // readOnly (لا يتغير من المستخدم)
      permissions: initialData.permissions,
    );
  }

  Future<void> saveProfile() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!(formKey.currentState?.validate() ?? false)) return;

    isSaving = true;
    update();

    try {
      final updated = buildUpdatedModel();

      // TODO: send updated.toJson() to API with Dio
      await Future.delayed(const Duration(milliseconds: 800));

      Get.snackbar('Success'.tr, 'Profile Updated Successfully'.tr);

      // إذا تحب ترجع البيانات للصفحة السابقة:
      // Get.back(result: updated);
    } catch (_) {
      Get.snackbar('Error'.tr, 'Profile Update Failed'.tr);
    } finally {
      isSaving = false;
      update();
    }
  }

  @override
  void onClose() {
    companyRegistrationNumberController.dispose();
    nameController.dispose();
    emailController.dispose();
    agencyNumberController.dispose();
    phoneController.dispose();
    countryController.dispose();
    addressController.dispose();
    websiteController.dispose();
    statusController.dispose();
    super.onClose();
  }
}
