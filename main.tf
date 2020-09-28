resource "google_storage_bucket" "bucket" {
  name                        = local.final_bucket_name
  labels                      = var.labels
  location                    = var.region
  project                     = var.project
  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true
  }

}

# insert suffix in bucket name based if label.type sandbox or public.
locals {
    final_bucket_name = "${var.bucket_name}${var.labels.type == "sandbox" ? "-sandbox" : ""}${var.labels.type == "public" ? "-public" : ""}${var.randomise == true ? "-${random_id.id[0].hex}" : ""}"
    objectAdmin = [
      "user:petar.sekul@kiwi.com",
      "service.account:smg@kiwilkdaskl.com",
    ]
    objectCreator = []
}

resource "google_storage_bucket_iam_member" "admins" {
  for_each  = toset(var.members_storage_admin)
  bucket    = google_storage_bucket.bucket.name
  role      = "roles/storage.admin"
  member    = each.value
  #to ensure bucket is created first
  depends_on = [
    google_storage_bucket.bucket,
  ]
}

resource "google_storage_bucket_iam_member" "objectCreator" {
  for_each    = toset(var.members_object_creator)
  bucket      = google_storage_bucket.bucket.name
  role        = "roles/storage.objectCreator"
  member      = each.value
  depends_on  = [
    google_storage_bucket.bucket,
  ]
}
#### alternative
#resource "google_storage_bucket_iam_binding" "binding" {
#  bucket = google_storage_bucket.bucket.name
#  role = "roles/storage.admin"
#  members = var.members_object_creator
#  depends_on = [
#    google_storage_bucket.bucket,
#  ]
#}

#--------------
resource "random_id" "id" {
  byte_length = 4
  #prefix      = "${var.bucket_name}-"
  count       = var.randomise == true ? 1 : 0
}

