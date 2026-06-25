# BigQuery Agent Verification Guide & Physical Mapping Reference

본 문서는 Dataplex Catalog의 Custom Aspect인 **`physical-mapping` (물리 매핑 룰셋)** 정의와 이를 활용하여 대화형 분석 에이전트(Text-to-SQL LLM)를 검증하기 위한 상세 가이드라인입니다.

---

## 1. `physical-mapping` Aspect 스키마 및 활용 가이드

Dataplex Catalog에 등록된 비즈니스 용어는 자연어 설명 외에도 아래와 같이 구조화된 물리 매핑 정보를 Aspect 데이터로 포함하고 있습니다. 이를 활용하여 에이전트가 100% 일관되고 올바른 SQL을 작성하도록 가이드합니다.

| 필드명 (Field) | 타입 (Type) | 필수 여부 | 설명 및 활용 방식 |
| :--- | :--- | :--- | :--- |
| **`type`** | `string` | **Yes** | 매핑 종류 (`SQL_Filter`, `Node_Attribute`, `SQL_Expression`, `Graph_Node`, `Graph_Edge`, `Graph_Path`, `Web_Analytics`) |
| **`table`** | `string` | No | 매핑되는 원천 BigQuery 물리 테이블 (예: `thelook_ecommerce.users`) |
| **`condition`** | `string` | No | `SQL_Filter` 타입일 때 WHERE 절 혹은 서브쿼리 필터에 삽입할 조건 스니펫 |
| **`expression`** | `string` | No | `SQL_Expression` / `Web_Analytics` 타입일 때 집계 연산에 적용할 SQL 수식 |
| **`attribute`** | `string` | No | 특정 노드나 테이블의 매핑 컬럼명 (예: `traffic_source`) |
| **`label`** | `string` | No | 그래프 분석용 노드/엣지 레이블 식별자 (예: `DistributionCenter`) |
| **`pattern`** | `string` | No | `Graph_Path` 분석을 위한 그래프 경로 매칭 패턴 (Cypher 형식) |

---

## 2. 주요 용어별 물리 매핑 룰셋 조견표 (Relational / Hybrid)

| 용어 ID | 용어명 (디스플레이) | 매핑 종류 (`type`) | 타겟 테이블 (`table`) | 등록된 매핑 규칙 (`condition` / `expression` / `attribute`) |
| :--- | :--- | :--- | :--- | :--- |
| **`vip-customer`** | VIP 고객 | `SQL_Filter` | `thelook_ecommerce.users` | `condition`: `id IN (SELECT user_id FROM thelook_ecommerce.order_items GROUP BY user_id HAVING SUM(sale_price) >= 500 OR COUNT(DISTINCT order_id) >= 5)` |
| **`traffic-source`** | 유입 경로 | `Node_Attribute` | `thelook_ecommerce.users` | `attribute`: `traffic_source` |
| **`churned-customer`** | 이탈 고객 | `SQL_Filter` | `thelook_ecommerce.users` | `condition`: `id NOT IN (SELECT DISTINCT user_id FROM thelook_ecommerce.orders WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY))` |
| **`newly-registered-customer`** | 신규 가입 고객 | `SQL_Filter` | `thelook_ecommerce.users` | `condition`: `created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY)` |
| **`cart-abandonment-rate`** | 장바구니 포기율 | `Web_Analytics` | `thelook_ecommerce.events` | `expression`: `COUNT(DISTINCT CASE WHEN event_type = 'Cart' AND session_id NOT IN (SELECT DISTINCT session_id FROM thelook_ecommerce.events WHERE event_type = 'Purchase') THEN session_id END) / COUNT(DISTINCT CASE WHEN event_type = 'Cart' THEN session_id END) * 100` |
| **`profit-margin-rate`** | 마진율 | `SQL_Expression` | `thelook_ecommerce.products` | `expression`: `(retail_price - cost) / retail_price * 100` |
| **`distribution-center`** | 물류 센터 | `Graph_Node` | `thelook_ecommerce.distribution_centers` | `label`: `DistributionCenter` |
| **`returned-cancelled-items`** | 반품/취소 건 | `SQL_Filter` | `thelook_ecommerce.order_items` | `condition`: `status IN ('Returned', 'Cancelled')` |
| **`avg-shipping-lead-time`** | 평균 배송 소요 시간 | `SQL_Expression` | `thelook_ecommerce.orders` | `expression`: `AVG(TIMESTAMP_DIFF(delivered_at, shipped_at, DAY))` |
| **`return-rate`** | 취소/반품 비율 | `SQL_Expression` | `thelook_ecommerce.order_items` | `expression`: `COUNTIF(status IN ('Returned', 'Cancelled')) / COUNT(*) * 100` |

---

## 3. 대화형 분석 검증 시나리오 및 예상 SQL (Q1 - Q4)

### Q1. [동의어 역맵핑 & SQL Filter 결합] 우수 고객 집계
* **자연어 질문:** `"지난 달에 주문 이력이 존재하는 우수 고객은 총 몇 명인가요?"`
* **에이전트 매핑 경로:**
  1. `우수 고객` (동의어) $\rightarrow$ `VIP 고객` (용어 ID: `vip-customer`) 매핑
  2. `VIP 고객 (ID: vip-customer)` 에 등록된 `physical-mapping` 스키마 획득
  3. `condition` 필터 조건문을 WHERE 절에 결합
