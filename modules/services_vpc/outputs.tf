output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "services vpc id"
}

output "vpc_private_subnets" {
  value       = module.vpc.private_subnets
  description = "services vpc private subnets"
}

output "vpc_sg_id" {
  value       = aws_security_group.sg.id
  description = "services security-group id"
}