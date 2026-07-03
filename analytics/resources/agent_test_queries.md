# BigQuery Agent Verification Guide & Metadata Reference

본 문서는 Dataplex Catalog에 등록된 Custom Aspect인 **`sql-mapping` (SQL 매핑 룰셋)** 및 **`term-governance` (비즈니스 거버넌스 룰셋)** 정의와 이를 활용하여 대화형 분석 에이전트(Text-to-SQL 및 메타데이터 조회 LLM)를 검증하기 위한 상세 가이드라인입니다.

---

## 1. Custom Aspect 스키마 및 정의

비즈니스 용어집(Glossary)의 각 용어는 단순 자연어 설명을 넘어, 에이전트가 데이터 질의 및 메타 가이드를 올바르게 수행할 수 있도록 아래 두 가지 Custom Aspect 데이터를 내장하고 있습니다.

### 1.1. `sql-mapping` Aspect (SQL 매핑 룰셋)
에이전트가 자연어를 SQL로 번역할 때 오차가 없도록 테이블 및 조건 스니펫을 정의합니다.

| 필드명 (Field) | 타입 (Type) | 필수 여부 | 설명 및 활용 방식 |
| :--- | :--- | :--- | :--- |
| **`type`** | `string` | **Yes** | 매핑 종류 (`SQL_Filter`, `Node_Attribute`, `SQL_Expression`, `Web_Analytics`) |
| **`table`** | `string` | No | 매핑되는 원천 BigQuery 물리 테이블 (예: `thelook_ecommerce.users`) |
| **`condition`** | `string` | No | `SQL_Filter` 타입일 때 WHERE 절에 삽입할 조건 SQL 스니펫 |
| **`expression`** | `string` | No | `SQL_Expression` / `Web_Analytics` 타입일 때 집계 연산에 적용할 SQL 수식 |
| **`attribute`** | `string` | No | 특정 테이블의 매핑 컬럼명 (예: `traffic_source`) |

### 1.2. `term-governance` Aspect (비즈니스 거버넌스 룰셋)
용어의 소유권, 비즈니스 계산 정의, 갱신 주기 및 보안 등급을 관리하여 에이전트가 거버넌스 관련 질문에 응답할 수 있도록 합니다.

| 필드명 (Field) | 타입 (Type) | 필수 여부 | 설명 및 활용 방식 |
| :--- | :--- | :--- | :--- |
| **`owner`** | `string` | **Yes** | 해당 용어 및 데이터를 담당하는 소유자 팀의 이메일 (예: `marketing-squad@thelook.com`) |
| **`business_formula`** | `string` | No | 비즈니스 관점의 현업 사용자용 한글 수식 및 규칙 설명 |
| **`update_cycle`** | `string` | No | 원천 데이터의 적재/갱신 주기 (예: `DAILY`, `HOURLY`, `REALTIME`, `MONTHLY`) |
| **`sensitivity_level`** | `string` | No | 데이터 보안 분류 등급 (예: `PUBLIC`, `INTERNAL_ONLY`, `PII_CONFIDENTIAL`) |

---

## 2. 주요 용어별 Custom Aspect 조견표

### 2.1. SQL Mapping Aspect 조견표 (`sql-mapping`)

