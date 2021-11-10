# insert suffix in bucket name based if label.type sandbox or public .
data "google_project" "current" {}

locals {
  final_bucket_name = "${var.bucket_name}${var.labels.env == "sandbox" ? "-sandbox" : ""}${var.randomise == true ? "-${random_id.id[0].hex}" : ""}"
  test              = var.owner_info.communication_slack_channel

  # Additional labels that are nice to have and are not forced in the bucket module interface
  additional_labels = {
    active = try(var.labels.active, "yes")
    bill_project = data.google_project.current
    bill_path = ""
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
    for_each = var.lifecycle_rules
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                    = lookup(lifecycle_rule.value.condition, "age", null)
        created_before         = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state             = lookup(lifecycle_rule.value.condition, "with_state", lookup(lifecycle_rule.value.condition, "is_live", false) ? "LIVE" : null)
        matches_storage_class  = contains(keys(lifecycle_rule.value.condition), "matches_storage_class") ? split(",", lifecycle_rule.value.condition["matches_storage_class"]) : null
        num_newer_versions     = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        days_since_custom_time = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
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

resource "google_storage_bucket_iam_binding" "legacy_object_reader" {
  bucket  = google_storage_bucket.bucket.name
  role    = "roles/storage.legacyObjectReader"
  members = var.members_legacy_object_reader
  depends_on = [
    google_storage_bucket.bucket,
  ]
  count = length(var.members_legacy_object_reader) == 0 ? 0 : 1
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
