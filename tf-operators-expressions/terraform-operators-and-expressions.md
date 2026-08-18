# Terraform Operators and Expressions

This file is a practice guide for **Terraform operators and expressions**.

Terraform uses expressions to calculate values, compare values, transform collections, access data, and build dynamic configuration.

---

# 1. What Is an Expression?

An **expression** is something Terraform evaluates to produce a value.

For example:

```hcl
2 + 2
```

produces:

```text
4
```

Another example:

```hcl
"hello ${var.name}"
```

produces a string.

Another:

```hcl
[for num in var.numbers : num * 2]
```

produces a list.

So:

```text
Expression
    ↓
Terraform evaluates it
    ↓
Value
```

Examples:

```hcl
2 + 2

var.environment

local.region

var.name == "dev"

var.enabled ? "yes" : "no"

[for num in var.numbers : num * 2]
```

---

# 2. Variables Used in This Practice

```hcl
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
```

---

# 3. Arithmetic Operators

Terraform supports the following arithmetic operators:

| Operator | Meaning            | Example  | Result |
| -------- | ------------------ | -------- | -----: |
| `+`      | Addition           | `2 + 2`  |    `4` |
| `-`      | Subtraction        | `10 - 2` |    `8` |
| `*`      | Multiplication     | `8 * 3`  |   `24` |
| `/`      | Division           | `10 / 2` |    `5` |
| `%`      | Remainder / modulo | `10 % 4` |    `2` |

Example:

```hcl
locals {
  addition       = 2 + 2
  subtraction    = 10 - 2
  multiplication = 8 * 3
  division       = 10 / 2
  modulo         = 10 % 4
}
```

## Modulo

Modulo returns the remainder:

```hcl
10 % 4
```

Result:

```text
2
```

because:

```text
10 ÷ 4 = 2 remainder 2
```

This is very useful for checking odd/even numbers:

```hcl
num % 2 == 0
```

means the number is even.

```hcl
num % 2 != 0
```

means the number is odd.

---

# 4. Unary Operators

Terraform supports unary operators.

## Unary Minus

```hcl
negative = -10
```

Result:

```text
-10
```

You can also negate an expression:

```hcl
value = -(10 - 3)
```

Result:

```text
-7
```

## Logical NOT

The `!` operator reverses a boolean:

```hcl
enabled = true

disabled = !local.enabled
```

Result:

```text
false
```

---

# 5. Comparison Operators

Comparison expressions return a boolean:

```text
true
or
false
```

| Operator | Meaning               |
| -------- | --------------------- |
| `==`     | Equal                 |
| `!=`     | Not equal             |
| `<`      | Less than             |
| `>`      | Greater than          |
| `<=`     | Less than or equal    |
| `>=`     | Greater than or equal |

Examples:

```hcl
locals {
  equal       = 4 == 4
  not_equal   = 2 != 3
  less        = 2 < 5
  greater     = 10 > 5
  less_equal  = 5 <= 5
  greater_equal = 10 >= 10
}
```

Results:

```text
4 == 4   → true
2 != 3   → true
2 < 5    → true
10 > 5   → true
5 <= 5   → true
10 >= 10 → true
```

---

# 6. Logical Operators

Terraform supports logical operators for combining boolean expressions.

| Operator | Meaning |   |    |
| -------- | ------- | - | -- |
| `&&`     | AND     |   |    |
| `        |         | ` | OR |
| `!`      | NOT     |   |    |

## AND

Both conditions must be true.

```hcl
both_true = true && true
```

Result:

```text
true
```

Example:

```hcl
is_dev     = var.environment == "dev"
is_enabled = var.enabled

can_deploy = local.is_dev && local.is_enabled
```

---

## OR

At least one condition must be true.

```hcl
result = false || true
```

Result:

```text
true
```

Example:

```hcl
is_dev  = var.environment == "dev"
is_prod = var.environment == "prod"

known_environment = local.is_dev || local.is_prod
```

---

## NOT

Reverses a boolean:

```hcl
result = !true
```

Result:

```text
false
```

---

# 7. Operator Precedence

Terraform follows operator precedence rules.

For example:

