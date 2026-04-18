import 'dart:convert';

import 'package:alzajeltravel/utils/app_apis.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:cross_file/cross_file.dart';


Dio dio = Dio(
  BaseOptions(
    baseUrl: AppApis.baseUrl,
    connectTimeout: const Duration(seconds: 12),
    receiveTimeout: const Duration(seconds: 20),
    sendTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
    responseType: ResponseType.json,
  ),
);

class Api {
  Future<dynamic> get(
    String uri, {
    String extra = "",
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final String url = uri + extra;
      if (kDebugMode) debugPrint("get url: ${dio.options.baseUrl}$url");

      final response = await dio.get(
        url,
        queryParameters: params,
        options: Options(headers: headers),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint("Downloading progress get: ${received / total * 100}%");
          }
        },
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      }
    } on DioException catch (err) {
      debugPrint("❌ GET error status: ${err.response?.statusCode}");
      debugPrint("❌ GET error data: ${err.response?.data}");
    }
    return null;
  }

  /// - file: XFile (من image_picker) يعمل على Android/iOS/Web
  /// - asJson: true => JSON raw
  /// - asJson: false => x-www-form-urlencoded
  Future<dynamic> post(
    String uri, {
    String extra = "",
    Map<String, dynamic>? params,
    Map<String, dynamic>? headers,
    XFile? file,                  // ✅ بدل File
    String fileFieldName = 'file', // اسم الحقل في السيرفر
    bool asJson = true,
  }) async {
    params = params ?? {};
    params.removeWhere((key, value) => value == null);

    dynamic body;
    Options options;

    // 1) multipart/form-data (مع ملف)
    if (file != null) {
      final bytes = await file.readAsBytes();

      final filename = (file.name.isNotEmpty)
          ? file.name
          : p.basename(file.path);

      params[fileFieldName] = MultipartFile.fromBytes(
        bytes,
        filename: filename,
      );

      body = FormData.fromMap(params);

      options = Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json', ...?headers},
      );
    }
    // 2) JSON raw
    else if (asJson) {
      body = jsonEncode(params);
      options = Options(
        contentType: Headers.jsonContentType,
        headers: {'Accept': 'application/json', ...?headers},
      );
    }
    // 3) x-www-form-urlencoded
    else {
      body = params;
      options = Options(
        contentType: Headers.formUrlEncodedContentType,
        headers: {'Accept': 'application/json', ...?headers},
      );
    }

    try {
      final url = uri + extra;
      if (kDebugMode) {
        debugPrint("url: $url");
        debugPrint("full: ${dio.options.baseUrl}$url");
        debugPrint("params: $params");
      }

      final response = await dio.post(
        url,
        data: body,
        options: options,
        onSendProgress: (received, total) {
          if (total != -1) {
            debugPrint("Uploading progress post: ${received / total * 100}%");
          }
        },
        onReceiveProgress: (received, total) {
          if (total != -1) {
            debugPrint("Downloading progress post: ${received / total * 100}%");
          }
        },
      );

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return response.data;
      }
    } on DioException catch (err) {
      debugPrint("❌ POST error status: ${err.response?.statusCode}");
      debugPrint("❌ POST error data: ${err.response?.data}");
    }
    return null;
  }
}
