# bucket-module

A sandbox for GCS buckets module
```terraform
module "test_bucket" {
  source = "/home/petar/Documents/posao/code/my/bucket-module"
  #source = "http://terraform-modules.skypicker.com.s3.amazonaws.com/gcp-bucket/dev/gcp-bucket.zip"

  bucket_name   = "bucket-test"
  location      = var.GOOGLE_REGION
  storage_class = "NEARLINE"
  randomise     = true

  labels = {
    team = "infra"
    type = "public"
  }

  members_storage_admin = [
    "user:random.user@kiwi.com",
    "user:another.one@kiwi.com",
  ]
  members_object_creator = [
    "service.account:something@platform-sandbox-6b6f7700.iam.gserviceaccount.com ",
  ]

}
```
##