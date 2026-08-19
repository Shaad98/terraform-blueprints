# Terraform Multi-Resource Creation: `count` and `for_each`

Terraform often needs to create the **same kind of resource multiple times**.

For example:

- 3 EC2 instances
- 3 S3 buckets
- multiple security-group rules
- multiple IAM users
- multiple subnets

Instead of writing the same `resource` block again and again, Terraform provides two important meta-arguments:

- `count`
- `for_each`

Both help us create multiple instances of a resource, but they work differently and are useful in different situations.

---

## 1. Why Do We Need `count` and `for_each`?

Without them, you might write:

```hcl
resource "aws_instance" "server1" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}

resource "aws_instance" "server2" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}

resource "aws_instance" "server3" {
  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

This works, but it becomes repetitive and difficult to maintain.

With `count`:

```hcl
resource "aws_instance" "server" {
  count = 3

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

Terraform creates 3 instances from one resource block.

---

# 2. `count`

`count` tells Terraform:

> Create this resource block this many times.

## Basic Syntax

```hcl
resource "resource_type" "name" {
  count = 3

  # resource arguments
}
```

Terraform creates these instances:

```text
resource.name[0]
resource.name[1]
resource.name[2]
```

The index starts at **0**.

---

## 3. Simple `count` Example

```hcl
resource "aws_instance" "server" {
  count = 3

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = "server-${count.index}"
  }
}
```

Terraform conceptually creates:

```text
server-0
server-1
server-2
```

### `count.index`

Inside a resource using `count`, Terraform provides:

```hcl
count.index
```

It represents the current instance index.

For example:

| Instance | `count.index` |
|---|---:|
| first | 0 |
| second | 1 |
| third | 2 |

---

# 4. Using a Variable with `count`

Hard-coding `count = 3` is sometimes inconvenient.

We can use a variable instead.

```hcl
variable "instance_count" {
  type    = number
  default = 3
}

resource "aws_instance" "server" {
  count = var.instance_count

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = "server-${count.index}"
  }
}
```

Now changing the number of instances only requires changing the variable value.

For example:

```hcl
instance_count = 5
```

Terraform will create 5 instances.

---

# 5. `count` with a List

`count` is also useful when working with a list.

```hcl
variable "server_names" {
  type = list(string)

  default = [
    "web",
    "api",
    "worker"
  ]
}

resource "aws_instance" "server" {
  count = length(var.server_names)

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = var.server_names[count.index]
  }
}
```

Result:

```text
server[0] -> web
server[1] -> api
server[2] -> worker
```

The important part is:

```hcl
var.server_names[count.index]
```

Terraform uses the current index to retrieve the corresponding list element.

---

# 6. Important Problem with `count`

`count` is **index-based**.

Suppose we start with:

```hcl
variable "server_names" {
  default = [
    "web",
    "api",
    "worker"
  ]
}
```

Terraform sees:

```text
[0] web
[1] api
[2] worker
```

Now suppose we remove `api`:

```hcl
variable "server_names" {
  default = [
    "web",
    "worker"
  ]
}
```

Terraform now sees:

```text
[0] web
[1] worker
```

Previously:

```text
server[1] -> api
server[2] -> worker
```

After the change:

```text
server[1] -> worker
```

The indexes shifted.

That can cause Terraform to destroy/recreate resources because resource identity is based on the index.

This is one of the major reasons `for_each` is often better when each item has a meaningful identity.

---

# 7. `for_each`

`for_each` also creates multiple resource instances, but instead of using numeric indexes, it uses **keys**.

Basic syntax:

```hcl
resource "resource_type" "name" {
  for_each = var.some_collection

  # resource arguments
}
```

Terraform creates instances like:

```text
resource.name["key1"]
resource.name["key2"]
resource.name["key3"]
```

---

# 8. `for_each` with a Set

Example:

```hcl
variable "server_names" {
  type = set(string)

  default = [
    "web",
    "api",
    "worker"
  ]
}

resource "aws_instance" "server" {
  for_each = var.server_names

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = each.key
  }
}
```

Terraform creates:

```text
server["web"]
server["api"]
server["worker"]
```

For a set of strings, `each.key` and `each.value` represent the set element.

---

# 9. `each.key` and `each.value`

Inside a `for_each` resource, Terraform gives us:

```hcl
each.key
each.value
```

For a map:

```hcl
variable "servers" {
  type = map(string)

  default = {
    web    = "t3.micro"
    api    = "t3.small"
    worker = "t3.medium"
  }
}
```

Resource:

```hcl
resource "aws_instance" "server" {
  for_each = var.servers

  ami           = "ami-xxxxxxxx"
  instance_type = each.value

  tags = {
    Name = each.key
  }
}
```

Terraform sees:

| Key | Value |
|---|---|
| `web` | `t3.micro` |
| `api` | `t3.small` |
| `worker` | `t3.medium` |

So:

```hcl
each.key
```

means the map key.

And:

```hcl
each.value
```

means the corresponding map value.

---

# 10. A More Realistic `for_each` Example

Suppose we want different servers with different instance types.

```hcl
variable "servers" {
  type = map(object({
    instance_type = string
    environment   = string
  }))

  default = {
    web = {
      instance_type = "t3.micro"
      environment   = "dev"
    }

    api = {
      instance_type = "t3.small"
      environment   = "dev"
    }

    worker = {
      instance_type = "t3.medium"
      environment   = "prod"
    }
  }
}

resource "aws_instance" "server" {
  for_each = var.servers

  ami           = "ami-xxxxxxxx"
  instance_type = each.value.instance_type

  tags = {
    Name        = each.key
    Environment = each.value.environment
  }
}
```

This is much more expressive than using a simple numeric count.

Terraform resources become:

```text
aws_instance.server["web"]
aws_instance.server["api"]
aws_instance.server["worker"]
```

---

# 11. `count` vs `for_each`

| Feature | `count` | `for_each` |
|---|---|---|
| Resource identity | Numeric index | Key |
| Syntax | `resource[0]` | `resource["web"]` |
| Main concept | Number of copies | Collection of named items |
| Works with | Number | Map or set |
| Access value | `count.index` | `each.key`, `each.value` |
| Best for | Nearly identical resources | Named/distinct resources |
| Sensitive to list reordering | Yes | Much less likely when keys stay stable |

A simple rule:

> Use `count` when you mainly care about **how many** resources you need.

> Use `for_each` when you care about **which named resources** you are creating.

---

# 12. `count` Example: Multiple Identical Resources

Suppose you need 3 identical development servers.

```hcl
variable "server_count" {
  type    = number
  default = 3
}

resource "aws_instance" "dev_server" {
  count = var.server_count

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"

  tags = {
    Name = "dev-server-${count.index + 1}"
  }
}
```

Result:

```text
dev-server-1
 dev-server-2
dev-server-3
```

Here `count` is a natural choice because the servers are essentially identical.

---

# 13. `for_each` Example: Different Named Resources

Suppose we have these environments:

```hcl
variable "buckets" {
  type = map(string)

  default = {
    logs    = "logs-bucket"
    backups = "backup-bucket"
    assets  = "assets-bucket"
  }
}
```

Resource:

```hcl
resource "aws_s3_bucket" "bucket" {
  for_each = var.buckets

  bucket = each.value
}
```

Terraform resource addresses become:

```text
aws_s3_bucket.bucket["logs"]
aws_s3_bucket.bucket["backups"]
aws_s3_bucket.bucket["assets"]
```

The key gives each resource a meaningful identity.

---

# 14. Resource Addressing

This is an important Terraform concept.

Without `count` or `for_each`:

```text
aws_instance.server
```

With `count`:

```text
aws_instance.server[0]
aws_instance.server[1]
aws_instance.server[2]
```

With `for_each`:

```text
aws_instance.server["web"]
aws_instance.server["api"]
aws_instance.server["worker"]
```

You will see these addresses in commands such as:

```bash
terraform state list
```

and when Terraform shows a plan.

---

# 15. Referencing a `count` Resource

Suppose:

```hcl
resource "aws_instance" "server" {
  count = 3

  ami           = "ami-xxxxxxxx"
  instance_type = "t3.micro"
}
```

A specific instance can be referenced using an index:

```hcl
aws_instance.server[0].id
```

Another example:

```hcl
aws_instance.server[1].private_ip
```

---

# 16. Referencing a `for_each` Resource

Suppose:

```hcl
resource "aws_instance" "server" {
  for_each = var.servers

  ami           = "ami-xxxxxxxx"
  instance_type = each.value.instance_type
}
```

You can reference a specific instance using its key:

```hcl
aws_instance.server["web"].id
```

Or:

```hcl
aws_instance.server["api"].private_ip
```

---

# 17. Creating Outputs from `count`

```hcl
output "server_ids" {
  value = aws_instance.server[*].id
}
```

The `[*]` expression collects values from all instances.

Conceptually:

```text
[
  "id-1",
  "id-2",
  "id-3"
]
```

---

# 18. Creating Outputs from `for_each`

For `for_each`, a common pattern is a `for` expression:

```hcl
output "server_ids" {
  value = {
    for name, server in aws_instance.server :
    name => server.id
  }
}
```

Result conceptually:

```hcl
{
  web    = "i-123..."
  api    = "i-456..."
  worker = "i-789..."
}
```

This keeps the resource keys attached to the corresponding IDs.

---

# 19. `count` and Conditional Creation

A useful pattern is using `count` to create a resource only when a condition is true.

```hcl
variable "create_monitoring" {
  type    = bool
  default = true
}

resource "aws_cloudwatch_log_group" "app" {
  count = var.create_monitoring ? 1 : 0

  name = "/app/logs"
}
```

If:

```hcl
create_monitoring = true
```

Terraform creates:

```text
aws_cloudwatch_log_group.app[0]
```

If it is false, Terraform creates zero instances.

This pattern is commonly used for optional resources.

---

# 20. `for_each` and Conditional Filtering

You can filter a map using a `for` expression.

Example:

```hcl
variable "servers" {
  type = map(object({
    instance_type = string
    enabled       = bool
  }))
}
```

Create only enabled servers:

```hcl
resource "aws_instance" "server" {
  for_each = {
    for name, server in var.servers :
    name => server
    if server.enabled
  }

  ami           = "ami-xxxxxxxx"
  instance_type = each.value.instance_type
}
```

This is a powerful Terraform pattern:

```text
Input collection
      |
      v
 filter with for expression
      |
      v
  for_each
      |
      v
 create selected resources
```

---

# 21. Important Rule: `for_each` Needs Known Keys

Terraform must know the keys used by `for_each` during planning.

Good:

```hcl
for_each = {
  web = "t3.micro"
  api = "t3.small"
}
```

The keys are known:

```text
web
api
```

Be careful when the keys depend on values that Terraform cannot know until apply time.

The general idea is:

> Terraform needs stable, known resource identities during the plan phase.

---

# 22. `for_each` Does Not Directly Accept a List

This is commonly encountered.

You should not normally do:

```hcl
for_each = ["web", "api", "worker"]
```

Instead, use a set:

```hcl
for_each = toset(["web", "api", "worker"])
```

Or use a map:

```hcl
for_each = {
  web    = "web"
  api    = "api"
  worker = "worker"
}
```

A set is useful when only the values matter.

A map is useful when you want explicit keys and associated values.

---

# 23. When Should You Use `count`?

Use `count` when:

- resources are nearly identical
- you primarily care about the number of resources
- numeric indexing is acceptable
- you need a simple conditional resource using `0` or `1`

Example:

```hcl
resource "aws_instance" "server" {
  count = 3

  # same configuration
}
```

---

# 24. When Should You Use `for_each`?

Use `for_each` when:

- resources have meaningful names
- every item may have different configuration
- you want stable keys
- you are working with maps or sets
- resource identity should represent the item itself

Example:

```hcl
resource "aws_instance" "server" {
  for_each = var.servers

  instance_type = each.value.instance_type
}
```

---

# 25. Practical Mental Model

Think about the difference this way.

## `count`

```text
How many?

3 servers

0 -> server
1 -> server
2 -> server
```

Identity is based on **position**.

## `for_each`

```text
Which ones?

web
api
worker
```

Identity is based on **key**.

That is the most important concept to remember.

---

# 26. Small Practice Exercise

Try creating three S3 buckets using `count`.

```hcl
resource "aws_s3_bucket" "demo" {
  count = 3

  bucket = "my-demo-bucket-${count.index}"
}
```

Then convert it to `for_each`:

```hcl
variable "bucket_names" {
  type = set(string)

  default = [
    "logs",
    "backups",
    "assets"
  ]
}

resource "aws_s3_bucket" "demo" {
  for_each = var.bucket_names

  bucket = "my-demo-bucket-${each.key}"
}
```

Compare the resource addresses:

`count`:

```text
aws_s3_bucket.demo[0]
aws_s3_bucket.demo[1]
aws_s3_bucket.demo[2]
```

`for_each`:

```text
aws_s3_bucket.demo["logs"]
aws_s3_bucket.demo["backups"]
aws_s3_bucket.demo["assets"]
```

---

# 27. Quick Cheat Sheet

## `count`

```hcl
resource "example" "name" {
  count = 3

  name = "server-${count.index}"
}
```

Access:

```hcl
count.index
```

Address:

```text
example.name[0]
```

---

## `for_each` with a set

```hcl
resource "example" "name" {
  for_each = toset(["web", "api", "worker"])

  name = each.key
}
```

Access:

```hcl
each.key
each.value
```

Address:

```text
example.name["web"]
```

---

## `for_each` with a map

```hcl
resource "example" "name" {
  for_each = {
    web = "t3.micro"
    api = "t3.small"
  }

  name = each.key
  type = each.value
}
```

---

# 28. Final Rule to Remember

```text
count   -> number / index
for_each -> key / collection
```

Or even simpler:

```text
COUNT
"Give me N copies"

FOR_EACH
"Create one resource for each item"
```

When resources are simple and identical, start with `count`.

When resources have names, identities, or different values, prefer `for_each`.

