import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';
import '../../utils/app_consts.dart';

class MyDrawer extends StatefulWidget {
  final PersistentTabController? persistentTabController;
  const MyDrawer({super.key, this.persistentTabController});

  @override
  State<MyDrawer> createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {
  ProfileModel? profileModel;

  @override
  void initState() {
    super.initState();
    profileModel = GetStorage().read('profile') != null
        ? ProfileModel.fromJson(GetStorage().read('profile'))
        : null;
  }

  void _closeDrawer() => Navigator.of(context).pop();

  void _jumpToTab(int index) {
    widget.persistentTabController?.jumpToTab(index);
    _closeDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Drawer(
      backgroundColor: cs.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ━━━━━━ ❶ Header: Navy gradient + gold decorations + avatar ━━━━━━
          _buildHeader(cs),

          // ━━━━━━ ❷ Main items ━━━━━━
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(
                children: [
                  _DrawerItem(
                    icon: Icons.home_rounded,
                    title: "Home".tr,
                    onTap: () => _jumpToTab(0),
                  ),
                  _DrawerItem(
                    icon: Icons.search_rounded,
                    title: "Search".tr,
                    onTap: () => _jumpToTab(1),
                  ),
                  _DrawerItem(
                    icon: Icons.flight_takeoff_rounded,
                    title: "Bookings".tr,
                    onTap: () => _jumpToTab(2),
                  ),
                  _DrawerItem(
                    icon: Icons.info_outline_rounded,
                    title: "About Us".tr,
                    onTap: () {
                      AppFuns.openUrl(AppConsts.aboutUsUrl);
                      _closeDrawer();
                    },
                  ),

                  // فاصل ناعم
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Divider(
                      height: 1,
                      thickness: 1,
                      color: cs.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),

                  _DrawerItem(
                    icon: Icons.notifications_rounded,
                    title: "Notifications".tr,
                    onTap: () => _jumpToTab(1),
                  ),
                  _DrawerItem(
                    icon: Icons.settings_rounded,
                    title: "Settings".tr,
                    onTap: () => _jumpToTab(4),
                  ),
                ],
              ),
            ),
          ),

          // ━━━━━━ ❸ Logout button ━━━━━━
          _buildLogoutButton(cs),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme cs) {
    final safeTop = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppConsts.primaryColor,
            Color(0xFF1E2F7A),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          // دوائر ذهبية زخرفية (glow حديث)
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConsts.secondaryColor.withValues(alpha: 0.22),
                    AppConsts.secondaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppConsts.secondaryColor.withValues(alpha: 0.10),
                    AppConsts.secondaryColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),

          // المحتوى
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _jumpToTab(3),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, safeTop + 22, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar مع إطار/ظلّ ذهبي
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppConsts.secondaryColor,
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppConsts.secondaryColor.withValues(alpha: 0.45),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        profileModel != null
                            ? AppFuns.getAvatarText(profileModel!.name)
                            : '?',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppConsts.primaryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // الاسم + شريط ذهبي
                    if (profileModel != null) ...[
                      Row(
                        children: [
                          Container(
                            width: 3,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppConsts.secondaryColor,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              profileModel!.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: AppConsts.xlg,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsetsDirectional.only(start: 11),
                        child: Text(
                          profileModel!.email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: AppConsts.sm,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(ColorScheme cs) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () async {
              context.loaderOverlay.show();
              try {
                final res = await AppVars.api.post(AppApis.logout);
                if (res['status'] == 'success') {
                  if (context.mounted) context.loaderOverlay.hide();
                  Get.offAll(() => LoginPage());
                }
              } catch (_) {
                if (context.mounted) context.loaderOverlay.hide();
                AppFuns.showSnack("Error".tr, "Could not logout".tr, type: SnackType.error);
              }
            },
            splashColor: cs.error.withValues(alpha: 0.15),
            highlightColor: cs.error.withValues(alpha: 0.05),
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: cs.error.withValues(alpha: 0.55), width: 1.2),
                color: cs.error.withValues(alpha: 0.08),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout_rounded, size: 18, color: cs.error),
                  const SizedBox(width: 8),
                  Text(
                    "Logout".tr,
                    style: TextStyle(
                      color: cs.error,
                      fontSize: AppConsts.normal,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback? onTap;

  const _DrawerItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: AppConsts.secondaryColor.withValues(alpha: 0.15),
          highlightColor: AppConsts.secondaryColor.withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: [
                // حاوية دائرية بلون ذهبي شفّاف حول الأيقونة
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppConsts.secondaryColor.withValues(alpha: 0.15),
                        AppConsts.secondaryColor.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: AppConsts.secondaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: AppConsts.lg,
                      color: cs.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl
                      ? Icons.chevron_left_rounded
                      : Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
