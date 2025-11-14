# 테스트 가이드

Expiration Tracker 앱의 테스트 코드 실행 방법을 안내합니다.

---

## 📋 작성된 테스트 코드

### 백엔드 테스트 (Java/JUnit)

1. **GiftCardServiceTest** - 서비스 계층 단위 테스트
   - 위치: `backend/src/test/java/com/expirationtracker/service/GiftCardServiceTest.java`
   - 테스트 개수: 14개
   - 커버리지:
     - ✅ 전체 카드 조회
     - ✅ ID로 카드 조회 (성공/실패)
     - ✅ 상태별 조회
     - ✅ 카테고리별 조회
     - ✅ 유효기간 임박 조회
     - ✅ 만료된 카드 조회
     - ✅ 카드 생성
     - ✅ 카드 수정
     - ✅ 카드 삭제
     - ✅ 사용 완료 처리
     - ✅ 만료 카드 업데이트
     - ✅ 통계 조회

2. **GiftCardControllerTest** - 컨트롤러 계층 통합 테스트
   - 위치: `backend/src/test/java/com/expirationtracker/controller/GiftCardControllerTest.java`
   - 테스트 개수: 13개
   - 커버리지:
     - ✅ GET /api/cards (전체 조회)
     - ✅ GET /api/cards/{id} (개별 조회)
     - ✅ GET /api/cards/status/{status}
     - ✅ GET /api/cards/category/{category}
     - ✅ GET /api/cards/expiring-soon
     - ✅ GET /api/cards/expired
     - ✅ POST /api/cards (생성)
     - ✅ POST /api/cards (유효성 검증 실패)
     - ✅ PUT /api/cards/{id} (수정)
     - ✅ DELETE /api/cards/{id} (삭제)
     - ✅ PUT /api/cards/{id}/use (사용 완료)
     - ✅ GET /api/cards/stats (통계)

3. **OcrServiceTest** - OCR 서비스 단위 테스트
   - 위치: `backend/src/test/java/com/expirationtracker/service/OcrServiceTest.java`
   - 테스트 개수: 11개
   - 커버리지:
     - ✅ OCR API 미설정 시 실패 응답
     - ✅ 잘못된 이미지 오류 처리
     - ✅ 날짜 추출 (YYYY-MM-DD, YYYY.MM.DD, YYYYMMDD)
     - ✅ 바코드 추출 (10-15자리)
     - ✅ 카드 이름 추출

**총 테스트 개수**: 38개

---

## 🧪 테스트 실행 방법

### 1. 전체 테스트 실행

**PowerShell:**
```powershell
cd C:\workspace\expiration-tracker-app\backend
.\gradlew.bat test
```

**예상 출력:**
```
> Task :test

GiftCardServiceTest > getAllCards_Success() PASSED
GiftCardServiceTest > getCardById_Success() PASSED
GiftCardServiceTest > getCardById_NotFound() PASSED
...
GiftCardControllerTest > getAllCards() PASSED
GiftCardControllerTest > createCard() PASSED
...
OcrServiceTest > extractExpirationDate_HyphenFormat() PASSED
...

BUILD SUCCESSFUL in 15s
38 tests completed, 38 succeeded
```

### 2. 특정 테스트 클래스만 실행

**PowerShell:**
```powershell
# GiftCardServiceTest만 실행
.\gradlew.bat test --tests "com.expirationtracker.service.GiftCardServiceTest"

# GiftCardControllerTest만 실행
.\gradlew.bat test --tests "com.expirationtracker.controller.GiftCardControllerTest"

# OcrServiceTest만 실행
.\gradlew.bat test --tests "com.expirationtracker.service.OcrServiceTest"
```

### 3. 특정 테스트 메서드만 실행

**PowerShell:**
```powershell
.\gradlew.bat test --tests "com.expirationtracker.service.GiftCardServiceTest.getAllCards_Success"
```

### 4. 테스트 리포트 확인

테스트 실행 후 HTML 리포트가 생성됩니다:

**위치**: `backend/build/reports/tests/test/index.html`

**열기**:
```powershell
# 기본 브라우저로 열기
start backend\build\reports\tests\test\index.html
```

---

## 📊 테스트 커버리지 확인 (선택 사항)

