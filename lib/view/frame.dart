import 'package:alzajeltravel/model/profile/profile_model.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:alzajeltravel/view/bookings_report/bookings_report_page.dart';
import 'package:alzajeltravel/view/frame/home_2.dart';
import 'package:alzajeltravel/view/login/login_page.dart';
import 'package:alzajeltravel/view/profile/profile_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/controller/frame_controller.dart';
import 'package:alzajeltravel/locale/translation_controller.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/view/frame/home.dart';
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
  TranslationController translationController = Get.put(TranslationController());
  // MainController mainController = Get.put(MainController());
  FrameController frameController = Get.put(FrameController());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    AppVars.profile = AppVars.getStorage.read('profile') != null ? ProfileModel.fromJson(AppVars.getStorage.read('profile')) : null;
    print("profile: ${AppVars.profile?.id}");
    Jiffy.setLocale(AppVars.lang ?? 'en');
  }

  DateTime? _leftAt;
  int timeout = 20;
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      print("paused 1: ${_leftAt}");
      _leftAt = DateTime.now();
      print("paused 2: ${_leftAt}");
    } else if (state == AppLifecycleState.resumed) {
      final leftAt = _leftAt;
      _leftAt = null;
      print("resumed");
      if (leftAt != null) {
        final diff = DateTime.now().difference(leftAt);
        print("diff: ${diff.inSeconds}");
        if (diff.inSeconds >= timeout) {
          _goToLogin();
        }
      }
    }
  }

  void _goToLogin() {
    print("_goToLogin");
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
      // Home(persistentTabController: frameController.persistentTabController),
      Home2(),
      SearchFlight(frameContext: context),
      const BookingsReportPage(),
      AppVars.profile != null ? ProfilePage(data: AppVars.profile!) : const Center(child: Text("No Profile")),
      SettingsPage(),
    ];
  }

  // ✅ عناصر الأيقونات
  List<PersistentBottomNavBarItem> navBarsItems() {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Color activeColorPrimary = cs.primaryContainer;
    Color activeTextColorPrimary = cs.onInverseSurface;
    Color inactiveColorPrimary = Colors.grey;
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          (AppFuns.isDark(context)) ? AppConsts.logo2 : AppConsts.logo3,
          width: 24,
          height: 24,
        ),  
        inactiveIcon: SvgPicture.asset(AppConsts.logoBlack, width: 24, height: 24, color: Colors.grey[400]),
        title: ("   ${'Home'.tr}"),
        textStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.normal, fontSize: AppConsts.lg),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.search_outlined),
        title: (" ${'Search'.tr}"),
        textStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.normal, fontSize: AppConsts.lg),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.flight_takeoff_outlined),
        title: (" ${'Bookings'.tr}"),
        textStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.normal, fontSize: AppConsts.lg),
        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.person),
        title: (" ${'Account'.tr}"),
        textStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.normal, fontSize: AppConsts.lg),

        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(Icons.settings),
        title: (" ${'Settings'.tr}"),
        textStyle: TextStyle(fontFamily: AppConsts.font, fontWeight: FontWeight.normal, fontSize: AppConsts.lg),

        activeColorPrimary: activeColorPrimary,
        inactiveColorPrimary: inactiveColorPrimary,
        activeColorSecondary: activeTextColorPrimary,
      ),
    ];
  }



  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      bottom: true,
      top: false,
      child: Scaffold(
        drawer: MyDrawer(persistentTabController: frameController.persistentTabController),
    
        body: PersistentTabView(
          context,
          backgroundColor: cs.surfaceContainerHighest,
          controller: frameController.persistentTabController,
          screens: _buildScreens(),
          items: navBarsItems(),
          confineToSafeArea: true,
          handleAndroidBackButtonPress: false,
          resizeToAvoidBottomInset: true,
          stateManagement: true, 
          hideNavigationBarWhenKeyboardAppears: true, 
          navBarHeight: 70,
          decoration: NavBarDecoration(
            borderRadius: BorderRadius.circular(0.0),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4)],
          ),
    
          // ✅ النمط المطلوب (Style 10)
          navBarStyle: NavBarStyle.style10,
          
          // ✅ هنا الحل
          onWillPop: (BuildContext? tabContext) async {
            print("onWillPop");
            // لو كنت في أي Tab غير Home: يرجعك لـ Home بدل ما يخرج
            if (frameController.persistentTabController.index != 0) {
              frameController.persistentTabController.jumpToTab(0);
              return false;
            }
            
            final ok = await AppFuns.confirmExit();
            if (ok) {
              await SystemNavigator.pop();
            }
            return false;
          },

    
        ),
      ),
    );
  }

}
