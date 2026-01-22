import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'mrz_scan_service.dart';

/// ضع هذه الصفحة في مشروعك، وتأكد أن تطبيقك يستخدم GetMaterialApp
/// وكل النصوص مكتوبة بالإنجليزية متبوعة بـ .tr كما طلبت.
class MyMrzPage extends StatefulWidget {
  const MyMrzPage({super.key});

  @override
  State<MyMrzPage> createState() => _MyMrzPageState();
}

class _MyMrzPageState extends State<MyMrzPage> {
  static const int _maxAttempts = 24;

  final ImagePicker _picker = ImagePicker();
  final MrzScanService _scanner = MrzScanService();

  File? _imageFile;
  String? _jsonOutput;
  String? _error;
  String? _status;
  bool _busy = false;

  @override
  void dispose() {
    // _scanner.dispose();
    super.dispose();
  }

  Future<void> _pickCropAndScan(ImageSource source) async {
    setState(() {
      _error = null;
      _jsonOutput = null;
      _status = null;
    });

    final XFile? xfile = await _picker.pickImage(
      source: source,
      imageQuality: 100,
      maxWidth: 2400,
    );

    if (xfile == null) return;

    final File picked = File(xfile.path);

    // Crop step (v11 API)
    final File? cropped = await _cropImage(picked);
    final File finalFile = cropped ?? picked;

    if (cropped == null) {
      setState(() {
        _status = 'Crop cancelled. Using the original image.'.tr;
      });
    }

    setState(() {
      _imageFile = finalFile;
    });

    // Auto scan right after crop
    await _scan();
  }

  Future<void> _cropAgainAndScan() async {
    final file = _imageFile;
    if (file == null) return;

    final File? cropped = await _cropImage(file);
    if (cropped == null) return;

    setState(() {
      _imageFile = cropped;
      _error = null;
      _jsonOutput = null;
      _status = null;
    });

    await _scan();
  }

  Future<File?> _cropImage(File file) async {
    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 100,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image'.tr,
          hideBottomControls: false,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(
          title: 'Crop image'.tr,
          aspectRatioLockEnabled: false,
        ),
      ],
    );

    if (cropped == null) return null;
    return File(cropped.path);
  }

  Future<void> _scan() async {
    final file = _imageFile;
    if (file == null) {
      setState(() => _error = 'No image selected.'.tr);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _jsonOutput = null;
      _status = null;
    });

    try {
      // final output = await _scanner.scanPassport(
      //   file,
      //   maxAttempts: _maxAttempts,
      //   onAttempt: (attempt, total, tag) {
      //     if (!mounted) return;
      //     setState(() {
      //       _status =
      //           '${'Please wait while analyzing the image...'.tr} ($attempt/$total)';
      //     });
      //   },
      // );

      final output = null;

      final pretty = const JsonEncoder.withIndent('  ').convert(output);
      debugPrint(pretty);

      setState(() {
        _jsonOutput = pretty;
        _status = null;
      });
    } catch (e) {
      final msg = "";
      setState(() {
        _error = msg;
        _status = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imgWidget = _imageFile == null
        ? Text('No image selected.'.tr)
        : Image.file(_imageFile!, fit: BoxFit.contain);

    return Scaffold(
      appBar: AppBar(
        title: Text('Passport MRZ Scanner'.tr),
        actions: [
          IconButton(
            tooltip: 'Toggle language'.tr,
            onPressed: () {
              // تبديل سريع بين العربية والإنجليزية (اختياري)
              final current = Get.locale?.languageCode ?? 'en';
              Get.updateLocale(current == 'ar' ? const Locale('en') : const Locale('ar'));
            },
            icon: const Icon(Icons.language),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: imgWidget,
              ),
            ),
          ),
          const SizedBox(height: 12),

          if (_busy) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
          ],
          if (_status != null) ...[
            Text(_status!, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 12,
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : () => _pickCropAndScan(ImageSource.camera),
                  icon: const Icon(Icons.camera_alt),
                  label: Text('Pick from camera'.tr),
                ),
              ),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _busy ? null : () => _pickCropAndScan(ImageSource.gallery),
                  icon: const Icon(Icons.photo),
                  label: Text('Pick from gallery'.tr),
                ),
              ),
              // FilledButton.icon(
              //   onPressed: _busy ? null : _scan,
              //   icon: const Icon(Icons.qr_code_scanner),
              //   label: Text('Scan'.tr),
              // ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _busy || _imageFile == null ? null : _cropAgainAndScan,
            icon: const Icon(Icons.crop),
            label: Text('Crop image'.tr),
          ),

          const SizedBox(height: 16),

          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],

          if (_jsonOutput != null) ...[
            Text(
              'Result JSON:'.tr,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black12.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.black12),
              ),
              child: SelectableText(_jsonOutput!, textDirection: TextDirection.ltr,),
            ),
          ],
        ],
      ),
    );
  }
}

/// ترجمة جاهزة (ادمجها مع ترجمات مشروعك إن أردت)
// class MyMrzTranslations extends Translations {
//   @override
//   Map<String, Map<String, String>> get keys => {
//         'en': {
//           'Passport MRZ Scanner': 'Passport MRZ Scanner',
//           'Pick from camera': 'Pick from camera',
//           'Pick from gallery': 'Pick from gallery',
//           'Crop image': 'Crop image',
//           'Scan': 'Scan',
//           'Result JSON:': 'Result JSON:',
//           'No image selected.': 'No image selected.',
//           'Please wait while analyzing the image...':
//               'Please wait while analyzing the image...',
//           'Could not extract MRZ.': 'Could not extract MRZ.',
//           'Try a clearer photo and ensure the MRZ lines are fully visible.':
//               'Try a clearer photo and ensure the MRZ lines are fully visible.',
//           'Crop cancelled. Using the original image.':
//               'Crop cancelled. Using the original image.',
//           'Toggle language': 'Toggle language',
//         },
//         'ar': {
//           'Passport MRZ Scanner': 'فحص MRZ من جواز السفر',
//           'Pick from camera': 'التقاط من الكاميرا',
//           'Pick from gallery': 'اختيار من المعرض',
//           'Crop image': 'قص الصورة',
//           'Scan': 'فحص',
//           'Result JSON:': 'نتيجة JSON:',
//           'No image selected.': 'اختر صورة أولاً.',
//           'Please wait while analyzing the image...': 'انتظر حتى يتم تحليل الصورة ...',
//           'Could not extract MRZ.': 'تعذر استخراج MRZ.',
//           'Try a clearer photo and ensure the MRZ lines are fully visible.':
//               'جرّب صورة أوضح وتأكد أن سطري MRZ ظاهرين بالكامل.',
//           'Crop cancelled. Using the original image.':
//               'تم إلغاء القص، سيتم استخدام الصورة الأصلية.',
//           'Toggle language': 'تبديل اللغة',
//         },
//       };
// }
