import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import 'package:alzajeltravel/model/passport/passport_model.dart';
import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:alzajeltravel/utils/app_consts.dart';
import 'package:alzajeltravel/utils/app_vars.dart';

/// Passport/card scanning page.
///
/// Flow:
/// 1) The user captures an image with the camera or picks one from the gallery.
/// 2) The image is cropped around the MRZ/barcode area.
/// 3) The image is uploaded to [AppApis.passportScan] as multipart/form-data.
/// 4) The JSON response is parsed with [PassportModel.fromJson].
/// 5) The parsed model is returned to the caller with `Get.back(result: model)`.
class PassportScannerPage extends StatefulWidget {
  const PassportScannerPage({super.key});

  @override
  State<PassportScannerPage> createState() => _PassportScannerPageState();
}

class _PassportScannerPageState extends State<PassportScannerPage> {
  final ImagePicker _picker = ImagePicker();

  XFile? _image;
  bool _busy = false;
  String? _status;
  String? _error;

  Future<void> _pickAndCrop(ImageSource source) async {
    setState(() {
      _error = null;
      _status = null;
    });

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 95,
        maxWidth: 2400,
      );
      if (picked == null) return;

      final XFile? cropped = await _crop(picked);
      if (!mounted) return;
      setState(() => _image = cropped ?? picked);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() => _error = _pickerErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  String _pickerErrorMessage(PlatformException e) {
    switch (e.code) {
      case 'camera_access_denied':
        return 'Camera access was denied.'.tr;
      case 'photo_access_denied':
      case 'gallery_access_denied':
        return 'Photo access was denied.'.tr;
      default:
        return (e.message?.trim().isNotEmpty ?? false) ? e.message! : e.code;
    }
  }

  Future<XFile?> _crop(XFile file) async {
    final CroppedFile? cropped = await ImageCropper().cropImage(
      sourcePath: file.path,
      compressFormat: ImageCompressFormat.jpg,
      compressQuality: 95,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop image'.tr,
          toolbarColor: AppConsts.primaryColor,
          toolbarWidgetColor: Colors.white,
          activeControlsWidgetColor: AppConsts.secondaryColor,
          hideBottomControls: false,
          lockAspectRatio: false,
          initAspectRatio: CropAspectRatioPreset.original,
        ),
        IOSUiSettings(title: 'Crop image'.tr, aspectRatioLockEnabled: false),
      ],
    );
    if (cropped == null) return null;
    return XFile(cropped.path);
  }

  Future<void> _recrop() async {
    if (_image == null) return;
    final XFile? cropped = await _crop(_image!);
    if (cropped != null) setState(() => _image = cropped);
  }

  Future<void> _scan() async {
    final file = _image;
    if (file == null) {
      setState(() => _error = 'No image selected.'.tr);
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _status = 'Please wait while analyzing the image...'.tr;
    });

    try {
      final response = await AppVars.api.post(
        AppApis.passportScan,
        file: file,
        fileFieldName: 'image',
        params: {'lang': AppVars.lang},
      );

      if (response == null) {
        throw 'Could not extract MRZ.'.tr;
      }

      // Accept either {data: {...}} or a direct model map.
      Map<String, dynamic> raw;
      if (response is Map) {
        raw = Map<String, dynamic>.from(response);
      } else {
        throw 'Unexpected server response'.tr;
      }

      final Map<String, dynamic> data = (raw['data'] is Map)
          ? Map<String, dynamic>.from(raw['data'] as Map)
          : raw;

      final model = PassportModel.fromJson(data);
      if (!mounted) return;
      Get.back(result: model);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _status = null;
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? cs.surface
          : const Color(0xFFFAF6F1),
      appBar: AppBar(
        title: Text(
          'Scan passport'.tr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: AppConsts.xlg,
          ),
        ),
        backgroundColor: AppConsts.primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _previewBox(cs),
                    const SizedBox(height: 16),
                    if (_busy) ...[
                      const LinearProgressIndicator(
                        color: AppConsts.secondaryColor,
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_status != null)
                      Text(
                        _status!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      _errorBox(cs),
                    ],
                    const SizedBox(height: 20),
                    _hintCard(cs),
                  ],
                ),
              ),
            ),
            _bottomActions(cs),
          ],
        ),
      ),
    );
  }

  Widget _previewBox(ColorScheme cs) {
    return AspectRatio(
      aspectRatio: 4 / 3,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _image == null
                ? cs.outlineVariant
                : AppConsts.secondaryColor,
            width: _image == null ? 1 : 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: _image == null
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    FontAwesomeIcons.idCard,
                    size: 48,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No image selected.'.tr,
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ],
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  _image!.path,
                  errorBuilder: (_, __, ___) => _localImage(),
                ),
              ),
      ),
    );
  }

  /// On Android/iOS the image path is local, so fall back to reading bytes.
  Widget _localImage() {
    return FutureBuilder(
      future: _image!.readAsBytes(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const SizedBox.shrink();
        }
        return Image.memory(snap.data!, fit: BoxFit.contain);
      },
    );
  }

  Widget _errorBox(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.error.withValues(alpha: 0.12),
        border: Border.all(color: cs.error, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: cs.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_error!, style: TextStyle(color: cs.error)),
          ),
        ],
      ),
    );
  }

  Widget _hintCard(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppConsts.secondaryColor.withValues(alpha: 0.10),
        border: Border.all(
          color: AppConsts.secondaryColor.withValues(alpha: 0.35),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppConsts.secondaryColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Try a clearer photo and ensure the MRZ lines are fully visible.'
                  .tr,
              style: TextStyle(color: cs.onSurface, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomActions(ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        border: Border(top: BorderSide(color: cs.outlineVariant, width: 0.7)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _pickAndCrop(ImageSource.camera),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConsts.secondaryColor,
                    side: const BorderSide(
                      color: AppConsts.secondaryColor,
                      width: 1.4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: Text('Pick from camera'.tr),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy
                      ? null
                      : () => _pickAndCrop(ImageSource.gallery),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppConsts.secondaryColor,
                    side: const BorderSide(
                      color: AppConsts.secondaryColor,
                      width: 1.4,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.photo, size: 18),
                  label: Text('Pick from gallery'.tr),
                ),
              ),
            ],
          ),
          if (_image != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _busy ? null : _recrop,
                    icon: const Icon(Icons.crop, size: 18),
                    label: Text('Crop image'.tr),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : _scan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConsts.secondaryColor,
                      foregroundColor: AppConsts.primaryColor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: AppConsts.normal,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: Text('Scan'.tr),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
