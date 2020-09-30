variable "bucket_name" {
  type        = string
  description = "Name of GCS bucket. Must be unique company wide"

  validation {
    condition     = length(var.bucket_name) > 3 || length(var.bucket_name) < 43
    error_message = "The bucket_name length must be > 3."
  }
}

variable "labels" {
  type = map(string)
  default = {
    "tribe" = ""
    "type" = ""
    #"responsible_people" = ""
    #"communication_slack_channel" = ""
  }

  validation {
    condition     = length(var.labels.tribe) > 0
    error_message = "Tag team is mandatory."
  }
  validation {
    condition     = var.labels.type == "sandbox" || var.labels.type == "public" || var.labels.type == "production"
    error_message = "Tag type can be: sandbox,production,public."
  }
  #validation {
  #  condition     = length(var.labels.responsible_people) > 0
  #  error_message = "Tag responsible_people is mandatory."
  #}
  #validation {
  #  condition     = length(var.labels.communication_slack_channel) > 0
  #  error_message = "Tag communication_slack_channel is mandatory."
  #}
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
  validation {
    condition     = var.storage_class == "STANDARD" || var.storage_class == "NEARLINE" || var.storage_class == "COLDLINE" || var.storage_class == "ARCHIVE" || var.storage_class == "MULTI_REGIONAL" || var.storage_class == "REGIONAL"
    error_message = "The role value must be one of the following: STANDARD,NEARLINE,COLDLINE,ARCHIVE,MULTI_REGIONAL,REGIONAL."
  }
}

variable "randomise" {
  type        = bool
  default     = true
}

variable "expiration_rule" {
  type = map(string)
  default = {
    delete = "yes"
    days  = 0
  }
  validation {
    condition = length(var.expiration_rule.days) > 0
    error_message = "Set days value > 0, or if you have a valid usage case, set delete to: no ."
  }
}

variable "conversion_rule" {
  type = list(map(string))
  default =[]
}