# 테라폼 관리 리소스 목록
AWS에서 제공하는 모듈을 활용해 간단하게 관리
- VPC 
- RDS
- Endpoints
- EKS 

# Terraform 상태 관리

S3 + DynamoDB를 활용해 상태를 공유합니다.

### S3 (상태 파일 저장)

* State 파일을 S3 버킷에 저장하여 **공유 및 동기화**.
* 로컬에 저장하지 않으므로 다른 환경에서도 동일한 상태를 참조 가능.

### DynamoDB (Lock 관리)

* 동시에 여러 사용자가 `terraform apply` 실행 시 충돌 방지를 위해 Lock 기능 사용.
* Terraform 실행 중에는 DynamoDB 테이블에 Lock 레코드가 생성되고, 실행 완료 후 삭제됨.