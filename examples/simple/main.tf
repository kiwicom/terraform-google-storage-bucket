module "simple" {
  source = "../.."

  bucket_name = "peto-sandbox-simple-bucket"
  location = "EU"

  owner_info = {
    responsible_people          = "peter.malina@kiwi.com"
    communication_slack_channel = "#plz-platform-infra"
  }

  labels = {
    tribe   = "platform"
    env     = "sandbox"
    public  = "no"
  }

  lifecycle_rules = [{
    action = {
      type = "Delete"
    }
    condition = {
      days_since_custom_time = 50
    }
  }]
}