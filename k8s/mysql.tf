############## EBS 볼륨 생성 ##############
resource "aws_ebs_volume" "mysql_ebs" {
  availability_zone = "ap-northeast-2a"  # 원하는 가용 영역 설정
  size              = 10
  type              = "gp3"
  tags = {
    Name = "mysql-ebs-volume"
  }
}

############## Persistent Volume (PV) ##############
resource "kubernetes_persistent_volume" "mysql_pv" {
  metadata {
    name = "mysql-pv"
  }

  spec {
    capacity = {
      storage = "10Gi"
    }
    access_modes = ["ReadWriteOnce"]
    persistent_volume_source {
      aws_elastic_block_store {
        volume_id = aws_ebs_volume.mysql_ebs.id  # EBS 볼륨의 ID 참조
        fs_type   = "ext4"                       # 파일 시스템 타입 (ext4, xfs 등)
      }
    }
  }
}


resource "kubernetes_persistent_volume_claim" "mysql_pvc" {
  metadata {
    name = "mysql-pv-claim"
  }
  spec {
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    volume_name = kubernetes_persistent_volume.mysql_pv.metadata.name
  }
}

############## statefulset ###############
resource "kubernetes_stateful_set" "mysql" {
  metadata {
    name = "mysql"
    labels = {
      app = "mysql"
    }
  }

  spec {
    service_name = "mysql"
    replicas     = 1

    selector {
      match_labels = {
        app = "mysql"
      }
    }

    template {
      metadata {
        labels = {
          app = "mysql"
        }
      }

      spec {
        container {
          name  = "mysql"
          image = "mysql:5.7"

          env {
            name  = "MYSQL_ROOT_PASSWORD"
            value = var.db_passwd
            # terraform cloud에 sensitive로 값을 저장하여 외부 노출 방지
          }

          port {
            container_port = 3306  # MySQL 포트
          }
          volume_mount {
            name      = kubernetes_persistent_volume_claim.mysql_pvc.metadata.name
            mount_path = "/var/lib/mysql"  # MySQL 데이터 저장 경로
          }
        }
      }
    }
  }
}

############## 서비스 ###############
resource "kubernetes_service" "mysql" {
  metadata {
    name = "mysql"
  }

  spec {
    selector = {
      app = "mysql"
    }

    port {
      port        = 3306
      target_port = 3306
    }

    type = "ClusterIP"
  }
}