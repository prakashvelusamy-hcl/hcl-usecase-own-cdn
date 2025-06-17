package main

deny[msg] {
  input.resource_changes[_].type == "aws_security_group"
  ingress := input.resource_changes[_].change.after.ingress[_]
  cidr := ingress.cidr_blocks[_]
  cidr == "0.0.0.0/0"
  msg := sprintf("Ingress open to the world on security group %v", [input.resource_changes[_].address])
}