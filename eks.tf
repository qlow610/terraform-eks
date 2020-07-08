resource "aws_eks_cluster" "cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster.arn

  version = var.eks_version
  vpc_config {
    subnet_ids             = aws_subnet.eks-cluster-subnet[*].id
    endpoint_public_access = var.public_access
  }
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSClusterPolicy",
    "aws_iam_role_policy_attachment.AmazonEKSServicePolicy",
    "aws_cloudwatch_log_group.eks_cloudwatch",
  ]
}


resource "aws_eks_node_group" "cluster" {
  cluster_name    = aws_eks_cluster.cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_worker_node_role.arn
  subnet_ids      = aws_subnet.eks-cluster-subnet[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1

  }
  depends_on = [
    "aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy",
    "aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy",
    "aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly",
  ]
}
