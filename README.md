# jh-kubernetes
목적 : Terraform을 사용하여 EKS 클러스터와 Node group, 그리고 cluster 내부의 리소스 생성

point
1. aws의 리소스 생성과 kubernetes 내부의 리소스 생성 프로젝트 분리
   - Terraform 코드 전체를 apply하지 않고 세부적인 적용을 통해 세부적인 관리 용이성 확보
2. 