# Terraform Functions

Terraform provides many **built-in functions** for manipulating strings, numbers, lists, maps, sets, objects, JSON, timestamps, and other values.

A Terraform function follows this basic syntax:

```hcl
function_name(argument1, argument2, ...)
```

For example:

```hcl
length([10, 20, 30])
```

Terraform evaluates the expression and returns:

```text
3
```

Functions are expressions, so they can be used inside:

* variables
* locals
* resource arguments
* outputs
* conditional expressions
* `for` expressions
* other functions

---

# 1. String Functions

String functions are used when working with text.

## `trimspace()`

Removes leading and trailing whitespace.

```hcl
trimspace("  hello  ")
```

Result:

```text
"hello"
```

Useful when:

* input may contain unwanted spaces
* cleaning user-provided values
* normalizing names before using them in resource names

Example:

```hcl
locals {
  clean_name = trimspace(var.name)
}
```

---

## `upper()`

Converts text to uppercase.

```hcl
upper("terraform")
```

Result:

```text
"TERRAFORM"
```

Useful for:

* labels
* tags
* generated messages

---

## `lower()`

Converts text to lowercase.

```hcl
lower("TERRAFORM")
```

Result:

```text
"terraform"
```

This is particularly useful when resource naming must follow a consistent lowercase convention.

---

## `replace()`

Replaces occurrences of one string with another.

```hcl
replace("dev-environment", "dev", "production")
```

Result:

```text
"production-environment"
```

Example:

```hcl
locals {
  environment = replace(var.environment, "dev", "development")
}
```

---

## `substr()`

Extracts a portion of a string.

Syntax:

```hcl
substr(string, offset, length)
```

Example:

```hcl
substr("Terraform", 0, 4)
```

Result:

```text
"Terr"
```

Terraform uses a **zero-based offset**.

---

## `startswith()`

Checks whether a string starts with another string.

```hcl
startswith("terraform-project", "terraform")
```

Result:

```text
true
```

Useful for validation and conditional logic.

---

## `endswith()`

Checks whether a string ends with another string.

```hcl
endswith("app-prod", "prod")
```

Result:

```text
true
```

---

## `strcontains()`

Checks whether one string exists inside another.

```hcl
strcontains("terraform-project", "form")
```

Result:

```text
true
```

This is useful when a configuration needs to react to part of a string.

---

## `join()`

Combines list elements into one string.

```hcl
join("-", ["aws", "dev", "server"])
```

Result:

```text
"aws-dev-server"
```

A very common Terraform use case is building names:

```hcl
locals {
  resource_name = join(
    "-",
    [var.project, var.environment, "server"]
  )
}
```

---

## `split()`

Splits one string into a list.

```hcl
split(",", "dev,stage,prod")
```

Result:

```hcl
[
  "dev",
  "stage",
  "prod"
]
```

Very useful when input arrives as a comma-separated string.

---

## `format()`

Creates a formatted string.

```hcl
format(
  "Environment: %s | Port: %d",
  "prod",
  443
)
```

Result:

```text
"Environment: prod | Port: 443"
```

Common format specifiers include:

```text
%s  → string
%d  → integer
%f  → floating-point number
```

---

# 2. Mathematical Functions

Terraform provides functions for common mathematical operations.

## `abs()`

Returns the absolute value.

```hcl
abs(-25)
```

Result:

```text
25
```

---

## `ceil()`

Rounds a number upward.

```hcl
ceil(10.2)
```

Result:

```text
11
```

---

## `floor()`

Rounds a number downward.

```hcl
floor(10.8)
```

Result:

```text
10
```

Terraform does not use Python's:

```text
//
```

for floor division.

Instead:

```hcl
floor(10 / 3)
```

returns:

```text
3
```

---

## `max()`

Returns the largest number.

```hcl
max(10, 20, 5, 100)
```

Result:

```text
100
```

Useful for selecting the largest value among configuration inputs.

---

## `min()`

Returns the smallest number.

```hcl
min(10, 20, 5, 100)
```

Result:

```text
5
```

---

## `pow()`

Raises a number to a power.

```hcl
pow(2, 4)
```

Result:

```text
16
```

This is the Terraform alternative to Python's:

```text
2 ** 4
```

---

## `log()`

Calculates a logarithm.

```hcl
log(100, 10)
```

Result:

```text
2
```

The first argument is the number and the second is the base.

---

## `signum()`

Returns the sign of a number.

```hcl
signum(-50)
```

Result:

```text
-1
```

Typical results:

```text
positive → 1
zero     → 0
negative → -1
```

---

# 3. Collection Functions

Collection functions are extremely important in Terraform because Terraform configurations frequently work with lists, maps, sets, and objects.

