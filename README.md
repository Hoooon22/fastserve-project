# FastServe Project

## 🎯 프로젝트 목표

다양한 언어와 서버 구조에서 동일한 기능을 구현하고 성능을 측정하여, 웹 서버의 구조적 특성과 최적화 방법을 체계적으로 비교·분석하는 것을 목표로 합니다.

### 주요 목표:

1. **성능 최적화 역량 강화**
   - 다양한 기술 조합의 성능 차이를 실제 데이터로 검증
   - 웹 서버 튜닝 요소(gzip, keep-alive, HTTP 버전, 캐시 전략 등)에 대한 실전 지식 습득

2. **기술 스택 비교 및 분석**
   - Spring Boot, Node.js, Go, Python 등 주요 백엔드 기술의 성능 특성 이해
   - 각 언어/프레임워크의 장단점을 성능 지표와 함께 문서화

3. **부하 테스트 및 모니터링 시스템 구축**
   - wrk, k6를 활용한 체계적인 부하 테스트 설계
   - Grafana, Prometheus 기반의 성능 측정 및 시각화 환경 구성

4. **실전 DevOps 역량 개발**
   - Docker 기반의 일관된 테스트 환경 구성
   - Nginx 프록시, Redis 캐시 서버 등 실제 서비스 아키텍처 구현
   - 멀티 컨테이너 환경에서의 서비스 통합 및 최적화

5. **데이터 기반 의사결정 능력 강화**
   - 실험 결과를 바탕으로 한 기술 선택 논리 개발
   - 성능 테스트 결과와 코드를 체계적으로 정리하여 기술적 통찰력 증명

## 🧩 공통 테스트 API 설계

모든 프레임워크에서 동일한 기능을 구현하여 공정한 비교를 할 수 있도록 표준화된 API 엔드포인트를 설계했습니다.

| API 엔드포인트 | 설명 | 테스트 목적 | 요청 방식 |
|----------------|------|------------|-----------|
| GET /api/compute | CPU 연산 부하 테스트 (피보나치 계산) | CPU 처리 성능 | GET |
| GET /api/cache | 자주 쓰는 데이터 캐시 후 반환 | 캐시 hit/miss 속도 차이 | GET |
| GET /api/db | DB에서 무작위 레코드 조회 | DB I/O 성능 | GET |
| GET /api/health | "ok" 텍스트 반환 | 기본 헬스 체크 / 응답 속도 최소 측정 | GET |

### 🔧 각 API 상세 설계

#### 1. /api/compute
- **설명**: CPU 부하를 주기 위한 계산 처리 (피보나치 40번째 계산)
- **요구사항**: 순수 계산 기반 (I/O 없음)
- **예시 결과**:
  ```json
  {
    "input": 40,
    "result": 102334155,
    "elapsedMs": 184
  }
  ```

#### 2. /api/cache
- **설명**: 일정한 요청이 들어왔을 때 캐시를 이용해서 빠르게 반환
- **요구사항**: 캐시가 없으면 "DB 요청" 흉내 내기 (2초 sleep 등), 이후 캐싱
- **캐시 종류**: Redis / In-memory(Caffeine, Map 등)
- **예시 결과**:
  ```json
  {
    "source": "cache",
    "value": "This is a cached response",
    "cachedAt": "2025-04-22T23:00:00"
  }
  ```

#### 3. /api/db
- **설명**: DB에서 무작위로 하나의 데이터 조회
- **요구사항**:
  - DB 테이블: quotes (id, author, content)
  - 1000개 더미 데이터 생성
- **예시 결과**:
  ```json
  {
    "id": 372,
    "author": "Albert Einstein",
    "content": "Imagination is more important than knowledge."
  }
  ```

#### 4. /api/health
- **설명**: 단순 "ok" 텍스트 반환 (헬스 체크 및 부하 없을 때 성능 측정용)
- **예시 결과**: `ok`

### 🎯 API 활용 실험 방식

