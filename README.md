# bucket-module

## Usage
Here is a example of what is needed to create a bucket 
```hcl-terraform
module "test_bucket" {
  source = "kiwicom/storage-bucket/google"
  version = "~> 2.0.0" # version >= 2.0.0 and < 2.1.0, e.g. 2.0.X

  bucket_name   = "test-bucket"     #base name, random suffix will be added and depending on labels other suffixes
  location      = var.GOOGLE_REGION #this will set location of bucket to project location

  owner_info = {
    responsible_people          = "some.user@kiwi.com, @some.user"
    communication_slack_channel = "#plz-platform-infra"
  }

  labels = {
    tribe     = "platform" 
    env       = "sandbox" # can be sandbox of production
    public    = "no"      # yes or no
    bill_path = "namespace__service" # this is used for billing attribution
  }
}
```

## Editable variables

* `bucket_name` (string)
    * Base name of bucket. Final bucket name is generated by adding a random suffix and depends on labels (-sandbox and/or -public)
    * Module enforces validation that string length must be > 3 and < 39, and naming restriction (Bucket names must contain only lowercase letters, numbers, dashes (-), underscores (_))
    * There are additional [limitations](https://cloud.google.com/storage/docs/naming-buckets) to bucket naming so please check them before deciding on a name. 
<br />

* `location` (string)   
    * Location of bucket, by using var.GOOGLE_REGION bucket will be created in same region as host google project.
    * If you need to create in a different [location](https://cloud.google.com/storage/docs/locations) set it here.
<br />

* `storage_class` (string)  
    * Set the [storage class](https://cloud.google.com/storage/docs/storage-classes) of your bucket
    * If not set, default is: STANDARD
    * Available options are STANDARD,NEARLINE,COLDLINE,ARCHIVE,MULTI_REGIONAL,REGIONAL
<br /> 

* `labels` map(string)
    * Labels `public` , `tribe` and `env` are mandatory. Naming of bucket and creation of IAM rules are dependent on these.
    * Label `public` determines if bucket content should be publicly available. IAM rule granting `AllUsers` the role `roles/storage.legacyObjectReader`, enabling public access to objects in the bucket but preventing public listing of bucket content. Default is `"no"`
    * Label `env` can be set to `sandbox` or `production`. If set to `sandbox` suffix will be added to name.
    * Label `tribe` can be set to (`ancillaries`|`autobooking`|`bass`|`bi`|`booking`|`cs-systems`|`data-acquisition`|`finance`|`php`|`platform`|`reservations`|`search`|`tequila`)
    * Label `active` can be `yes` and `no`. Bucket are not deleted, so use this to signal the bucket is not used.
    * Label `bill_path` is used to attribute the costs of the bucket to the deployment/workload. Fill with `namespace` (mandatory) or `namespace__deployment` if you need finner attribution.
    * Label `bill_project` is used to attribute the costs of the bucket to the project, this will be automatically filed with bucket project, if you need to override use this.
    * You may add additional labels in form `arbitrary = "label"` but you must follow these [rules](https://cloud.google.com/storage/docs/key-terms#bucket-labels) or the bucket creation will fail on Terraform apply!
<br /> 

* `owner_info` map(string)
    * This info is needed so Infra staff can find Point Of Contact for the bucket.
    * Value `responsible_people` please fill with email of slack handle. Not optional, but can be empty string if there is no direct responsible person.
    * Value `communication_slack_channel` Name of primary Slack channel for communication Examples: #platform-infra
<br />

* `members_object_viewer` `members_legacy_object_reader` `members_object_creator` `members_object_admin` `members_storage_admin` list(string)
    * Through these you control access to bucket.
    * These set the [IAM binding](https://www.terraform.io/docs/providers/google/r/storage_bucket_iam.html#google_storage_bucket_iam_binding) to the bucket for the [predefined IAM role](https://cloud.google.com/storage/docs/access-control/iam-roles) for GCS.
    * GCP applications should use [service accounts](https://kiwi.wiki/handbook/tooling/gcp/service-accounts/) to access GCS buckets.
    * **_NOTE:_** Always assign the least permissive role that satisfies the requirements.

```hcl-terraform
  members_object_viewer = [
    "user:random.user@kiwi.com",
    "user:another.one@kiwi.com",
  ]
  members_object_creator = [
    "serviceAccount:something@platform-sandbox-6b6f7700.iam.gserviceaccount.com ",
  ]
```
<br />

* `lifecycle_rules` set(object({ action = map(string) condition = map(string) }))
    * Use these when you want to delete old objects or change Storage Class.
    * We generally use these to move objects to a cost-efficient storage when data is no longer accessed on daily basis.
    * See [Lifecycle Actions](https://cloud.google.com/storage/docs/lifecycle#actions) and [Lifecycle Conditions](https://cloud.google.com/storage/docs/lifecycle#conditions) on what can be defined here.
  
  
```terraform
  lifecycle_rules = [
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 50 # in days
      }
    }
  ]
```
<br />

* `randomise` bool
    * If there is a valid use case to omit the random suffix added to `bucket_name` set this to `true`
    
* `website` object, see the documentation for [google_storage_bucket](https://www.terraform.io/docs/providers/google/r/storage_bucket.html#website)

* `versioning_enable` bool
    * Default if `false`, set to `true` if you want enable [object versioning](https://cloud.google.com/storage/docs/object-versioning) 

## Complex Example

```hcl-terraform
module "test_bucket2" {
  source = "kiwicom/storage-bucket/google"
  version = "~> 2.0.0" # version >= 2.0.0 and < 2.1.0, e.g. 2.0.X

  bucket_name       = "test-bucket2"     
  location          = "europe-west1"
  storage_class     = "REGIONAL"
  randomise         = false
  versioning_enable = true

  owner_info = {
    responsible_people          = "some.user@kiwi.com, @some.user"
    communication_slack_channel = "#plz-platform-infra"
  }

  labels = {
    tribe         = "platform" 
    env           = "sandbox" 
    public        = "no"      
    arbitrary     = "label"
    active        = "yes"
    bill_path     = "namespace__deployment"
    bill_project  = "platform-sandbox-6b6f7700" 
  }

  members_object_viewer = [
    "user:random.user@kiwi.com",
    "user:another.one@kiwi.com",
  ]
  members_object_creator = [
    "serviceAccount:something@platform-sandbox-6b6f7700.iam.gserviceaccount.com",
  ]
  
  lifecycle_rules = [
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
      condition = {
        age = 90 # in days
      }
    },
    {
      action = {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
      condition = {
        age = 180
      }
    },
    {
      action = {
        type = "Delete"
      }
      condition = {
        age = 365
      }
    }
  ]
  
  website = {
    main_page_suffix = "index.html"
    not_found_page = null
  }
}
```
## Release notes

### 1.0.0
Initial release

### 1.0.4
Add support for versioning[]

### 2.0

Breaking change: `expiration_rule` and `conversion_rule` were replaced by `lifecycle_rules`

### 2.0.1
Add legacyObjectReader

### 2.0.2
Removed the public suffix naming as it wasn't working, and naming change would be a breaking change (rename=recreate).

### 2.0.3
Add bill_path, bill_project to support billing attribution.