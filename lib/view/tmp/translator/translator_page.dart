import 'package:alzajeltravel/services/translator/translator_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';

class TranslatorPage extends StatefulWidget {
  const TranslatorPage({super.key});

  @override
  State<TranslatorPage> createState() => _TranslatorPageState();
}

class _TranslatorPageState extends State<TranslatorPage> {
  TextEditingController controller = TextEditingController();
  final translatorService = TranslatorService();
  String translated = '';
  bool loading = false;

  Future<void> doTranslate(String serverText) async {
    loading = true;
    setState(() {});
    try {
      translated = await translatorService.translateEnToAr(serverText);
    } catch (e) {
      translated = 'A translation error occurred'.tr;
    } finally {
      loading = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Translator')),
      body: Center(
        child: Column(
          children: [ 
            TextField(
              controller: controller,
              keyboardType: TextInputType.multiline,
              maxLines: 5,
              decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Enter text'),
            ),
            ElevatedButton(
              onPressed: () async {
                await doTranslate(controller.text);
              },
              child: const Text('Translate'),
            ),
            const SizedBox(height: 20),
            Text("The text is: ", style: const TextStyle(fontSize: 16)),
            Text(
              translated, 
              textAlign: TextAlign.start,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 16), 
            ),
          ],
        ),
      ),
    );
  }
}