| 용어 ID | 용어명 (디스플레이) | 매핑 종류 (`type`) | 타겟 테이블 (`table`) | 등록된 매핑 규칙 (`condition` / `expression` / `attribute`) |
| :--- | :--- | :--- | :--- | :--- |
| **`vip-customer`** | VIP 고객 | `SQL_Filter` | `thelook_ecommerce.users` | `condition`: `id IN (SELECT user_id FROM thelook_ecommerce.order_items GROUP BY user_id HAVING SUM(sale_price) >= 500 OR COUNT(DISTINCT order_id) >= 5)` |
| **`traffic-source`** | 유입 경로 | `Node_Attribute` | `thelook_ecommerce.users` | `attribute`: `traffic_source` |
| **`churned-customer`** | 이탈 고객 | `SQL_Filter` | `thelook_ecommerce.users` | `condition`: `id NOT IN (SELECT DISTINCT user_id FROM thelook_ecommerce.orders WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY))` |
| **`newly-registered-customer`** | 신규 가입 고객 | `SQL_Filter` | `thelook_ecommerce.users` | `condition`: `created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)` |
| **`cart-abandonment-rate`** | 장바구니 포기율 | `Web_Analytics` | `thelook_ecommerce.events` | `expression`: `COUNT(DISTINCT CASE WHEN event_type = 'Cart' AND session_id NOT IN (SELECT DISTINCT session_id FROM thelook_ecommerce.events WHERE event_type = 'Purchase') THEN session_id END) / COUNT(DISTINCT CASE WHEN event_type = 'Cart' THEN session_id END) * 100` |
| **`profit-margin-rate`** | 마진율 | `SQL_Expression` | `thelook_ecommerce.products` | `expression`: `(retail_price - cost) / retail_price * 100` |
| **`returned-cancelled-items`** | 반품/취소 건 | `SQL_Filter` | `thelook_ecommerce.order_items` | `condition`: `status IN ('Returned', 'Cancelled')` |
| **`avg-shipping-lead-time`** | 평균 배송 소요 시간 | `SQL_Expression` | `thelook_ecommerce.orders` | `expression`: `AVG(TIMESTAMP_DIFF(delivered_at, shipped_at, DAY))` |
| **`return-rate`** | 취소/반품 비율 | `SQL_Expression` | `thelook_ecommerce.order_items` | `expression`: `COUNTIF(status IN ('Returned', 'Cancelled')) / COUNT(*) * 100` |

### 2.2. Term Governance Aspect 조견표 (`term-governance`)

| 용어 ID | 용어명 (디스플레이) | 담당 팀 (`owner`) | 비즈니스 공식/정의 (`business_formula`) | 갱신 주기 (`update_cycle`) | 보안 등급 (`sensitivity_level`) |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`vip-customer`** | VIP 고객 | `marketing-squad@thelook.com` | 누적 주문 총액이 500달러 이상이거나 주문 건수가 5회 이상인 고객 | `DAILY` | `INTERNAL_ONLY` |
| **`traffic-source`** | 유입 경로 | `growth-marketing@thelook.com` | 회원 가입 또는 첫 주문 세션의 마케팅 유입 채널 | `REALTIME` | `PUBLIC` |
| **`churned-customer`** | 이탈 고객 | `crm-campaign@thelook.com` | 현재 시점 기준 최근 90일 동안 주문 생성이 한 건도 없는 회원 | `DAILY` | `INTERNAL_ONLY` |
| **`newly-registered-customer`** | 신규 가입 고객 | `crm-campaign@thelook.com` | 가입일(created_at)이 최근 30일 이내인 회원 | `DAILY` | `INTERNAL_ONLY` |
| **`cart-abandonment-rate`** | 장바구니 포기율 | `product-analytics@thelook.com` | (장바구니 담기 후 결제하지 않은 세션 수) / (장바구니 담기 세션 수) * 100 | `HOURLY` | `PUBLIC` |
| **`profit-margin-rate`** | 마진율 | `finance-planning@thelook.com` | (판매 가격 - 공급 원가) / 판매 가격 * 100 | `DAILY` | `INTERNAL_ONLY` |
| **`distribution-center`** | 물류 센터 | `global-logistics@thelook.com` | 출고 및 배송 거점 정보 테이블 마스터 데이터 | `MONTHLY` | `PUBLIC` |
| **`returned-cancelled-items`** | 반품/취소 건 | `global-logistics@thelook.com` | 배송 상태(status)가 Returned 또는 Cancelled인 주문 아이템 건 수 | `REALTIME` | `INTERNAL_ONLY` |
| **`avg-shipping-lead-time`** | 평균 배송 소요 시간 | `delivery-partnership@thelook.com` | 배송 완료일(delivered_at)과 배송 시작일(shipped_at)의 날짜 차이에 대한 평균 일수 | `DAILY` | `PUBLIC` |
| **`return-rate`** | 취소/반품 비율 | `delivery-partnership@thelook.com` | (취소 및 반품 아이템 수) / (전체 주문 아이템 수) * 100 | `DAILY` | `PUBLIC` |

