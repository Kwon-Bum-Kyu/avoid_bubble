#!/bin/bash

echo "🚀 Starting production build process..."

# .env 파일 백업 및 프로덕션 모드 설정
echo "📝 Setting up production environment..."
cp .env .env.backup
cp .env.production .env

echo "🔍 Current environment settings:"
cat .env

# 의존성 업데이트
echo "📦 Updating dependencies..."
flutter clean
flutter pub get

echo "🔨 Building for multiple platforms..."

# 웹 빌드
echo "🌐 Building for Web..."
flutter build web --release

# 빌드 확인
echo "🔍 Checking build..."
if [ -f "build/web/main.dart.js" ]; then
    echo "✅ Web build successful"
else
    echo "❌ Web build failed"
    exit 1
fi

# Android APK 빌드  
echo "📱 Building Android APK..."
flutter build apk --release

# Android App Bundle 빌드 (선택사항)
echo "📦 Building Android App Bundle..."
flutter build appbundle --release

# Linux 빌드 (macOS에서는 선택사항)
echo "🖥️  Building for Linux..."
flutter build linux --release

# .env 파일 복구
echo "🔄 Restoring development environment..."
mv .env.backup .env

echo "✅ Production build completed!"
echo "📂 Build outputs:"
echo "   - Web: build/web/"
echo "   - Android APK: build/app/outputs/flutter-apk/"
echo "   - Android AAB: build/app/outputs/bundle/release/"
echo "   - Linux: build/linux/x64/release/bundle/"

echo ""
echo "⚠️  Important: The production build has developer features DISABLED"
echo "   - No invincible mode"
echo "   - No pattern timing controls"
echo "   - No game difficulty adjustments"