```hcl
2 + 3 * 4
```

is evaluated as:

```text
2 + (3 * 4)
```

Result:

```text
14
```

not:

```text
(2 + 3) * 4
```

which would be `20`.

When the expression might be confusing, use parentheses:

```hcl
result = (2 + 3) * 4
```

Result:

```text
20
```

Parentheses make the intended order obvious.

---

# 8. Conditional Expression

Terraform has a conditional expression:

```hcl
condition ? true_value : false_value
```

Example:

```hcl
locals {
  server_size = var.environment == "prod" ? "t3.medium" : "t3.micro"
}
```

If:

```text
environment = "prod"
```

then:

```text
t3.medium
```

Otherwise:

```text
t3.micro
```

Think of it like:

```text
if condition
    use true_value
else
    use false_value
```

Another example:

```hcl
locals {
  message = var.enabled ? "Deployment enabled" : "Deployment disabled"
}
```

---

# 9. String Interpolation

Terraform allows expressions inside strings using:

```hcl
${expression}
```

Example:

```hcl
variable "environment" {
  default = "dev"
}

locals {
  app_name = "my-app-${var.environment}"
}
```

Result:

```text
my-app-dev
```

You can combine multiple expressions:

```hcl
locals {
  name = "${var.environment}-${var.num_list[0]}"
}
```

Result:

```text
dev-1
```

For simple cases, Terraform can often automatically convert expressions inside strings, but `${...}` is useful when clearly embedding an expression.

---

# 10. List Indexing

Lists use zero-based indexing.

Given:

```hcl
variable "num_list" {
  default = [1, 2, 3, 4, 5]
}
```

Access elements like this:

```hcl
var.num_list[0]
```

Result:

```text
1
```

```hcl
var.num_list[2]
```

Result:

```text
3
```

```hcl
var.num_list[4]
```

Result:

```text
5
```

Important:

```text
[1, 2, 3, 4, 5]
 ↑  ↑  ↑  ↑  ↑
 0  1  2  3  4
```

---

# 11. Map Access

Given:

```hcl
variable "map_list" {
  default = {
    one   = 1
    two   = 2
    three = 3
  }
}
```

Access a value by key:

```hcl
var.map_list["one"]
```

Result:

```text
1
```

You can also use the attribute-style syntax when the key is a valid identifier:

```hcl
var.map_list.one
```

Result:

```text
1
```

Bracket notation is more general and is required when the key is not a valid identifier.

---

# 12. Object Attribute Access

An object contains named attributes.

Given:

```hcl
variable "person_list" {
  type = list(object({
    name  = string
    age   = number
    email = string
  }))
}
```

The first person can be accessed using:

```hcl
var.person_list[0]
```

Then an attribute:

```hcl
var.person_list[0].name
```

Result:

```text
Ravi Kumar
```

Email:

```hcl
var.person_list[0].email
```

Result:

```text
ravi312@gmail.com
```

---

# 13. `for` Expressions

Terraform's `for` expression is used to transform or filter collections.

Basic syntax:

```hcl
[for item in collection : expression]
```

Example:

```hcl
locals {
  double = [
    for num in var.num_list : num * 2
  ]
}
```

Input:

```text
[1, 2, 3, 4, 5]
```

Output:

```text
[2, 4, 6, 8, 10]
```

Conceptually:

```text
num = 1 → 1 * 2 → 2
num = 2 → 2 * 2 → 4
num = 3 → 3 * 2 → 6
num = 4 → 4 * 2 → 8
num = 5 → 5 * 2 → 10
```

---

# 14. `for` Expression With Filtering

You can add an `if` condition:

```hcl
locals {
  odd = [
    for num in var.num_list : num
    if num % 2 != 0
  ]
}
```

This means:

```text
for each number
    keep it only if
    number % 2 != 0
```

Input:

```text
[1, 2, 3, 4, 5]
```

Output:

```text
[1, 3, 5]
```

---

# 15. `for` Expression With Objects

You can access object attributes while iterating.

```hcl
locals {
  emails = [
    for person in var.person_list : person.email
  ]
}
```

Result:

