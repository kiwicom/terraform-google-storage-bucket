resource "google_storage_bucket" "bucket" {
  name                = var.bucket_name
  labels              = var.labels
  location            = var.GOOGLE_REGION
  storage_class       = var.storage_class
  uniform_bucket_level_access  = true  # Important to specify. This assures that objects in the bucket cannot have different access control than the bucket.

  lifecycle {
    prevent_destroy = true
  }

}


resource "google_storage_bucket_iam_member" "iam_member" {
  bucket = google_storage_bucket.bucket.name
  role   = var.role
  member = "user:petar.sekul@kiwi.com"
  #member = var.role_members
  #to ensure bucket is created first
  depends_on = [
    google_storage_bucket.bucket,
  ]
}

#--------------
resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.bucket_name}-"
}

#locals {
#  modules-logs-admins = [
#    "serviceAccount:${google_service_account.modules_storage.email}",
#    "serviceAccount:${google_service_account.backbone.email}",
#    "serviceAccount:${google_service_account.sherlog_storage.email}",
#    "serviceAccount:sherlog-storage-dev@autobooking-sandbox-aef8fdd4.iam.gserviceaccount.com"
#  ]
#  modules-logs-viewers = [
#    "serviceAccount:bookie@reservations-prod-22bb532e.iam.gserviceaccount.com",
#    "serviceAccount:bookie@reservations-sandbox-973bbbeb.iam.gserviceaccount.com"
#  ]
#}
#
#resource "google_storage_bucket_iam_member" "modules-logs" {
#   for_each  = toset(local.modules-logs-admins)
#   bucket    = google_storage_bucket.modules-logs.name
#   role      = "roles/storage.objectAdmin"
#   member    = each.value
#}