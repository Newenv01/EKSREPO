resource "aws_iam_role" "new_cluster" {
    name = "terraform-eks-iam-new-cluster"

    assume_role_policy = <<-POLICY
    {
      "Version": "2012-10-17",
      "Statement": [
        {
           "Effect": "Allow",
           "Principal": {
               "Service": "eks.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
      ]
     }
   POLICY
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSClusterPolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
    role       = aws_iam_role.new_cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster-AmazonEKSServicePolicy" {
    policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
    role       = aws_iam_role.new_cluster.name
}

resource "aws_security_group" "new_cluster" {
    name        = "terraform-eks-new-cluster"
    description = "Cluster Communication with worker Nodes"
    vpc_id      = aws_vpc.new_vpc.id

    egress {
       from_port   = 0
       to_port     = 0
       protocol    = "-1"
       cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
       Name = "terraform-eks.new"
    }
}

resource "aws_security_group_rule" "new_cluster_ingress_workstation_https" {
    cidr_blocks      = [local.workstation-external-cidr]
    description      = "Allow workstation to communicate with teh cluster API Server"
    from_port        = 443
    protocol         = "tcp"
    security_group_id= aws_security_group.new_cluster.id
    to_port          = 443
    type             = "ingress"
}

resource "aws_eks_cluster" "new_eks_cluster" {
    name     = "${var.cluster-name}"
    role_arn = aws_iam_role.new_cluster.arn
 
    vpc_config {
      security_group_ids = [aws_security_group.new_cluster.id]
      subnet_ids         = aws_subnet.new_sub[*].id
    }
 
    depends_on = [
      aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
      aws_iam_role_policy_attachment.cluster-AmazonEKSServicePolicy,
    ]  
}