> **"5분 생존할 수 있나요?"** - Avoid Bubble 개발 여정

## 🎯 프로젝트 개요

### 🎮 게임 소개

안녕하세요! 이번에 **Flutter + Flame**으로 탄막 피하기 게임을 개발하고 itch.io 정식 출시까지 완료했습니다.

**Avoid Bubble**은 점점 어려워지는 패턴을 피하며 최대한 오래 생존하는 게임입니다.

**🌐 지금 바로 플레이**: https://dev-kbk.itch.io/avoid-bubble

### 🛠️ 기술 스택

- **Flutter**: 크로스 플랫폼 개발
- **Flame**: 2D 게임 엔진
- **Supabase**: 온라인 랭킹 시스템
- **ARB**: 국제화 (한국어/영어)
- **GitHub Actions**: 태그 기반 자동 배포
- **itch.io**: 웹 게임 배포 플랫폼
- **Claude CLI**: 에이전틱 코딩 도구

## 🏗️ 아키텍처 설계

### 📁 프로젝트 구조

```
lib/
├── main.dart                    # 앱 진입점 및 상태 관리
├── game/
│   ├── avoid_bubble_game.dart  # Flame 게임 엔진 핵심
│   └── game_state.dart         # 게임 상태 enum
├── screens/
│   ├── start_screen.dart       # 메인 메뉴
│   ├── settings_screen.dart    # 설정 화면
│   └── game_over_screen.dart   # 게임 오버
├── components/
│   ├── player.dart            # 플레이어 Flame 컴포넌트
│   └── bullet.dart            # 총알 Flame 컴포넌트
├── models/
│   ├── game_settings.dart     # 게임 설정 모델
│   ├── game_stats.dart        # 통계 관리 모델
│   ├── player_model.dart      # 플레이어 비즈니스 로직
│   └── bullet_model.dart      # 총알 로직 및 팩토리
├── services/
│   ├── localization_service.dart # ARB 기반 다국어
│   ├── ranking_service.dart      # Supabase 랭킹
│   └── nickname_service.dart     # 닉네임 관리
└── l10n/
    ├── app_en.arb             # 영어 번역
    └── app_ko.arb             # 한국어 번역
```

### 🎯 핵심 아키텍처 패턴

#### 1. **Component-Model 패턴**

Flame 컴포넌트와 비즈니스 로직을 분리하여 유지보수성을 높였습니다.

```dart
// Player 컴포넌트는 렌더링과 애니메이션만 담당
class Player extends SpriteAnimationComponent with HasGameReference<AvoidBubbleGame> {
  late PlayerModel model;

  @override
  void update(double dt) {
    super.update(dt);
    // 비즈니스 로직은 모델에 위임
    model.updatePosition(dt, game.size);
    position = model.position;
    _updateAnimation();
  }
}

// 플레이어의 데이터와 상태를 관리하는 모델 클래스
class PlayerModel {
  final double speed;
  final CharacterSkin skin;
  Vector2 position;
  Vector2 velocity;
  Vector2 _screenSize = Vector2.zero();

  PlayerModel({
    this.speed = GameConstants.playerSpeed,
    this.skin = CharacterSkin.fireChar,
    Vector2? initialPosition,
  }) : position = initialPosition ?? Vector2.zero(),
       velocity = Vector2.zero();

  // 매 프레임마다 위치를 업데이트
  void updatePosition(double dt, Vector2 screenSize) {
    position += velocity * dt;
    // 플레이어가 화면 밖으로 나가지 않도록 제한
    position.x = position.x.clamp(collisionRadius, screenSize.x - collisionRadius);
    position.y = position.y.clamp(collisionRadius, screenSize.y - collisionRadius);
  }

  // 스케일링된 충돌 반지름 getter
  double get collisionRadius => _screenSize != Vector2.zero()
      ? skin.getScaledCollisionRadius(_screenSize)
      : skin.baseCollisionRadius;
}
```

#### 2. **총알 생성**

다양한 총알 패턴을 관리했습니다.

