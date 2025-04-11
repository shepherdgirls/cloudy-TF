# 키 저장을 위한 디렉토리 생성
resource "null_resource" "create_keys_directory" {
  provisioner "local-exec" {
    command = "mkdir -p ${path.module}/keys"
  }
}