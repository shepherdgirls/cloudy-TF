# SSH 키 생성
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# SSH 키 페어 생성
resource "aws_key_pair" "generated_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# 로컬 파일로 개인 키 저장 (옵션)
resource "local_file" "private_key" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/keys/${var.project_name}-key.pem"
  file_permission = "0600"
}