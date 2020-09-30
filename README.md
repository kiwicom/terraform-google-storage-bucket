# bucket-module


## Usage
A sandbox for GCS buckets module
```hcl-terraform
module "test_bucket" {
  source = "http://terraform-modules.skypicker.com.s3.amazonaws.com/gcp-bucket/dev/gcp-bucket.zip"

  bucket_name   = "bucket-test"
  location      = var.GOOGLE_REGION
  storage_class = "NEARLINE"

  labels = {
    team                        = "infra"
    type                        = "public"
    responsible_people          = "@random.user"
    communication_slack_channel = "#plz-platform-infra"
  }

  members_storage_admin = [
    "user:random.user@kiwi.com",
    "user:another.one@kiwi.com",
  ]
  members_object_creator = [
    "service.account:something@platform-sandbox-6b6f7700.iam.gserviceaccount.com ",
  ]
  
  expiration_rule = {
    delete  = "yes"
    days    = 365
  }

  conversion_rule = [
    {
      storage_class = "NEARLINE"
      days = 90
    },
    {
      storage_class = "ARCHIVE"
      days = 180
    }

}
```
##