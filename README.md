# 📅 Today (오늘) - 차세대 하이브리드 일정 관리 플랫폼

**"당신의 일정, 당신의 방식대로 — 오프라인의 독립성과 온라인의 연결성을 하나로."**

**Today**는 개인의 프라이버시를 최우선으로 하는 **Offline-First** 아키텍처 기반의 일정 관리 애플리케이션입니다. 인터넷 연결 없이도 즉시 사용 가능한 빠른 반응성을 제공하며, 필요 시 클라우드 동기화를 통해 타인과의 일정 조율을 매끄럽게 지원합니다.

---

## 🚀 핵심 기능 (Key Features)

### 1. ⚡ 오프라인 퍼스트 (Offline First) - 무제한 로컬 일정 관리
- 로그인이나 인터넷 연결 없이 앱 설치 즉시 일정 관리를 시작할 수 있습니다.
- 모든 데이터는 **Isar (NoSQL DB)**를 통해 로컬 기기에 안전하게 암호화되어 저장됩니다.
- 비행기 모드나 데이터가 없는 환경에서도 완벽하게 동작합니다.

### 2. ☁️ 하이브리드 클라우드 동기화 (Premium)
- 구독 시 오프라인 데이터를 클라우드 서버와 동기화합니다.
- 스마트폰, 태블릿, PC 등 여러 기기에서 실시간으로 일정을 관리할 수 있습니다.
- 기기 분실 시에도 계정 로그인을 통해 데이터를 안전하게 복구할 수 있습니다.

### 3. 🤝 소셜 일정 조율 & 빈틈 찾기 (Conflict Detection)
- 친구의 구체적인 일정 내용은 숨기면서, '가능한 시간'과 '바쁜 시간'만 시각적으로 보여줍니다.
- 일일이 "시간 돼?"라고 물어볼 필요 없이, 서로의 빈 시간을 찾아 약속(Appointment)을 제안할 수 있습니다.
- 프라이버시를 지키면서도 사회적인 연결을 놓치지 않는 스마트한 예약 시스템을 제공합니다.

---

## 💼 비즈니스 모델 (Business Model)

**전략: Freemium (부분 유료화)**

| 티어 (Tier) | 가격 | 주요 기능 | 타겟 유저 |
| :--- | :--- | :--- | :--- |
| **Free (기본)** | 무료 | 무제한 로컬 일정 생성, 캘린더 뷰, 광고 없음 | 데이터 프라이버시 중시, 가벼운 사용자 |
| **Premium (구독)** | 월 5,900원 | 초 단위 클라우드 동기화, 친구와 일정 공유, 데이터 백업 | 멀티 디바이스 사용자, 커플, 팀 |

- **수익 구조:** 무료 사용자로 트래픽과 신뢰를 확보한 후, **"데이터 백업"**과 **"친구와의 공유"** 니즈가 발생할 때 자연스럽게 구독으로 유도합니다. (첫 달 무료 체험 제공)

---

## 🏗️ 기술 스택 및 인프라 (Tech Stack & Infrastructure)

### 📱 Client (Mobile)
- **Framework:** Flutter (Cross-platform)
- **Language:** Dart
- **Architecture:** Clean Architecture + DDD (Domain Driven Design)
- **State Management:** Riverpod 2.0 (Code Generation, Annotation)
- **Local Database:** Isar (High-performance NoSQL)
- **Functional Programming:** fpdart (Either 타입을 통한 견고한 에러 핸들링)
- **Networking:** Dio (Interceptor, Retry Logic)
- **Sync/Background:** Workmanager, Background Fetch

### 🖥️ Server (Backend)
- **Framework:** Spring Boot
- **Language:** Java 21
- **Security:** Spring Security, OAuth 2.0 (Google, Kakao, Discord), JWT (Access/Refresh Rotation)
- **Database:** MySQL (AWS RDS), Redis (Caching)
- **Infra:** AWS (EC2, S3), Docker

---

## 💡 기술적 고민과 해결 (Technical Challenges)

### 1. 🔄 오프라인-온라인 데이터 동기화 (Data Synchronization)
**Challenge:** 사용자가 오프라인 상태에서 수정한 데이터와 서버의 데이터가 충돌할 때 어떻게 처리할 것인가?
- **Solution:** 
    - **Dirty Flag & Soft Delete:** 로컬 DB에 `is_synced`, `last_modified` 필드를 두어 변경 사항을 추적합니다. 삭제 시에도 데이터를 즉시 지우지 않고 `is_deleted` 마킹을 통해 서버에 삭제 상태를 전파합니다.
    - **Conflict Resolution (Last Write Wins):** 기본적으로 마지막 수정 시간을 기준으로 충돌을 해결하되, 서버 시간을 'Authority(권위)'로 인정하여 시계 오차 문제를 최소화했습니다.
    - **Migration Logic:** 비로그인 상태(Guest)에서 쌓인 로컬 데이터를 로그인 시 서버 계정으로 이관하는 'Bulk Upload' 마이그레이션 로직을 구현하여 데이터 유실 없는 전환을 보장했습니다.

### 2. 🧱 Clean Architecture & DDD 적용
**Challenge:** 복잡해지는 앱의 비즈니스 로직과 UI 코드를 어떻게 분리하고 유지보수성을 높일 것인가?
- **Solution:** 
    - **Layered Architecture:** `Presentation`, `Domain`, `Data` 레이어를 철저히 분리했습니다.
    - **Use Cases:** 각 기능을 명확한 유스케이스 단위로 캡슐화하여 비즈니스 로직의 재사용성을 높였습니다.
    - **Entity vs Model:** 도메인 엔티티(순수 로직)와 데이터 모델(DB/JSON 매핑)을 분리하여 외부 라이브러리 의존성을 도메인 로직에서 제거했습니다.

### 3. ✅ 함수형 프로그래밍을 통한 에러 처리
**Challenge:** 런타임 예외(Exception)로 인한 앱 비정상 종료를 어떻게 방지할 것인가?
- **Solution:** `fpdart`의 `Either<Failure, Success>` 패턴을 도입했습니다. 예외를 던지는(Throw) 대신 에러 객체를 값으로 리턴(Return)함으로써, 컴파일 단계에서 에러 처리 누락을 방지하고 예측 가능한 코드 흐름을 만들었습니다.
