class OcrResponse {
  final String? name;
  final String? expirationDate;
  final String? barcode;
  final bool success;
  final String message;

  OcrResponse({
    this.name,
    this.expirationDate,
    this.barcode,
    required this.success,
    required this.message,
  });

  // JSON에서 OcrResponse 객체로 변환
  factory OcrResponse.fromJson(Map<String, dynamic> json) {
    return OcrResponse(
      name: json['name'] as String?,
      expirationDate: json['expirationDate'] as String?,
      barcode: json['barcode'] as String?,
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
    );
  }

  // OcrResponse 객체를 JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (expirationDate != null) 'expirationDate': expirationDate,
      if (barcode != null) 'barcode': barcode,
      'success': success,
      'message': message,
    };
  }

  // 날짜 파싱 (문자열을 DateTime으로 변환)
  DateTime? get parsedExpirationDate {
    if (expirationDate == null) return null;
    try {
      return DateTime.parse(expirationDate!);
    } catch (e) {
      return null;
    }
  }
}
