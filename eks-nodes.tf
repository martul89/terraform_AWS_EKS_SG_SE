
resource "aws_iam_role" "demo-node" {
  name = "${var.prefix}-eks-demo-node-${random_id.random-string.dec}"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.demo-node.name
}

resource "aws_iam_role_policy_attachment" "demo-node-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.demo-node.name
}

resource "aws_eks_node_group" "demo" {
  cluster_name    = aws_eks_cluster.demo.name
  node_group_name = "${var.prefix}-eks-${random_id.random-string.dec}"
  node_role_arn   = aws_iam_role.demo-node.arn
  subnet_ids      = [aws_subnet.private-subnet.id]
  instance_types = ["t3.xlarge"]

 


  scaling_config {
    desired_size = 1
    max_size     = 4
    min_size     = 1
  }

  tags = {
    Name = "${var.prefix}-eks-nodes"
    Environment = "${var.prefix}-terraform"
  }

  depends_on = [
    aws_iam_role_policy_attachment.demo-node-AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.demo-node-AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.demo-node-AmazonEC2ContainerRegistryReadOnly,
  ]
}

## To do k8s call from machine to AWS EKS Endpoint

resource "null_resource" "eks_kubeconfig" {
    provisioner "local-exec" {
    command = "/bin/bash scripts/kubeconfig.sh"
    environment = {
    access_key = var.access_key
    secret_key = var.secret_key
    region = var.region
    }
    }
    depends_on = [aws_eks_node_group.demo]
  }

# To deploy application and KIC

resource "null_resource" "app_deployment" {
    provisioner "local-exec" {
    command = "/bin/bash app_deployment/nginx.sh"
    }
    depends_on = [null_resource.eks_kubeconfig]
  }


 /*
  remote_access {
    ec2_ssh_key = aws_key_pair.main.id
    source_security_group_ids = [aws_security_group.sgweb.id]
  }
  */