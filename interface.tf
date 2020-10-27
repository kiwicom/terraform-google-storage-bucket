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
    "responsible_people" = ""
    "communication_slack_channel" = ""
  }

  validation {
    condition     = length(var.owner_info.communication_slack_channel) > 0
    error_message = "Please fill in communication_slack_channel it's mandatory."
  }
}

variable "labels" {
  type = map(string)
  default = {
    "public" = "no"
    "tribe" = ""
    "env" = ""
  }
  validation {
    condition     = var.labels.env == "sandbox" || var.labels.env == "production"
    error_message = "Label env is mandatory and can be: sandbox or production."
  }
  validation {
    condition     = var.labels.public == "yes" || var.labels.public == "no"
    error_message = "Label public is mandatory and can be: yes or no."
  }
  validation {
    condition     = var.labels.tribe == "anciliaries" || var.labels.tribe == "autobooking" || var.labels.tribe == "bass" || var.labels.tribe == "bi" || var.labels.tribe == "booking" || var.labels.tribe == "cs-systems" || var.labels.tribe == "data-acquisition" || var.labels.tribe == "finance" || var.labels.tribe == "platform" || var.labels.tribe == "reservations" || var.labels.tribe == "search"
    error_message = "Label tribe is mandatory and can be (anciliaries|autobooking|bass|bi|booking|cs-systems|data-acquisition|finance|platform|reservations|search)."
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
  type = object({
    delete  = bool
    days    = number
  }
  )
  default = {
    delete = true
    days  = 0
  }
  validation {
    condition = var.expiration_rule.delete == false || var.expiration_rule.days > 0
    error_message = "Set days > 0, or if you have a valid usage case, set delete to: false ."
  }
}

variable "conversion_rule" {
  type = list(map(string))
  default =[]
}

variable "website" {
  type = object({
    main_page_suffix = string
    not_found_page = string
  })
  default = null
}