```text
[
  "ravi312@gmail.com",
  "ps523@gmail.com"
]
```

You can select names:

```hcl
locals {
  names = [
    for person in var.person_list : person.name
  ]
}
```

Or ages:

```hcl
locals {
  ages = [
    for person in var.person_list : person.age
  ]
}
```

---

# 16. Two Variables in a `for` Expression

For maps, you can receive both the key and value.

```hcl
locals {
  map_keys = [
    for key, value in var.map_list : key
  ]
}
```

Result:

```text
[
  "one",
  "two",
  "three"
]
```

Values:

```hcl
locals {
  map_values = [
    for key, value in var.map_list : value
  ]
}
```

Result:

```text
[
  1,
  2,
  3
]
```

If you don't need one of the values, `_` can be used for an ignored variable:

```hcl
locals {
  map_keys = [
    for key, _ in var.map_list : key
  ]
}
```

---

# 17. Creating a Map With a `for` Expression

Square brackets produce a collection such as a list.

Curly brackets can produce a map/object:

```hcl
locals {
  double_map = {
    for key, value in var.map_list :
    key => value * 2
  }
}
```

Input:

```text
{
  one   = 1
  two   = 2
  three = 3
}
```

Output:

```text
{
  one   = 2
  two   = 4
  three = 6
}
```

Important mental model:

```text
[for ...] → list
{for ...} → map/object
```

---

# 18. Filtering a Map

You can also filter maps:

```hcl
locals {
  values_greater_than_one = {
    for key, value in var.map_list :
    key => value
    if value > 1
  }
}
```

Result:

```text
{
  two   = 2
  three = 3
}
```

---

# 19. Splat Expressions

A splat expression is useful for extracting the same attribute from multiple objects.

Given a list of objects:

```hcl
var.person_list
```

You can get all emails with:

```hcl
var.person_list[*].email
```

This produces:

```text
[
  "ravi312@gmail.com",
  "ps523@gmail.com"
]
```

The equivalent `for` expression is:

```hcl
[
  for person in var.person_list : person.email
]
```

For simple attribute extraction, splat syntax can be shorter.

---

# 20. Function Calls Are Expressions

Terraform provides many built-in functions.

Example:

```hcl
length(var.num_list)
```

Result:

```text
5
```

Other examples:

```hcl
upper("terraform")
```

Result:

```text
TERRAFORM
```

```hcl
lower("TERRAFORM")
```

Result:

```text
terraform
```

```hcl
max(10, 20, 5)
```

Result:

```text
20
```

```hcl
min(10, 20, 5)
```

Result:

```text
5
```

Functions are also expressions because Terraform evaluates them to produce a value.

---

# 21. Math Functions

Some useful mathematical functions:

```hcl
pow(2, 4)
```

Result:

```text
16
```

`pow()` can be used instead of Python-style:

```text
2 ** 4
```

Terraform does not use Python's `**` operator.

---

## Floor

Terraform provides the `floor()` function:

```hcl
floor(10 / 3)
```

Result:

```text
3
```

Terraform does not use Python-style:

```text
10 // 3
```

Instead, use the appropriate function such as:

```hcl
floor(10 / 3)
```

---

# 22. String Functions

Examples:

```hcl
upper("terraform")
```

```hcl
lower("TERRAFORM")
```

```hcl
trimspace("  hello  ")
```

```hcl
replace("hello-world", "-", "_")
```

These are all expressions because they return values.

---

# 23. Collection Functions

Some useful collection functions:

## `length`

```hcl
length(var.num_list)
```

Returns:

```text
5
```

## `contains`

```hcl
contains(var.num_list, 3)
```

Returns:

```text
true
```

## `concat`

Combines lists:

```hcl
concat([1, 2], [3, 4])
```

Result:

```text
[1, 2, 3, 4]
```

## `flatten`

Flattens nested lists:

```hcl
flatten([
  [1, 2],
  [3, 4]
])
```

Result:

```text
[1, 2, 3, 4]
```

## `distinct`

Removes duplicate values:

```hcl
distinct([1, 2, 2, 3, 3])
```

Result:

```text
[1, 2, 3]
```

---

