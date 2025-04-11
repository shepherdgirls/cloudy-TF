output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.main.dns_name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.main.endpoint
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.main.bucket
}

output "ssh_private_key_pem" {
  description = "The private key for SSH access to EC2 instances"
  value       = tls_private_key.ssh_key.private_key_pem
  sensitive   = true
}

output "web_instance_public_ips" {
  description = "The public IP addresses of the web instances"
  value = {
    web_server_1 = aws_instance.web_server_1.public_ip
    web_server_2 = aws_instance.web_server_2.public_ip
  }
}