output "bucket_name" {
  value = google_storage_bucket.bucket.name
}
output "owner" {
  value = var.owner_info.communication_slack_channel
}
