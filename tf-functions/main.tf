terraform {}

# ============================================================
# VARIABLES
# ============================================================

variable "name" {
  type    = string
  default = "  Shaad Bangi  "
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "numbers" {
  type    = list(number)
  default = [10, 20, 20, 30, 40, 50]
}

variable "users" {
  type = list(object({
    name  = string
    age   = number
    email = string
  }))

  default = [
    {
      name  = "Ravi"
      age   = 30
      email = "ravi@gmail.com"
    },
    {
      name  = "Pavan"
      age   = 45
      email = "pavan@gmail.com"
    },
    {
      name  = "Amit"
      age   = 25
      email = "amit@gmail.com"
    }
  ]
}

variable "ports" {
  type = map(number)

  default = {
    http  = 80
    https = 443
    ssh   = 22
  }
}


# ============================================================
# LOCALS
# ============================================================

locals {

  # ==========================================================
  # 1. STRING FUNCTIONS
  # ==========================================================

  # Removes leading and trailing whitespace.
  trimmed_name = trimspace(var.name)

  # Converts string to uppercase.
  upper_name = upper(local.trimmed_name)

  # Converts string to lowercase.
  lower_name = lower(local.trimmed_name)

  # Replace part of a string.
  environment_name = replace(
    var.environment,
    "dev",
    "development"
  )

  # Extract part of a string.
  # substr(string, offset, length)
  short_name = substr(local.trimmed_name, 0, 5)

  # Check whether string starts with given prefix.
  starts_with_shaad = startswith(local.trimmed_name, "Shaad")

  # Check whether string ends with given suffix.
  ends_with_i = endswith(local.trimmed_name, "i")

  # Check whether string contains another string.
  contains_bangi = strcontains(local.trimmed_name, "Bangi")

  # Convert list into a single string.
  joined_numbers = join("-", ["10", "20", "30"])

  # Split one string into a list.
  split_values = split(",", "dev,stage,prod")

  # Format string.
  formatted_message = format(
    "Environment: %s | Region: %s",
    var.environment,
    "us-east-1"
  )

  # Format number using format().
  formatted_number = format(
    "Port: %d",
    8080
  )

  # ==========================================================
  # 2. MATH FUNCTIONS
  # ==========================================================

  absolute_value = abs(-25)

  rounded_up = ceil(10.2)

  rounded_down = floor(10.8)

  largest_number = max(10, 20, 5, 100, 30)

  smallest_number = min(10, 20, 5, 100, 30)

  power_value = pow(2, 4)

  logarithm = log(100, 10)

  positive_or_negative = signum(-50)

  # ==========================================================
  # 3. COLLECTION FUNCTIONS
  # ==========================================================

  # Number of elements.
  number_count = length(var.numbers)

  # Checks whether a list contains a value.
  contains_30 = contains(var.numbers, 30)

  # Removes duplicate values.
  unique_numbers = distinct(var.numbers)

  # Combines two or more lists.
  combined_numbers = concat(
    [1, 2, 3],
    [4, 5, 6]
  )

  # Reverses a list.
  reversed_numbers = reverse([1, 2, 3, 4, 5])

  # Sorts a list.
  sorted_numbers = sort(["banana", "apple", "mango"])

  # Extract part of a list.
  sliced_numbers = slice(
    [10, 20, 30, 40, 50],
    1,
    4
  )

  # Selects an element from a list.
  selected_element = element(
    ["dev", "stage", "prod"],
    1
  )

  # Converts nested lists into one list.
  flattened_numbers = flatten([
    [1, 2],
    [3, 4],
    [5, 6]
  ])

  # ==========================================================
  # 4. MAP / OBJECT FUNCTIONS
  # ==========================================================

  # Get all keys from a map.
  port_keys = keys(var.ports)

  # Get all values from a map.
  port_values = values(var.ports)

  # Get a value using a key.
  http_port = lookup(
    var.ports,
    "http",
    0
  )

  # Merge maps.
  common_tags = merge(
    {
      Project   = "Terraform"
      ManagedBy = "Terraform"
    },
    {
      Environment = var.environment
    }
  )

  # Create a map from two lists.
  created_map = zipmap(
    ["dev", "stage", "prod"],
    [1, 2, 3]
  )

  # ==========================================================
  # 5. SET FUNCTIONS
  # ==========================================================

  set_a = toset(["dev", "stage", "prod"])
  set_b = toset(["stage", "prod", "test"])

  # Values present in either set.
  union_values = setunion(
    local.set_a,
    local.set_b
  )

  # Values present in both sets.
  intersection_values = setintersection(
    local.set_a,
    local.set_b
  )

  # Values present in first set but not second.
  difference_values = setdifference(
    local.set_a,
    local.set_b
  )

  # ==========================================================
  # 6. TYPE CONVERSION FUNCTIONS
  # ==========================================================

  number_value = tonumber("100")

  string_value = tostring(500)

  bool_value = tobool("true")

  list_value = tolist(
    toset(["dev", "stage", "prod"])
  )

  set_value = toset(
    ["dev", "dev", "stage"]
  )

  # ==========================================================
  # 7. NULL / DEFAULT VALUE FUNCTIONS
  # ==========================================================

  # coalesce() returns the first non-null value.
  default_environment = coalesce(
    null,
    null,
    var.environment,
    "unknown"
  )

  # compact() removes empty strings from a list.
  cleaned_list = compact([
    "dev",
    "",
    "prod",
    "",
    "stage"
  ])

  # coalescelist() returns the first non-empty list.
  selected_list = coalescelist(
    [],
    [],
    ["dev", "prod"]
  )

  # ==========================================================
  # 8. ERROR-HANDLING FUNCTIONS
  # ==========================================================

  # try() returns the first expression that succeeds.
  first_user_email = try(
    var.users[0].email,
    "no-email"
  )

  # can() checks whether an expression can be evaluated.
  first_user_has_email = can(
    var.users[0].email
  )

  # ==========================================================
  # 9. ENCODING / DECODING FUNCTIONS
  # ==========================================================

  # Base64 encoding.
  encoded_text = base64encode("Hello Terraform")

  # Base64 decoding.
  decoded_text = base64decode(
    base64encode("Hello Terraform")
  )

  # Convert Terraform value to JSON.
  json_text = jsonencode({
    name        = "Shaad"
    environment = var.environment
    port        = 8080
  })

  # Convert JSON string back to Terraform value.
  decoded_json = jsondecode(
    jsonencode({
      name        = "Shaad"
      environment = var.environment
      port        = 8080
    })
  )

  # ==========================================================
  # 10. DATE / TIME FUNCTIONS
  # ==========================================================

  # Current timestamp.
  current_timestamp = timestamp()

  # Format timestamp into readable date.
  formatted_date = formatdate(
    "YYYY-MM-DD",
    timestamp()
  )

  # Add time to current timestamp.
  future_time = timeadd(
    timestamp(),
    "24h"
  )

  # ==========================================================
  # 11. LIST OF OBJECTS + FOR EXPRESSIONS
  # ==========================================================

  user_names = [
    for user in var.users : user.name
  ]

  user_emails = [
    for user in var.users : user.email
  ]

  adult_users = [
    for user in var.users : user.name
    if user.age >= 30
  ]

  # Create a map:
  # username => email
  user_email_map = {
    for user in var.users :
    user.name => user.email
  }

  # Create a map:
  # username => age
  user_age_map = {
    for user in var.users :
    user.name => user.age
  }

  # ==========================================================
  # 12. USEFUL COMBINATIONS
  # ==========================================================

  # Build a clean resource name from multiple expressions.
  resource_name = join(
    "-",
    [
      lower(trimspace(var.name)),
      var.environment,
      "server"
    ]
  )

  # Create tag values dynamically.
  deployment_tag = format(
    "%s-%s",
    upper(var.environment),
    "APP"
  )

  # Select instance type dynamically.
  instance_type = contains(
    ["prod", "production"],
    var.environment
  ) ? "t3.medium" : "t3.micro"
}


# ============================================================
# OUTPUTS
# ============================================================

output "string_functions" {
  value = {
    trimmed          = local.trimmed_name
    upper            = local.upper_name
    lower            = local.lower_name
    replaced         = local.environment_name
    substring        = local.short_name
    starts_with      = local.starts_with_shaad
    ends_with        = local.ends_with_i
    contains         = local.contains_bangi
    joined           = local.joined_numbers
    split            = local.split_values
    formatted        = local.formatted_message
    formatted_number = local.formatted_number
  }
}

output "math_functions" {
  value = {
    absolute = local.absolute_value
    ceil     = local.rounded_up
    floor    = local.rounded_down
    max      = local.largest_number
    min      = local.smallest_number
    power    = local.power_value
    log      = local.logarithm
    signum   = local.positive_or_negative
  }
}

output "collection_functions" {
  value = {
    length    = local.number_count
    contains  = local.contains_30
    distinct  = local.unique_numbers
    concat    = local.combined_numbers
    reverse   = local.reversed_numbers
    sort      = local.sorted_numbers
    slice     = local.sliced_numbers
    element   = local.selected_element
    flatten   = local.flattened_numbers
  }
}

output "map_functions" {
  value = {
    keys       = local.port_keys
    values     = local.port_values
    http_port  = local.http_port
    common_tags = local.common_tags
    created_map = local.created_map
  }
}

output "set_functions" {
  value = {
    union        = local.union_values
    intersection = local.intersection_values
    difference   = local.difference_values
  }
}

output "type_conversions" {
  value = {
    number = local.number_value
    string = local.string_value
    bool   = local.bool_value
    list   = local.list_value
    set    = local.set_value
  }
}

output "default_functions" {
  value = {
    environment = local.default_environment
    cleaned     = local.cleaned_list
    selected    = local.selected_list
  }
}

output "error_handling" {
  value = {
    email     = local.first_user_email
    email_exists = local.first_user_has_email
  }
}

output "encoding" {
  value = {
    encoded      = local.encoded_text
    decoded      = local.decoded_text
    json         = local.json_text
    decoded_json = local.decoded_json
  }
}

output "date_time" {
  value = {
    current_timestamp = local.current_timestamp
    formatted_date    = local.formatted_date
    future_time       = local.future_time
  }
}

output "users" {
  value = {
    names      = local.user_names
    emails     = local.user_emails
    adults     = local.adult_users
    email_map  = local.user_email_map
    age_map    = local.user_age_map
  }
}

output "useful_combinations" {
  value = {
    resource_name  = local.resource_name
    deployment_tag = local.deployment_tag
    instance_type  = local.instance_type
  }
}