---

## `length()`

Returns the number of elements.

```hcl
length([10, 20, 30])
```

Result:

```text
3
```

For a string:

```hcl
length("terraform")
```

returns:

```text
9
```

---

## `contains()`

Checks whether a collection contains a value.

```hcl
contains(["dev", "stage", "prod"], "prod")
```

Result:

```text
true
```

Very useful inside conditional expressions:

```hcl
var.environment == "prod"
```

or:

```hcl
contains(["prod", "production"], var.environment)
```

---

## `distinct()`

Removes duplicate values.

```hcl
distinct([1, 2, 2, 3, 3])
```

Result:

```text
[1, 2, 3]
```

Useful when inputs may contain duplicates.

---

## `concat()`

Combines lists.

```hcl
concat(
  [1, 2],
  [3, 4]
)
```

Result:

```text
[1, 2, 3, 4]
```

---

## `reverse()`

Reverses a list.

```hcl
reverse([1, 2, 3, 4])
```

Result:

```text
[4, 3, 2, 1]
```

---

## `sort()`

Sorts a list of strings.

```hcl
sort(["banana", "apple", "mango"])
```

Result:

```text
[
  "apple",
  "banana",
  "mango"
]
```

---

## `slice()`

Extracts part of a list.

Syntax:

```hcl
slice(list, start, end)
```

Example:

```hcl
slice(
  [10, 20, 30, 40, 50],
  1,
  4
)
```

Result:

```text
[20, 30, 40]
```

The end index is exclusive.

---

## `element()`

Returns an element from a list.

```hcl
element(
  ["dev", "stage", "prod"],
  1
)
```

Result:

```text
"stage"
```

---

## `flatten()`

Turns nested lists into a single list.

```hcl
flatten([
  [1, 2],
  [3, 4],
  [5, 6]
])
```

Result:

```text
[1, 2, 3, 4, 5, 6]
```

Useful when working with dynamically generated nested collections.

---

# 4. Map and Object Functions

---

## `keys()`

Returns all keys from a map.

```hcl
keys({
  http  = 80
  https = 443
})
```

Result:

```text
[
  "http",
  "https"
]
```

---

## `values()`

Returns all values from a map.

```hcl
values({
  http  = 80
  https = 443
})
```

Result:

```text
[
  80,
  443
]
```

---

## `lookup()`

Gets a map value using a key.

Syntax:

```hcl
lookup(map, key, default)
```

Example:

```hcl
lookup(
  {
    http  = 80
    https = 443
  },
  "http",
  0
)
```

Result:

```text
80
```

The third argument is the fallback value if the key does not exist.

---

## `merge()`

Combines multiple maps or objects.

```hcl
merge(
  {
    Project = "Terraform"
  },
  {
    Environment = "dev"
  }
)
```

Result:

```hcl
{
  Project     = "Terraform"
  Environment = "dev"
}
```

This is one of the most useful Terraform functions for AWS tags.

Example:

```hcl
locals {
  common_tags = merge(
    var.additional_tags,
    {
      ManagedBy = "Terraform"
    }
  )
}
```

---

## `zipmap()`

Creates a map from two lists.

```hcl
zipmap(
  ["dev", "stage", "prod"],
  [1, 2, 3]
)
```

Result:

```hcl
{
  dev   = 1
  stage = 2
  prod  = 3
}
```

The first list becomes the keys and the second becomes the values.

---

# 5. Set Functions

Terraform sets contain unique values.

Convert a list to a set:

```hcl
toset(["dev", "dev", "prod"])
```

Result:

```text
["dev", "prod"]
```

---

## `setunion()`

Returns values from either set.

```hcl
setunion(
  toset(["dev", "stage"]),
  toset(["stage", "prod"])
)
```

Conceptually:

```text
dev
stage
prod
```

---

## `setintersection()`

Returns values present in both sets.

```hcl
setintersection(
  toset(["dev", "stage", "prod"]),
  toset(["stage", "prod"])
)
```

Result contains:

```text
stage
prod
```

---

## `setdifference()`

Returns values that exist in the first set but not the second.

```hcl
setdifference(
  toset(["dev", "stage", "prod"]),
  toset(["stage"])
)
```

Result:

```text
dev
prod
```

---

# 6. Type Conversion Functions

Terraform is strongly typed, so type conversion is sometimes necessary.

---

## `tonumber()`

String → number.

```hcl
tonumber("100")
```

Result:

```text
100
```

---

## `tostring()`

Number → string.

```hcl
tostring(500)
```

Result:

```text
"500"
```

---

## `tobool()`

String → boolean.

```hcl
tobool("true")
```

Result:

```text
true
```

---

## `tolist()`

