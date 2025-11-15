class ApiEndpoints {
  // 환경 설정 (빌드 시 --dart-define=USE_PRODUCTION=true 로 변경 가능)
  static const bool _useProduction = bool.fromEnvironment('USE_PRODUCTION', defaultValue: false);

  // Base URL - 로컬 개발용
  static const String localBaseUrl = 'http://localhost:8080'; // Windows 앱용
  static const String mobileBaseUrl = 'http://192.168.0.11:8080'; // 모바일 기기용 (PC IP)
  static const String emulatorBaseUrl = 'http://10.0.2.2:8080'; // Android 에뮬레이터용

  // 프로덕션 URL (Render 배포)
  static const String prodBaseUrl = 'https://expiration-tracker-app.onrender.com';

  // 현재 사용 중인 Base URL (환경에 따라 자동 선택)
  static String get baseUrl => _useProduction ? prodBaseUrl : mobileBaseUrl;

  // Gift Card API Endpoints
  static String get cards => '$baseUrl/api/cards';
  static String cardById(int id) => '$baseUrl/api/cards/$id';
  static String cardsByStatus(String status) => '$baseUrl/api/cards/status/$status';
  static String cardsByCategory(String category) => '$baseUrl/api/cards/category/$category';
  static String expiringSoon(int days) => '$baseUrl/api/cards/expiring-soon?days=$days';
  static String get expired => '$baseUrl/api/cards/expired';
  static String get stats => '$baseUrl/api/cards/stats';
  static String markAsUsed(int id) => '$baseUrl/api/cards/$id/use';

  // OCR API Endpoints
  static String get ocrProcess => '$baseUrl/api/ocr/process';
}