---

## 3. 대화형 분석 에이전트 검증 시나리오

### 3.1. Text-to-SQL 변역 검증 (Relational DB 질의)

#### Q1. [동의어 역맵핑 & SQL Filter 결합] 우수 고객 집계
* **자연어 질문:** `"지난 달에 주문 이력이 존재하는 우수 고객은 총 몇 명인가요?"`
* **에이전트 매핑 경로:**
  1. `우수 고객` (동의어) $\rightarrow$ `VIP 고객` (용어 ID: `vip-customer`) 매핑
  2. `VIP 고객 (ID: vip-customer)` 에 등록된 `sql-mapping` 스키마 획득
  3. `condition` 필터 조건문을 WHERE 절에 결합
* **예상 결과 SQL:**
  ```sql
  SELECT COUNT(DISTINCT u.id) AS vip_user_count
  FROM `your-project-id.thelook_ecommerce.users` u
  JOIN `your-project-id.thelook_ecommerce.orders` o ON u.id = o.user_id
  WHERE u.id IN (
    -- 💡 Dataplex Aspect에서 추출된 VIP 고객 필터 스니펫 주입
    SELECT user_id 
    FROM `your-project-id.thelook_ecommerce.order_items` 
    GROUP BY user_id 
    HAVING SUM(sale_price) >= 500 OR COUNT(DISTINCT order_id) >= 5
  )
  AND o.created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);
  ```

#### Q2. [웹 로그 분석 & 마케팅 속성 결합] 채널별 장바구니 포기 트렌드
* **자연어 질문:** `"유입 마케팅 채널별로 장바구니 이탈율을 계산해서 이탈율이 높은 순으로 정렬해줘."`
* **에이전트 매핑 경로:**
  1. `마케팅 채널` $\rightarrow$ `유입 경로` (용어 ID: `traffic-source`) $\rightarrow$ `users.traffic_source`
  2. `장바구니 이탈율` $\rightarrow$ `장바구니 포기율` (용어 ID: `cart-abandonment-rate`)
  3. `장바구니 포기율 (ID: cart-abandonment-rate)` 에 정의된 계산 `expression` 추출 및 적용
* **예상 결과 SQL:**
  ```sql
  SELECT 
    u.traffic_source AS marketing_channel,
    -- 💡 Dataplex Aspect에서 추출된 세션 기반 이탈율 공식 주입
    COUNT(DISTINCT CASE WHEN e.event_type = 'Cart' AND e.session_id NOT IN (
      SELECT DISTINCT session_id 
      FROM `your-project-id.thelook_ecommerce.events` 
      WHERE event_type = 'Purchase'
    ) THEN e.session_id END) / 
    COUNT(DISTINCT CASE WHEN e.event_type = 'Cart' THEN e.session_id END) * 100 AS cart_abandonment_rate
  FROM `your-project-id.thelook_ecommerce.events` e
  JOIN `your-project-id.thelook_ecommerce.users` u ON e.user_id = u.id
  GROUP BY marketing_channel
  ORDER BY cart_abandonment_rate DESC;
  ```

#### Q3. [복합 룰 결합] 마진율 및 환불률 분석
* **자연어 질문:** `"여성 의류 중에서 상품 마진이 40% 이상인 제품들의 환불률을 브랜드별로 계산해줘."`
* **에이전트 매핑 경로:**
  1. `상품 마진` $\rightarrow$ `마진율` (용어 ID: `profit-margin-rate`) $\rightarrow$ `expression` 필터화
  2. `환불률` $\rightarrow$ `취소/반품 비율` (용어 ID: `return-rate`) $\rightarrow$ `expression` 집계화
