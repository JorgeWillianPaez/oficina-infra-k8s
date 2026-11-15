output "api_url" {
  value = aws_apigatewayv2_api.this.api_endpoint
}

output "cluster_name" {
  value = aws_eks_cluster.this.name
}

output "vpc_id" {
  value = aws_vpc.this.id
}

output "ecr_repositories" {
  value = { for name, repository in aws_ecr_repository.microservice : name => repository.repository_url }
}

output "rabbitmq_host" {
  value = "${kubernetes_service.rabbitmq.metadata[0].name}.${kubernetes_namespace.messaging.metadata[0].name}.svc.cluster.local"
}
