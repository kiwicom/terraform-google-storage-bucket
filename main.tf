resource "google_storage_bucket" "bucket" {
  name                = var.bucket_name
  labels              = var.labels
  location            = var.GOOGLE_REGION
  uniform_bucket_level_access  = true  # Important to specify. This assures that objects in the bucket cannot have different access control than the bucket.
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