```dart
  // 패턴 1: 플레이어를 타겟팅하는 총알 생성
  void spawnTargetedBullet() {
...
  }
  void spawnEightDirectionBullets() {
  ...
  }
  void spawnLinearBullets() {
  ...
  }

```

#### 3. **게임 설정**

모든 게임 파라미터를 `GameSettings`에서 중앙화 관리했습니다.

```dart
class GameSettings {
  // 게임 난이도
  double bulletSpeed; // 총알 속도
  double playerSpeed; // 플레이어 속도
  bool isInvincible; // 무적 모드 여부 (개발용)

  // 패턴 타이밍 설정
  PatternTimings patternTimings;

}
```

## 🚨 트러블슈팅 경험

### 1. **모바일 세로 모드 회전 안내 메시지 문제**

#### 문제 상황

itch.io iframe 환경에서 모바일 회전 안내 메시지가 표시되지 않는 문제

#### 원인 분석

```javascript
// 기존 코드 - iframe 감지로 인해 모바일에서 메시지 차단
if (window.parent === window && Math.abs(orientation) !== 90) {
  showOrientationMessage();
}
```

#### 해결 방법

iframe 제한을 제거하고 브라우저 언어 감지를 추가했습니다.

```javascript
// 개선된 코드
// 세로 방향일 때 알림 표시 (모바일에서는 iframe 여부와 관계없이)
if (Math.abs(orientation) !== 90) {
	showOrientationMessage();
}

function showOrientationMessage() {
        let orientationMsg = document.getElementById("orientation-message");
        if (!orientationMsg) {
          // 브라우저 언어 감지
          const isEnglish = navigator.language.toLowerCase().startsWith("en");
          const title = isEnglish
            ? "Please rotate your screen"
            : "화면을 회전해주세요";
          const subtitle = isEnglish
            ? "Please play in landscape mode for better gaming experience"
            : "더 나은 경험을 위해 가로 모드로 플레이해주세요";
            // 메시지 표시
         	...
        }
}
```

### 2. **반응형 스케일링 시스템**

#### 문제 상황

다양한 화면 크기에서 게임 요소들의 크기가 일관되지 않음

#### 해결 방법

화면 크기 기반 동적 스케일링을 구현했습니다.

```dart
  // 스케일링된 크기 계산
  Vector2 getScaledRenderSize(Vector2 screenSize) {
    final scale = _calculateScale(screenSize);
    final scaledX = baseRenderSizeX * scale;
    final scaledY = baseRenderSizeY * scale;
    // 최소 32px로 제한
    final result =
        Vector2(scaledX.clamp(36.0, 48.0), scaledY.clamp(36.0, 48.0));
    debugPrint('player size ${result.x} x ${result.y} (scale: $scale)');
    return result;
  }
  ...
   // 화면 크기에 따른 총알 반지름 계산 (1440x720 기준 12px)
  double _calculateRadius() {
    if (_screenSize == null) {
      return GameConstants.bulletRadius; // 기본값 사용
    }

    // 기준 해상도 (1440x720)
    const baseWidth = 1440.0;
    const baseHeight = 720.0;
    const baseBulletRadius = GameConstants.bulletRadius; // 1440x720에서 24px

    // 현재 화면 크기
    final currentWidth = _screenSize.x;
    final currentHeight = _screenSize.y;

    // 화면 비율에 따른 스케일링
    final scaleX = currentWidth / baseWidth;
    final scaleY = currentHeight / baseHeight;
    final scale = (scaleX + scaleY) / 2; // 평균 스케일 사용

    // 스케일링된 크기 계산 (최소 8px 제한)
    final scaledRadius = baseBulletRadius * scale;
    final finalRadius = scaledRadius.clamp(16.0, 24.0);

    debugPrint(
        'bullet radius calculation - screen: ${currentWidth}x$currentHeight, scale: $scale, radius: $finalRadius');
    return finalRadius;
  }
```

### 4. **태그 기반 자동 배포 시스템**

#### 요구사항

main 브랜치 푸시가 아닌 버전 태그 기반으로 배포 전환

#### GitHub Actions 워크플로우