# 24. `merge()` Function

`merge()` combines maps or objects.

Example:

```hcl
locals {
  common_tags = {
    Project   = "Terraform"
    ManagedBy = "Terraform"
  }

  environment_tags = {
    Environment = var.environment
  }

  final_tags = merge(
    local.common_tags,
    local.environment_tags
  )
}
```

Result:

```text
{
  Project     = "Terraform"
  ManagedBy   = "Terraform"
  Environment = "dev"
}
```

This is commonly used for Terraform resource tags.

---

# 25. Type Conversion Functions

Terraform has functions for converting values between compatible types.

Examples:

```hcl
tonumber("10")
```

Result:

```text
10
```

```hcl
tostring(100)
```

Result:

```text
"100"
```

```hcl
tobool("true")
```

Result:

```text
true
```

You should use these when you explicitly need a particular type.

---

# 26. `try()` Function

`try()` can return the first expression that succeeds.

Example:

```hcl
locals {
  example = try(var.person_list[0].email, "no-email")
}
```

If the email expression succeeds, Terraform returns the email.

Otherwise:

```text
no-email
```

`try()` is particularly useful when working with optional or potentially missing values.

---

# 27. `can()` Function

`can()` checks whether an expression can be evaluated successfully.

Example:

```hcl
locals {
  valid_email = can(var.person_list[0].email)
}
```

The result is:

```text
true
```

or:

```text
false
```

`can()` is especially useful in validation expressions.

---

# 28. `null`

Terraform has a special value called `null`.

Example:

```hcl
locals {
  optional_value = null
}
```

`null` generally means:

```text
No value
```

It is different from:

```text
""
```

because an empty string is still a string containing zero characters.

It is also different from:

```text
0
```

because `0` is a number.

So:

```text
null
""
0
false
```

are different values.

---

# 29. Boolean Values

Terraform supports:

```hcl
true
false
```

Example:

```hcl
locals {
  deployment_allowed = true
}
```

Boolean expressions commonly come from comparisons:

```hcl
locals {
  is_production = var.environment == "prod"
}
```

---

# 30. Conditional + Operators Together

Expressions can be combined.

```hcl
locals {
  instance_type = (
    var.environment == "prod" && var.enabled
  ) ? "t3.medium" : "t3.micro"
}
```

The expression performs:

```text
environment == "prod"
        +
enabled
        ↓
      &&
        ↓
conditional operator
        ↓
instance type
```

This shows how multiple Terraform expression features work together.

---

# 31. Complete Practice Example

```hcl
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

locals {

  # -----------------------------------
  # Arithmetic operators
  # -----------------------------------

  add = 2 + 2
  mul = 8 * 3
  sub = 10 - 2
  div = 10 / 3
  mod = 10 % 4

  # -----------------------------------
  # Comparison operators
  # -----------------------------------

  equal         = 4 == 4
  not_equal     = 2 != 3
  less          = 2 < 5
  greater       = 10 > 5
  less_equal    = 5 <= 5
  greater_equal = 10 >= 10

  # -----------------------------------
  # Logical operators
  # -----------------------------------

  is_dev     = var.environment == "dev"
  is_enabled = var.enabled

  can_deploy = local.is_dev && local.is_enabled

  # -----------------------------------
  # Conditional expression
  # -----------------------------------

  instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"

  # -----------------------------------
  # List transformation
  # -----------------------------------

  double = [
    for num in var.num_list : num * 2
  ]

  # -----------------------------------
  # List filtering
  # -----------------------------------

  odd = [
    for num in var.num_list : num
    if num % 2 != 0
  ]

  # -----------------------------------
  # Object attribute extraction
  # -----------------------------------

  emails = [
    for person in var.person_list : person.email
  ]

  names = [
    for person in var.person_list : person.name
  ]

  # -----------------------------------
  # Map key extraction
  # -----------------------------------

  map_keys = [
    for key, value in var.map_list : key
  ]

  # -----------------------------------
  # Map value extraction
  # -----------------------------------

  map_values = [
    for key, value in var.map_list : value
  ]

  # -----------------------------------
  # Creating a new map
  # -----------------------------------

  double_map = {
    for key, value in var.map_list :
    key => value * 2
  }

  # -----------------------------------
  # Filtering a map
  # -----------------------------------

  filtered_map = {
    for key, value in var.map_list :
    key => value
    if value > 1
  }

  # -----------------------------------
  # Splat expression
  # -----------------------------------

  person_emails = var.person_list[*].email

  # -----------------------------------
  # Function expressions
  # -----------------------------------

  number_count = length(var.num_list)

  contains_three = contains(var.num_list, 3)

  # -----------------------------------
  # Math functions
  # -----------------------------------

  power = pow(2, 4)

  rounded_down = floor(10 / 3)

  # -----------------------------------
  # String functions
  # -----------------------------------

  environment_upper = upper(var.environment)

  # -----------------------------------
  # String interpolation
  # -----------------------------------

  application_name = "my-app-${var.environment}"

  # -----------------------------------
  # Combining maps
  # -----------------------------------

  common_tags = merge(
    {
      Project   = "Terraform"
      ManagedBy = "Terraform"
    },
    {
      Environment = var.environment
    }
  )

  # -----------------------------------
  # Conditional + logical operators
  # -----------------------------------

  deployment_type = (
    var.environment == "prod" && var.enabled
  ) ? "production-deployment" : "non-production-deployment"
}
```

