# AWS VPC Networking — Beginner Notes

## 1. What is a VPC?

A **VPC (Virtual Private Cloud)** is your own private network inside AWS.

Think of it like a college campus:

```text
College Campus
└── Entire campus = VPC
```

Inside the VPC, we create smaller networks called **subnets**.

```text
VPC: 10.0.0.0/16
│
├── Public Subnet
│
└── Private Subnet
```

So remember:

> **VPC = big network**
>
> **Subnet = smaller network inside the VPC**

---

## 2. Why do we need subnets?

EC2 instances and other AWS resources are placed inside subnets.

For example:

```text
VPC
│
├── Public Subnet
│   └── Web Server / EC2
│
└── Private Subnet
    └── Database
```

A common architecture is:

```text
Internet
   ↓
Public EC2
   ↓
Private Database
```

The database is kept private because we normally don't want users on the Internet connecting directly to it.

---

## 3. What is CIDR?

CIDR means:

**Classless Inter-Domain Routing**

A CIDR block defines the IP address range of a network.

Example:

```text
10.0.0.0/16
```

The `/16` means the first 16 bits identify the network.

The remaining 16 bits can identify addresses inside the network.

```text
IPv4 = 32 bits

10.0.0.0/16

Network = 16 bits
Host    = 16 bits
```

Therefore:

```text
2^16 = 65,536 total IPv4 addresses
```

AWS reserves 5 IP addresses in each subnet, so the number of usable addresses is lower.

---

## 4. Why CIDR instead of Class A, B, and C?

Originally, IPv4 networks were divided into classes.

### Class A

Approximately:

```text
/8
```

It provides a very large number of addresses.

### Class B

Approximately:

```text
/16
```

It provides around 65,534 usable addresses in the traditional example.

### Class C

Approximately:

```text
/24
```

It provides 254 usable addresses in the traditional example.

The problem was that the class system was inflexible.

For example, suppose you need around 500 addresses:

```text
Class C → too small
Class B → much larger than necessary
```

CIDR lets us choose a more appropriate network size.

For example:

```text
/24
/25
/26
/27
/28
```

and so on.

So:

> **CIDR gives us flexible network sizes instead of forcing us into fixed classes.**

---

## 5. Your VPC CIDR

You created:

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "my_vpc"
  }
}
```

This gives your VPC the range:

```text
10.0.0.0/16
```

Conceptually:

```text
10.0.0.0
     ↓
10.0.255.255
```

You can divide this large range into smaller subnets.

---

# 6. What is a subnet?

A subnet is a smaller IP network inside your VPC.

Your VPC:

```text
10.0.0.0/16
```

contains your subnets:

```text
10.0.1.0/24
10.0.2.0/24
```

Your architecture becomes:

```text
VPC
10.0.0.0/16
│
├── Private Subnet
│   10.0.1.0/24
│
└── Public Subnet
    10.0.2.0/24
```

A `/24` contains:

```text
2^8 = 256 total IPv4 addresses
```

AWS reserves 5 addresses in each subnet.

Therefore:

```text
256 - 5 = 251 usable IPv4 addresses
```

---

# 7. Public vs Private Subnet

A subnet is generally called **public** when its route table has a route to an Internet Gateway.

Example:

```text
Public Subnet
     ↓
Route Table
     ↓
0.0.0.0/0 → Internet Gateway
     ↓
Internet
```

A private subnet does not have a direct route to an Internet Gateway.

A common private architecture is:

```text
Private EC2
    ↓
Private Route Table
    ↓
NAT Gateway
    ↓
Internet Gateway
    ↓
Internet
```

The NAT Gateway is used when private resources need to initiate outbound Internet connections.

For a beginner lab, you usually don't need a NAT Gateway. It is a billable AWS resource.

---

# 8. What is an Internet Gateway?

An **Internet Gateway (IGW)** is the connection between your VPC and the Internet.

Think of your VPC as a campus:

```text
VPC / Campus
     │
     │
     ↓
Internet Gateway = Main Gate
     │
     ↓
