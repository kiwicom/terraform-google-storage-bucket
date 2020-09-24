module "test_bucket" {
  source = "./gcs-bucket"

  bucket_name       = "ami-test"
}
