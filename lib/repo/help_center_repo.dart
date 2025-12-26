// lib/repo/help_center_repo.dart
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:flutter/foundation.dart';
import 'package:alzajeltravel/model/help_center_model.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

class HelpCenterRepo {
  static const String uri = "/appm/jsons/help-center.json";

  Future<List<HelpCenterModel>?> fetchServerData() async {
    try {
      // await Future.delayed(Duration(seconds: 1));
      final response = await AppVars.api.get(uri);

      // null => خطأ شبكة/سيرفر (تريدها تظل null)
      if (response == null) return null;

      if (response is List) {
        if (response.isEmpty) return <HelpCenterModel>[]; // لا توجد بيانات
        return response.whereType<Map>().map((e) => HelpCenterModel.fromJson(Map<String, dynamic>.from(e))).toList();
      }

      // شكل غير متوقع => اعتبره خطأ
      return null;
    } catch (err) {
      if (kDebugMode) print("err $uri: $err");
      return null; // خطأ => null
    }
  }

  Future<List<HelpCenterModel>?> fetchTmpData() async {
    return [
      HelpCenterModel(
        name: 'WhatsApp',
        url: 'https://api.whatsapp.com/send/+967770442646',
        text: 'hello',
        image: '/help-center/whatsapp.png',
      ),
      HelpCenterModel(
        name: 'Telegram',
        url: 'https://t.me/brightness909',
        text: 'hello',
        image: '/help-center/telegram.png',
      ),
      HelpCenterModel(
        name: 'Phone',
        url: 'tel:+967770442646',
        text: 'hello',
        image: '/help-center/phone.png',
      ),
      HelpCenterModel(
        name: 'SMS',
        url: 'sms:+967770442646',
        text: 'hello',
        image: '/help-center/sms.png',
      ),
      HelpCenterModel(
        name: 'Email',
        url: 'mailto:horizonfortravelsl@gmail.com',
        text: 'hello',
        image: '/help-center/email.png', 
      ),
      HelpCenterModel(
        name: 'Website',
        url: AppConsts.baseUrl,
        text: null,
        image: '/help-center/web.png',
      ),
    ];
  }
}
