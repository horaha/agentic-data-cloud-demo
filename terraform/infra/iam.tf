# 3. IAM 생성
module "iam" {
  source = "../modules/iam"

  project_id   = var.project_id
  account_id   = "playground-sa"
  display_name = "Playground Service Account"
  roles        = ["roles/viewer"]

  depends_on = [module.apis]
}
