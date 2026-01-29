// lib/ui/notification_demo_page.dart
import 'package:flutter/material.dart';
import 'package:alzajeltravel/services/notification_service.dart';

class NotificationDemoPage extends StatefulWidget {
  const NotificationDemoPage({super.key});

  @override
  State<NotificationDemoPage> createState() => _NotificationDemoPageState();
}

class _NotificationDemoPageState extends State<NotificationDemoPage> {


  // حقول نصية للغتين + رابط صورة اختياري
  final _titleAr = TextEditingController(text: 'تنبيه جديد');
  final _bodyAr  = TextEditingController(text: 'هذه تفاصيل الإشعار بالعربية.');
  final _titleEn = TextEditingController(text: 'New alert');
  final _bodyEn  = TextEditingController(text: 'Notification details in English.');
  final _imageUrl = TextEditingController(); // اتركه فارغًا لإشعار بدون صورة

  // تنظيف الكنترولرز
  @override
  void dispose() {
    _titleAr.dispose();
    _bodyAr.dispose();
    _titleEn.dispose();
    _bodyEn.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  Future<void> _showNotification() async {
    // تجهيز payload (بيانات إضافية). يمكنك تعديلها كما تريد.
    final payload = <String, String>{
      // مثال: مسار صفحة تريد فتحها عند Open/الضغط على جسم الإشعار
      // إذا كنت تستخدم enum Pages:
      'route': "add_passport", // أو '/booking'
      'order_id': '84291',
      // نخزن أيضًا عنوان/تفاصيل كنُسَخ احتياطية للمشاركة
      'title': _titleEn.text,
      'body': _bodyEn.text,
    };

    await NotificationService.showLocalizedNotification(
      titleAr: _titleAr.text.trim(),
      bodyAr:  _bodyAr.text.trim(),
      titleEn: _titleEn.text.trim(),
      bodyEn:  _bodyEn.text.trim(),
      imageUrl: _imageUrl.text.trim().isEmpty ? null : _imageUrl.text.trim(),
      payload: payload,
    );

    // مجرد ملاحظة للمستخدم أثناء التجربة
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الإشعار 👍')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Demo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('العربية', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleAr,
              decoration: const InputDecoration(labelText: 'العنوان (AR)'),
            ),
            TextField(
              controller: _bodyAr,
              decoration: const InputDecoration(labelText: 'التفاصيل (AR)'),
              maxLines: 2,
            ),

            const SizedBox(height: 16),
            const Text('English', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _titleEn,
              decoration: const InputDecoration(labelText: 'Title (EN)'),
            ),
            TextField(
              controller: _bodyEn,
              decoration: const InputDecoration(labelText: 'Body (EN)'),
              maxLines: 2,
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _imageUrl,
              decoration: const InputDecoration(
                labelText: 'رابط صورة (اختياري) — https://',
                hintText: 'اتركه فارغًا لإشعار بدون صورة',
              ),
            ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showNotification,
              icon: const Icon(Icons.notifications_active),
              label: const Text('إظهار الإشعار الآن'),
            ),

            const SizedBox(height: 8),
            const Text(
              'ملاحظات:\n'
              '• إذا أدخلت رابط صورة صحيح (https) سيظهر الإشعار بتخطيط BigPicture.\n'
              '• زر SHARE سيشارك العنوان + التفاصيل حسب لغة الجهاز (أو من payload احتياطيًا).\n'
              '• زر OPEN يمكنك ربطه بالتنقل داخل المستمع (NotificationController.onActionReceivedMethod).',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