Converts a compatible collection into a list.

```hcl
tolist(toset(["dev", "stage", "prod"]))
```

---

## `toset()`

Converts a collection into a set and removes duplicates.

```hcl
toset(["dev", "dev", "prod"])
```

Conceptually:

```text
dev
prod
```

---

# 7. Default / Null Handling Functions

These are especially useful when Terraform inputs may be optional.

---

## `coalesce()`

Returns the first non-null value.

```hcl
coalesce(
  null,
  null,
  "dev",
  "prod"
)
```

Result:

```text
"dev"
```

Useful when you have fallback values.

---

## `compact()`

Removes empty strings from a list.

```hcl
compact([
  "dev",
  "",
  "prod",
  "",
  "stage"
])
```

Result:

```text
[
  "dev",
  "prod",
  "stage"
]
```

---

## `coalescelist()`

Returns the first non-empty list.

```hcl
coalescelist(
  [],
  [],
  ["dev", "prod"]
)
```

Result:

```text
["dev", "prod"]
```

---

# 8. `try()` and `can()`

These are extremely useful when working with optional or potentially invalid expressions.

---

## `try()`

Returns the first expression that succeeds.

```hcl
try(
  var.users[0].email,
  "no-email"
)
```

If the first expression works:

```text
ravi@gmail.com
```

Otherwise:

```text
no-email
```

A common mental model:

```text
try(expression1, expression2, expression3)
            ↓
Use first successful expression
```

---

## `can()`

Checks whether an expression can be evaluated.

```hcl
can(var.users[0].email)
```

Possible result:

```text
true
```

or:

```text
false
```

This is useful when validating whether a value or attribute is available.

---

# 9. Encoding Functions

Terraform often needs to encode or decode data.

---

## `base64encode()`

```hcl
base64encode("Hello Terraform")
```

Returns a Base64 encoded string.

---

## `base64decode()`

```hcl
base64decode("SGVsbG8gVGVycmFmb3Jt")
```

Returns:

```text
Hello Terraform
```

---

## `jsonencode()`

Converts a Terraform value into JSON.

```hcl
jsonencode({
  name        = "Shaad"
  environment = "dev"
  port        = 8080
})
```

Result is a JSON string similar to:

```json
{
  "name": "Shaad",
  "environment": "dev",
  "port": 8080
}
```

This is extremely useful when passing structured configuration to APIs, user data, policies, or other systems expecting JSON.

---

## `jsondecode()`

Converts a JSON string into a Terraform value.

```hcl
jsondecode(
  "{\"name\":\"Shaad\",\"age\":25}"
)
```

Terraform can then access fields from the decoded object.

---

# 10. Date and Time Functions

---

## `timestamp()`

Returns the current UTC timestamp.

```hcl
timestamp()
```

Example result:

```text
2026-08-18T14:30:00Z
```

The exact value changes because it represents the current time.

Be careful using `timestamp()` in resource arguments that affect infrastructure state, because it can cause values to change on future evaluations.

---

## `formatdate()`

Formats a timestamp.

```hcl
formatdate(
  "YYYY-MM-DD",
  timestamp()
)
```

Result resembles:

```text
2026-08-18
```

Useful when you need a readable date.

---

## `timeadd()`

Adds a duration to a timestamp.

```hcl
timeadd(
  timestamp(),
  "24h"
)
```

This gives a timestamp approximately 24 hours in the future.

Useful units include durations such as:

```text
10m
2h
24h
```

---

# 11. `for` Expressions + Functions

Terraform functions become especially powerful when combined with `for` expressions.

Example:

```hcl
[
  for user in var.users :
  upper(user.name)
]
```

If the users are:

```text
Ravi
Pavan
Amit
```

the result becomes:

```text
RAVI
PAVAN
AMIT
```

Another example:

```hcl
[
  for user in var.users :
  trimspace(lower(user.email))
]
```

Here multiple operations are combined:

```text
user.email
    ↓
trimspace()
    ↓
lower()
    ↓
new list
```

---

# 12. Functions Inside Conditional Expressions

Functions can also be used inside conditions.

Example:

```hcl
contains(
  ["prod", "production"],
  var.environment
) ? "t3.medium" : "t3.micro"
```

Meaning:

```text
Is environment either "prod" or "production"?
           │
       yes │ no
           ▼
    t3.medium
           │
           ▼
       t3.micro
```

This is much cleaner than writing multiple conditions manually.

---

# 13. Combining Multiple Functions

Terraform functions can be nested.

Example:

```hcl
upper(
  trimspace(var.name)
)
```

Terraform evaluates from the inside outward:

```text
var.name
   ↓
trimspace()
   ↓
upper()
   ↓
final value
```

