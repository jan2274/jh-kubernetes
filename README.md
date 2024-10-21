# jh-kubernetes
1. Terraform으로 eks 생성                                  # eks-infra directory
2. Terraform으로 eks 클러스터 내에서 web, DB, CI/CD 생성       # k8s directory
3. CI/CD를 통해 web 스크립트 수정 파이프라인 구축


1016
1. Terraform으로 aws 인프라를 생성과 eks클러스터 내의 리소스를 생성하는 것으로 프로젝트를 분할
2. nginx, jenkins, DB 각각의 deployment 생성 확인
- 본격적인 CI/CD 테스트 시작

1017
1. jenkins web 접속을 위한 service 코드 생성
2. instance 크기 t2.medium에서 t2.small로 변경
3. git, github integration, kubernetes, kubernetes CLI, ssh pipeline steps, strict crumb issuer 6개의 플러그인 설치
4. git의 토큰 정보를 jenkins에 credential로 등록
- 계속해서 403 에러가 발생
- git과 jenkins를 연동화는 과정에서 git의 토큰을 jenkins에 credential로 등록하였으나 jenkins에서 등록된 credential을 인식하지 못함
- 403 에러 발생 때문에 인식을 못하는 것인지 의심되는 상황
- bastion이나 인스턴스를 하나 더 생성해서 젠킨스 설치 테스트
- 인스턴스 사용을 위해 vpc 리소스는 생성되어 있음

1021
1. ec2에 jenkins 설치
2. jenkins - git 연동
- eks 클러스터 배포
- git - aws 연동
