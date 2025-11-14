class ApiEndpoints {
  // Base URL - 로컬 개발용
  static const String localBaseUrl = 'http://localhost:8080';

  // 프로덕션 URL (Railway 배포 후 업데이트)
  static const String prodBaseUrl = 'https://your-railway-url.railway.app';

  // 현재 사용 중인 Base URL (개발 시에는 local, 배포 후에는 prod로 변경)
  static const String baseUrl = localBaseUrl;

  // Gift Card API Endpoints
  static const String cards = '$baseUrl/api/cards';
  static String cardById(int id) => '$baseUrl/api/cards/$id';
  static String cardsByStatus(String status) => '$baseUrl/api/cards/status/$status';
  static String cardsByCategory(String category) => '$baseUrl/api/cards/category/$category';
  static String expiringSoon(int days) => '$baseUrl/api/cards/expiring-soon?days=$days';
  static const String expired = '$baseUrl/api/cards/expired';
  static const String stats = '$baseUrl/api/cards/stats';
  static String markAsUsed(int id) => '$baseUrl/api/cards/$id/use';

  // OCR API Endpoints
  static const String ocrProcess = '$baseUrl/api/ocr/process';
}
