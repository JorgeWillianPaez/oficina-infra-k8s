resource "kubernetes_namespace" "environment" {
  for_each = var.environments

  metadata {
    name = "${var.project}-${each.value}"
  }

  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"

  depends_on = [aws_eks_node_group.this]
}

resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-type"
    value = "nlb"
  }

  depends_on = [aws_eks_node_group.this]
}

data "kubernetes_service" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = helm_release.ingress_nginx.namespace
  }

  depends_on = [helm_release.ingress_nginx]
}

resource "helm_release" "new_relic" {
  count            = var.new_relic_license_key == "" ? 0 : 1
  name             = "newrelic-bundle"
  namespace        = "newrelic"
  create_namespace = true
  repository       = "https://helm-charts.newrelic.com"
  chart            = "nri-bundle"

  set {
    name  = "global.cluster"
    value = aws_eks_cluster.this.name
  }

  set_sensitive {
    name  = "global.licenseKey"
    value = var.new_relic_license_key
  }

  set {
    name  = "kube-state-metrics.enabled"
    value = "true"
  }

  set {
    name  = "kubeEvents.enabled"
    value = "true"
  }

  set {
    name  = "newrelic-logging.enabled"
    value = "true"
  }

  depends_on = [aws_eks_node_group.this]
}
