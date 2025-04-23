#!/bin/bash

# 사용법 확인
if [ $# -lt 1 ]; then
    echo "사용법: $0 [서비스 이름] [옵션]"
    echo "예시: $0 spring-tomcat"
    echo "예시: $0 go-fiber --http2"
    echo "서비스 이름: spring-tomcat, spring-netty, node-express, node-fastify, go-nethttp, go-fiber, python-flask, python-fastapi, rust-actix, rust-axum, cpp-pistache, csharp-aspnet"
    exit 1
fi

SERVICE=$1
HTTP_VER="http"
PORT=80
ENDPOINT="api/compute"
DURATION=30
CONNECTIONS=100
THREADS=4

# HTTP/2 사용 설정
if [[ "$*" == *--http2* ]]; then
    HTTP_VER="https"
    PORT=443
    echo "HTTP/2 활성화 (HTTPS 사용)"
fi

# 서비스별 엔드포인트 설정
SERVICE_PATH="/${SERVICE}"
SERVICE_URL="${HTTP_VER}://localhost:${PORT}${SERVICE_PATH}/${ENDPOINT}"

echo "========================================================"
echo "🚀 FastServe 벤치마크 시작: ${SERVICE}"
echo "========================================================"
echo "테스트 URL: ${SERVICE_URL}"
echo "실행 시간: ${DURATION}초"
echo "동시 연결: ${CONNECTIONS}"
echo "스레드 수: ${THREADS}"
echo "HTTP 버전: ${HTTP_VER}"
echo "========================================================"

# wrk를 사용한 벤치마크 실행
if command -v wrk &> /dev/null; then
    echo "wrk를 사용하여 벤치마크 실행..."
    
    if [[ "$HTTP_VER" == "https" ]]; then
        wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION}s --latency -H "Connection: keep-alive" --timeout 2s ${SERVICE_URL}
    else
        wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION}s --latency -H "Connection: keep-alive" --timeout 2s ${SERVICE_URL}
    fi
    
    echo "wrk 벤치마크 완료!"
else
    echo "wrk가 설치되어 있지 않습니다. 설치 후 다시 시도하세요."
    echo "macOS: brew install wrk"
    echo "Ubuntu: apt install wrk"
fi

echo "========================================================"
echo "📊 벤치마크 결과 저장 중..."

# 결과 디렉토리 생성
RESULT_DIR="../result-graphs"
mkdir -p ${RESULT_DIR}

# 타임스탬프로 결과 파일 이름 생성
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
RESULT_FILE="${RESULT_DIR}/${SERVICE}_${HTTP_VER}_${TIMESTAMP}.txt"

# 실행 결과를 파일로 저장
if command -v wrk &> /dev/null; then
    wrk -t${THREADS} -c${CONNECTIONS} -d${DURATION}s --latency -H "Connection: keep-alive" --timeout 2s ${SERVICE_URL} > ${RESULT_FILE}
    
    echo "결과가 다음 파일에 저장되었습니다: ${RESULT_FILE}"
fi

echo "========================================================"
echo "✅ 벤치마크 완료: ${SERVICE}"
echo "========================================================" 