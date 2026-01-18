import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/view/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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
    profileModel = GetStorage().read('profile') != null ? ProfileModel.fromJson(GetStorage().read('profile')) : null;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: cs.primary,
            child: InkWell(
              onTap: () {
                if (widget.persistentTabController != null) {
                  widget.persistentTabController!.jumpToTab(3);
                }
                Navigator.of(context).pop();
              },
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                decoration: BoxDecoration(
                  // color: AppConsts.primaryColor,
                ),
                height: 300,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // if (user != null) ...[
                    //   ClipRRect(
                    //     borderRadius: BorderRadius.circular(100),
                    //     child: SizedBox(height: 80, width: 80, child: CacheImg("${user!.photoURL}")),
                    //   ),
                    //   SizedBox(height: 16),
                    //   Text(
                    //     "${user!.displayName}",
                    //     textAlign: TextAlign.center,
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(
                    //       color: cs.onPrimary,
                    //       fontFamily: AppConsts.font,
                    //       fontWeight: FontWeight.normal,
                    //       fontSize: AppConsts.lg,
                    //     ),
                    //   ),
                    //   Text(
                    //     "${user!.email}",
                    //     textAlign: TextAlign.center,
                    //     maxLines: 2,
                    //     overflow: TextOverflow.ellipsis,
                    //     style: TextStyle(
                    //       color: cs.onPrimary,
                    //       fontFamily: AppConsts.font,
                    //       fontWeight: FontWeight.normal,
                    //       fontSize: AppConsts.sm,
                    //     ),
                    //   ),
                    // ],
                    // if (user == null) ...[
                    SvgPicture.asset(AppConsts.logo3, width: 60, height: 60),
                    SizedBox(height: 16),
                    if (profileModel != null) ...[
                      Text(
                        "${profileModel!.name}",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontFamily: AppConsts.font,
                          fontWeight: FontWeight.normal,
                          fontSize: AppConsts.lg,
                        ),
                      ),
                      Text(
                        "${profileModel!.email}",
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: cs.onPrimary,
                          fontFamily: AppConsts.font,
                          fontWeight: FontWeight.normal,
                          fontSize: AppConsts.sm,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Text(
                      //   AppFuns.priceWithCoin(profileModel!.remainingBalance, "\$"),
                      //   textAlign: TextAlign.center,
                      //   maxLines: 2,
                      //   overflow: TextOverflow.ellipsis,
                      //   style: TextStyle(
                      //     color: Colors.green,
                      //     fontFamily: AppConsts.font,
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: AppConsts.xlg,
                      //   ),
                      // ),

                    ],
                    // ],
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  DrawerItem(
                    icon: SvgPicture.asset(AppConsts.logoBlack, width: 24, height: 24, color: Get.isDarkMode ? Colors.white : Colors.black),
                    title: "Home".tr,
                    onClick: () async {
                      if (widget.persistentTabController != null) {
                        widget.persistentTabController!.jumpToTab(0);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  DrawerItem(
                    icon: Icon(
                      Icons.search,
                      size: 26,
                      // color: AppConsts.tertiaryColor[800],
                    ),
                    title: "Search".tr,
                    onClick: () async {
                      if (widget.persistentTabController != null) {
                        widget.persistentTabController!.jumpToTab(1);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  DrawerItem(
                    icon: Icon(
                      Icons.flight_land,
                      size: 26,
                      // color: AppConsts.tertiaryColor[800],
                    ),
                    title: "Bookings".tr,
                    onClick: () async {
                      if (widget.persistentTabController != null) {
                        widget.persistentTabController!.jumpToTab(2);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  DrawerItem(
                    icon: Icon(
                      Icons.groups_2_outlined,
                      size: 26,
                      // color: AppConsts.tertiaryColor[800],
                    ),
                    title: "About Us".tr,
                    onClick: () async {
                      AppFuns.openUrl(AppConsts.aboutUsUrl);
                      Navigator.of(context).pop();
                    },
                  ),
                  Divider(height: 1),
                  DrawerItem(
                    icon: Icon(
                      Icons.notifications_outlined,
                      size: 26,
                      // color: AppConsts.tertiaryColor[800],
                    ),
                    title: "Notifications".tr,
                    onClick: () async {
                      if (widget.persistentTabController != null) {
                        widget.persistentTabController!.jumpToTab(1);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  DrawerItem(
                    icon: Icon(
                      Icons.settings_outlined,
                      size: 26,
                      // color: AppConsts.tertiaryColor[800],
                    ),
                    title: "Settings".tr,
                    onClick: () async {
                      if (widget.persistentTabController != null) {
                        widget.persistentTabController!.jumpToTab(4);
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          ),
        
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(0)),
              ),
            ),
            onPressed: () async {
              context.loaderOverlay.show();
              try {
                final res = await AppVars.api.post(AppApis.logout);
                if (res['status'] == 'success') {
                  print("res: $res");
                  if(context.mounted) context.loaderOverlay.hide();
                  Get.offAll(() => LoginPage());
                }
              } catch (e) {
                if(context.mounted) context.loaderOverlay.hide();
                Get.snackbar("Error".tr, "Could not logout".tr, snackPosition: SnackPosition.BOTTOM);
              }
               
            },
            child: Text("Logout".tr),
          ),
        ],
      ),
    );
  }
}

class DrawerItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final Function()? onClick;

  const DrawerItem({super.key, required this.icon, required this.title, this.onClick});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: AppConsts.sizeContext(context).width,
      height: 70,
      child: TextButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Get.isDarkMode ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
        ),
        onPressed: onClick,
        child: Row(
          children: [
            SizedBox(width: 8),
            icon,
            SizedBox(width: 16),
            Text(title, style: TextStyle(fontSize: AppConsts.lg)),
          ],
        ),
      ),
    );
  }
}
