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
  - `DB_PASSWORD` (RDS 데이터베이스 관리자 비밀번호)

## 시작하기

1. 이 저장소를 클론합니다.
2. `variables.tf` 파일에서 변수 기본값을 필요에 맞게 수정합니다.
3. GitHub 저장소에 필요한 시크릿을 설정합니다.
4. GitHub 리포지토리에 변경 사항을 푸시합니다.
5. GitHub Actions 워크플로우가 자동으로 시작되어 인프라를 배포합니다.

## 주요 파일 구조

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml  # GitHub Actions 워크플로우 파일
├── directory.tf       # 키 저장용 디렉토리 생성
├── key.tf             # SSH 키 생성
├── providers.tf       # 테라폼 프로바이더 설정
├── network.tf         # 네트워크 리소스 (VPC, 서브넷 등)
├── security_groups.tf # 보안 그룹
├── ec2.tf             # EC2 인스턴스
├── alb.tf             # 애플리케이션 로드 밸런서
├── rds.tf             # RDS 데이터베이스
├── s3.tf              # S3 버킷
├── variables.tf       # 변수 정의
└── outputs.tf         # 출력 변수
```

## GitHub Actions 워크플로우

GitHub Actions 워크플로우는 다음 작업을 수행합니다:

1. Pull Request 및 푸시 시:
   - Terraform 초기화
   - Terraform 검증
   - Terraform 계획 (변경 사항 미리보기)

2. 메인 브랜치 푸시 시 추가 작업:
   - Terraform 적용 (인프라 배포)
   - 출력 값 저장 및 아티팩트 업로드

## 인프라 접근 방법

배포가 완료되면 다음과 같이 인프라에 접근할 수 있습니다:

1. **웹 애플리케이션 접근**:
   - ALB DNS 이름을 통해 웹 브라우저에서 접속
   - 출력된 `alb_dns_name` 값 사용

2. **EC2 인스턴스 SSH 접속**:
   - GitHub Actions 아티팩트에서 SSH 키 다운로드
   - 출력된 `web_instance_public_ips` 값을 사용하여 접속
   ```bash
   chmod 400 private-key.pem
   ssh -i private-key.pem ec2-user@<EC2_PUBLIC_IP>
   ```

3. **RDS 데이터베이스 접속**:
   - EC2 인스턴스에서 MySQL 클라이언트를 통해 연결
   ```bash
   sudo yum install -y mysql
   mysql -h <RDS_ENDPOINT> -u admin -p
   ```

## 인프라 삭제

### Terraform을 통한 삭제 (권장)

1. 로컬에서 Terraform 설치:
   - [Terraform 다운로드 페이지](https://developer.hashicorp.com/terraform/downloads)에서 최신 버전 다운로드
   - 대부분의 현대 컴퓨터는 amd64(64비트) 버전 설치

2. 리포지토리 클론 및 Terraform 초기화:
   ```bash
   git clone <REPO_URL>
   cd <REPO_DIR>
   terraform init
   ```

3. AWS 자격 증명 및 데이터베이스 비밀번호 설정:
   ```bash
   # Windows
   set AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY>
   set AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_KEY>
   set TF_VAR_db_password=<YOUR_DB_PASSWORD>
   
   # Linux/Mac
   export AWS_ACCESS_KEY_ID=<YOUR_ACCESS_KEY>
   export AWS_SECRET_ACCESS_KEY=<YOUR_SECRET_KEY>
   export TF_VAR_db_password=<YOUR_DB_PASSWORD>
   ```

4. 인프라 삭제:
   ```bash
   terraform destroy
   ```
   
5. 확인 메시지에 'yes' 입력

### AWS 관리 콘솔에서 수동 삭제

다음 순서로 리소스를 삭제합니다:

1. ALB 및 타겟 그룹
2. EC2 인스턴스
3. RDS 데이터베이스 (최종 스냅샷 생성 옵션 해제)
4. S3 버킷 (내용물 먼저 비우기)
5. 보안 그룹
6. 네트워크 리소스 (인터넷 게이트웨이, 서브넷, 라우팅 테이블, VPC)

### 리소스 확인

비용이 청구되지 않도록 다음 리소스 삭제 여부를 확인합니다:
- EC2 인스턴스
- RDS 데이터베이스
- 로드 밸런서 (ALB)
- 탄력적 IP (EIP)
- S3 버킷
- 스냅샷 및 백업

## 참고 사항

- 테스트 목적으로 EC2 인스턴스를 퍼블릭 서브넷에 배치했으나, 실제 프로덕션 환경에서는 보안을 위해 프라이빗 서브넷에 배치하는 것이 권장됩니다.
- S3 버킷에 접근하기 위해 EC2 인스턴스에 적절한 IAM 역할을 연결하는 기능은 포함되어 있지 않습니다. 필요한 경우 코드를 수정하여 추가해야 합니다.
- 비용 절감을 위해 사용하지 않는 리소스는 반드시 삭제하세요.
