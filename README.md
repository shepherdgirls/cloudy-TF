# AWS 인프라 자동화 프로젝트

이 프로젝트는 Terraform과 GitHub Actions를 사용하여 AWS에 ALB, EC2, RDS 및 S3를 포함한 인프라를 자동으로 배포합니다.

## 아키텍처 개요

이 프로젝트는 다음과 같은 AWS 리소스를 생성합니다:

- **네트워크 인프라**:
  - VPC
  - 퍼블릭 서브넷 (2개, ALB 및 EC2용)
  - 프라이빗 서브넷 (2개, RDS용)
  - 인터넷 게이트웨이
  - 라우팅 테이블

- **컴퓨팅 리소스**:
  - 퍼블릭 서브넷에 EC2 인스턴스 2대
  - 퍼블릭 서브넷에 Application Load Balancer

- **데이터베이스**:
  - 프라이빗 서브넷에 MariaDB RDS 인스턴스

- **스토리지**:
  - S3 버킷 (버전 관리 및 라이프사이클 규칙 설정)

## 사전 요구 사항

- AWS 계정
- GitHub 계정
- AWS 액세스 키 및 비밀 키
- GitHub 저장소에 다음 시크릿 설정:
  - `AWS_ACCESS_KEY_ID`
  - `AWS_SECRET_ACCESS_KEY`

## 시작하기

1. 이 저장소를 클론합니다.
2. `variables.tf` 파일에서 변수 기본값을 필요에 맞게 수정합니다.
3. GitHub 리포지토리에 변경 사항을 푸시합니다.
4. GitHub Actions 워크플로우가 자동으로 시작되어 인프라를 배포합니다.

## 중요 변수

- `db_password`: RDS 데이터베이스 암호 (GitHub Actions 시크릿으로 설정 권장)
- `aws_region`: 리소스를 배포할 AWS 지역
- `project_name`: 리소스 이름 지정에 사용될 프로젝트 이름
- `s3_bucket_name`: S3 버킷 이름 (설정하지 않으면 자동 생성)

## GitHub Actions 워크플로우

GitHub Actions 워크플로우는 다음 작업을 수행합니다:

1. Pull Request 시:
   - Terraform 초기화
   - Terraform 검증
   - Terraform 계획 (변경 사항 미리보기)

2. 메인 브랜치 푸시 시:
   - Terraform 초기화
   - Terraform 검증
   - Terraform 적용 (인프라 배포)
   - 출력 값 저장 및 아티팩트 업로드

## 인프라 접근 방법

- ALB는 퍼블릭 IP를 통해 접근 가능합니다.
- EC2 인스턴스는 퍼블릭 IP를 통해 SSH로 직접 접근 가능합니다.
- RDS는 프라이빗 서브넷에 위치하여 EC2 인스턴스를 통해서만 접근 가능합니다.
- S3 버킷은 적절한 AWS 자격 증명을 통해 접근 가능합니다.

## 인프라 삭제

인프라를 삭제하려면 다음 명령을 실행합니다:

```bash
terraform destroy -auto-approve
```

또는 GitHub Actions 워크플로우에 destroy 단계를 추가할 수 있습니다.