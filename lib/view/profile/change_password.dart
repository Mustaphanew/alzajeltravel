
import 'package:alzajeltravel/controller/profile/change_password_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/widgets/custom_button.dart';
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
    if (context.mounted) context.loaderOverlay.hide();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color cardBg = isDark ? const Color(0xFF121A38) : Colors.white;
    final Color borderColor =
        AppConsts.secondaryColor.withValues(alpha: isDark ? 0.35 : 0.28);

    return GetBuilder<ChangePasswordController>(
      init: ChangePasswordController(),
      tag: tag,
      global: false,
      builder: (c) {
        return Form(
          key: c.formKey,
          child: Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor, width: 1),
              boxShadow: [
                BoxShadow(
                  color: AppConsts.primaryColor.withValues(
                    alpha: isDark ? 0.25 : 0.07,
                  ),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Theme(
              data: theme.copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                controller: c.expandableController,
                leading: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        AppConsts.secondaryColor.withValues(alpha: 0.16),
                    border: Border.all(
                      color: AppConsts.secondaryColor
                          .withValues(alpha: 0.55),
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    color: AppConsts.secondaryColor,
                    size: 18,
                  ),
                ),
                title: Text(
                  'Change Password'.tr,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: AppConsts.normal,
                    color: cs.onSurface,
                    letterSpacing: 0.2,
                  ),
                ),
                iconColor: AppConsts.secondaryColor,
                collapsedIconColor: AppConsts.secondaryColor,
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                shape: const RoundedRectangleBorder(),
                collapsedShape: const RoundedRectangleBorder(),
                tilePadding: const EdgeInsetsDirectional.only(
                    start: 14, end: 14),
                childrenPadding: EdgeInsets.zero,
                children: [
                  Container(
                    height: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppConsts.secondaryColor.withValues(alpha: 0),
                          AppConsts.secondaryColor.withValues(alpha: 0.45),
                          AppConsts.secondaryColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: c.currentPassword,
                          obscureText: c.obscureCurrent,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: 'Current Password'.tr,
                            hintText: 'Enter current password'.tr,
                            prefixIcon: const Icon(
                              Icons.key_rounded,
                              color: AppConsts.secondaryColor,
                            ),
                            suffixIcon: IconButton(
                              onPressed: c.toggleCurrent,
                              icon: Icon(
                                c.obscureCurrent
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppConsts.secondaryColor,
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
                            prefixIcon: const Icon(
                              Icons.lock_outline_rounded,
                              color: AppConsts.secondaryColor,
                            ),
                            suffixIcon: IconButton(
                              onPressed: c.toggleNew,
                              icon: Icon(
                                c.obscureNew
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppConsts.secondaryColor,
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
                            prefixIcon: const Icon(
                              Icons.verified_outlined,
                              color: AppConsts.secondaryColor,
                            ),
                            suffixIcon: IconButton(
                              onPressed: c.toggleConfirm,
                              icon: Icon(
                                c.obscureConfirm
                                    ? Icons.visibility_off_rounded
                                    : Icons.visibility_rounded,
                                color: AppConsts.secondaryColor,
                              ),
                              tooltip: 'Show/Hide'.tr,
                            ),
                          ),
                          validator: c.validateConfirmPassword,
                          onFieldSubmitted: (_) => submit(c, context),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            onPressed: c.loading
                                ? null
                                : () => submit(c, context),
                            icon: c.loading
                                ? null
                                : const Icon(
                                    Icons.check_circle_outline_rounded,
                                    color: AppConsts.secondaryColor,
                                    size: 18,
                                  ),
                            label: c.loading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                              AppConsts.secondaryColor),
                                    ),
                                  )
                                : Text(
                                    'Change Password'.tr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
