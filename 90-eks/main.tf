module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.0" # this module version

  name               = local.common_name_suffix
  # kubernetes_version = "1.33" #blue version 1.32 & after upgrading green version 1.33 kubernetes version is 1.33
  kubernetes_version = var.eks_version

  addons = {
    coredns = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy = {}
    vpc-cni = {
      before_compute = true
    }
    metrics-server = {}
  }

  # Optional
  endpoint_public_access = false

  # Optional: Adds the current caller identity as an administrator via cluster access entry
  enable_cluster_creator_admin_permissions = true

  vpc_id                     = local.vpc_id
  subnet_ids                 = local.private_subnet_ids
  control_plane_subnet_ids   = local.private_subnet_ids
  create_node_security_group = false
  create_security_group      = false
  node_security_group_id     = local.eks_node_sg_id
  security_group_id          = local.eks_control_plane_sg_id



  EKS Managed Node Group(s)
  eks_managed_node_groups = {
    blue = {
      create = var.eks_nodegroup_blue_version
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"] #
      iam_role_additional_policies = {
        amazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        amazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      # cluster  Node Auto Scaling  
      min_size     = 2
      max_size     = 10 # DEFAULT NEED TO GIVE 10 MY instance not supporting for 10 So i given 5
      desired_size = 2
    }  


    green = {
      create = var.eks_nodegroup_green_version
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["c7i-flex.large"] #
      iam_role_additional_policies = {
        amazonEFS = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
        amazonEBS = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
      }

      # cluster  Node Auto Scaling  
      min_size     = 2
      max_size     = 10
      desired_size = 2

      # taints = {
      #   upgrade = {
      #     key = "upgrade"
      #     value = "true"
      #     effect = "NO_SCHEDULE"
      #   }
      # }
      labels = {
        nodegroup = "blue"
      }
    }   
  }   
  

  tags = merge(
    local.common_tags,
    {
      Name = local.common_name_suffix
    }
  )
}






# note deployment we use for 
# purpose: dp-demo
# project : roboshop

# for headless service
# project : headless-svc-demo
# project: roboshop