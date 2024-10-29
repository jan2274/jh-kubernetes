# jh-kubernetes
목적 : Terraform을 사용하여 EKS 클러스터와 Node group, 그리고 cluster 내부의 리소스(deployment, service 등) 생성

Point: 
aws의 리소스 생성과 kubernetes 내부의 리소스 생성 프로젝트 분리
   - aws-infra와 k8s로 Repository Directory 분리
   - Terraform Backend인 Terraform Cloud에서 두개의 Workspace를 생성하여 각 Directory를 인식하도록 설정
   - Terraform 코드 전체를 apply하지 않고 세부적인 적용을 통해 세부적인 관리 용이성 확보
