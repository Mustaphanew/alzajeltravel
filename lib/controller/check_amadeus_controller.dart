import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/utils/app_funs.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class CheckAmadeusController extends GetxController {
  static const String uri = "/amadeus_api.php";
  bool tokenOk = false;
  bool loading = false;

  isLoading({bool loading = false}) {
    this.loading = loading;
    update();
  }

  Future<bool> check() async {
    isLoading(loading: true);
    try {
      final Map<String, dynamic>? response = await AppVars.api.post(
        uri,
        params: {"action": "health"},
      );
      print("response $response");
      if (response != null) {
        CheckAmadeusModel checkAmadeusModel = CheckAmadeusModel.fromJson(response);
        tokenOk = checkAmadeusModel.amadeusTokenOk;
      }
    } catch (err) {
      if (kDebugMode) print("err $uri: $err");
    }
    isLoading(loading: false);
    return tokenOk;
  }

}

class CheckAmadeusModel {
  String action;
  bool amadeusTokenOk;
  Map<String, dynamic> ping;
  String env;
  String serveTime;

  CheckAmadeusModel({required this.action, required this.amadeusTokenOk, required this.ping, required this.env, required this.serveTime});

  factory CheckAmadeusModel.fromJson(Map<String, dynamic> json) {
    return CheckAmadeusModel(
      action: json['action'],
      amadeusTokenOk: AppFuns.toBool(json['amadeus_token_ok']),
      ping: json['ping'],
      env: json['env'],
      serveTime: json['server_time'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'action': action, 'amadeus_token_ok': amadeusTokenOk, 'ping': ping, 'env': env, 'server_time': serveTime};
  }


}