* **예상 결과 SQL:**
  ```sql
  SELECT COUNT(DISTINCT u.id) AS vip_user_count
  FROM `junho-preview-playground.thelook_ecommerce.users` u
  JOIN `junho-preview-playground.thelook_ecommerce.orders` o ON u.id = o.user_id
  WHERE u.id IN (
    -- 💡 Dataplex Aspect에서 추출된 VIP 고객 필터 스니펫 주입
    SELECT user_id 
    FROM `junho-preview-playground.thelook_ecommerce.order_items` 
    GROUP BY user_id 
    HAVING SUM(sale_price) >= 500 OR COUNT(DISTINCT order_id) >= 5
  )
  AND o.created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);
  ```

### Q2. [웹 로그 분석 & 마케팅 속성 결합] 채널별 장바구니 포기 트렌드
* **자연어 질문:** `"유입 마케팅 채널별로 장바구니 이탈율을 계산해서 이탈율이 높은 순으로 정렬해줘."`
* **에이전트 매핑 경로:**
  1. `마케팅 채널` $\rightarrow$ `유입 경로` (용어 ID: `traffic-source`) $\rightarrow$ `users.traffic_source`
  2. `장바구니 이탈율` $\rightarrow$ `장바구니 포기율` (용어 ID: `cart-abandonment-rate`)
  3. `장바구니 포기율 (ID: cart-abandonment-rate)` 에 정의된 복잡한 로그 계산 `expression` 추출 및 적용
* **예상 결과 SQL:**
  ```sql
  SELECT 
    u.traffic_source AS marketing_channel,
    -- 💡 Dataplex Aspect에서 추출된 세션 기반 이탈율 공식 주입
    COUNT(DISTINCT CASE WHEN e.event_type = 'Cart' AND e.session_id NOT IN (
      SELECT DISTINCT session_id 
      FROM `junho-preview-playground.thelook_ecommerce.events` 
      WHERE event_type = 'Purchase'
    ) THEN e.session_id END) / 
    COUNT(DISTINCT CASE WHEN e.event_type = 'Cart' THEN e.session_id END) * 100 AS cart_abandonment_rate
  FROM `junho-preview-playground.thelook_ecommerce.events` e
  JOIN `junho-preview-playground.thelook_ecommerce.users` u ON e.user_id = u.id
  GROUP BY marketing_channel
  ORDER BY cart_abandonment_rate DESC;
  ```

### Q3. [복합 룰 결합] 마진율 및 환불률 분석
* **자연어 질문:** `"여성 의류 중에서 상품 마진이 40% 이상인 제품들의 환불률을 브랜드별로 계산해줘."`
* **에이전트 매핑 경로:**
  1. `상품 마진` $\rightarrow$ `마진율` (용어 ID: `profit-margin-rate`) $\rightarrow$ `expression` 필터화
  2. `환불률` $\rightarrow$ `취소/반품 비율` (용어 ID: `return-rate`) $\rightarrow$ `expression` 집계화
* **예상 결과 SQL:**
  ```sql
  SELECT 
    p.brand,
    -- 💡 취소/반품 비율 집계식 적용
    COUNTIF(oi.status IN ('Returned', 'Cancelled')) / COUNT(*) * 100 AS refund_rate,
    COUNT(oi.id) AS total_orders
  FROM `junho-preview-playground.thelook_ecommerce.order_items` oi
  JOIN `junho-preview-playground.thelook_ecommerce.products` p ON oi.product_id = p.id
  WHERE p.category = 'Women'
    -- 💡 마진율 공식 필터링 적용
    AND ((p.retail_price - p.cost) / p.retail_price * 100) >= 40
  GROUP BY p.brand
  ORDER BY refund_rate DESC
  LIMIT 10;
  ```

### Q4. [부정 조건 및 속성 결합] 휴면 고객 유입 분포
* **자연어 질문:** `"휴면 고객들이 가장 많이 유입되었던 가입 경로 3가지는 무엇인가요?"`
* **에이전트 매핑 경로:**
  1. `휴면 고객` $\rightarrow$ `이탈 고객` (용어 ID: `churned-customer`) $\rightarrow$ `condition` 부정 필터 적용
  2. `가입 경로` $\rightarrow$ `유입 경로` (용어 ID: `traffic-source`) $\rightarrow$ `users.traffic_source`
* **예상 결과 SQL:**
  ```sql
  SELECT 
    traffic_source AS signup_channel,
    COUNT(*) AS user_count
  FROM `junho-preview-playground.thelook_ecommerce.users`
  WHERE id NOT IN (
    -- 💡 최근 90일간 주문 기록이 존재하지 않는 이탈 필터 삽입
    SELECT DISTINCT user_id 
    FROM `junho-preview-playground.thelook_ecommerce.orders` 
    WHERE created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
  )
  GROUP BY signup_channel
  ORDER BY user_count DESC
  LIMIT 3;
  ```
