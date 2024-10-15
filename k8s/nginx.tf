############## 서비스 ###############
resource "kubernetes_service" "nginx" {
  metadata {
    name      = "nginx-service"
    namespace = "default"
    labels = {
      app = "nginx"
    }
  }

  spec {
    selector = {
      app = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}

############## configmap ###############
resource "kubernetes_config_map" "nginx_html" {
  metadata {
    name      = "nginx-html"
    namespace = "default"
  }

  data = {
    "index.html" = "<html><body><h1>Hello, World</h1></body></html>"
  }
}

############## deployment ###############
resource "kubernetes_deployment" "nginx" {
  metadata {
    name      = "nginx-deployment"
    namespace = "default"
    labels = {
      app = "nginx"
    }
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          app = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"

          port {
            container_port = 80 
          }
##########
          volume_mount {
            name       = "nginx-html"
            mount_path = "/usr/share/nginx/html"
            read_only  = true
          }
##########          
        }
##########
        volume {
          name = "nginx-html"

          config_map {
            name = kubernetes_config_map.nginx_html.metadata[0].name
          }
        }
##########
      }
    }
  }
}
