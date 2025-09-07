#!/bin/bash

# Chrome 개발 모드 실행 스크립트 (Hot Reload + Supabase)
# 사용법: ./run_chrome_dev.sh

echo "🚀 Chrome 개발 모드로 Flutter 앱 실행 중..."

# 기본 환경변수 설정
ENVIRONMENT="development"
DEVELOPER_MODE_ENABLED="true" 
DEBUG_INFO="true"

# 환경 파일에서 Supabase 설정 로드 시도
ENV_FILES=(".env" ".env.development" "assets/env/.env" "assets/env/.env.development")

echo "🔍 환경 파일 검사 중..."

for env_file in "${ENV_FILES[@]}"; do
    if [ -f "$env_file" ]; then
        echo "  📁 $env_file 발견됨"
        
        # 환경 파일에서 Supabase 설정 추출
        if [ -z "$SUPABASE_URL" ]; then
            SUPABASE_URL=$(grep "^SUPABASE_URL=" "$env_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'" | xargs)
        fi
        
        if [ -z "$SUPABASE_ANON_KEY" ]; then
            SUPABASE_ANON_KEY=$(grep "^SUPABASE_ANON_KEY=" "$env_file" 2>/dev/null | cut -d'=' -f2- | tr -d '"' | tr -d "'" | xargs)
        fi
        
        # 디버깅: 추출된 값 확인 (개발 시에만 활성화)
        # echo "    DEBUG - URL: '${SUPABASE_URL}'"
        # echo "    DEBUG - KEY: '${SUPABASE_ANON_KEY:0:20}...'"
        
        # 값이 모두 찾아졌으면 더 이상 검사하지 않음
        if [ ! -z "$SUPABASE_URL" ] && [ ! -z "$SUPABASE_ANON_KEY" ]; then
            echo "  ✅ $env_file 에서 Supabase 설정 로드됨"
            break
        fi
    fi
done

if [ -z "$SUPABASE_URL" ] && [ -z "$SUPABASE_ANON_KEY" ]; then
    echo "  ⚠️ 환경 파일에서 Supabase 설정을 찾을 수 없음"
fi

echo ""
echo "📝 개발 환경 설정:"
echo "  - ENVIRONMENT: $ENVIRONMENT"
echo "  - DEVELOPER_MODE: $DEVELOPER_MODE_ENABLED"
echo "  - DEBUG_INFO: $DEBUG_INFO"
echo "  - Hot Reload: 활성화"

# Supabase 설정 확인 (빈 문자열이 아니고 더미 값도 아닌 경우)
if [ ! -z "$SUPABASE_URL" ] && [ ! -z "$SUPABASE_ANON_KEY" ] && \
   [ "$SUPABASE_URL" != "https://your-project-id.supabase.co" ] && \
   [ "$SUPABASE_ANON_KEY" != "your-anon-key-here" ]; then
    echo "  - 🔗 Supabase: 온라인 모드"
    echo "  - SUPABASE_URL: ${SUPABASE_URL:0:30}..."
    echo "  - SUPABASE_ANON_KEY: ${SUPABASE_ANON_KEY:0:20}..."
    
    # Supabase 포함 실행
    flutter run -d chrome \
        --web-experimental-hot-reload \
        --dart-define=ENVIRONMENT="$ENVIRONMENT" \
        --dart-define=DEVELOPER_MODE_ENABLED="$DEVELOPER_MODE_ENABLED" \
        --dart-define=DEBUG_INFO="$DEBUG_INFO" \
        --dart-define=SUPABASE_URL="$SUPABASE_URL" \
        --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY"
else
    echo "  - ⚠️ Supabase: 오프라인 모드"
    echo "     (온라인 랭킹 기능 비활성화)"
    
    # 오프라인 모드 실행
    flutter run -d chrome \
        --web-experimental-hot-reload \
        --dart-define=ENVIRONMENT="$ENVIRONMENT" \
        --dart-define=DEVELOPER_MODE_ENABLED="$DEVELOPER_MODE_ENABLED" \
        --dart-define=DEBUG_INFO="$DEBUG_INFO"
fi