```yaml
name: Deploy to itch.io
on:
  push:
    tags:
      - "v*.*.*"

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
     - name: Analyze tag and update pubspec.yaml
            id: analyze_tag
            run: |
              if [ "${{ github.event_name }}" == "push" ] && [[ "${{ github.ref }}" == refs/tags/* ]]; then
                # 태그에서 버전 추출
                TAG_VERSION=${GITHUB_REF#refs/tags/v}
                echo "Tag version: $TAG_VERSION"

                # 현재 pubspec.yaml의 버전 확인
                CURRENT_VERSION=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)
                echo "Current pubspec version: $CURRENT_VERSION"

                # Semantic version 검증 (major.minor.patch 형태)
                if [[ ! $TAG_VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
                  echo "❌ Invalid semantic version format: $TAG_VERSION"
                  echo "   Expected format: major.minor.patch (e.g., 1.2.3)"
                  exit 1
                fi
                ...
                # 버전이 다를 시 pubspec.yaml 업데이트 및 메이저, 마이너, 패치 판별
```

## 🎮 게임 메커니즘 설계

### 3단계 탄막 시스템

#### Stage 1: 타겟팅 시스템 (2-15초)

```dart
void spawnTargetedBullet() {
    if (isGameOver || !isLoaded || !isMounted) return;
    // 화면 가장자리 4방향 중 랜덤한 위치에서 시작
    final side = random.nextInt(4);
    late Vector2 startPosition;

    switch (side) {
      case 0: // 상단
        startPosition = Vector2(random.nextDouble() * size.x, 10);
        break;
      case 1: // 우측
        startPosition = Vector2(size.x - 10, random.nextDouble() * size.y);
        break;
      case 2: // 하단
        startPosition = Vector2(random.nextDouble() * size.x, size.y - 10);
        break;
      case 3: // 좌측
        startPosition = Vector2(10, random.nextDouble() * size.y);
        break;
    }
    ...
}
```

#### Stage 2: 8방향 동시 공격 (15초+)

```dart
void spawnEightDirectionBullets() {
   if (isGameOver || !isLoaded || !isMounted) return;
   final playerCenter = player.playerCenter;

    // 8개의 정규화된 방향 벡터
   final directions = [
     Vector2(0, -1), // N
     Vector2(1, -1)..normalize(), // NE
     Vector2(1, 0), // E
     Vector2(1, 1)..normalize(), // SE
     Vector2(0, 1), // S
     Vector2(-1, 1)..normalize(), // SW
     Vector2(-1, 0), // W
     Vector2(-1, -1)..normalize(), // NW
   ];
   ...
}
```

#### Stage 3: 순차 직선 탄막 (30초+)

```dart
void spawnLinearBullets() {
    if (isGameOver || !isLoaded || !isMounted) return;
    final direction = pattern3Direction;

    late Vector2 startPos;
    late Vector2 directionVector;
    late double spacing;
    late int bulletCount;
    ...
}
```

### 난이도 진행 시스템

```dart
...
    // 5초마다 총알 속도 1씩 증가 (무한 증가)
    final speedBonus = (survivalTime ~/ 5).toDouble();
    final adjustedSpeed = settings.bulletSpeed + speedBonus;

    // 디버그 로그 추가
    if (kDebugMode) {
      debugPrint(
          '🔥 Pattern1 Bullet - Speed: $adjustedSpeed (base: ${settings.bulletSpeed}, bonus: $speedBonus), Direction: $direction');
    }

    final bullet = Bullet(
      startPosition: startPosition,
      direction: direction,
      speed: adjustedSpeed,
      type: BulletType.targeted,
      screenSize: size,
    );
    add(bullet);
...
    // 15초 이후 패턴 1 강화
    if (survivalTime >= timings.pattern1EndTime) {
      if (survivalTime - lastBulletSpawn >= timings.pattern1FastInterval) {
        spawnTargetedBullet();
        lastBulletSpawn = survivalTime;
      }
    }
```

## 🌍 다국어 지원 전략

### 브라우저 언어 자동 감지

