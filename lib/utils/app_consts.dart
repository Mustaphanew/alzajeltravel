import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppConsts {
  static const String androidLink = "https://play.google.com/store/apps/details?id=com.alzajeltravel.agent";
  static const String baseUrl = "https://www.alzajeltravel.com/mobile.alzajeltravel.com";
  static const String aboutUsUrl = "https://www.alzajeltravel.com/whorwe";
  static const String imageUrl =
      "https://www.alzajeltravel.com/mobile.alzajeltravel.com/appm/amadeus_api.php?test_path=1&folder=images&file=";
  static const String imageSliderUrl =
      "https://www.alzajeltravel.com/mobile.alzajeltravel.com/appm/amadeus_api.php?test_path=1&folder=images/slider&file=";
  static const String imageAirlineUrl =
      "https://www.alzajeltravel.com/mobile.alzajeltravel.com/appm/amadeus_api.php?test_path=1&folder=images/airline&file=";
  static const String fileUrl =
      "https://www.alzajeltravel.com/mobile.alzajeltravel.com/appm/amadeus_api.php?test_path=1&folder=files&file=";

  static const String serverToken = "_";
  static const String subscribeFCM = "_";

  static const String font = "Almaria";
  static const String fnDG = "DG";

  // assets path ______________________________________________
  static const String splash = "assets/images/splash.png";
  static const String splashSvg = "assets/images/icons/splash.svg";
  static const String splashArSvg = "assets/images/icons/splash_ar.svg";
  static const String icon = "assets/images/icon.png";

  static const String logo = "assets/images/icons/logo.svg";
  static const String logo2 = "assets/images/icons/logo_2.svg";
  static const String logo3 = "assets/images/icons/logo_3.svg";
  static const String brand = "assets/images/icons/brand.svg";
  static const String logoBlack = "assets/images/icons/logo_black.svg";
  static const String facebookLogo = "assets/images/icons/facebook.svg";
  static const String googleLogo = "assets/images/icons/google.svg";
  static const String gmailLogo = "assets/images/icons/gmail.svg";
  static const String home = "assets/images/icons/home.svg";
  static const String homeFill = "assets/images/icons/home_fill.svg";
  static const String menu = "assets/images/icons/menu.svg";
  static const String menuFill = "assets/images/icons/menu_fill.svg";
  static const String orders = "assets/images/icons/orders.svg";
  static const String ordersFill = "assets/images/icons/orders_fill.svg";
  static const String cart = "assets/images/icons/cart.svg";
  static const String cartFill = "assets/images/icons/cart_fill.svg";
  static const String user = "assets/images/icons/user.svg";
  static const String userFill = "assets/images/icons/user_fill.svg";
  static const String categories = "assets/images/icons/categories.svg";
  static const String categoriesFill = "assets/images/icons/categories_fill.svg";
  static const String gps = "assets/images/icons/gps.svg";
  static const String gpsFill = "assets/images/icons/gps_fill.svg";
  static const String location = "assets/images/icons/location.svg";
  static const String locationFill = "assets/images/icons/location_fill.svg";
  static const String bell = "assets/images/icons/bell.svg";
  static const String bellFill = "assets/images/icons/bell_fill.svg";
  static const String search = "assets/images/icons/search.svg";
  static const String searchFill = "assets/images/icons/search_fill.svg";
  static const String download = "assets/images/icons/download.svg";
  static const String downloadFill = "assets/images/icons/download_fill.svg";
  static const String favorite = "assets/images/icons/favorite.svg";
  static const String favoriteFill = "assets/images/icons/favorite_fill.svg";
  static const String phone = "assets/images/icons/phone.svg";
  static const String phoneFill = "assets/images/icons/phone_fill.svg";
  static const String settings = "assets/images/icons/settings.svg";
  static const String settingsFill = "assets/images/icons/settings_fill.svg";
  static const String telegram = "assets/images/icons/telegram.svg";
  static const String telegramFill = "assets/images/icons/telegram_fill.svg";
  static const String collapse = "assets/images/icons/collapse.svg";
  static const String expand = "assets/images/icons/expand.svg";

  static const String flightLoaderLight = "assets/images/gifs/flight_loader_light.gif";
  static const String flightLoaderDark = "assets/images/gifs/flight_loader_dark.gif";

  // static const String soundBuzz = "sounds/buzz.mp3";
  // static const String soundCorrect = "sounds/correct.mp3";
  // end assets path __________________________________________

  // colors _________________________________________________
  static const Color primaryColor = Color(0xff132057);
  static const Color secondaryColor = Color(0xffe7b245);
  static const MaterialColor tertiaryColor = Colors.grey;
  static const Color bgColor = Color(0xfff8ece3);
  static Map<int, Color> primarySwatchColor() {
    return {
      50: primaryColor.withOpacity(0.1),
      100: primaryColor.withOpacity(0.2),
      200: primaryColor.withOpacity(0.3),
      300: primaryColor.withOpacity(0.4),
      400: primaryColor.withOpacity(0.5),
      500: primaryColor.withOpacity(0.6),
      600: primaryColor.withOpacity(0.7),
      700: primaryColor.withOpacity(0.8),
      800: primaryColor.withOpacity(0.9),
      900: primaryColor.withOpacity(1.0),
    };
  }
  // end colors _____________________________________________

  // sizes __________________________________________________
  static const double xxlg = 20;
  static const double xlg = 18;
  static const double lg = 16;
  static const double normal = 14;
  static const double sm = 12;
  static const double xsm = 10;
  static const double xxsm = 8;
  // end sizes ______________________________________________

  static Size sizeContext(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  static String getAppLang() {
    final code = Get.locale?.languageCode ?? Get.deviceLocale?.languageCode ?? 'en';
    return code;
  }

  static String getAppTheme() {
    return Get.isDarkMode ? "dark" : "light";
  }

  static String logoStr = """
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 93.4 76.14"><g id="Layer_2" data-name="Layer 2"><g id="Isolation_Mode" data-name="Isolation Mode"><path fill="#f6b124" fill-rule="evenodd" d="M55.81,59.23l.46,5.65C36.6,78.53,16.67,79.1,6.29,70.2-8.72,57.33,2,16.66,51.15.56,49,1.4,3.53,19.87,4.25,48.17c.63,24.9,31.33,24.53,51.56,11.06Z"/><path fill="#1e2758"d="M75.74,48A95.8,95.8,0,0,1,57.45,64.25a37.75,37.75,0,0,0-.55-5.54A42.13,42.13,0,0,0,68.49,47.39c11.45-17.17-1.17-20.76-1.17-20.76l-4.18,8s-7.59.68-14.61-7.69l8-4.67S32,18.25,12.72,41c.24-.53,8.2-17.57,35.53-30.85,19.39-9.41,29.11-8,32.15-7a6.55,6.55,0,0,1,.64.22h0l.42.18.12-.1h0c.91-.81,5.82-4.73,11.78-3,0,0-.77,4.38-3.49,7C90.24,7.72,101.34,17.84,75.74,48Z"/></g></g></svg>
""";
}
