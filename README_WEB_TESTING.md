# 🌐 웹 빌드 테스트 가이드

## ❌ 잘못된 방법 (CORS 오류 발생)

```bash
# 이렇게 하지 마세요!
open build/web/index.html
# 또는 브라우저에서 file:// 프로토콜로 직접 열기
```

**오류 메시지:**
```
Failed to load resource: net::ERR_FILE_NOT_FOUND
Access to internal resource at 'file:///manifest.json' from origin 'null' has been blocked by CORS policy
```

## ✅ 올바른 방법 (웹 서버 사용)

### 1. 자동 스크립트 사용 (권장)

```bash
# 로컬 웹 서버만 시작
./scripts/serve-web.sh

# 빌드 + 테스트 통합
./scripts/build-and-test-web.sh

# itch.io용 빌드 (테스트 포함)
./scripts/build-web-itch.sh
```

### 2. 수동 방법

```bash
# 웹 빌드 생성
flutter build web --release

# Python으로 웹 서버 시작
cd build/web
python3 -m http.server 8080

# 브라우저에서 접속
open http://localhost:8080
```

## 🔧 지원하는 웹 서버

스크립트가 자동으로 감지하여 사용:

1. **Python 3** (우선순위 1)
   ```bash
   python3 -m http.server 8080
   ```

2. **Python 2** (우선순위 2)
   ```bash
   python -m http.server 8080
   ```

3. **Node.js** (우선순위 3)
   ```bash
   npx http-server -p 8080 -c-1
   ```

## 🌍 접속 URL

- **로컬**: http://localhost:8080
- **네트워크**: http://[YOUR-IP]:8080
- **포트 충돌시**: 자동으로 8081, 8082, 8083, 8000, 3000 순서로 시도

## 🧪 테스트 체크리스트

### 기본 기능
- [ ] 게임 로딩 확인
- [ ] 플레이어 이동 (WASD/방향키)
- [ ] 탄막 패턴 동작
- [ ] 게임 오버 처리
- [ ] 설정 화면 접근

### 웹 특화 기능
- [ ] 모바일 터치 컨트롤
- [ ] 풀스크린 모드
- [ ] 브라우저 호환성 (Chrome, Firefox, Safari)
- [ ] 네트워크/오프라인 모드

### 성능 확인
- [ ] 초기 로딩 시간 (5-10초 내)
- [ ] 프레임레이트 안정성
- [ ] 메모리 사용량
- [ ] 브라우저 콘솔 에러 없음

## 🚨 문제 해결

### CORS 오류 계속 발생
```bash
# 브라우저 캐시 클리어 후 재시도
# Chrome: Ctrl+Shift+R (하드 리프레시)
# 또는 시크릿 모드에서 테스트
```

### 포트 충돌
```bash
# 사용 중인 포트 확인
lsof -i :8080

# 프로세스 종료
kill -9 [PID]
```

### 웹 서버 종료
```bash
# 터미널에서 Ctrl+C
# 또는 스크립트 자동 종료 대기
```

## 💡 개발 팁

### VS Code Live Server
VS Code Extension "Live Server" 사용 가능:
1. `build/web/index.html` 우클릭
2. "Open with Live Server" 선택

### Flutter 개발 서버
개발 중에는 Flutter 개발 서버 사용:
```bash
flutter run -d chrome
```

### 빌드 자동화
```bash
# 파일 변경 감지 시 자동 빌드
# (별도 스크립트 필요)
```

## 📱 모바일 테스트

네트워크 URL로 모바일에서 접속:
1. 스크립트 실행 시 표시되는 Network URL 확인
2. 모바일 브라우저에서 해당 URL 접속
3. 터치 컨트롤 테스트

---

**⚠️ 중요**: itch.io 업로드 전에 반드시 로컬 테스트를 완료하세요!