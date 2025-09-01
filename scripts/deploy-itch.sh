#!/bin/bash

# Itch.io 배포용 스크립트
# Flutter 웹 앱을 빌드하고 itch.io용 zip 파일을 생성합니다.

set -e

echo "🎮 Itch.io 배포 스크립트 시작"

# 프로젝트 루트로 이동
cd "$(dirname "$0")/.."

# 기존 빌드 정리
echo "📁 기존 빌드 파일 정리..."
flutter clean

# Flutter 웹 빌드 (dart-define 환경변수 포함)
echo "🔨 Flutter 웹 릴리즈 빌드 중..."

# 환경변수 확인 및 빌드 옵션 설정
BUILD_ARGS="--release"

# 기본 환경변수 설정
BUILD_ARGS="$BUILD_ARGS --dart-define=ENVIRONMENT=production"
BUILD_ARGS="$BUILD_ARGS --dart-define=DEVELOPER_MODE_ENABLED=false"
BUILD_ARGS="$BUILD_ARGS --dart-define=DEBUG_INFO=false"
BUILD_ARGS="$BUILD_ARGS --dart-define=API_TIMEOUT=5000"
BUILD_ARGS="$BUILD_ARGS --dart-define=MAX_RETRIES=2"

# Supabase 설정 (환경변수로 제공된 경우)
if [ ! -z "$SUPABASE_URL" ] && [ ! -z "$SUPABASE_ANON_KEY" ]; then
    echo "🔗 Supabase 설정 감지됨"
    BUILD_ARGS="$BUILD_ARGS --dart-define=SUPABASE_URL=$SUPABASE_URL"
    BUILD_ARGS="$BUILD_ARGS --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
    echo "  - SUPABASE_URL: ${SUPABASE_URL:0:30}..."
    echo "  - SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
else
    echo "⚠️  Supabase 미설정 - 오프라인 모드로 빌드"
    echo "   온라인 랭킹 기능이 비활성화됩니다."
fi

echo "📝 빌드 설정:"
echo "  - 환경: Production"
echo "  - 개발자 모드: 비활성화"
echo "  - 디버그 정보: 비활성화"
echo ""

# 실제 빌드 실행
flutter build web $BUILD_ARGS

# 빌드 성공 확인
if [ ! -d "build/web" ]; then
    echo "❌ 빌드 실패: build/web 폴더가 없습니다."
    exit 1
fi

# itch.io 호환성 확인
echo "🔧 itch.io 호환성 확인..."
if grep -q "itch.zone\|itch.io" build/web/index.html; then
    echo "✅ 동적 base href 설정이 포함되어 있습니다."
else
    echo "⚠️  itch.io 호환성 설정을 확인할 수 없습니다."
fi

# 타임스탬프 생성
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ZIP_NAME="avoid-bubble-itch-${TIMESTAMP}.zip"

# 기존 itch 배포 zip 파일들 정리
echo "🗑️ 기존 itch 배포 파일 정리..."
rm -f avoid-bubble-itch-*.zip

# itch.io용 zip 파일 생성
echo "📦 itch.io용 zip 파일 생성 중..."
cd build/web
zip -r "../../${ZIP_NAME}" .
cd ../..

# 파일 크기 확인
FILE_SIZE=$(ls -lh "${ZIP_NAME}" | awk '{print $5}')

echo "✅ 배포 준비 완료!"
echo "📄 파일명: ${ZIP_NAME}"
echo "📏 파일크기: ${FILE_SIZE}"
echo ""
echo "🚀 itch.io 업로드 준비됨!"
echo ""
echo "📦 수동 업로드:"
echo "   1. itch.io 개발자 대시보드로 이동"
echo "   2. 게임 페이지에서 'Upload files' 클릭"
echo "   3. ${ZIP_NAME} 파일 업로드"
echo "   4. 'This file will be played in the browser' 선택"
echo ""
echo "🤖 Butler 자동 업로드:"
echo "   butler push build/web username/game:web --userversion \"${TIMESTAMP}\""
echo ""
echo "🔧 Supabase와 함께 빌드하려면:"
echo "   SUPABASE_URL=\"https://your-project.supabase.co\" \\"
echo "   SUPABASE_ANON_KEY=\"your-anon-key\" \\"
echo "   ./scripts/deploy-itch.sh"
echo ""
echo "💡 팁:"
echo "   - 오프라인 모드: 환경변수 없이 실행"
echo "   - 온라인 모드: SUPABASE_URL, SUPABASE_ANON_KEY 설정"
echo "   - Butler 설정: ./scripts/setup-butler.sh"
echo "   - CI/CD 가이드: docs/CICD_SETUP.md"
echo ""