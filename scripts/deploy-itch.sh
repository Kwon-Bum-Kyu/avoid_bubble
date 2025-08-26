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

# Flutter 웹 빌드
echo "🔨 Flutter 웹 릴리즈 빌드 중..."
flutter build web --release

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
echo "   1. itch.io 개발자 대시보드로 이동"
echo "   2. 게임 페이지에서 'Upload files' 클릭"
echo "   3. ${ZIP_NAME} 파일 업로드"
echo "   4. 'This file will be played in the browser' 선택"
echo ""