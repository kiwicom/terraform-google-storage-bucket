variable "bucket_name" {
  type        = string
  description = "Name of GCS bucket."

  validation {
    # TODO: Add back length limit, e.g. `length(var.bucket_name) < 39`
    condition     = length(var.bucket_name) > 3 && can(regex("^[a-zA-Z0-9.\\-_]{1,255}$", var.bucket_name))
    error_message = "The bucket_name length must be > 3, and pass bucket naming rules."
  }
}

variable "owner_info" {
  type = map(string)
  default = {
    "responsible_people"          = ""
    "communication_slack_channel" = ""
  }

  validation {
    condition     = length(var.owner_info.communication_slack_channel) > 0
    error_message = "Please fill in communication_slack_channel it's mandatory."
  }
}

variable "labels" {
  description = "Labels that are mandatory and have to be specified in the bucket module interface"
  type        = map(string)
  default = {
    "env"    = ""
    "public" = "no"
    "tribe"  = ""
  }
  validation {
    condition     = contains(["production", "sandbox"], var.labels["env"])
    error_message = "Label env is mandatory and can be: sandbox or production."
  }
  validation {
    condition     = contains(["yes", "no"], var.labels["public"])
    error_message = "Label public is mandatory and can be: yes or no."
  }
  validation {
    condition     = contains(["ancillaries", "autobooking", "bass", "bi", "booking", "cs-systems", "data-acquisition", "finance", "platform", "php", "reservations", "search", "tequila"], var.labels["tribe"])
    error_message = "Label tribe is mandatory and can be (ancillaries|autobooking|bass|bi|booking|cs-systems|data-acquisition|finance|platform|php|reservations|search|tequila)."
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

variable "members_legacy_object_reader" {
  type        = list(string)
  default     = []
  description = "List of members that will receive roles/storage.legacyObjectReader to bucket"
}


variable "members_object_admin" {
  type        = list(string)
  default     = []
  description = "List of members that will receive roles/storage.objectAdmin to bucket"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
  validation {
    condition     = var.storage_class == "STANDARD" || var.storage_class == "NEARLINE" || var.storage_class == "COLDLINE" || var.storage_class == "ARCHIVE" || var.storage_class == "MULTI_REGIONAL" || var.storage_class == "REGIONAL"
    error_message = "The role value must be one of the following: STANDARD,NEARLINE,COLDLINE,ARCHIVE,MULTI_REGIONAL,REGIONAL."
  }
}

variable "randomise" {
  type    = bool
  default = true
}

variable "lifecycle_rules" {
  type = set(object({
    action    = map(string)
    condition = map(string)
  }))
  description = "https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule"
  default     = []
}

variable "website" {
  type = object({
    main_page_suffix = string
    not_found_page   = string
  })
  default = null
}

variable "versioning_enable" {
  type    = bool
  default = false
}