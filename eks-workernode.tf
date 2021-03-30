resource "aws_iam_role" "new_node" {
   name = "EKSNodeInstanceRole"

   assume_role_policy = <<-POLICY
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

resource "aws_iam_role_policy_attachment" "new_node_AmazonEKSWorkerNodePolicy" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
   role       = aws_iam_role.new_node.name
}

resource "aws_iam_role_policy_attachment" "new_node_AmazonEKS_CNI_Policy" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
   role       = aws_iam_role.new_node.name
}

resource "aws_iam_role_policy_attachment" "new_node_AmazonEC2ContainerRegistryReadOnly" {
   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
   role       = aws_iam_role.new_node.name
}

resource "aws_eks_node_group" "new_node" {
   cluster_name    = aws_eks_cluster.new_eks_cluster.name
   node_group_name = "new_node_group"
   node_role_arn   = aws_iam_role.new_node.arn
   subnet_ids      = aws_subnet.new_sub[*].id

   scaling_config {
     desired_size = 2
     max_size     = 2
     min_size     = 2
   }

   depends_on = [
     aws_iam_role_policy_attachment.new_node_AmazonEKSWorkerNodePolicy,
     aws_iam_role_policy_attachment.new_node_AmazonEKS_CNI_Policy,
     aws_iam_role_policy_attachment.new_node_AmazonEC2ContainerRegistryReadOnly,
   ]
}