import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ocr_response_model.dart';
import '../../core/constants/api_endpoints.dart';

class OcrApiService {
  // 이미지 OCR 처리
  Future<OcrResponse> processImage(String imageBase64) async {
    try {
      final response = await http.post(
        Uri.parse(ApiEndpoints.ocrProcess),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: json.encode({'imageBase64': imageBase64}),
      );

      if (response.statusCode == 200) {
        return OcrResponse.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception('Failed to process OCR: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to process OCR: $e');
    }
  }
}
