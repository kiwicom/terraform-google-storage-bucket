# bucket-module


## Usage
Here is a example of what is needed to create a bucket 
```hcl-terraform
module "test_bucket" {
  source = "kiwicom/storage-bucket/google"
  version = "~> 1.0.0" # version >= 1.0.0 and < 1.1.0, e.g. 1.0.X

  bucket_name   = "test-bucket"     #base name, random suffix will be added and depending on labels other suffixes
  location      = var.GOOGLE_REGION #this will set location of bucket to project location

  owner_info = {
    responsible_people          = "some.user@kiwi.com, @some.user"
    communication_slack_channel = "#plz-platform-infra"
  }

  labels = {
    tribe   = "platform" 
    env     = "sandbox" # can be sandbox of production
    public  = "no"      # yes or no
  }

  expiration_rule = {   # expiration policy in days
    delete  = true
    days    = 365
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
    * Labels `public` , `tribe` and `env` are mandatory. Naming of bucket and creation of IAM rules are dependant on these.
    * Label `public` determines if bucket content should be publicly available. If set to `"yes"` a suffix `-public` will be added to bucket name. IAM rule granting `AllUsers` the role `roles/storage.legacyObjectReader`, enabling public access to objects in the bucket but preventing public listing of bucket content. Default is `"no"`
    * Label `env` can be set to `sandbox` or `production`. If set to `sandbox` suffix will be added to name.
    * Label `tribe` can be set to (`anciliaries`|`autobooking`|`bass`|`bi`|`booking`|`cs-systems`|`data-acquisition`|`finance`|`platform`|`reservations`|`search`)
    * You may add additional labels in form `arbitrary = "label"` but you must follow these [rules](https://cloud.google.com/storage/docs/key-terms#bucket-labels) or the bucket creation will fail on Terraform apply!
<br /> 

* `owner_info` map(string)
    * This info is needed so Infra staff can find Point Of Contact for the bucket.
    * Value `responsible_people` please fill with with email of slack handle. Not optional, but can be empty string if there is no direct responsible person.
    * Value `communication_slack_channel` Name of primary slack channel for communication Examples: #platform-infra
<br /> 
  
* `expiration_rule` object(bool, number)
    * This defines a object [lifecycle](https://cloud.google.com/storage/docs/lifecycle) action with `Delete` action set to value of `days`
    * Is is strongly encouraged to define a expiration_rule for your bucket, please consider usage cases for data in your bucket and set accordingly.
    * If your usage case requires it, it's possible to not set a expiration_rule by setting `delete = false`
<br />

* `members_object_viewer` `members_object_creator` `members_object_admin` `members_storage_admin` list(string)
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

* `conversion_rule` list(map(string))
    * Use these to change the [storage class](https://cloud.google.com/storage/docs/storage-classes) of an object when the object meets conditions specified in the lifecycle rule.
    * This defines a object [lifecycle](https://cloud.google.com/storage/docs/lifecycle) action with `SetStorageClass` with `Age` set to value of `days`
    * Generally we use these downgrade storage class of objects in order to reduce costs.
  
  
```hcl-terraform
  conversion_rule = [
    {
      storage_class = "NEARLINE"
      days          = 90
    },
    {
      storage_class = "ARCHIVE"
      days          = 365
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
  version = "~> 1.0.0" # version >= 1.0.0 and < 1.1.0, e.g. 1.0.X

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
    tribe     = "platform" 
    env       = "sandbox" 
    public    = "no"      
    arbitrary = "label"
  }

  members_object_viewer = [
    "user:random.user@kiwi.com",
    "user:another.one@kiwi.com",
  ]
  members_object_creator = [
    "serviceAccount:something@platform-sandbox-6b6f7700.iam.gserviceaccount.com",
  ]

  expiration_rule = {
    delete  = true
    days    = 730
  }

  conversion_rule = [
    {
      storage_class = "NEARLINE"
      days          = 90
    },
    {
      storage_class = "ARCHIVE"
      days          = 365
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
Add support for versioning