
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
    final cs = Theme.of(context).colorScheme;
    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      tag: tag,
      global: false,
      builder: (c) {
        return Form(
          key: c.formKey,
          child: ExpansionTile(
            controller: c.expandableController,
            leading: const Icon(
              Icons.lock,
              color: Color(0xFFe7b244),
            ),
            title: Text('Change Password'.tr, style: TextStyle(fontWeight: FontWeight.bold)),
            // backgroundColor: cs.surfaceContainerHighest,
            collapsedBackgroundColor: cs.surfaceContainerHighest,
            backgroundColor: Color(0xFFe4e4e4),
            shape:  RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              // border top
              side: BorderSide(
                width: 1,
                color: cs.outline,
              ),
            ),
            collapsedShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            children: [
              Container(
                color: cs.surface,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), 
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
                    const SizedBox(height: 22),
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
