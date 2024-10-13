resource "kubernetes_deployment" "python_app" {
  metadata {
    name      = "python-app"
    namespace = "default"
    labels = {
      app = "python-app"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "python-app"
      }
    }

    template {
      metadata {
        labels = {
          app = "python-app"
        }
      }

      spec {
        container {
          name  = "python-app-container"
          image = "python:3.9"
          
          ports {
            container_port = 8080
          }

          # 실행할 Python 명령어
          command = [ "python", "-m", "http.server", "8080" ]  # 예시: Python 내장 서버 실행

        #   env {
        #     name  = "ENV_VAR_EXAMPLE"
        #     value = "example_value"
        #   }
        }
      }
    }
  }
}
