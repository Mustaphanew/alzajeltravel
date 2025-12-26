import 'package:alzajeltravel/model/api.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

final CookieJar cookieJar = CookieJar();

void initDio() {
  final alreadyAddedCookieManager = dio.interceptors.any((i) => i is CookieManager);
  if (!alreadyAddedCookieManager) {
    dio.interceptors.add(CookieManager(cookieJar));
  }
}
