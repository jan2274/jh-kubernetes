output "eks_cluster_name" {
  value = aws_eks_cluster.main.name
}

output "eks_cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}

output "eks_cluster_version" {
  value = aws_eks_cluster.main.version
}

output "eks_node_group_name" {
  value = aws_eks_node_group.node_group.node_group_name
}

output "eks_node_group_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

# output "python_app_service_external_hostname" {
#   value = kubernetes_service.python_app.status.load_balancer.ingress.hostname
#   # value = kubernetes_service.python_app_service.status[0].load_balancer[0].ingress[0].hostname  
#   description = "The external hostname of the Python app service."
# }
output "python_app_service_lb_dns" {
  value = kubernetes_service.python_app.status[0].load_balancer_ingress[0].hostname
  description = "The DNS of the LoadBalancer for the Python app service"
}
