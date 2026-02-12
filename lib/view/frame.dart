import 'package:alzajeltravel/controller/airline_controller.dart';
import 'package:alzajeltravel/controller/travelers_controller.dart';
import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:alzajeltravel/view/bookings_report/bookings_report_page.dart';
import 'package:alzajeltravel/view/frame/home_2.dart';
import 'package:alzajeltravel/view/login/login_page.dart';
import 'package:alzajeltravel/view/profile/profile_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/frame_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/view/frame/my_drawer.dart';
import 'package:alzajeltravel/view/frame/search_flight.dart';
import 'package:alzajeltravel/view/settings/settings.dart';
import 'package:jiffy/jiffy.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class Frame extends StatefulWidget {
  const Frame({super.key});

  @override
  State<Frame> createState() => _FrameState();
}

class _FrameState extends State<Frame> with WidgetsBindingObserver {

final FrameController frameController =
    Get.isRegistered<FrameController>()
        ? Get.find<FrameController>()
        : Get.put(FrameController(), permanent: true);

final AirlineController airlineController =
    Get.isRegistered<AirlineController>()
        ? Get.find<AirlineController>()
        : Get.put(AirlineController(), permanent: true);

final TravelersController travelersController =
    Get.isRegistered<TravelersController>()
        ? Get.find<TravelersController>()
        : Get.put(TravelersController(), permanent: true);



  DateTime? _leftAt;
  final int timeout = 10;

  // ✅ منع تكرار نافذة الخروج عند الضغط السريع
  bool _isExitDialogOpen = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    final raw = AppVars.getStorage.read('profile');
    AppVars.profile = raw is Map
        ? ProfileModel.fromJson(Map<String, dynamic>.from(raw))
        : null;

    Jiffy.setLocale(AppVars.lang ?? 'en');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _leftAt = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      final leftAt = _leftAt;
      _leftAt = null;

      if (leftAt != null) {
        final diff = DateTime.now().difference(leftAt);
        if (diff.inSeconds >= timeout) {
          _goToLogin();
        }
      }
    }
  }

  void _goToLogin() {
    // امنع التكرار
    if (Get.currentRoute == Routes.login.path) return;
    Get.offAll(() => const LoginPage());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ✅ الشاشات لكل تبويب
  List<Widget> _buildScreens() {
    return [
      Home2(persistentTabController: frameController.persistentTabController),
      Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: Text("Search Flight".tr),
          centerTitle: true,
        ),
        body: SearchFlight(),
      ),
      const BookingsReportPage(),
      AppVars.profile != null
          ? ProfilePage(data: AppVars.profile!)
          : const Center(child: Text("No Profile")),
      SettingsPage(),
    ];
  }

  // ✅ عناصر الأيقونات
  List<PersistentBottomNavBarItem> navBarsItems() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final Color activeColorPrimary = cs.primaryContainer;
    final Color activeTextColorPrimary = cs.onInverseSurface;
    const Color inactiveColorPrimary = Colors.grey;

    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          (AppFuns.isDark(context)) ? AppConsts.logo2 : AppConsts.logo3,
          width: 24,
          height: 24,
        ),
        inactiveIcon: SvgPicture.asset(
          AppConsts.logoBlack,
          width: 24,
          height: 24,
          color: Colors.grey,
        ),
        title: ("   ${'Home'.tr}"),
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontWeight: FontWeight.normal,
          fontSize: AppConsts.lg,
        ),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_outlined),
        title: (" ${'Search'.tr}"),
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontWeight: FontWeight.normal,
          fontSize: AppConsts.lg,
        ),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.flight_takeoff_outlined),
        title: (" ${'Bookings'.tr}"),
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontWeight: FontWeight.normal,
          fontSize: AppConsts.lg,
        ),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: (" ${'Account'.tr}"),
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontWeight: FontWeight.normal,
          fontSize: AppConsts.lg,
        ),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: (" ${'Settings'.tr}"),
        textStyle: TextStyle(
          fontFamily: AppConsts.font,
          fontWeight: FontWeight.normal,
          fontSize: AppConsts.lg,
        ),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
    ];
  }

  void exitAppSafely() {
    if (kIsWeb) return;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        SystemNavigator.pop();
        break;
      case TargetPlatform.iOS:
        // iOS: لا تغلق التطبيق، اتركه
        // ممكن Get.back() أو Get.offAllNamed(...) حسب app
        break;
      default:
        SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      bottom: true,
      top: false,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;

          // ✅ لو أنت في أي تبويب غير Home2 -> رجعك لـ Home2
          if (frameController.persistentTabController.index != 0) {
            frameController.persistentTabController.jumpToTab(0);
            return;
          }

          // ✅ أنت في Home2 -> تأكيد خروج (مع منع التكرار)
          if (_isExitDialogOpen) return;
          _isExitDialogOpen = true;

          try {
            final ok = await AppFuns.confirmExit(
              title: "Exit".tr,
              message: "Are you sure you want to exit?".tr,
            );

            if (ok) {
              exitAppSafely();
            }
          } finally {
            _isExitDialogOpen = false;
          }
        },
        child: Scaffold(
          drawer: MyDrawer(
            persistentTabController: frameController.persistentTabController,
          ),
          body: PersistentTabView(
            context,
            backgroundColor: cs.surfaceContainerHighest,
            controller: frameController.persistentTabController,
            screens: _buildScreens(),
            items: navBarsItems(),
            confineToSafeArea: true,

            // ✅ مهم: نخلي PopScope هو اللي يتحكم بالرجوع
            handleAndroidBackButtonPress: false,

            resizeToAvoidBottomInset: true,
            stateManagement: true,
            hideNavigationBarWhenKeyboardAppears: true,
            navBarHeight: 70,
            decoration: NavBarDecoration(
              borderRadius: BorderRadius.circular(0.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                ),
              ],
            ),
            navBarStyle: NavBarStyle.style10,
          ),
        ),
      ),
    );
  }
}
