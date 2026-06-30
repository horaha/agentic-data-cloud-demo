# 데이터 분석 플레이그라운드

이 디렉터리는 BigQuery 퍼블릭 데이터셋인 `thelook_ecommerce`를 탐색, 분석 및 테스트하기 위한 공간입니다.

## 의존성 관리 및 설치

이 프로젝트는 `pyproject.toml`을 기반으로 의존성을 관리하며, 빠르고 효율적인 환경 구축을 위해 **[uv](https://github.com/astral-sh/uv)** 사용을 권장합니다.

```bash
# 의존성 설치 및 가상환경 동기화
uv sync
```

## 구성 내용

- `notebooks/`: 대화형 분석 및 메타데이터 설정을 위한 Jupyter 노트북 파일들
  - [01_data_profile_quality.ipynb](notebooks/01_data_profile_quality.ipynb): 데이터 프로파일 및 데이터 품질 스캔 규칙을 자동으로 생성하고 일괄 실행하는 파이프라인 노트북.
  - [02_metadata_effectiveness.ipynb](notebooks/02_metadata_effectiveness.ipynb): 프로필, 품질 등 메타데이터 주입이 LLM 기반 에이전트의 SQL 작성 능력에 미치는 효용성을 분석하는 노트북.
  - [03_schema_descriptions.ipynb](notebooks/03_schema_descriptions.ipynb): Dataplex DataScans를 활용하여 컬럼 한글 설명을 자동으로 주입하고 BigQuery 스키마와 동기화하는 노트북.
  - [04_dataset_insights.ipynb](notebooks/04_dataset_insights.ipynb): 데이터셋 탐색적 분석 및 통계 분석 노트북.
  - [05_glossary_setup.ipynb](notebooks/05_glossary_setup.ipynb): 비즈니스 용어집 데이터를 Dataplex에 적재하는 노트북.
  - [06_graph_analysis.ipynb](notebooks/06_graph_analysis.ipynb): Property Graph 및 GQL을 활용한 상품 추천 실습.
  - [07_glossary_graph_setup.ipynb](notebooks/07_glossary_graph_setup.ipynb): 그래프 관련 비즈니스 용어집 적재 및 그래프 테이블 연동용 노트북.
  - [08_bigquery_ai_ml_demo.ipynb](notebooks/08_bigquery_ai_ml_demo.ipynb): BigQuery 생성형 AI 및 머신러닝 분석 실습 (원격 모델, 개인화 추천 메일, 카탈로그 번역 및 태그 추출, 상품 임베딩 및 벡터 검색).
  - [09_bigquery_ai_functions.ipynb](notebooks/09_bigquery_ai_functions.ipynb): BigQuery 고수준 AI 함수 실습 (AI.CLASSIFY, AI.SIMILARITY, AI.IF, AI.SEARCH, Distillation).

- `resources/`: 용어집 정의 및 매핑 설정을 위한 리소스 파일들
  - [agent_test_queries.md](resources/agent_test_queries.md): 대화형 분석 에이전트 검증을 위한 물리 매핑 규칙 가이드 및 시나리오별 예상 SQL 레퍼런스 문서.
  - [aspect_sql_mapping.json](resources/aspect_sql_mapping.json): SQL 매핑을 위한 Dataplex Aspect의 JSON 스키마 정의.
  - [aspect_graph_mapping.json](resources/aspect_graph_mapping.json): 그래프 매핑을 위한 Dataplex Aspect의 JSON 스키마 정의.
  - [business_glossary.json](resources/business_glossary.json): 비즈니스 용어 정의 메타데이터.
  - [business_glossary_graph.json](resources/business_glossary_graph.json): 그래프 테이블용 비즈니스 용어 정의 메타데이터.
- `.venv/`: 분석 작업에 필요한 라이브러리들이 설치된 파이프라인 독립형 가상환경.
