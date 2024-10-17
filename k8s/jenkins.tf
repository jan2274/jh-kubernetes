############## 서비스 ###############
resource "kubernetes_service" "jenkins" {
  metadata {
    name      = "jenkins-service"
    namespace = "default"
    labels = {
      app = "jenkins"
    }
  }

  spec {
    selector = {
      app = "jenkins"
    }

    port {
      port        = 8080
      target_port = 8080
    }

    type = "LoadBalancer"
  }
}

############## deployment ###############
resource "kubernetes_deployment" "jenkins" {
  metadata {
    name      = "jenkins"
    namespace = "default"
    labels = {
      app = "jenkins"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "jenkins"
      }
    }

    template {
      metadata {
        labels = {
          app = "jenkins"
        }
      }

      spec {
        container {
          name  = "jenkins-container"
          image = "jenkins/jenkins:lts-jdk11"  # Jenkins의 LTS 버전 사용

          port {
            container_port = 8080  # Jenkins 웹 인터페이스
          }

          port {
            container_port = 50000  # Jenkins 에이전트 통신 포트
          }

          # Jenkins는 기본적으로 실행할 명령어가 정해져 있으므로 command를 따로 지정할 필요는 없음

          # 환경 변수를 통해 설정을 전달할 수 있음 (예: Jenkins 홈 디렉토리 등)
          env {
            name  = "JAVA_OPTS"
            value = "-Djenkins.install.runSetupWizard=false"  # 설치 마법사 비활성화
          }

#          env {
#            name  = "JENKINS_OPTS"
#            value = "--prefix=/jenkins"  # Jenkins URL 경로 설정
#          }
# 이 환경 변수를 사용하려면 젠킨스와 연결된 service인 Loadbalancer를 테라폼의 리소스로 가져와야 할 것이다.
# 그래야 그 loadbalancer의 DNS를 변수화 시킬 수 있을 테니까
        }
      }
    }
  }
}
