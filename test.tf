module "test_bucket" {
  source = "./gcs-bucket"

  bucket_name       = "kiwi-test"
 #storage_class     = "NEARLINE"
  randomise         = true
  members_storage_admin = [
    "user:petar.sekul@kiwi.com",
   # "service.account:smg@kiwilkdaskl.com",
  ]
  members_object_creator = [
    "user:marek.viklicky@kiwi.com",
   # "service.account:smg@kiwilkdaskl.com",
  ]
  labels = {
    team = "infra"
    type = "public"
  }

}
