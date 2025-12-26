import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart' as auth;

class FCM {
  static Future<String> getAccessToken() async {
    final jsonString = await rootBundle.loadString(
      'assets/notifications_key/alzajeltravel-58086-554b4e952af7.json',
    );

    final accountCredentials = auth.ServiceAccountCredentials.fromJson(jsonString);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
    final client = await auth.clientViaServiceAccount(accountCredentials, scopes);

    return client.credentials.accessToken.data;
  }
}