Internet
```

Your Terraform creates it with:

```hcl
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "my_igw"
  }
}
```

Important:

> Creating an Internet Gateway alone does NOT automatically make a subnet public.

The subnet also needs a route that points Internet traffic to the Internet Gateway.

---

# 9. What is a Route Table?

A route table is like a set of **traffic directions**.

It answers:

> "Where should traffic go?"

Your route:

```hcl
route {
  cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.my_igw.id
}
```

means:

```text
Destination       Send traffic to
-----------------------------------
0.0.0.0/0         Internet Gateway
```

`0.0.0.0/0` basically means:

> Any IPv4 destination that doesn't have a more specific route.

For example, if an EC2 wants to reach:

```text
8.8.8.8
```

the route table can match:

```text
0.0.0.0/0
```

and send the traffic to the Internet Gateway.

---

# 10. Route Table Association

Creating a route table isn't enough.

We need to associate it with a subnet.

Your code:

```hcl
resource "aws_route_table_association" "public_sub" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}
```

means:

> Attach `my_rt` to `public_subnet`.

Therefore:

```text
Public Subnet
     ↓
Route Table
     ↓
0.0.0.0/0
     ↓
Internet Gateway
     ↓
Internet
```

This is what makes the subnet **public from a routing perspective**.

---

# 11. Your Current Terraform Architecture

Your current configuration creates:

```text
                         INTERNET
                            │
                            ↓
                  ┌─────────────────┐
                  │ Internet Gateway│
                  └────────┬────────┘
                           │
                           ↓
                 ┌──────────────────┐
                 │       VPC        │
                 │   10.0.0.0/16    │
                 │                  │
                 │ ┌──────────────┐ │
                 │ │ Public       │ │
                 │ │ Subnet       │ │
                 │ │ 10.0.2.0/24  │ │
                 │ └──────┬───────┘ │
                 │        │         │
                 │   Route Table     │
                 │   0.0.0.0/0      │
                 │        │         │
                 │ ┌──────▼───────┐ │
                 │ │ Private      │ │
                 │ │ Subnet       │ │
                 │ │ 10.0.1.0/24  │ │
                 │ └──────────────┘ │
                 └──────────────────┘
```

However, there is an important detail.

---

# 12. Important: Your "Private Subnet" is not fully configured as private

You named this:

```hcl
resource "aws_subnet" "private_subnet" {
  ...
}
```

But simply naming a subnet `private_subnet` doesn't make it private.

Your private subnet needs appropriate routing.

You have explicitly associated the custom route table with the public subnet:

```hcl
resource "aws_route_table_association" "public_sub" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}
```

That is correct for the public subnet.

For a more complete architecture, you would create a separate private route table.

Conceptually:

```text
Public Subnet
     ↓
Public Route Table
     ↓
0.0.0.0/0 → Internet Gateway


Private Subnet
     ↓
Private Route Table
     ↓
No direct Internet Gateway route
```

If private resources need outbound Internet access:

```text
Private Subnet
     ↓
Private Route Table
     ↓
NAT Gateway
     ↓
Internet Gateway
     ↓
Internet
```

---

# 13. Availability Zones

An AWS subnet belongs to one Availability Zone.

For example:

```text
Region: us-east-1

us-east-1a
└── Public Subnet

us-east-1b
└── Private Subnet
```

In production, resources are often distributed across multiple Availability Zones to improve availability.

For a beginner Terraform lab, one Availability Zone is enough.

---

# 14. EC2 Inside a Subnet

Suppose you launch an EC2 instance inside:

```text
10.0.2.0/24
```

It could receive a private IP such as:

```text
10.0.2.10
```

The hierarchy is:

```text
AWS Account
    │
    └── Region
         │
         └── VPC
              │
              ├── Public Subnet
              │    │
              │    └── EC2
              │
              └── Private Subnet
                   │
                   └── Database
```

Remember this hierarchy.

---

# 15. Security Group

A **Security Group** is a virtual firewall associated with resources such as EC2.

Example:

```text
Security Group
│
├── Allow SSH
│   Port 22
│
├── Allow HTTP
│   Port 80
│
└── Allow HTTPS
    Port 443
```

For example:

```text
Internet
   ↓
Port 80
   ↓
Security Group
   ↓
EC2
```

A route table decides:

> Where should traffic go?

A security group decides:

> Is this traffic allowed to the resource?

These are different jobs.

---

# 16. Network ACL (NACL)

A **Network ACL** is another layer of network filtering.

The simple difference:

```text
Security Group
→ Resource-level firewall

NACL
→ Subnet-level firewall
```

Security Groups are stateful.

NACLs are stateless.

For beginner projects, you can normally start with Security Groups and learn NACLs afterward.

---

# 17. Private IP vs Public IP

An EC2 can have a private IP such as:

```text
10.0.2.10
```

This is used inside the VPC.

A public IPv4 address allows communication over the Internet.

Conceptually:

```text
Internet
   ↓
