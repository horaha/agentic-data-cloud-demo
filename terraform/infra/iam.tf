# Grant necessary roles to the Compute Engine default service account for Cloud Build execution
# (Modern GCP projects run Cloud Build under the compute service account by default, requiring storage read, registry write, and logs write permissions)
resource "google_project_iam_member" "compute_roles" {
  for_each = toset([
    "roles/storage.objectViewer",
    "roles/artifactregistry.writer",
    "roles/logging.logWriter"
  ])

  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"

  depends_on = [module.apis]
}
