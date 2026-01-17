import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChangePasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();

  ExpansibleController expandableController = ExpansibleController();

  late final TextEditingController currentPassword;
  late final TextEditingController newPassword;
  late final TextEditingController confirmNewPassword;


  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  bool loading = false;

  @override
  void onInit() {
    super.onInit();
    currentPassword = TextEditingController();
    newPassword = TextEditingController();
    confirmNewPassword = TextEditingController();
    expandableController.collapse();
  }

  @override
  void onClose() {
    currentPassword.dispose();
    newPassword.dispose();
    confirmNewPassword.dispose();
    super.onClose();
  }



  void toggleCurrent() {
    obscureCurrent = !obscureCurrent;
    update();
  }

  void toggleNew() {
    obscureNew = !obscureNew;
    update();
  }

  void toggleConfirm() {
    obscureConfirm = !obscureConfirm;
    update();
  }

  String? validateCurrentPassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Current password is required'.tr;
    if (value.length < 6) return 'Current password is too short'.tr;
    return null;
  }

  String? validateNewPassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'New password is required'.tr;
    if (value.length < 6) return 'Password must be at least 6 characters'.tr;

    if (currentPassword.text.trim().isNotEmpty &&
        value == currentPassword.text.trim()) {
      return 'New password must be different from current password'.tr;
    }

    return null;
  }

  String? validateConfirmPassword(String? v) {
    final value = (v ?? '').trim();
    if (value.isEmpty) return 'Confirm new password is required'.tr;
    if (value != newPassword.text.trim()) return 'Passwords do not match'.tr;
    return null;
  }

  Future<bool> submit() async {
    

    final valid = formKey.currentState?.validate() == true;
    if (!valid) {
      return false;
    }

    try {
      AppFuns.hideKeyboard();
      loading = true;
      update();

      // TODO: اربطها مع API عبر Dio داخل Controller/Repo
      // await Get.find<AccountController>().changePassword(
      //   current: currentPassword.text.trim(),
      //   next: newPassword.text.trim(),
      // );
      await Future.delayed(const Duration(seconds: 5));

      Get.snackbar('Success'.tr, 'Password changed successfully'.tr);

      // اختياري: تنظيف الحقول بعد النجاح
      // currentPassword.clear();
      // newPassword.clear();
      // confirmNewPassword.clear();

      expandableController.collapse();
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to change password'.tr);
      return false;
    } finally {
      loading = false;
      update();
    }
    return true;
  }
}
