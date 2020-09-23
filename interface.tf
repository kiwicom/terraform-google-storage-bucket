variable "bucket_name" {
  type = string
  description = "Name of GCS bucket. Must be unique company wide"

   validation {
    condition     = length(var.bucket_name) > 4 && substr(var.bucket_name, 0, 4) == "ami-"
    error_message = "The image_id value must be a valid AMI id, starting with \"ami-\"."
  }
}

variable "labels" {
  type = map(string)
  default = {
    "team"  = ""
    "type"   = ""
  }
}

# how do I inherit this from project?
variable "GOOGLE_REGION" {
  type = string
  default = "eu-west-1"
}
#---------------
variable "role" {
  type = string
  default = "roles/storage.objectViewer"

    validation {
      condition     = var.role == "roles/storage.objectCreator" || var.role == "roles/storage.objectViewer" || var.role == "roles/storage.objectAdmin" || var.role == "roles/storage.admin"
      error_message = "The role value must be one of the following: roles/storage.objectCreator,roles/storage.objectViewer,roles/storage.objectAdmin,roles/storage.admin ."
  }
}

variable "role_members" {
  type = list(string)
  default = [
    "user:petar.sekul@kiwi.com",
    "serviceaccount"
  ]
}