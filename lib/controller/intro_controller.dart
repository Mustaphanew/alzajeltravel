import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class IntroController extends GetxController {
  static const String uri = "/api/countries";
  static const String table = "countries";

  bool loading = true;

  isLoading({bool loading = false}) {
    this.loading = loading;
    update();
  }

  List? dataList;

  getData({String condition = ""}) async {
    try {
      final response = await AppVars.dbHelper.select(
        column: "*",
        table: table,
        condition: " 1 $condition ",
      );
      if (response.isNotEmpty) {
        dataList = [];
        for (var element in response) {
          dataList!.add(element);
        }
      }
    } catch (err) {
      if (kDebugMode) print("err $uri: $err");
    }
    if (kDebugMode) print("dataList $uri: $dataList");
    isLoading(loading: false);
  }

  getServerData() async {
    try {
      final response = await AppVars.api.get(uri);
      print("response $response");
      if (response != null && response.isNotEmpty) {
        if (response is List) {
          dataList = [];
          for (var element in response) {
            dataList!.add(element);
          }
        }
      }
    } catch (err) {
      if (kDebugMode) print("err $uri: $err");
    }
    isLoading(loading: false);
  }

  tmpData() async {
    await Future.delayed(Duration(seconds: 1));
    dataList = [
      {
        "id": 1,
        "name": "أفضل العروض بأقل الأسعار",
        "body": "أكتشف أجمل الوجهات السياحية والشعاب المرجانية في العالم",
        "image": "1.jpg",
        "priority": 1,
        "deleted_at": null,
        "created_at": "2024-02-22T19:22:11",
        "updated_at": "2024-02-22T19:22:11",
      },
      {
        "id": 2,
        "name": "انطلق في رحلة لأكتشاف العالم",
        "body": "أكتشف أجمل الوجهات السياحية والشعاب المرجانية في العالم",
        "image": "2.jpg",
        "priority": 1,
        "deleted_at": null,
        "created_at": "2024-02-22T19:22:11",
        "updated_at": "2024-02-22T19:22:11",
      },
      {
        "id": 3,
        "name": "عِش تجربة الحياة بأسلوب مختلف",
        "body": "أكتشف أجمل الوجهات السياحية والشعاب المرجانية في العالم",
        "image": "3.jpg",
        "priority": 1,
        "deleted_at": null,
        "created_at": "2024-02-22T19:22:11",
        "updated_at": "2024-02-22T19:22:11",
      },
    ];
    isLoading(loading: false);
  }
}