* **예상 결과 SQL:**
  ```sql
  SELECT 
    p.brand,
    -- 💡 취소/반품 비율 집계식 적용
    COUNTIF(oi.status IN ('Returned', 'Cancelled')) / COUNT(*) * 100 AS refund_rate
  FROM `your-project-id.thelook_ecommerce.order_items` oi
  JOIN `your-project-id.thelook_ecommerce.products` p ON oi.product_id = p.id
  WHERE p.category = 'Women'
    -- 💡 마진율 공식 필터링 적용
    AND ((p.retail_price - p.cost) / p.retail_price * 100) >= 40
  GROUP BY p.brand
  ORDER BY refund_rate DESC;
  ```

#### Q4. [부정 조건 및 속성 결합] 휴면 고객 유입 분포
* **자연어 질문:** `"휴면 고객들이 가장 많이 유입되었던 가입 경로 3가지는 무엇인가요?"`
* **에이전트 매핑 경로:**
  1. `휴면 고객` $\rightarrow$ `이탈 고객` (용어 ID: `churned-customer`) $\rightarrow$ `condition` 부정 필터 적용
  2. `가입 경로` $\rightarrow$ `유입 경로` (용어 ID: `traffic-source`) $\rightarrow$ `users.traffic_source`
* **예상 결과 SQL:**
  ```sql
  SELECT 
    traffic_source AS signup_channel,
    COUNT(*) AS user_count
  FROM `your-project-id.thelook_ecommerce.users`
  WHERE id NOT IN (
    -- 💡 최근 90일간 주문 기록이 존재하지 않는 이탈 필터 삽입
    SELECT DISTINCT user_id 
    FROM `your-project-id.thelook_ecommerce.orders` 
    WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  )
  GROUP BY signup_channel
  ORDER BY user_count DESC
  LIMIT 3;
  ```

---

### 3.2. 메타데이터 조회 및 거버넌스 질의 검증 (Metadata Lookup)

#### Q5. [소유권 및 보안 식별] 데이터 담당 부서 및 등급 정보 조회
* **자연어 질문:** `"장바구니 포기율의 담당 부서(Owner)와 데이터 보안 등급은 무엇인가요?"`
* **에이전트 검증 동작:**
  1. 자연어의 **"장바구니 포기율"**을 용어 ID `cart-abandonment-rate`로 검색
  2. 해당 용어에 바인딩된 `term-governance` Aspect 데이터를 조회
  3. `owner` 및 `sensitivity_level` 속성값을 바탕으로 정보 안내
* **예상 답변:**
  > 장바구니 포기율(`cart-abandonment-rate`)의 데이터 담당 부서는 **`product-analytics@thelook.com`**이며, 보안 등급은 **`PUBLIC`** (전체 공개 가능)으로 정의되어 있습니다.

#### Q6. [비즈니스 수식 조회] 지표 계산 로직 조회
* **자연어 질문:** `"마진율과 취소/반품 비율의 현업 공식 정의를 보여주세요."`
* **에이전트 검증 동작:**
  1. 자연어 **"마진율"** 및 **"취소/반품 비율"**을 각각 `profit-margin-rate` 및 `return-rate`로 식별
  2. 각 용어의 `term-governance` Aspect에서 `business_formula` 값을 추출
* **예상 답변:**
  > 해당 지표들의 현업 공식 정의는 다음과 같습니다:
  > * **마진율**: `(판매 가격 - 공급 원가) / 판매 가격 * 100` (소유자: `finance-planning@thelook.com`)
  > * **취소/반품 비율**: `(취소 및 반품 아이템 수) / (전체 주문 아이템 수) * 100` (소유자: `delivery-partnership@thelook.com`)