---

# 32. Outputs

You can inspect the results using outputs:

```hcl
output "arithmetic" {
  value = {
    add = local.add
    mul = local.mul
    sub = local.sub
    div = local.div
    mod = local.mod
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

output "logical" {
  value = {
    is_dev     = local.is_dev
    is_enabled = local.is_enabled
    can_deploy = local.can_deploy
  }
}

output "conditional" {
  value = local.instance_type
}

output "doubled_numbers" {
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

output "person_emails" {
  value = local.person_emails
}

output "function_results" {
  value = {
    number_count  = local.number_count
    contains_three = local.contains_three
    power         = local.power
    rounded_down  = local.rounded_down
  }
}

output "application_name" {
  value = local.application_name
}

output "tags" {
  value = local.common_tags
}
```

---

# 33. Important Operator/Expression Summary

## Arithmetic

```text
+
-
*
/
%
```

## Comparison

```text
==
!=
<
>
<=
>=
```

## Logical

```text
&&
||
!
```

## Conditional

```text
condition ? true_value : false_value
```

## Collection / access expressions

```text
list[index]

map["key"]

object.attribute

list[*].attribute
```

## `for` expressions

```text
[for item in collection : expression]

[for item in collection : expression if condition]

{for key, value in map : key => expression}
```

## Function expressions

```text
length(...)
upper(...)
lower(...)
merge(...)
concat(...)
flatten(...)
distinct(...)
pow(...)
floor(...)
try(...)
can(...)
```

---

# 34. Python Comparison

Terraform is similar to programming languages, but the syntax is not identical.

### Terraform

```hcl
[for num in var.num_list : num * 2]
```

Conceptually similar to Python:

```python
[num * 2 for num in numbers]
```

Terraform:

```hcl
num % 2 != 0
```

Python:

```python
num % 2 != 0
```

But Terraform does **not** use Python's:

```text
**
//
```

Use functions instead:

```hcl
pow(2, 4)

floor(10 / 3)
```

Also remember that Terraform configuration is **declarative**. A `for` expression creates a value; it is not an imperative loop that performs statements one by one.

---

# 35. Most Important Mental Model

Think of Terraform expressions like this:

```text
INPUT
  │
  ▼
variable
  │
  ▼
expression
  │
  ├── arithmetic
  ├── comparison
  ├── logical
  ├── conditional
  ├── function
  ├── for expression
  ├── indexing
  ├── attribute access
  └── collection transformation
  │
  ▼
value
  │
  ▼
resource / output / local
```

The most important distinction is:

```text
Variable
    ↓
Provides data

Expression
    ↓
Calculates / transforms / accesses data

Local
    ↓
Stores a reusable expression result

Resource
    ↓
Uses the resulting value
```

This is why Terraform becomes much more powerful when expressions and locals are combined.
