variable "bucket_name" {
  type        = string
  description = "Name of GCS bucket. Must be unique company wide"

  validation {
    condition     = length(var.bucket_name) > 4
    error_message = "The bucket_name length must be > 4."
  }
}

variable "labels" {
  type = map(string)
  default = {
    "team" = ""
    "type" = ""
  }

  validation {
    condition     = length(var.labels.team) > 0
    error_message = "Tag team is mandatory."
  }

  validation {
    condition     = var.labels.type == "sandbox" || var.labels.type == "public" || var.labels.type == "production"
    error_message = "Tag type can be: sandbox,production,public."
  }
}

variable "location" {
  type = string
}

variable "members_storage_admin" {
  type        = list(string)
  default     = []
  description = "List of members that will receive roles/storage.admin to bucket"
}

variable "members_object_creator" {
  type        = list(string)
  default     = []
  description = "List of members that will receive roles/storage.objectCreator to bucket"
}

variable "members_object_viewer" {
  type        = list(string)
  default     = []
  description = "List of members that will receive roles/storage.objectViewer to bucket"
}

variable "members_object_admin" {
  type        = list(string)
  default     = []
  description = "List of members that will receive roles/storage.objectAdmin to bucket"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
  # no point in this as invalid class will be ponited out in plan ? It will not, PLAN wil pass but apply will fail
  validation {
    condition     = var.storage_class == "STANDARD" || var.storage_class == "NEARLINE" || var.storage_class == "COLDLINE" || var.storage_class == "ARCHIVE" || var.storage_class == "MULTI_REGIONAL" || var.storage_class == "REGIONAL"
    error_message = "The role value must be one of the following: STANDARD,NEARLINE,COLDLINE,ARCHIVE,MULTI_REGIONAL,REGIONAL."
  }
}

variable "randomise" {
  type        = bool
  default     = false
  description = "Do you need a random suffix added to bucket name"
}

variable "lc_del_rule" {
  type = map(string)

  default = {
    delete = "no"
    value  = ""
  }
}