```dart
  /// 브라우저 언어를 감지하여 언어 설정
  static void detectBrowserLanguage() {
    try {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final languageCode = locale.languageCode.toLowerCase();
      // 지원 언어: 한국어(ko), 영어(en)
      if (languageCode == 'ko') {
        _currentLanguage = 'ko';
      } else {
        _currentLanguage = 'en'; // 기본값
      }
    } catch (e) {
      _currentLanguage = 'en'; // 오류 시 영어로 기본 설정
    }
  }
```

## 📊 성능 최적화

### 1. **화면 밖 오브젝트 자동 제거**

```dart
// bullet.dart
  @override
  void update(double dt) {
    super.update(dt);

    // 모델의 위치를 업데이트하고 컴포넌트 위치와 동기화
    model.updatePosition(dt);
    position = model.position;

    // 모델의 로직에 따라 화면을 벗어났는지 확인하고 제거
    if (model.shouldRemove(game.size, game.player.position)) {
      removeFromParent();
    }
  }
```

## 🚀 배포 및 DevOps

### Butler를 활용한 자동 배포

itch.io에서 공식 제공하는 **[bulter](https://itch.io/docs/butler/)**를 사용하면 명령어 한 줄로 게임을 업로드할 수 있습니다.

#### Butler 설치 및 설정

```bash
# Butler 다운로드 (macOS 예시)
curl -L -o butler.zip https://broth.itch.ovh/butler/darwin-amd64/LATEST/archive/default
unzip butler.zip -d butler
chmod +x butler/butler
sudo mv butler/butler /usr/local/bin/

# 로그인 (브라우저에서 인증)
butler login

# API 키로 로그인 (CI/CD용)
butler login --api-key YOUR_API_KEY
```

#### 자동 배포 스크립트

```bash
#!/bin/bash
# scripts/deploy-itch.sh

echo "🎮 Itch.io 배포 스크립트 시작"

# Flutter 웹 빌드
flutter build web --release --base-href "./"

# pubspec.yaml에서 버전 추출
VERSION=$(grep "^version:" pubspec.yaml | cut -d' ' -f2)

# ZIP 파일 생성
cd build/web
ZIP_FILE="../../avoid-bubble-itch-v${VERSION}.zip"
zip -r "$ZIP_FILE" .
cd ../..

echo "✅ ZIP 파일 생성 완료: avoid-bubble-itch-v${VERSION}.zip"

# Butler로 자동 업로드
if command -v butler &> /dev/null; then
    echo "🚀 Butler로 itch.io 업로드 중..."
    butler push build/web username/avoid-bubble:web --userversion "$VERSION"
    echo "✅ itch.io 업로드 완료!"
else
    echo "⚠️  Butler가 설치되지 않음. 수동으로 ZIP 파일을 업로드하세요."
    echo "📦 업로드할 파일: avoid-bubble-itch-v${VERSION}.zip"
fi
```

#### GitHub Actions에서 Butler 사용

```yaml
# .github/workflows/itch-deploy.yml
name: Deploy to itch.io

on:
  push:
    tags: ["v*.*.*"]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.x"

      - name: Install Butler
        run: |
          curl -L -o butler.zip https://broth.itch.ovh/butler/linux-amd64/LATEST/archive/default
          unzip butler.zip -d butler
          chmod +x butler/butler
          sudo mv butler/butler /usr/local/bin/

      - name: Build Flutter Web
        run: flutter build web --release --base-href "./"

      - name: Deploy to itch.io
        env:
          BUTLER_API_KEY: ${{ secrets.BUTLER_API_KEY }}
        run: |
          butler login --api-key $BUTLER_API_KEY
          VERSION=${GITHUB_REF#refs/tags/v}
          butler push build/web ${{ secrets.ITCH_USERNAME }}/${{ secrets.ITCH_GAME }}:web --userversion "$VERSION"
```

#### Butler의 장점과 실제 사용 경험

**장점**:

1. **자동화**: CI/CD 파이프라인에 통합 가능
2. **안정성**: itch.io에서 공식 지원하는 도구
3. **로그**: 상세한 업로드 로그 제공
   ![업로드 히스토리](https://velog.velcdn.com/images/bumkyu98/post/312b7df7-b320-42f0-b4c2-dd7e69f95fad/image.png)

**실제 사용 후기**:

```bash
# Butler 배포 로그 예시
✓ Pushing 15.2 MB (23 files, 0 dirs, 0 symlinks)
✓ Build is now processing, should be up in a bit (see itch.io page)
✓ 🌐 https://dev-kbk.itch.io/avoid-bubble

# 배포 시간: 약 2-3분 (ZIP 업로드 대비 1/3 단축)
```

**개발 효율성 향상**:

- 수동 배포 시간: 평균 10분 → Butler 자동 배포: 평균 3분
- 실수 확률: 수동 작업 시 20% → 자동화 후 1% 미만
- 버전 관리: 태그 기반으로 명확한 릴리즈 추적 가능

## 📈 개발 성과 및 배운 점

### 🎯 핵심 성과

- **크로스플랫폼 게임**: 웹, 모바일 모두 지원
- **국제화 시스템**: 한국어/영어 ARB 기반 지원
- **자동화된 배포 파이프라인**: 태그 기반 CI/CD와 Butler 연동
- **확장 가능한 아키텍처**: Component-Model 패턴으로 유지보수성 확보

### 🧠 기술적 성장

1. **Flame 엔진**: 2D 게임 개발의 전체 워크플로우 이해
2. **Flutter 고급**: ARB 국제화, 브라우저 API, 성능 최적화
3. **DevOps**: GitHub Actions, Butler CLI, 시맨틱 버저닝
4. **데이터베이스**: 대용량 데이터 마이그레이션, 등급 시스템 재설계
5. **문제 해결**: 체계적인 디버깅과 트러블슈팅 역량

## 🎮 게임 플레이해보기

**5분 생존 도전을 받아들이시겠습니까?** 😏

👉 **지금 바로 플레이**: https://dev-kbk.itch.io/avoid-bubble

- 웹 브라우저, 모바일에서 즉시 플레이
- 모바일 조이스틱 컨트롤 지원

## 🔗 프로젝트 링크

- **🎮 게임 플레이**: https://dev-kbk.itch.io/avoid-bubble
- **📂 GitHub**: [깃허브 레포](https://github.com/Kwon-Bum-Kyu/avoid_bubble)

---

## 🎯 마무리하며

이 게임을 개발하면서 정말 많은 시행착오를 겪었어요. 단순한 게임이라고 생각했는데, ~~(막상 개발해보니 욕심으로 인해..)~~ 성능 최적화, 크로스 플랫폼 호환성, 사용자 경험, 배포 자동화 등 고려해야 할 요소들이 정말 많더라고요.

[Flutter + Flame 프로젝트](https://velog.io/@bumkyu98/%EB%8B%B7%EC%A7%80-%EB%B2%84%EB%B8%94-%ED%9A%8C%EA%B3%A0)를 이전에도 진행해봤지만 완성 후 여러가지 문제(플레이 스토어 테스터 20명 모집, 애플 라이센스 비용등)로 인해 출시를 제대로 못해서 아쉬웠던 경험이 있는데 itch를 활용해서 출시한건 정말 다행이라고 생각합니다!

특히 **"5분 생존"**이라는 목표를 설정한 게 게임의 정체성을 확실히 만들어준 것 같아요. 저도 개발자인데 아직 S등급을 못 땄다는... 😅

### 🤝 오픈소스로 공개하는 이유

Flutter + Flame으로 게임 개발을 시작하려는 분들께 조금이나마 도움이 되었으면 좋겠어서 **모든 코드를 오픈소스로 공개**했습니다. 제가 겪었던 트러블슈팅 과정들이 다른 분들께는 시간 단축이 될 수 있을 거라 생각해요.

### 🚀 다음에는...

다음에도 생각했던 프로젝트가 여러개 있긴 한데 게임 보다는 다른 쪽을 도전해보고 싶기에 다음 프로젝트는 다른 것을 도전해보려고 합니다!

---

긴 글 읽어주셔서 감사합니다! 🎮
