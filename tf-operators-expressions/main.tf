terraform {}

# ============================================================
# VARIABLES
# ============================================================

variable "num_list" {
  type    = list(number)
  default = [1, 2, 3, 4, 5]
}

variable "person_list" {
  type = list(object({
    name  = string
    age   = number
    email = string
  }))

  default = [
    {
      name  = "Ravi Kumar"
      age   = 30
      email = "ravi312@gmail.com"
    },
    {
      name  = "Pavan Singh"
      age   = 45
      email = "ps523@gmail.com"
    }
  ]
}

variable "map_list" {
  type = map(number)

  default = {
    one   = 1
    two   = 2
    three = 3
  }
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "enabled" {
  type    = bool
  default = true
}


# ============================================================
# LOCALS / EXPRESSIONS
# ============================================================

locals {

  # ----------------------------------------------------------
  # 1. Arithmetic Operators
  # ----------------------------------------------------------

  add = 2 + 2
  sub = 10 - 2
  mul = 8 * 3
  div = 10 / 3
  mod = 10 % 4

  # Unary minus
  negative = -10

  # ----------------------------------------------------------
  # 2. Comparison Operators
  # ----------------------------------------------------------

  equal         = 4 == 4
  not_equal     = 2 != 3
  less          = 2 < 5
  greater       = 10 > 5
  less_equal    = 5 <= 5
  greater_equal = 10 >= 10

  # ----------------------------------------------------------
  # 3. Logical Operators
  # ----------------------------------------------------------

  is_dev     = var.environment == "dev"
  is_enabled = var.enabled

  logical_and = local.is_dev && local.is_enabled
  logical_or  = local.is_dev || false
  logical_not = !var.enabled

  # ----------------------------------------------------------
  # 4. Conditional Expression
  #
  # condition ? true_value : false_value
  # ----------------------------------------------------------

  instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"

  deployment_type = (
    var.environment == "prod" && var.enabled
  ) ? "production" : "non-production"

  # ----------------------------------------------------------
  # 5. String Interpolation
  # ----------------------------------------------------------

  application_name = "my-app-${var.environment}"

  # ----------------------------------------------------------
  # 6. List Indexing
  # ----------------------------------------------------------

  first_number = var.num_list[0]
  third_number = var.num_list[2]

  # ----------------------------------------------------------
  # 7. Object Attribute Access
  # ----------------------------------------------------------

  first_person_name  = var.person_list[0].name
  first_person_email = var.person_list[0].email

  # ----------------------------------------------------------
  # 8. FOR Expression - Transform List
  # ----------------------------------------------------------

  double = [
    for num in var.num_list : num * 2
  ]

  # ----------------------------------------------------------
  # 9. FOR Expression - Filter List
  # ----------------------------------------------------------

  odd = [
    for num in var.num_list : num
    if num % 2 != 0
  ]

  # ----------------------------------------------------------
  # 10. FOR Expression - Extract Object Attribute
  # ----------------------------------------------------------

  emails = [
    for person in var.person_list : person.email
  ]

  names = [
    for person in var.person_list : person.name
  ]

  # ----------------------------------------------------------
  # 11. FOR Expression - Map Keys
  # ----------------------------------------------------------

  map_keys = [
    for key, value in var.map_list : key
  ]

  # ----------------------------------------------------------
  # 12. FOR Expression - Map Values
  # ----------------------------------------------------------

  map_values = [
    for key, value in var.map_list : value
  ]

  # ----------------------------------------------------------
  # 13. FOR Expression - Create New Map
  # ----------------------------------------------------------

  double_map = {
    for key, value in var.map_list :
    key => value * 2
  }

  # ----------------------------------------------------------
  # 14. FOR Expression - Filter Map
  # ----------------------------------------------------------

  filtered_map = {
    for key, value in var.map_list :
    key => value
    if value > 1
  }

  # ----------------------------------------------------------
  # 15. Splat Expression
  # ----------------------------------------------------------

  person_emails = var.person_list[*].email

  # ----------------------------------------------------------
  # 16. Built-in Functions
  # ----------------------------------------------------------

  number_count   = length(var.num_list)
  contains_three = contains(var.num_list, 3)

  # ----------------------------------------------------------
  # 17. Mathematical Functions
  # ----------------------------------------------------------

  power        = pow(2, 4)
  rounded_down = floor(10 / 3)

  # ----------------------------------------------------------
  # 18. String Functions
  # ----------------------------------------------------------

  environment_upper = upper(var.environment)
  environment_lower = lower(var.environment)

  # ----------------------------------------------------------
  # 19. Collection Functions
  # ----------------------------------------------------------

  combined_list = concat(
    [1, 2],
    [3, 4]
  )

  flattened_list = flatten([
    [1, 2],
    [3, 4]
  ])

  unique_numbers = distinct([1, 2, 2, 3, 3])

  # ----------------------------------------------------------
  # 20. Merge Function
  # ----------------------------------------------------------

  common_tags = merge(
    {
      Project   = "Terraform"
      ManagedBy = "Terraform"
    },
    {
      Environment = var.environment
    }
  )

  # ----------------------------------------------------------
  # 21. Type Conversion
  # ----------------------------------------------------------

  number_from_string = tonumber("100")
  string_from_number = tostring(100)
  bool_from_string   = tobool("true")

  # ----------------------------------------------------------
  # 22. NULL
  # ----------------------------------------------------------

  optional_value = null

  # ----------------------------------------------------------
  # 23. try()
  #
  # Returns the first expression that succeeds.
  # ----------------------------------------------------------

  first_email = try(
    var.person_list[0].email,
    "no-email"
  )

  # ----------------------------------------------------------
  # 24. can()
  #
  # Checks whether an expression can be evaluated.
  # ----------------------------------------------------------

  first_email_exists = can(
    var.person_list[0].email
  )
}


# ============================================================
# OUTPUTS
# ============================================================

output "arithmetic" {
  value = {
    add      = local.add
    sub      = local.sub
    mul      = local.mul
    div      = local.div
    mod      = local.mod
    negative = local.negative
  }
}

output "comparisons" {
  value = {
    equal         = local.equal
    not_equal     = local.not_equal
    less          = local.less
    greater       = local.greater
    less_equal    = local.less_equal
    greater_equal = local.greater_equal
  }
}

output "logical_operations" {
  value = {
    and = local.logical_and
    or  = local.logical_or
    not = local.logical_not
  }
}

output "conditional" {
  value = {
    instance_type   = local.instance_type
    deployment_type = local.deployment_type
  }
}

output "string_expression" {
  value = local.application_name
}

output "indexed_values" {
  value = {
    first = local.first_number
    third = local.third_number
  }
}

output "person_attributes" {
  value = {
    name  = local.first_person_name
    email = local.first_person_email
  }
}

output "double_numbers" {
  value = local.double
}

output "odd_numbers" {
  value = local.odd
}

output "emails" {
  value = local.emails
}

output "names" {
  value = local.names
}

output "map_keys" {
  value = local.map_keys
}

output "map_values" {
  value = local.map_values
}

output "double_map" {
  value = local.double_map
}

output "filtered_map" {
  value = local.filtered_map
}

output "splat_emails" {
  value = local.person_emails
}

output "function_results" {
  value = {
    count          = local.number_count
    contains_three = local.contains_three
    power          = local.power
    rounded_down   = local.rounded_down
  }
}

output "string_functions" {
  value = {
    upper = local.environment_upper
    lower = local.environment_lower
  }
}

output "collection_functions" {
  value = {
    combined  = local.combined_list
    flattened = local.flattened_list
    unique    = local.unique_numbers
  }
}

output "tags" {
  value = local.common_tags
}

output "type_conversions" {
  value = {
    number = local.number_from_string
    string = local.string_from_number
    bool   = local.bool_from_string
  }
}

output "null_value" {
  value = local.optional_value
}

output "try_result" {
  value = local.first_email
}

output "can_result" {
  value = local.first_email_exists
}