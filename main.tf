# insert suffix in bucket name based if label.type sandbox or public .
locals {
  final_bucket_name = "${var.bucket_name}${var.labels.env == "sandbox" ? "-sandbox" : ""}${var.labels.public == true ? "-public" : ""}${var.randomise == true ? "-${random_id.id[0].hex}" : ""}"
  test              = var.owner_info.communication_slack_channel

  # Additional labels that are nice to have and are not forced in the bucket module interface
  additional_labels = {
    active = try(var.labels.active, "yes")
  }
}

resource "google_storage_bucket" "bucket" {
  name                        = local.final_bucket_name
  labels                      = merge(var.labels, local.additional_labels)
  location                    = var.location
  storage_class               = var.storage_class
  uniform_bucket_level_access = true

  dynamic "website" {
    for_each = var.website[*]
    content {
      main_page_suffix = website.value.main_page_suffix
      not_found_page   = website.value.not_found_page
    }
  }

  lifecycle {
    prevent_destroy = true
  }

  dynamic "lifecycle_rule" {
    for_each = var.expiration_rule.delete == true ? [1] : []
    content {
      action {
        type = "Delete"
      }
      condition {
        age = var.expiration_rule.days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = [for item in var.conversion_rule : item]
    content {
      action {
        type          = "SetStorageClass"
        storage_class = lookup(lifecycle_rule.value, "storage_class", null)
      }
      condition {
        age = lookup(lifecycle_rule.value, "days", null)
      }
    }
  }

  dynamic "versioning" {
    for_each = var.versioning_enable == true ? [1] : []
    content {
      enabled = true
    }
  }

}

resource "google_storage_bucket_iam_binding" "storage_admin" {
  bucket  = google_storage_bucket.bucket.name
  role    = "roles/storage.admin"
  members = var.members_storage_admin
  depends_on = [
    google_storage_bucket.bucket,
  ]
  count = length(var.members_storage_admin) == 0 ? 0 : 1
}

resource "google_storage_bucket_iam_binding" "object_admin" {
  bucket  = google_storage_bucket.bucket.name
  role    = "roles/storage.objectAdmin"
  members = var.members_object_admin
  depends_on = [
    google_storage_bucket.bucket,
  ]
  count = length(var.members_object_admin) == 0 ? 0 : 1
}

resource "google_storage_bucket_iam_binding" "object_creator" {
  bucket  = google_storage_bucket.bucket.name
  role    = "roles/storage.objectCreator"
  members = var.members_object_creator
  depends_on = [
    google_storage_bucket.bucket,
  ]
  count = length(var.members_object_creator) == 0 ? 0 : 1
}

resource "google_storage_bucket_iam_binding" "object_viewer" {
  bucket  = google_storage_bucket.bucket.name
  role    = "roles/storage.objectViewer"
  members = var.members_object_viewer
  depends_on = [
    google_storage_bucket.bucket,
  ]
  count = length(var.members_object_viewer) == 0 ? 0 : 1
}
# Create to make bucket publicly readable, but not list-able
resource "google_storage_bucket_iam_member" "public_view" {
  bucket = google_storage_bucket.bucket.name
  role   = "roles/storage.legacyObjectReader"
  member = "allUsers"
  depends_on = [
    google_storage_bucket.bucket,
  ]
  count = var.labels.public == "yes" ? 1 : 0
}

resource "random_id" "id" {
  byte_length = 4
  count       = var.randomise == true ? 1 : 0
}