For:

```text
"  Shaad  "
```

the result is:

```text
"SHAAD"
```

Another example:

```hcl
join(
  "-",
  [
    lower(trimspace(var.name)),
    var.environment,
    "server"
  ]
)
```

This can produce:

```text
shaad-bangi-dev-server
```

The exact result depends on the input value.

---

# 14. Important Terraform Function Categories

A useful mental map:

```text
Terraform Functions
│
├── String
│   ├── upper()
│   ├── lower()
│   ├── trimspace()
│   ├── replace()
│   ├── substr()
│   ├── join()
│   ├── split()
│   └── format()
│
├── Math
│   ├── abs()
│   ├── ceil()
│   ├── floor()
│   ├── min()
│   ├── max()
│   ├── pow()
│   └── log()
│
├── Collection
│   ├── length()
│   ├── contains()
│   ├── distinct()
│   ├── concat()
│   ├── reverse()
│   ├── sort()
│   ├── slice()
│   ├── element()
│   └── flatten()
│
├── Map/Object
│   ├── keys()
│   ├── values()
│   ├── lookup()
│   ├── merge()
│   └── zipmap()
│
├── Set
│   ├── setunion()
│   ├── setintersection()
│   └── setdifference()
│
├── Conversion
│   ├── tonumber()
│   ├── tostring()
│   ├── tobool()
│   ├── tolist()
│   └── toset()
│
├── Null/Defaults
│   ├── coalesce()
│   ├── coalescelist()
│   └── compact()
│
├── Error Handling
│   ├── try()
│   └── can()
│
├── Encoding
│   ├── base64encode()
│   ├── base64decode()
│   ├── jsonencode()
│   └── jsondecode()
│
└── Date/Time
    ├── timestamp()
    ├── formatdate()
    └── timeadd()
```

---

# 15. Most Useful Functions to Remember First

You do **not** need to memorize every Terraform function.

For practical Terraform work, become comfortable with these first:

```text
String:
trimspace()
lower()
upper()
replace()
join()
split()
format()

Collections:
length()
contains()
distinct()
concat()
flatten()
sort()
slice()

Maps:
keys()
values()
lookup()
merge()
zipmap()

Sets:
toset()
setunion()
setintersection()
setdifference()

Conversion:
tonumber()
tostring()
tobool()
tolist()
toset()

Conditional/optional:
coalesce()
compact()
coalescelist()
try()
can()

Encoding:
jsonencode()
jsondecode()

Math:
abs()
ceil()
floor()
min()
max()
pow()

Date:
timestamp()
formatdate()
timeadd()
```

---

# 16. Functions vs Operators vs Expressions

These three concepts are related but not identical.

### Operator

An operator performs an operation:

```hcl
2 + 2

10 > 5

true && false
```

### Function

A function is a built-in Terraform operation:

```hcl
length([1, 2, 3])

upper("terraform")

merge({}, {})
```

### Expression

An expression is anything Terraform evaluates to produce a value.

For example:

```hcl
2 + 2
```

is an expression using an operator.

```hcl
length([1, 2, 3])
```

is an expression using a function.

```hcl
var.environment == "prod"
```

is a comparison expression.

```hcl
var.environment == "prod" ? "large" : "small"
```

is a conditional expression.

---

# 17. Practical Terraform Example

A realistic resource might combine variables, functions, locals, and expressions:

```hcl
locals {
  clean_project_name = lower(trimspace(var.project_name))

  resource_name = join(
    "-",
    [
      local.clean_project_name,
      var.environment,
      "server"
    ]
  )

  common_tags = merge(
    var.additional_tags,
    {
      Name        = local.resource_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  )
}
```

The processing looks like:

```text
var.project_name
       ↓
trimspace()
       ↓
lower()
       ↓
join()
       ↓
resource_name
       ↓
merge()
       ↓
common_tags
       ↓
AWS resource
```

This is the kind of function usage you will see frequently in real Terraform projects.

---

# 18. Final Mental Model

Remember:

```text
Variable
   ↓
Input

Operator
   ↓
Simple operation

Function
   ↓
Reusable built-in operation

Expression
   ↓
Terraform evaluates it

Local
   ↓
Stores/reuses the result

Resource
   ↓
Uses the final value
```

For example:

```hcl
locals {
  resource_name = join(
    "-",
    [
      lower(trimspace(var.project_name)),
      var.environment,
      "server"
    ]
  )
}
```

This single example contains:

```text
variable
   ↓
trimspace()
   ↓
lower()
   ↓
list expression
   ↓
join()
   ↓
local
   ↓
resource
```

That combination of **functions + expressions + locals + variables** is one of the most important parts of becoming comfortable with Terraform.
