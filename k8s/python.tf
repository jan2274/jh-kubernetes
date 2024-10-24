# resource "kubernetes_service" "python_app" {
#   metadata {
#     name = "python-app-service"
#   }

#   spec {
#     selector = {
#       app = "python-app"
#     }

#     port {
#       port        = 80
#       target_port = 8080
#     }

#     type = "LoadBalancer"
#   }
# }

# resource "kubernetes_deployment" "python_app" {
#   metadata {
#     name      = "python-app"
#     namespace = "default"
#     labels = {
#       app = "python-app"
#     }
#   }

#   spec {
#     replicas = 3

#     selector {
#       match_labels = {
#         app = "python-app"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "python-app"
#         }
#       }

#       spec {
#         container {
#           name  = "python-app-container"
#           image = "python:3.9"
          
#           port {
#             container_port = 8080
#           }

#           # 실행할 Python 명령어
#           command = [ "python", "-m", "http.server", "8080" ]  # 예시: Python 내장 서버 실행

#         #   env {
#         #     name  = "ENV_VAR_EXAMPLE"
#         #     value = "example_value"
#         #   }
#         }
#       }
#     }
#   }
# }
