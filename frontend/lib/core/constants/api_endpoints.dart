class ApiEndpoints {
  // Base URL - 로컬 개발용
  static const String localBaseUrl = 'http://localhost:8080'; // Windows 앱용
  static const String mobileBaseUrl = 'http://192.168.0.11:8080'; // 모바일 기기용 (PC IP)
  static const String emulatorBaseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터용

  // 프로덕션 URL (Railway 배포 후 업데이트)
  static const String prodBaseUrl = 'https://your-railway-url.railway.app';

  // 현재 사용 중인 Base URL (모바일 기기용으로 변경)
  static const String baseUrl = mobileBaseUrl;

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
