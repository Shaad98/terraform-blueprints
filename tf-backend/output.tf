output "ec2_instance_public_ip" {
  value = aws_instance.mywebserver01.public_ip
}

# Not providing instance name

# output "ec2_instance_name" {
#     value = aws_instance.mywebserver01.key_name
# }


# Fetch name by tags 

output "ec2_instance_name_tags" {
  value = aws_instance.mywebserver01.tags["Name"]
}