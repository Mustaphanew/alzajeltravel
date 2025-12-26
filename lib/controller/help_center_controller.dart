// lib/controller/help_center_controller.dart
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:alzajeltravel/model/help_center_model.dart';
import 'package:alzajeltravel/repo/help_center_repo.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterController extends GetxController {

  final repo = HelpCenterRepo();
  bool loading = true;
  List<HelpCenterModel>? items;
  Future<void> load() async {
    loading = true;
    update();
    // items = await repo.fetchServerData();
    items = await repo.fetchTmpData();
    loading = false;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    load();
  }

  // final List<Map<String, dynamic>> items = const [
  //   {
  //     'name': 'WhatsApp',
  //     'url': 'https://api.whatsapp.com/send/+967770442646',
  //     'text': 'hello',
  //     'image': '/help-center/whatsapp.png',
  //   },
  //   {
  //     'name': 'Telegram',
  //     'url': 'https://t.me/brightness909',
  //     'text': 'hello from app',
  //     'image': '/help-center/telegram.png',
  //   },
  //   {
  //     'name': 'Call',
  //     'url': 'tel:+967770442646',
  //     'text': null,
  //     'image': '/help-center/call.png',
  //   },
  //   {
  //     'name': 'SMS',
  //     'url': 'sms:+967770442646',
  //     'text': 'hello',
  //     'image': '/help-center/sms.png',
  //   },
  //   {
  //     'name': 'Email',
  //     'url': 'mailto:horizonfortravelsl@gmail.com',
  //     'text': "hello",
  //     'image': '/help-center/email.png',
  //   },
  //   {
  //     'name': 'Website',
  //     'url': AppConsts.baseUrl,
  //     'text': null,
  //     'image': '/help-center/web.png',
  //   },
  // ];

  // --- نفس منطق بناء الروابط المختصر الذي اتفقنا عليه ---
  Uri _buildUri(HelpCenterModel item) {
    final rawUrl = item.url.trim();
    final text = (item.text ?? '').trim();
    if (rawUrl.isEmpty) throw ArgumentError('Empty url');

    // mailto: text -> subject
    if (rawUrl.startsWith('mailto:') && text.isNotEmpty) {
      final sep = rawUrl.contains('?') ? '&' : '?';
      return Uri.parse('$rawUrl${sep}subject=${Uri.encodeComponent(text)}');
    }

    // sms/smsto: text -> body
    if (rawUrl.startsWith('sms:') || rawUrl.startsWith('smsto:')) {
      if (text.isEmpty) return Uri.parse(rawUrl);
      final sep = rawUrl.contains('?') ? '&' : '?';
      return Uri.parse('$rawUrl${sep}body=${Uri.encodeComponent(text)}');
    }

    // Telegram (إن أردت مشاركة نص عام)
    if (rawUrl.startsWith('tg:') ||
        rawUrl.startsWith('telegram:') ||
        rawUrl.startsWith('https://t.me') ||
        rawUrl.startsWith('http://t.me') ||
        rawUrl.startsWith('https://telegram.me') ||
        rawUrl.startsWith('http://telegram.me')) {
      if (text.isNotEmpty) {
        return Uri.https('t.me', '/share/url', {'text': text});
      }
      return Uri.parse(rawUrl);
    }

    // WhatsApp: طبّع إن لزم (اختصار شديد)
    if (rawUrl.contains('whatsapp') || rawUrl.contains('wa.me') || rawUrl.startsWith('whatsapp:')) {
      final uri = Uri.tryParse(rawUrl) ?? Uri.parse('https://$rawUrl');
      String phone = uri.queryParameters['phone'] ?? '';
      if (phone.isEmpty && uri.pathSegments.isNotEmpty) {
        if (uri.host == 'wa.me') {
          phone = uri.pathSegments.first;
        } else if (uri.host.contains('api.whatsapp.com') && uri.pathSegments.first == 'send' && uri.pathSegments.length > 1) {
          phone = uri.pathSegments[1];
        }
      }
      final qp = <String, String>{};
      if (phone.isNotEmpty) qp['phone'] = phone;
      if (text.isNotEmpty) qp['text'] = text;

      if (uri.scheme == 'whatsapp') {
        return Uri(scheme: 'whatsapp', path: 'send', queryParameters: qp.isEmpty ? null : qp);
      }
      return Uri(scheme: 'https', host: 'api.whatsapp.com', path: '/send', queryParameters: qp.isEmpty ? null : qp);
    }

    // default
    return Uri.parse(rawUrl);
  }

  Future<void> openItem(HelpCenterModel item) async {
    final uri = _buildUri(item);
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok) Get.snackbar('Error', 'Cannot open link');
    } catch (e) {
      if (kDebugMode) print('openItem error: $e');
      Get.snackbar('Error', e.toString());
    }
  }
}