| 테스트 목적 | 대상 API | 실험 방식 |
|------------|---------|-----------|
| CPU 부하 처리 성능 | /api/compute | 1000명 동시 요청 |
| 캐시 처리 속도 차이 | /api/cache | 캐시 전/후 응답 시간 비교 |
| DB I/O 성능 | /api/db | Pool 설정 변경하며 부하 테스트 |
| 최소 오버헤드 측정 | /api/health | 가장 가벼운 요청으로 기본 처리 시간 확인 |

## 💻 프로젝트 구조

```
fastserve-project/
├── README.md
├── benchmark-scripts/     # 벤치마크 테스트 스크립트
├── result-graphs/         # 결과 그래프 및 시각화 자료
├── prometheus/            # Prometheus 설정
├── grafana/               # Grafana 대시보드 설정
├── spring-tomcat/         # Java Spring Boot (Tomcat)
├── spring-netty/          # Java Spring Boot (Netty/WebFlux)
├── node-express/          # Node.js Express
├── node-fastify/          # Node.js Fastify
├── go-nethttp/            # Go 표준 net/http
├── go-fiber/              # Go Fiber
├── python-flask/          # Python Flask
├── python-fastapi/        # Python FastAPI
├── rust-actix/            # Rust Actix-web
├── rust-axum/             # Rust Axum
├── cpp-pistache/          # C++ Pistache
├── csharp-aspnet/         # C# ASP.NET Core
├── nginx-proxy/           # Nginx 리버스 프록시
└── docker-compose.yml     # Docker Compose 설정
```

## 🧪 실험 조합

| 언어 | 프레임워크 / 서버 | 실험 목적 |
|------|--------------------|-----------|
| **Java** | Spring Boot + Tomcat (기본 내장) | 동기 방식, 실제 사용률 1위, 기본 성능 비교 기준 |
|        | Spring Boot + Netty (WebFlux) | 논블로킹 처리 방식 성능 비교, 리액티브 특성 확인 |
| **Node.js** | Express | 가장 널리 쓰이는 Node 프레임워크, 기본 성능 확인 |
|           | Fastify | Express 대비 고성능 구조 비교 |
| **Go** | net/http (표준) | 최소 구성 서버, 효율적인 쓰레드 모델 확인 |
|       | Fiber | 매우 빠른 성능의 Express-like 프레임워크 |
| **Python** | Flask | 단순하고 가벼운 서버 구조, 처리량 확인 |
|           | FastAPI | 비동기 처리 기반, Flask보다 빠른 성능 확인 |
| **Rust** | Actix-web | 최고 수준의 처리 성능, 안전성과 성능 조합 |
|         | Axum | Tokio 기반, 구조적이고 현대적인 프레임워크 |
| **C++** | Pistache | 최저 수준 제어 가능, 고성능 실험용 |
| **C#** | ASP.NET Core | .NET 플랫폼 기반 서버, GC 기반 성능 확인 |

## 🔄 추가 실험 구성 요소

| 실험 요소 | 설명 |
|-----------|------|
| **Nginx Reverse Proxy** | gzip, keep-alive, HTTP/2 설정 ON/OFF 비교 |
| **Redis / Caffeine 캐시** | 캐시 적용 시 응답 시간 및 부하 변화 확인 |
| **MySQL / SQLite DB** | DB I/O에 따른 병목 분석 실험 |
| **wrk, k6, ApacheBench** | 다양한 부하 테스트 도구 사용 |
| **Grafana + Prometheus** | 리소스 사용량 및 응답 시간 시각화 |

## 🚀 시작하기

### 전체 환경 실행
```bash
docker-compose up -d
```

### 개별 서비스 실행
```bash
docker-compose up -d spring-tomcat
docker-compose up -d go-fiber
# 등등
```

### 벤치마크 실행
```bash
cd benchmark-scripts
./run-benchmark.sh spring-tomcat
```

## 📊 성능 테스트 결과

아직 테스트가 진행되지 않았습니다. 테스트 완료 후 결과가 여기에 추가될 예정입니다.

## 📝 라이센스

MIT
