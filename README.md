# Expiration Tracker - 유효기간 관리 앱

기프티콘, 모바일 상품권 등 유효기간이 있는 아이템들을 효율적으로 관리하는 애플리케이션입니다.

## 주요 기능

- **사진 기반 등록**: 기프티콘 사진을 촬영하면 OCR로 자동 정보 추출
- **수동 등록/수정**: OCR 실패 시 수동으로 정보 입력 가능
- **유효기간 알림**: FCM 푸시 알림으로 만료 임박 알림
- **바코드 표시**: 매장에서 바로 사용할 수 있도록 바코드 표시
- **카테고리 관리**: 기프티콘, 상품권, 쿠폰 등으로 분류
- **상태 관리**: 사용 가능, 사용 완료, 만료 상태 자동 업데이트

## 기술 스택

### 백엔드
- **프레임워크**: Spring Boot 3.2.0
- **언어**: Java 21
- **데이터베이스**: H2 (로컬), PostgreSQL (프로덕션)
- **ORM**: Spring Data JPA, Hibernate
- **OCR**: Naver Clova OCR API
- **알림**: Firebase Cloud Messaging (FCM)
- **빌드 도구**: Gradle 8.x

### 프론트엔드
- **프레임워크**: Flutter 3.x
- **상태 관리**: Provider
- **HTTP 클라이언트**: http
- **이미지 처리**: image_picker
- **바코드**: barcode_widget
- **알림**: firebase_messaging

### 배포
- **플랫폼**: Railway
- **데이터베이스**: Railway PostgreSQL

## 프로젝트 구조

```
expiration-tracker-app/
├── backend/                    # Spring Boot 백엔드
│   ├── src/main/java/com/expirationtracker/
│   │   ├── entity/            # 엔티티 (GiftCard, CardStatus, Category)
│   │   ├── repository/        # JPA 리포지토리
│   │   ├── service/           # 비즈니스 로직 (GiftCardService, OcrService)
│   │   ├── controller/        # REST API (GiftCardController, OcrController)
│   │   ├── dto/               # 데이터 전송 객체
│   │   ├── config/            # 설정 (CORS)
│   │   └── scheduler/         # 스케줄러 (만료 카드 처리, 알림)
│   ├── src/main/resources/
│   │   ├── application.yml    # 로컬 설정
│   │   └── application-prod.yml  # 프로덕션 설정
│   ├── build.gradle           # Gradle 빌드 설정
│   ├── Procfile               # Railway 실행 명령
│   └── railway.json           # Railway 빌드 설정
│
├── frontend/                   # Flutter 프론트엔드
│   ├── lib/
│   │   ├── main.dart          # 앱 진입점
│   │   ├── core/              # 상수, 유틸리티
│   │   ├── data/              # 모델, API 서비스
│   │   ├── presentation/      # 화면, 위젯, Provider
│   │   └── config/            # 설정
│   └── pubspec.yaml           # Flutter 패키지 설정
│
├── .gitignore
├── README.md
└── CLAUDE.md                   # 개발자 가이드 (이 파일!)
```

## 로컬 개발 환경 설정

### 1. 필수 도구 설치
- Java 21
- Flutter 3.x
- PostgreSQL (또는 H2 사용)

### 2. 백엔드 실행
```powershell
cd backend
.\gradlew.bat bootRun
```

서버: http://localhost:8080

### 3. 프론트엔드 실행
```powershell
cd frontend
flutter pub get
flutter run -d windows
```

### 4. API 테스트
H2 Console: http://localhost:8080/h2-console
- JDBC URL: `jdbc:h2:file:./data/expirationdb`
- Username: `sa`
- Password: (없음)

## API 엔드포인트

### 기프티콘 관리
- `GET /api/cards` - 전체 조회
- `GET /api/cards/{id}` - 개별 조회
- `GET /api/cards/status/{status}` - 상태별 조회
- `GET /api/cards/category/{category}` - 카테고리별 조회
- `GET /api/cards/expiring-soon?days=7` - 유효기간 임박 조회
- `GET /api/cards/expired` - 만료된 카드 조회
- `GET /api/cards/stats` - 통계 조회
- `POST /api/cards` - 생성
- `PUT /api/cards/{id}` - 수정
- `PUT /api/cards/{id}/use` - 사용 완료 처리
- `DELETE /api/cards/{id}` - 삭제

### OCR
- `POST /api/ocr/process` - 이미지 OCR 처리

## 환경 변수

### 로컬 개발 (application.yml)
```yaml
naver:
  clova:
    ocr:
      url: ${NAVER_CLOVA_OCR_URL}
      secret: ${NAVER_CLOVA_OCR_SECRET}

fcm:
  service-account-file: ${FCM_SERVICE_ACCOUNT_FILE}
```

### Railway 배포
- `SPRING_PROFILES_ACTIVE=prod`
- `DATABASE_URL` (자동 생성)
- `NAVER_CLOVA_OCR_URL`
- `NAVER_CLOVA_OCR_SECRET`
- `FCM_SERVICE_ACCOUNT_FILE`

## Railway 배포 가이드

### 1. GitHub 저장소 생성
```powershell
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/[username]/expiration-tracker-app.git
git push -u origin main
```

### 2. Railway 설정
1. Railway 프로젝트 생성
2. GitHub 저장소 연결
3. Root Directory: `/backend`
4. PostgreSQL 추가
5. 환경 변수 설정

### 3. 배포 확인
- Deployments 탭에서 빌드 로그 확인
- 도메인 생성 후 API 테스트

자세한 내용은 `CLAUDE.md`를 참조하세요.

## 라이선스

MIT License

## 개발자

lacram

---

**개발 시작일**: 2025-10-30
**최종 업데이트**: 2025-10-30
