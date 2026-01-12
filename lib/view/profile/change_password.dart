import 'package:alzajeltravel/controller/profile/change_password_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loader_overlay/loader_overlay.dart';



class ChangePassword extends StatelessWidget {
  final String? tag;

  const ChangePassword({super.key, this.tag});

  Future<void> submit(ChangePasswordController c, BuildContext context) async {
    context.loaderOverlay.show();
    final result = await c.submit(); 
    if (result) {
      // Get.back();
    }
    if(context.mounted) context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      tag: tag,
      global: false,
      builder: (c) {
        return Form(
          key: c.formKey,
          child: ExpansionTile(
            controller: c.expandableController,
            title: Text('Change Password'.tr),
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextFormField(
                      controller: c.currentPassword,
                      obscureText: c.obscureCurrent,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Current Password'.tr,
                        hintText: 'Enter current password'.tr,
                        suffixIcon: IconButton(
                          onPressed: c.toggleCurrent,
                          icon: Icon(
                            c.obscureCurrent
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: 'Show/Hide'.tr,
                        ),
                      ),
                      validator: c.validateCurrentPassword,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: c.newPassword,
                      obscureText: c.obscureNew,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'New Password'.tr,
                        hintText: 'Enter new password'.tr,
                        suffixIcon: IconButton(
                          onPressed: c.toggleNew,
                          icon: Icon(
                            c.obscureNew
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: 'Show/Hide'.tr,
                        ),
                      ),
                      validator: c.validateNewPassword,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: c.confirmNewPassword,
                      obscureText: c.obscureConfirm,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password'.tr,
                        hintText: 'Re-enter new password'.tr,
                        suffixIcon: IconButton(
                          onPressed: c.toggleConfirm,
                          icon: Icon(
                            c.obscureConfirm
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          tooltip: 'Show/Hide'.tr,
                        ),
                      ),
                      validator: c.validateConfirmPassword,
                      onFieldSubmitted: (_) => submit(c, context),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: c.loading ? null : () => submit(c, context),
                        child: Text(
                          c.loading ? 'Please wait...'.tr : 'Change Password'.tr,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