### JaCoCo 플러그인 추가

`backend/build.gradle`에 다음 추가:

```gradle
plugins {
    // 기존 플러그인...
    id 'jacoco'
}

jacoco {
    toolVersion = "0.8.11"
}

test {
    finalizedBy jacocoTestReport
}

jacocoTestReport {
    dependsOn test
    reports {
        xml.required = true
        html.required = true
    }
}
```

### 커버리지 리포트 생성

**PowerShell:**
```powershell
.\gradlew.bat test jacocoTestReport
```

**리포트 위치**: `backend/build/reports/jacoco/test/html/index.html`

**열기**:
```powershell
start backend\build\reports\jacoco\test\html\index.html
```

---

## 🐛 테스트 실패 시 문제 해결

### 1. 컴파일 오류

**오류:**
```
Compilation failed; see the compiler error output for details.
```

**해결:**
```powershell
.\gradlew.bat clean build
```

### 2. 테스트 의존성 오류

**오류:**
```
Could not resolve all dependencies for configuration ':testCompileClasspath'
```

**해결:**
```powershell
.\gradlew.bat --refresh-dependencies test
```

### 3. 특정 테스트 실패

**확인 방법:**
- 테스트 리포트 열기: `backend/build/reports/tests/test/index.html`
- 실패한 테스트 클릭 → 에러 메시지 확인
- 스택 트레이스 분석

**일반적인 원인:**
- Mock 객체 설정 오류
- 예상 값과 실제 값 불일치
- 날짜/시간 관련 타이밍 이슈

---

## ✅ 테스트 베스트 프랙티스

### 1. 테스트 작성 규칙

- **Given-When-Then** 패턴 사용
- 테스트 메서드명은 명확하게 (예: `createCard_Success`)
- `@DisplayName` 사용하여 한글 설명 추가
- 하나의 테스트는 하나의 기능만 검증

### 2. Mock vs 실제 객체

- **Service 테스트**: Repository를 Mock (@MockBean)
- **Controller 테스트**: Service를 Mock (@WebMvcTest)
- **통합 테스트**: 실제 DB 사용 (@SpringBootTest)

### 3. 테스트 데이터

- `@BeforeEach`에서 테스트 데이터 초기화
- 테스트마다 독립적인 데이터 사용
- 실제 운영 데이터와 유사한 시나리오

---

## 📝 추가 테스트 작성 가이드

### 새로운 서비스 메서드 추가 시

1. **서비스 단위 테스트 작성**
   ```java
   @Test
   @DisplayName("새로운 기능 테스트")
   void newFeature_Success() {
       // given
       // ...

       // when
       // ...

       // then
       assertThat(result).isNotNull();
   }
   ```

2. **컨트롤러 통합 테스트 작성**
   ```java
   @Test
   @DisplayName("GET /api/new-endpoint")
   void newEndpoint() throws Exception {
       mockMvc.perform(get("/api/new-endpoint"))
               .andExpect(status().isOk());
   }
   ```

### 테스트 커버리지 목표

- **Service 계층**: 80% 이상
- **Controller 계층**: 70% 이상
- **전체**: 75% 이상

---

## 🚀 CI/CD 파이프라인 (선택 사항)

### GitHub Actions 설정

`.github/workflows/test.yml` 파일 생성:

```yaml
name: Backend Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main, develop ]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v3

    - name: Set up JDK 21
      uses: actions/setup-java@v3
      with:
        java-version: '21'
        distribution: 'temurin'

    - name: Grant execute permission for gradlew
      run: chmod +x backend/gradlew

    - name: Run tests
      run: cd backend && ./gradlew test

    - name: Upload test results
      uses: actions/upload-artifact@v3
      if: always()
      with:
        name: test-results
        path: backend/build/reports/tests/test/
```

---

## 📚 참고 자료

- [JUnit 5 Documentation](https://junit.org/junit5/docs/current/user-guide/)
- [Mockito Documentation](https://site.mockito.org/)
- [Spring Boot Testing](https://spring.io/guides/gs/testing-web/)
- [AssertJ Documentation](https://assertj.github.io/doc/)

---

**문서 버전**: 1.0
**최종 수정**: 2025-10-30
**작성자**: Claude (Anthropic)
