FROM nginx:alpine

# SSL 인증서 생성을 위한 OpenSSL 설치
RUN apk add --no-cache openssl

# 디렉터리 생성
RUN mkdir -p /etc/nginx/ssl

# 자체 서명 인증서 생성 (개발용)
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=KR/ST=Seoul/L=Seoul/O=FastServe/CN=fastserve.local"

# Nginx 설정 파일 복사
COPY nginx.conf /etc/nginx/nginx.conf 