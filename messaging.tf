locals {
  rabbitmq_labels = { app = "rabbitmq" }
}

resource "kubernetes_namespace" "messaging" {
  metadata {
    name = "messaging"
  }

  depends_on = [aws_eks_node_group.this]
}

resource "kubernetes_secret" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.messaging.metadata[0].name
  }

  data = {
    RABBITMQ_DEFAULT_USER = var.rabbitmq_user
    RABBITMQ_DEFAULT_PASS = var.rabbitmq_password
  }
}

resource "kubernetes_deployment" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.messaging.metadata[0].name
    labels    = local.rabbitmq_labels
  }

  spec {
    replicas = 1

    selector {
      match_labels = local.rabbitmq_labels
    }

    strategy {
      type = "Recreate"
    }

    template {
      metadata {
        labels = local.rabbitmq_labels
      }

      spec {
        container {
          name  = "rabbitmq"
          image = "rabbitmq:4-management-alpine"

          port {
            container_port = 5672
          }

          port {
            container_port = 15672
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.rabbitmq.metadata[0].name
            }
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
            limits = {
              memory = "512Mi"
            }
          }

          readiness_probe {
            tcp_socket {
              port = 5672
            }
            initial_delay_seconds = 15
            period_seconds        = 10
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "rabbitmq" {
  metadata {
    name      = "rabbitmq"
    namespace = kubernetes_namespace.messaging.metadata[0].name
  }

  spec {
    selector = local.rabbitmq_labels

    port {
      name        = "amqp"
      port        = 5672
      target_port = 5672
    }

    port {
      name        = "management"
      port        = 15672
      target_port = 15672
    }
  }
}
