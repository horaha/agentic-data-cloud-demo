# 4. GCS 버킷 생성 및 리소스 파일 업로드
module "resource_bucket" {
  source = "../modules/gcs"

  project_id    = var.project_id
  bucket_name   = "metadata-resources-${var.project_id}"
  location      = var.region
  storage_class = "STANDARD"
  force_destroy = true

  depends_on = [module.apis]
}

# 비즈니스 용어집 JSON 파일 업로드
resource "google_storage_bucket_object" "business_glossary" {
  name   = "resources/business_glossary.json"
  source = "../../analytics/resources/business_glossary.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# 그래프 비즈니스 용어집 JSON 파일 업로드
resource "google_storage_bucket_object" "business_glossary_graph" {
  name   = "resources/business_glossary_graph.json"
  source = "../../analytics/resources/business_glossary_graph.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# SQL 매핑 Aspect 스키마 JSON 파일 업로드
resource "google_storage_bucket_object" "aspect_sql_mapping" {
  name   = "resources/aspect_sql_mapping.json"
  source = "../../analytics/resources/aspect_sql_mapping.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}

# 그래프 매핑 Aspect 스키마 JSON 파일 업로드
resource "google_storage_bucket_object" "aspect_graph_mapping" {
  name   = "resources/aspect_graph_mapping.json"
  source = "../../analytics/resources/aspect_graph_mapping.json"
  bucket = "metadata-resources-${var.project_id}"

  depends_on = [module.resource_bucket]
}
