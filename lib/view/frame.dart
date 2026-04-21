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

    // ضبط لغة Jiffy بشكل غير متزامن ثمّ إعادة بناء الواجهات التي تعتمد على
    // النصوص النسبية (مثل "قبل ساعة"). بدون await قد يظهر النصّ بالإنجليزية
    // لأنّ اللغة لم تُحمَّل بعد.
    Jiffy.setLocale(AppVars.lang ?? 'en').then((_) {
      if (mounted) setState(() {});
    });
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
        backgroundColor: AppFuns.isDark(context)
            ? const Color(0xFF0B1430)
            : const Color(0xFFFAF6F1),
        appBar: AppBar(
          elevation: 0,
          scrolledUnderElevation: 0,
          backgroundColor: AppConsts.primaryColor,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
          title: Text(
            "Search Flight".tr,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: AppConsts.xlg,
              letterSpacing: 0.3,
            ),
          ),
          centerTitle: true,
          shape: Border(
            bottom: BorderSide(
              color: AppConsts.secondaryColor.withValues(alpha: 0.35),
              width: 1,
            ),
          ),
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

  // ✅ عناصر الأيقونات — نهاري: شارة كحلية + محتوى أبيض | ليلي: شارة ذهبية + محتوى كحلي (وضع القراءة السليم)
  List<PersistentBottomNavBarItem> navBarsItems() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final Color activeBg = isDark ? AppConsts.secondaryColor : AppConsts.primaryColor;
    final Color activeFg = isDark ? AppConsts.primaryColor : Colors.white;
    final Color inactiveFg = cs.onSurfaceVariant;

    final navLabelStyle = TextStyle(
      fontFamily: AppConsts.font,
      fontWeight: FontWeight.w600,
      fontSize: AppConsts.normal,
    );

    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          AppFuns.isDark(context) ? AppConsts.logo2 : AppConsts.logo3,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(activeFg, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          AppConsts.logoBlack,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(inactiveFg, BlendMode.srcIn),
        ),
        title: ("   ${'Home'.tr}"),
        textStyle: navLabelStyle,
        activeColorPrimary: activeBg,
        inactiveColorPrimary: inactiveFg,
        activeColorSecondary: activeFg,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_outlined),
        title: (" ${'Search'.tr}"),
        textStyle: navLabelStyle,
        activeColorPrimary: activeBg,
        inactiveColorPrimary: inactiveFg,
        activeColorSecondary: activeFg,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.flight_takeoff_outlined),
        title: (" ${'Bookings'.tr}"),
        textStyle: navLabelStyle,
        activeColorPrimary: activeBg,
        inactiveColorPrimary: inactiveFg,
        activeColorSecondary: activeFg,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: (" ${'Account'.tr}"),
        textStyle: navLabelStyle,
        activeColorPrimary: activeBg,
        inactiveColorPrimary: inactiveFg,
        activeColorSecondary: activeFg,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: (" ${'Settings'.tr}"),
        textStyle: navLabelStyle,
        activeColorPrimary: activeBg,
        inactiveColorPrimary: inactiveFg,
        activeColorSecondary: activeFg,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // لون يتناسق مع هوية التطبيق بدل الأسود خلف شريط التنقل السفلي للنظام
    final Color systemNavBarColor =
        isDark ? const Color(0xFF0B1430) : const Color(0xFFFAF6F1);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: systemNavBarColor,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarDividerColor: systemNavBarColor,
      ),
      child: SafeArea(
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
            backgroundColor: systemNavBarColor,
            drawer: MyDrawer(
              persistentTabController: frameController.persistentTabController,
            ),
            body: PersistentTabView(
              context,
              backgroundColor: systemNavBarColor,
              controller: frameController.persistentTabController,
              screens: _buildScreens(),
              items: navBarsItems(),
              confineToSafeArea: true,

              onWillPop: null,

             // ✅ مهم: نخلي PopScope هو اللي يتحكم بالرجوع
              handleAndroidBackButtonPress: false,

              resizeToAvoidBottomInset: true,
              stateManagement: true,
              hideNavigationBarWhenKeyboardAppears: true,
              navBarHeight: 70,
              decoration: NavBarDecoration(
                borderRadius: BorderRadius.circular(0.0),
                colorBehindNavBar: systemNavBarColor,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppConsts.primaryColor.withValues(alpha: 0.45)
                        : Colors.black.withValues(alpha: 0.07),
                    blurRadius: 14,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              navBarStyle: NavBarStyle.style10,
            ),
          ),
        ),
      ),
    );
  }
}

