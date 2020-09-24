variable "bucket_name" {
  type = string
  description = "Name of GCS bucket. Must be unique company wide"

  validation {
    condition     = length(var.bucket_name) > 4
    error_message = "The bucket_name length must be > 4."
  }
}

variable "labels" {
  type = map(string)
  default = {
    "team"  = ""
    "type"   = ""
  }

  validation {
    condition     = length(var.labels.team) > 0
    error_message = "Tag team is mandatory."
  }
}

# how do I inherit this from project?
variable "GOOGLE_REGION" {
  type = string
  default = "eu-west-1"
}

#variable "role" {
#  type = string
#  default = "roles/storage.objectViewer"
#
#  validation {
#      condition     = var.role == "roles/storage.objectCreator" || var.role == "roles/storage.objectViewer" || var.role == "roles/storage.objectAdmin" || var.role == "roles/storage.admin"
#      error_message = "The role value must be one of the following: roles/storage.objectCreator,roles/storage.objectViewer,roles/storage.objectAdmin,roles/storage.admin ."
#  }
#}

#variable "role_members" {
#  type = map(string)
#  default = {
#    "objectAdmin" = "user:petar.sekul@kiwi.com",
#    "objectViewer"= "service.account:smg@kiwilkdaskl.com"
#  }
#}

variable "members_storage_admin" {
  type = list(string)
  default = []
  description = "List of members that will receive roles/storage.admin to bucket"
}

variable "members_object_creator" {
  type = list(string)
  default = []
  description = "List of members that will receive roles/storage.objectCreator to bucket"
}

variable "storage_class" {
  type = string
  default = "STANDARD"
  # no point in this as invalid class will be ponited out in plan ?
  #validation {
  #    condition     = var.storage_class == "STANDARD" || var.storage_class == "NEARLINE" || var.storage_class == "COLDLINE" || var.storage_class == "ARCHIVE"
  #    error_message = "The role value must be one of the following: STANDARD,NEARLINE,COLDLINE,ARCHIVE."
  #}
}

variable "randomise" {
  type = bool
  description = "Do you need a random suffix added to bucket name"
}
