import 'package:alzajeltravel/root_decider.dart';
import 'package:alzajeltravel/utils/classes/http_overrides/http_overrides.dart';
import 'package:alzajeltravel/firebase_options.dart';
import 'package:alzajeltravel/utils/routes.dart';
import 'package:alzajeltravel/view/frame/issuing/issuing_page.dart';
import 'package:alzajeltravel/view/login/login_page.dart';
import 'package:alzajeltravel/view/tmp/my_lottie.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:alzajeltravel/controller/main_controller.dart';
import 'package:alzajeltravel/locale/translation.dart';
import 'package:alzajeltravel/model/dio_init/dio_init.dart';
import 'package:alzajeltravel/services/notification_service.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';
import 'package:alzajeltravel/utils/themes.dart';
import 'package:alzajeltravel/utils/widgets.dart';
import 'package:alzajeltravel/view/frame.dart';
import 'package:alzajeltravel/view/frame/passport/passports_forms.dart';
import 'package:alzajeltravel/view/frame/search_flight.dart';
import 'package:alzajeltravel/view/intro.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path/path.dart';
import 'package:pwa_install/pwa_install.dart';

Future<void> main() async {
  // 1) أساسيات التمهيد
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  setupHttpOverrides();
  
  // 2) تهيئاتك المتزامنة/المسبقة
  await GetStorage.init();
  // await Jiffy.setLocale('ar');

  // 3) Firebase (يفضل قبل إظهار أي حوارات أذونات)
  try {
    final app = await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    print(
      "firebase initialized: ${app.name}, "
      "${app.options.apiKey}, ${app.options.appId}, ${app.options.projectId}",
    );
  } catch (e) {
    print("error firebase: $e");
  }

  // 4) إشعارات: تهيئة القناة + المستمعات + طلب إذن إذا لزم
  await NotificationService.init();
  initDio(); // 👈 مهم عشان الكوكيز تشتغل
  // لازم قبل runApp 
  if (kIsWeb) {
    PWAInstall().setup(installCallback: () {
      debugPrint('APP INSTALLED!');
    });
  }
  
  runApp(
    GlobalLoaderOverlay(
      // overlayColor: (Get.context?.theme.brightness == Brightness.light)? 
      //   Colors.white.withValues(alpha: 1):
      //   Colors.black.withValues(alpha: 1),
      
      overlayWidgetBuilder: (progress) {
        print("brightness: ${Get.context?.theme.brightness}");
        // return Container(height: 300, width: 300, child: FlightLoader());
        return MyLottie(
          title: (progress?? "Loading".tr).toString() + " ...",
        );
      },
      child: const MyApp(),
    ),
  );

  // 6) معالجة حالة "التطبيق مُنهى وتم فتحه عبر الإشعار"
  //    (مرة واحدة فقط، بعد runApp، ومع تأجيل لِـ frame لضمان جاهزية الـ Navigator والبلجنز)
  if (!kIsWeb) {
    final initial = await AwesomeNotifications().getInitialNotificationAction(removeFromActionEvents: true);
    if (initial != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        await NotificationController.onActionReceivedMethod(initial);
      });
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MainController mainController = Get.put(MainController());

  @override
  void initState() {
    super.initState();
    print("first_run: ${AppVars.getStorage.read("first_run")}"); // (first_run == null) is the first run
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MainController>(
      builder: (controller) {
        AppFuns.setUpRebuild();
        return GetMaterialApp(
          title: 'Alzajel Travel'.tr,
          debugShowCheckedModeBanner: false,

          // لا حاجة لوضع navigatorKey هنا غالبًا؛ Get يضبطه لك
          initialRoute: Routes.root.path,

          getPages: [
            GetPage(
              name: Routes.root.path,
              page: () => const RootDecider(),
            ),
            GetPage(
              name: Routes.intro.path,
              page: () => const Intro(),
            ),
            GetPage(
              name: Routes.login.path,
              page: () => const LoginPage(),
            ),
            GetPage(
              name: Routes.frame.path,
              page: () => Frame(),
            ),
            GetPage(
              name: Routes.searchFlight.path,
              page: () => SearchFlight(),
            ),
            GetPage(
              name: Routes.passportForms.path,
              page: () => PassportsFormsPage(
                adultsCounter: Get.arguments['adultsCounter'],
                childrenCounter: Get.arguments['childrenCounter'],
                infantsInLapCounter: Get.arguments['infantsInLapCounter'],
              ),
            ),
            GetPage(
              name: Routes.prebookingAndIssueing.path,
              page: () => IssuingPage(
                offerDetail: Get.arguments["offerDetail"],
                travelers: Get.arguments["travelers"],
                contact: Get.arguments["contact"], 
                pnr: Get.arguments["pnr"],
                booking: Get.arguments["booking"],
                fromPage: Get.arguments["fromPage"],
              ),
            ),
          ],

          theme: Themes.lightTheme(context),

          darkTheme: Themes.darkTheme(context),
          themeMode: AppVars.appThemeMode ?? ThemeMode.system,

          // ضمان ظهور خط التطبيق (Almaria) على جميع النصوص داخل أي شاشة/Overlay/Dialog
          // حتى للـ widgets التي لا تأخذ textTheme من الـ MaterialApp مباشرةً.
          builder: (context, child) {
            final base = DefaultTextStyle.of(context).style;
            return DefaultTextStyle(
              style: base.copyWith(
                fontFamily: AppConsts.font,
                fontFamilyFallback: Themes.fontFamilyFallback,
              ),
              child: child ?? const SizedBox.shrink(),
            );
          },

          // Translation __________________________________________
          locale: AppVars.appLocale,
          fallbackLocale: Locale("en"),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          translations: Translation(),
          supportedLocales: [const Locale("ar"), const Locale('en')],

          // end Translation __________________________________________
          // home: AppVars.getStorage.read("first_run") == null ? Intro() : LoginPage(),
        );
      },
    );
  }

}
