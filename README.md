# Terraform - EKS
목적: Terraform을 사용하여 VPC, EKS클러스터와 같은 AWS 리소스와 EKS클러스터 내부의 리소스(deployment, service 등)를 생성하여 테스트 환경 구성


Point: 
aws의 리소스 생성과 kubernetes 내부의 리소스 생성 프로젝트 분리
   - aws-infra와 k8s로 Repository Directory 분리
   - Terraform Backend인 Terraform Cloud에서 두개의 Workspace를 생성하여 각 Directory를 인식하도록 설정
   - Terraform 코드 전체를 apply하지 않고 세부적인 적용을 통해 세부적인 관리 용이성 확보

next : Helm, AWS Codebuild