Public IP
   ↓
EC2
   ↓
Private IP
10.0.2.10
```

The exact networking behavior also depends on routing and security-group rules.

---

# 18. NAT Gateway

A NAT Gateway is commonly used to allow resources in private subnets to initiate outbound connections to the Internet without making those resources directly reachable from the Internet.

Example:

```text
Private EC2
    ↓
Private Route Table
    ↓
NAT Gateway
    ↓
Internet Gateway
    ↓
Internet
```

Important:

> NAT Gateway is billable, so avoid creating one just for a basic learning lab unless you need it.

---

# 19. Elastic IP

An Elastic IP is a static public IPv4 address.

It can be useful when you need a stable public IP.

For beginner labs, be careful with public IPv4 and Elastic IP usage because AWS can charge for public IPv4 addresses.

---

# 20. Complete Mental Model

The most important relationship is:

```text
VPC
│
├── CIDR
│   └── Defines the overall IP range
│
├── Subnets
│   ├── Public
│   └── Private
│
├── Route Tables
│   └── Decide where traffic goes
│
├── Internet Gateway
│   └── Connects VPC to Internet
│
├── Security Groups
│   └── Firewall for resources
│
├── NACLs
│   └── Firewall for subnets
│
└── Resources
    ├── EC2
    ├── RDS
    └── Other AWS services
```

---

# 21. Simple Real-World Example

Imagine you are building a web application.

```text
                 INTERNET
                    │
                    ↓
             Internet Gateway
                    │
                    ↓
              PUBLIC SUBNET
              10.0.2.0/24
                    │
                    ↓
               EC2 / Web App
                    │
                    ↓
             PRIVATE SUBNET
              10.0.1.0/24
                    │
                    ↓
                Database
```

Users connect to the web server.

The web server connects to the database.

The database isn't directly exposed to the Internet.

This is one of the most common reasons for separating public and private subnets.

---

# 22. Your Terraform — What Each Resource Does

### VPC

```hcl
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
}
```

Creates the overall network.

---

### Private Subnet

```hcl
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.1.0/24"
}
```

Creates a smaller network inside the VPC.

---

### Public Subnet

```hcl
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = "10.0.2.0/24"
}
```

Creates another smaller network inside the VPC.

---

### Internet Gateway

```hcl
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}
```

Provides a gateway between the VPC and the Internet.

---

### Route Table

```hcl
resource "aws_route_table" "my_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}
```

Says:

```text
All other IPv4 traffic
        ↓
Internet Gateway
```

---

### Route Table Association

```hcl
resource "aws_route_table_association" "public_sub" {
  route_table_id = aws_route_table.my_rt.id
  subnet_id      = aws_subnet.public_subnet.id
}
```

Connects the route table to the public subnet.

---

# 23. One Sentence for Each Component

If you want to memorize it:

```text
VPC
→ My overall AWS network.

CIDR
→ The IP range of my network.

Subnet
→ A smaller network inside my VPC.

Route Table
→ Tells traffic where to go.

Internet Gateway
→ Connects the VPC to the Internet.

Security Group
→ Firewall for my resources.

NACL
→ Firewall for my subnet.

NAT Gateway
→ Allows private resources to access the Internet outbound.

Availability Zone
→ A separate infrastructure location inside an AWS Region.
```

---

# 24. Final Picture to Remember

```text
                         INTERNET
                            │
                            ↓
                    INTERNET GATEWAY
                            │
                            ↓
              ┌─────────────────────────┐
              │          VPC            │
              │       10.0.0.0/16       │
              │                         │
              │   ┌─────────────────┐   │
              │   │ PUBLIC SUBNET   │   │
              │   │ 10.0.2.0/24     │   │
              │   │                 │   │
              │   │      EC2        │   │
              │   └────────┬────────┘   │
              │            │            │
              │      Route Table        │
              │      0.0.0.0/0          │
              │            │            │
              │   ┌────────▼────────┐   │
              │   │ PRIVATE SUBNET  │   │
              │   │ 10.0.1.0/24     │   │
              │   │                 │   │
              │   │    Database      │   │
              │   └─────────────────┘   │
              │                         │
              └─────────────────────────┘
```

The key idea is:

> **VPC is the big network → subnets divide it → route tables control traffic → Internet Gateway provides Internet connectivity → Security Groups control allowed traffic to resources.**