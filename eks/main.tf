resource "aws_eks_cluster" "name" {
  name = "name"
  role_arn = aws_iam_role.example.arn

 vpc_config {
    subnet_ids = ["subnet-01520a6f2a33cd68d", "subnet-0a29d82b448bca8f1", "subnet-0d5495d057954746b"] # This is where nodes are going to be provisioned. This is a multi-zonal kubernetes cluster
  }


  depends_on = [
    aws_iam_role_policy_attachment.example-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.example-AmazonEKSVPCResourceController,
  ]
}


data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "example" {
  name               = "eks-cluster-example"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.example.name
}

# Optionally, enable Security Groups for Pods
# Reference: https://docs.aws.amazon.com/eks/latest/userguide/security-groups-for-pods.html
resource "aws_iam_role_policy_attachment" "example-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.example.name
}


resource "aws_eks_node_group" "example" {
  depends_on = [aws_eks_addon.example]
  cluster_name    = aws_eks_cluster.example.name
  node_group_name = "name-np-spot"
  node_role_arn   = aws_iam_role.node-example.arn
  subnet_ids      = ["subnet-01520a6f2a33cd68d", "subnet-0a29d82b448bca8f1", "subnet-0d5495d057954746b"]
  instance_types = ["t2.meduim","t2.large"]
  capacity_type = "SPOT"
  scaling_config {
    desired_size = 1
    max_size     = 3
    min_size     = 1
  }

}

resource "aws_iam_role" "node-example" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-example.name
}

resource "aws_eks_addon" "example" {
  depends_on = ["aws_eks_cluster.example"]
  cluster_name = aws_eks_cluster.example.name
  addon_name   = "vpc-cni"
}