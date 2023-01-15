# STA Instance
resource "aws_instance" "STAEC2Instance-ondemand" {
  count                = var.STALifecycle == "ondemand" ? 1 : 0
  ami                  = "ami-01be1673d282046fa" # {{$AMI$}}
  instance_type        = local.final_size
  ebs_optimized        = true
  key_name             = var.SSHKey
  iam_instance_profile = aws_iam_instance_profile.sta-instance-profile.id
  user_data            = "#!/bin/bash\n\nsudo /opt/coralogix/sta/userdata_autoexec/userdata_autoexec.py \"--region=eu-west-1\" \"--private_key=${var.PrivateKey}\" \"--company_id=${var.CompanyID}\" \"--app_name=${var.ApplicationName}\" \"--config_bucket=${length(var.ConfigS3BucketName) > 0 ? var.ConfigS3BucketName : aws_s3_bucket.STAConfigBucket[0].id}\" \"--packet_bucket=${var.PacketsS3BucketRequired == false ? "" : length(var.PacketsS3Bucket) > 0 ? var.PacketsS3Bucket : aws_s3_bucket.PacketsS3Bucket[0].id}\" \"--api_endpoint=api.${lookup(var.CoralogixEndpointMap, var.CoralogixEndpoint)}\" \"--syslog_endpoint=syslogserver.${lookup(var.CoralogixEndpointMap, var.CoralogixEndpoint)}\" \"--eip=\" \"--raw_capture_nic=\" \"--mgmt_nic=\" \"--wazuh-register-api-nlb-target-group=${var.WazuhRequired == true ? aws_lb_target_group.WazuhRegistrationNLBTargetGroup[0].id : null}\" \"--wazuh-api-nlb-target-group=${var.WazuhRequired == true ? aws_lb_target_group.WazuhNLBTargetGroup[0].id : null}\" \"--sniffing-nlb-target-group=\" \"--vpc_mirroring_target=${aws_ec2_traffic_mirror_target.TrafficMirrorTarget.id}\" \"--sniffing-nlb-dns-name=${aws_lb.SniffingNLB.dns_name}\" \"--wazuh-nlb-dns-name=${var.WazuhRequired == true ? aws_lb.WazuhNLB[0].dns_name : null}\""
  depends_on           = [aws_lb.SniffingNLB]
  root_block_device {
    volume_size = var.DiskSize
    encrypted   = var.EncryptDisk
    volume_type = length(var.DiskType) > 0 ? var.DiskType : "gp2"
  }
  network_interface {
    network_interface_id = aws_network_interface.VxLanSniffingNic[0].id
    device_index         = 0
  }
  network_interface {
    network_interface_id = aws_network_interface.RawSniffingNic.id
    device_index         = 1
  }
  network_interface {
    network_interface_id = aws_network_interface.ManagementNic.id
    device_index         = 2
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  tags = merge(var.tags, {
    Name                   = "Coralogix STA-NG"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_spot_fleet_request" "STASpotRequest" {
  count                               = var.STALifecycle == "spotfleet" ? 1 : 0
  iam_fleet_role                      = aws_iam_role.STASpotRequestRole[0].arn
  spot_price                          = var.SpotPrice
  allocation_strategy                 = "lowestPrice"
  target_capacity                     = 1
  terminate_instances_with_expiration = true
  launch_template_config {
    launch_template_specification {
      id      = aws_launch_template.STASpotFleetTemplate[0].id
      version = aws_launch_template.STASpotFleetTemplate[0].latest_version
    }
    overrides {
      instance_type = "c5.2xlarge"
    }
    overrides {
      instance_type = "c5d.2xlarge"
    }
    overrides {
      instance_type = "c5a.2xlarge"
    }
    overrides {
      instance_type = "c5n.2xlarge"
    }
    overrides {
      instance_type = "r5.2xlarge"
    }
    overrides {
      instance_type = "m5.2xlarge"
    }
  }
  depends_on = [aws_lb.WazuhNLB, aws_lb.SniffingNLB, aws_eip.MgmtNicElasticIp]
  tags       = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_launch_template" "STASpotFleetTemplate" {
  count         = var.STALifecycle == "spotfleet" ? 1 : 0
  name          = "STA-Spotfleet-Template-${random_string.id.id}"
  ebs_optimized = true
  image_id      = "ami-01be1673d282046fa" # {{$AMI$}}
  instance_type = local.final_size
  key_name      = var.SSHKey
  user_data     = base64encode("#!/bin/bash\n\nsudo /opt/coralogix/sta/userdata_autoexec/userdata_autoexec.py \"--region=eu-west-1\" \"--private_key=${var.PrivateKey}\" \"--company_id=${var.CompanyID}\" \"--app_name=${var.ApplicationName}\" \"--config_bucket=${length(var.ConfigS3BucketName) > 0 ? var.ConfigS3BucketName : aws_s3_bucket.STAConfigBucket[0].id}\" \"--packet_bucket=${var.PacketsS3BucketRequired == false ? "" : length(var.PacketsS3Bucket) > 0 ? var.PacketsS3Bucket : aws_s3_bucket.PacketsS3Bucket[0].id}\" \"--api_endpoint=api.${lookup(var.CoralogixEndpointMap, var.CoralogixEndpoint)}\" \"--syslog_endpoint=syslogserver.${lookup(var.CoralogixEndpointMap, var.CoralogixEndpoint)}\" \"--eip=${var.ElasticIpRequired == true ? aws_eip.MgmtNicElasticIp[0].id : ""}\" \"--raw_capture_nic=${aws_network_interface.RawSniffingNic.id}\" \"--mgmt_nic=${aws_network_interface.ManagementNic.id}\" \"--wazuh-register-api-nlb-target-group=${var.WazuhRequired == true ? aws_lb_target_group.WazuhRegistrationNLBTargetGroup[0].id : ""}\" \"--wazuh-api-nlb-target-group=${var.WazuhRequired == true ? aws_lb_target_group.WazuhNLBTargetGroup[0].id : ""}\" \"--sniffing-nlb-target-group=${aws_lb_target_group.SniffingNLBTargetGroup.id}\" \"--vpc_mirroring_target=${aws_ec2_traffic_mirror_target.TrafficMirrorTarget.id}\" \"--sniffing-nlb-dns-name=${aws_lb.SniffingNLB.dns_name}\" \"--wazuh-nlb-dns-name=${var.WazuhRequired == true ? aws_lb.WazuhNLB[0].dns_name : ""}\"")
  tag_specifications {
    resource_type = "instance"
    tags          = merge(var.tags, {
      Terraform-execution-ID = random_string.id.id
    })
  }
  iam_instance_profile {
    arn = aws_iam_instance_profile.sta-instance-profile.arn
  }
  block_device_mappings {
    device_name = "/dev/sda1"
    ebs {
      volume_size = var.DiskSize
      encrypted   = var.EncryptDisk
      volume_type = length(var.DiskType) > 0 ? var.DiskType : "gp2"
    }
  }
  network_interfaces {
    subnet_id                   = data.aws_subnet.sta-subnet.id
    security_groups             = [aws_security_group.CoralogixSecuritySniffingPolicy-spotfleet[0].id]
    device_index                = 0
    associate_public_ip_address = true
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
# S3 Buckets
resource "aws_s3_bucket" "STAConfigBucket" {
  count         = length(var.ConfigS3BucketName) > 0 ? 0 : 1
  bucket        = "sta-config-${var.ApplicationName}-${random_string.id.id}"
  force_destroy = true
  tags          = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_s3_bucket" "PacketsS3Bucket" {
  count         = var.PacketsS3BucketRequired == true && var.PacketsS3Bucket == "" ? 1 : 0
  bucket        = "sta-packets-${var.ApplicationName}-${random_string.id.id}"
  force_destroy = true
  tags          = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}

# Roles
resource "aws_iam_role" "STASpotRequestRole" {
  name               = "STA-spot-request-Role-${random_string.id.id}"
  count              = var.STALifecycle == "spotfleet" ? 1 : 0
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "spotfleet.amazonaws.com"
        }
      }
    ]
  })
  inline_policy {
    name   = "STA-SpotRequest-Role"
    policy = jsonencode({
      Version   = "2012-10-17"
      Statement = [
        {
          Action = [
            "ec2:DescribeImages",
            "ec2:DescribeSubnets"
          ]
          Effect   = "Allow"
          Resource = "*"
        }
      ]
    })
  }
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_iam_role" "CoralogixSTARole" {
  name               = "STA-Role-${random_string.id.id}"
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_iam_instance_profile" "sta-instance-profile" {
  name = "STA-Instance-Profile-${random_string.id.id}"
  role = aws_iam_role.CoralogixSTARole.name
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}

# Policies
resource "aws_iam_policy" "sta-basic-policy" {
  name   = "STA-basic-policy-${random_string.id.id}"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid : "BasicSTAPermissions",
        Effect : "Allow",
        Action : [
          "elasticloadbalancing:RegisterTargets",
          "cloudformation:DescribeStackResource",
          "ec2:DescribeNetworkInterfaces",
          "s3:ListAllMyBuckets",
          "eks:DescribeCluster",
          "elasticloadbalancing:DescribeInstanceHealth"
        ]
        Resource : "*"
      },
      {
        Sid : "VpcTrafficMirroring",
        Effect : "Allow",
        Action : [
          "ec2:DescribeTrafficMirrorSessions",
          "ec2:DescribeTrafficMirrorFilters",
          "ec2:DescribeTrafficMirrorTargets",
          "ec2:DeleteTrafficMirrorSession",
          "ec2:CreateTrafficMirrorSession",
          "sts:GetCallerIdentity",
          "ec2:DescribeInstances"
        ],
        Resource : "*"
      },
      {
        Sid : "DanglingDNSDetection",
        Effect : "Allow",
        Action : [
          "ec2:DescribeAddresses",
          "route53:ListResourceRecordSets",
          "route53:ListHostedZones"
        ],
        Resource : "*"
      },
      {
        Sid : "TagReadForMirroring",
        Effect : "Allow",
        Action : [
          "ec2:DescribeTags"
        ],
        Resource : "*"
      }
    ]
  })
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_iam_policy" "ConfigS3Access" {
  name   = "STA-Config-Bucket-Access-${random_string.id.id}"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid : "ConfigS3Access",
        Effect : "Allow",
        Action : "s3:*",
        Resource : [
          length(var.ConfigS3BucketName) > 0 ? "arn:aws:s3:::${var.ConfigS3BucketName}" : aws_s3_bucket.STAConfigBucket[0].arn,
          length(var.ConfigS3BucketName) > 0 ? "arn:aws:s3:::${var.ConfigS3BucketName}/*" : "${aws_s3_bucket.STAConfigBucket[0].arn}/*"
        ]
      }
    ]
  })
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_iam_policy" "STAInstanceInternalActions" {
  name   = "STA-instance-internal-actions-${random_string.id.id}"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid : "STAInstanceInternalActions",
        Effect : "Allow",
        Action : [
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource : var.STALifecycle == "ondemand" ? aws_instance.STAEC2Instance-ondemand[0].arn : "*"
      }
    ]
  })
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_iam_policy" "sta-spotfleet-initialization" {
  count  = var.STALifecycle == "spotfleet" ? 1 : 0
  name   = "STA-spotfleet-initialization-${random_string.id.id}"
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid : "STASpotfleetInitialization",
        Effect : "Allow",
        Action : [
          "ec2:AttachNetworkInterface"
        ]
        Resource : [
          "*"
          #          aws_network_interface.RawSniffingNic.arn,
          #          aws_network_interface.ManagementNic.arn,
        ]
      },
      {
        Sid : "EIPAssociation",
        Effect : "Allow",
        Action : [
          "ec2:AssociateAddress",
          "ec2:DisassociateAddress"
        ],
        Resource : [
          "*"
        ]
      }
    ]
  })
  tags = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
}

# Policies attachments
resource "aws_iam_policy_attachment" "sta-basic-policy" {
  name       = "sta-basic-policy-attachment"
  policy_arn = aws_iam_policy.sta-basic-policy.arn
  roles      = [aws_iam_role.CoralogixSTARole.name]
}
resource "aws_iam_policy_attachment" "ConfigS3Access" {
  name       = "sta-config-s3-access"
  policy_arn = aws_iam_policy.ConfigS3Access.arn
  roles      = [aws_iam_role.CoralogixSTARole.name]
}
resource "aws_iam_policy_attachment" "STAInstanceInternalActions" {
  name       = "sta-instance-internal-access"
  policy_arn = aws_iam_policy.STAInstanceInternalActions.arn
  roles      = [aws_iam_role.CoralogixSTARole.name]
}
resource "aws_iam_policy_attachment" "sta-spotfleet-initialization" {
  count      = var.STALifecycle == "spotfleet" ? 1 : 0
  name       = "sta-spotfleet-initialization-attach"
  policy_arn = aws_iam_policy.sta-spotfleet-initialization[0].arn
  roles      = [aws_iam_role.CoralogixSTARole.name]
}

# Security Groups
resource "aws_security_group" "management-sg-Wazuh" {
  count       = var.MgmtNicSecurityGroupID == "" && var.WazuhRequired == true ? 1 : 0
  name        = "STA-management-wazuh-${random_string.id.id}"
  description = "Allow management access to the STA"
  vpc_id      = data.aws_subnet.sta-subnet.vpc_id
  tags        = merge(var.tags, {
    Name                   = "STA-Management-with-wazuh"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_security_group" "management-sg-NoWazuh" {
  count       = var.MgmtNicSecurityGroupID == "" && var.WazuhRequired == false ? 1 : 0
  name        = "sta-management-no-wazuh${random_string.id.id}"
  description = "Allow management access to the STA"
  vpc_id      = data.aws_subnet.sta-subnet.vpc_id
  tags        = merge(var.tags, {
    Name                   = "STA-Management"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_security_group" "CoralogixSecuritySniffingPolicy-ondemand" {
  count       = var.STALifecycle == "ondemand" ? 1 : 0
  name        = "STA-internal-comm-for-${var.STALifecycle}-${random_string.id.id}"
  description = "Coralogix-Security-Sniffing-Policy"
  vpc_id      = data.aws_subnet.sta-subnet.vpc_id
  tags        = merge(var.tags, {
    Name                   = "STA-Sniffing"
    Terraform-execution-ID = random_string.id.id
  })
  ingress {
    description      = "TLS from VPC"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 4789
    to_port          = 4789
    protocol         = "udp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
}
resource "aws_security_group" "CoralogixSecuritySniffingPolicy-spotfleet" {
  count       = var.STALifecycle == "spotfleet" ? 1 : 0
  name        = "sta-internal-comm-for-${var.STALifecycle}-${random_string.id.id}"
  description = "Coralogix-Security-Sniffing-Policy"
  vpc_id      = data.aws_vpc.sta-vpc.id
  ingress {
    description      = "Mirroring to the STA"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 4789
    to_port          = 4789
    protocol         = "udp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
  egress {
    description      = "Outbound traffic from the STA during boot"
    cidr_blocks      = ["0.0.0.0/0"]
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
  tags = merge(var.tags, {
    Name                   = "STA-Internal-Communication"
    Terraform-execution-ID = random_string.id.id
  })
}
# Security Groups Rules
resource "aws_security_group_rule" "ssh-ingress" {
  count             = length(var.MgmtNicSecurityGroupID) == 0 ? 1 : 0
  description       = "Allow SSH from creator public IP"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = var.WazuhRequired == true ? aws_security_group.management-sg-Wazuh[0].id : aws_security_group.management-sg-NoWazuh[0].id
  to_port           = 22
  type              = "ingress"
  cidr_blocks       = ["${data.http.external-ip-address.response_body}/32"]
}
resource "aws_security_group_rule" "wazuh-udp-ingress" {
  count             = var.WazuhRequired == true && length(var.MgmtNicSecurityGroupID) == 0 ? 1 : 0
  description       = "Wazuh access"
  from_port         = 1514
  protocol          = "udp"
  security_group_id = aws_security_group.management-sg-Wazuh[0].id
  to_port           = 1515
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.sta-vpc.cidr_block]
}
resource "aws_security_group_rule" "wazuh-tcp-ingress" {
  count             = var.WazuhRequired == true && length(var.MgmtNicSecurityGroupID) == 0 ? 1 : 0
  description       = "Wazuh access"
  from_port         = 1514
  protocol          = "tcp"
  security_group_id = aws_security_group.management-sg-Wazuh[0].id
  to_port           = 1515
  type              = "ingress"
  cidr_blocks       = [data.aws_vpc.sta-vpc.cidr_block]
}
resource "aws_security_group_rule" "egress-any" {
  count             = length(var.MgmtNicSecurityGroupID) == 0 ? 1 : 0
  from_port         = 0
  protocol          = "all"
  security_group_id = var.WazuhRequired == true ? aws_security_group.management-sg-Wazuh[0].id : aws_security_group.management-sg-NoWazuh[0].id
  to_port           = 0
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
}
# Network Interfaces
resource "aws_network_interface" "VxLanSniffingNic" {
  count           = var.STALifecycle == "ondemand" ? 1 : 0
  subnet_id       = data.aws_subnet.sta-subnet.id
  security_groups = [
    var.STALifecycle == "ondemand" ? aws_security_group.CoralogixSecuritySniffingPolicy-ondemand[0].id : aws_security_group.CoralogixSecuritySniffingPolicy-spotfleet[0].id
  ]
  tags = merge(var.tags, {
    Name                   = "STA-VxLanSniffingNic-${random_string.id.id}"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_network_interface" "RawSniffingNic" {
  subnet_id       = data.aws_subnet.sta-subnet.id
  security_groups = [
    var.STALifecycle == "ondemand" ? aws_security_group.CoralogixSecuritySniffingPolicy-ondemand[0].id : aws_security_group.CoralogixSecuritySniffingPolicy-spotfleet[0].id
  ]
  tags = merge(var.tags, {
    Name                   = "STA-RawSniffingNic"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_network_interface" "ManagementNic" {
  subnet_id       = data.aws_subnet.sta-subnet.id
  security_groups = [
    length(var.MgmtNicSecurityGroupID) > 0 ? var.MgmtNicSecurityGroupID : var.WazuhRequired == true ? aws_security_group.management-sg-Wazuh[0].id : aws_security_group.management-sg-NoWazuh[0].id
  ]
  tags = merge(var.tags, {
    Name                   = "STA-ManagementNic"
    Terraform-execution-ID = random_string.id.id
  })
}
# EIP
resource "aws_eip" "MgmtNicElasticIp" {
  count = var.ElasticIpRequired == true ? 1 : 0
  vpc   = true
  tags  = merge(var.tags, {
    Name                   = "STA - Elastic IP"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_eip_association" "ElasticIpAssociation" {
  count                = var.ElasticIpRequired == true ? 1 : 0
  network_interface_id = aws_network_interface.ManagementNic.id
  allocation_id        = aws_eip.MgmtNicElasticIp[0].id
}

# Sniffing load balancer
resource "aws_lb" "SniffingNLB" {
  load_balancer_type = "network"
  name               = "SniffingNLB-${random_string.id.id}"
  internal           = true
  tags               = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  subnet_mapping {
    subnet_id = data.aws_subnet.sta-subnet.id
  }
}
resource "aws_lb_listener" "SniffingNLBListener" {
  load_balancer_arn = aws_lb.SniffingNLB.arn
  port              = 4789
  protocol          = "UDP"
  tags              = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  default_action {
    target_group_arn = aws_lb_target_group.SniffingNLBTargetGroup.arn
    type             = "forward"
  }
}
resource "aws_lb_target_group" "SniffingNLBTargetGroup" {
  name        = "SniffingNLB-TG-${random_string.id.id}"
  port        = 4789
  protocol    = "UDP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.sta-vpc.id
  tags        = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  health_check {
    port     = 4789
    protocol = "TCP"
  }
}
resource "aws_lb_target_group_attachment" "SniffingNLBTargetGroupAttachment" {
  count            = var.STALifecycle == "ondeamnd" ? 1 : 0
  target_group_arn = aws_lb_target_group.SniffingNLBTargetGroup.arn
  target_id        = aws_instance.STAEC2Instance-ondemand[0].id
}
# Wazuh load balancer
resource "aws_lb" "WazuhNLB" {
  count              = var.WazuhRequired == true ? 1 : 0
  load_balancer_type = "network"
  name               = "WazuhNLB-${random_string.id.id}"
  internal           = true
  tags               = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  subnet_mapping {
    subnet_id = data.aws_subnet.sta-subnet.id
  }
}
resource "aws_lb_listener" "WazuhNLBListener" {
  count             = var.WazuhRequired == true ? 1 : 0
  load_balancer_arn = aws_lb.WazuhNLB[0].arn
  port              = 1514
  protocol          = "TCP"
  tags              = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  default_action {
    target_group_arn = aws_lb_target_group.WazuhNLBTargetGroup[0].arn
    type             = "forward"
  }
}
resource "aws_lb_listener" "WazuhRegistrationNLBListener" {
  count             = var.WazuhRequired == true ? 1 : 0
  load_balancer_arn = aws_lb.WazuhNLB[0].id
  port              = 1515
  protocol          = "TCP_UDP"
  tags              = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  default_action {
    target_group_arn = aws_lb_target_group.WazuhRegistrationNLBTargetGroup[0].id
    type             = "forward"
  }
}
resource "aws_lb_target_group" "WazuhNLBTargetGroup" {
  count       = var.WazuhRequired == true ? 1 : 0
  name        = "WazuhNLB-TG-${random_string.id.id}"
  port        = 1514
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.sta-vpc.id
  tags        = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  health_check {
    port     = 1515
    protocol = "TCP"
  }
}
resource "aws_lb_target_group" "WazuhRegistrationNLBTargetGroup" {
  count       = var.WazuhRequired == true ? 1 : 0
  name        = "WazuhRegNLB-TG-${random_string.id.id}"
  port        = 1515
  protocol    = "TCP_UDP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.sta-vpc.id
  tags        = merge(var.tags, {
    Terraform-execution-ID = random_string.id.id
  })
  health_check {
    port     = 1515
    protocol = "TCP"
  }
}

# Mirror target
resource "aws_ec2_traffic_mirror_target" "TrafficMirrorTarget" {
  description               = "NLB target"
  network_load_balancer_arn = aws_lb.SniffingNLB.arn
  tags                      = merge(var.tags, {
    Name                   = "STA Traffic mirror target"
    Terraform-execution-ID = random_string.id.id
  })
}
# Mirror filter - All
resource "aws_ec2_traffic_mirror_filter" "CoralogixSecurityServiceMirrorFilterAll" {
  description      = "Coralogix STA - Mirror Everything"
  network_services = ["amazon-dns"]
  tags             = merge(var.tags, {
    Name                   = "STA - Mirror Filter - Everything"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorEgressFilterRuleAllEgress1" {
  description              = "Mirror ALL outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterAll.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "reject"
  traffic_direction        = "egress"
  protocol                 = 17
  destination_port_range {
    from_port = 4789
    to_port   = 4789
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorEgressFilterRuleAllEgress2" {
  description              = "Mirror ALL outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterAll.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 2
  rule_action              = "accept"
  traffic_direction        = "egress"
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleAllIngress1" {
  description              = "Mirror ALL incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterAll.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "ingress"
}
# Mirror filter - Moderate
resource "aws_ec2_traffic_mirror_filter" "CoralogixSecurityServiceMirrorFilterModerate" {
  description      = "Coralogix STA - Moderate Mirror"
  network_services = ["amazon-dns"]
  tags             = merge(var.tags, {
    Name                   = "STA - Mirror Filter - Moderate"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorEgressFilterRuleModerateEgress1" {
  description              = "Excludes HTTP outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "reject"
  traffic_direction        = "egress"
  protocol                 = 6
  destination_port_range {
    from_port = 80
    to_port   = 80
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorEgressFilterRuleModerateEgress2" {
  description              = "Excludes HTTPS and SMB outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 2
  rule_action              = "reject"
  traffic_direction        = "egress"
  protocol                 = 6
  destination_port_range {
    from_port = 443
    to_port   = 445
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleModerateIngress1" {
  description              = "Excludes HTTP incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "reject"
  traffic_direction        = "ingress"
  protocol                 = 6
  destination_port_range {
    from_port = 80
    to_port   = 80
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleModerateIngress2" {
  description              = "Excludes HTTPS and SMB outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 2
  rule_action              = "reject"
  traffic_direction        = "ingress"
  protocol                 = 6
  destination_port_range {
    from_port = 443
    to_port   = 445
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleModerateIngress3" {
  description              = "Excludes HTTP incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 3
  rule_action              = "reject"
  traffic_direction        = "ingress"
  protocol                 = 6
  source_port_range {
    from_port = 80
    to_port   = 80
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleModerateIngress4" {
  description              = "Excludes HTTPS and SMB outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 4
  rule_action              = "reject"
  traffic_direction        = "ingress"
  protocol                 = 6
  source_port_range {
    from_port = 443
    to_port   = 445
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleModerateIngress5" {
  description              = "Mirror most valuable incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 5
  rule_action              = "reject"
  traffic_direction        = "ingress"
  protocol                 = 17
  destination_port_range {
    from_port = 4789
    to_port   = 4789
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorEgressFilterRuleModerateEgress3" {
  description              = "Excludes HTTP outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 3
  rule_action              = "reject"
  traffic_direction        = "egress"
  protocol                 = 6
  source_port_range {
    from_port = 80
    to_port   = 80
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorEgressFilterRuleModerateEgress4" {
  description              = "Excludes HTTPS and SMB outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterModerate.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 4
  rule_action              = "reject"
  traffic_direction        = "egress"
  protocol                 = 6
  source_port_range {
    from_port = 443
    to_port   = 445
  }
}
# Mirror filter - Essential
resource "aws_ec2_traffic_mirror_filter" "CoralogixSecurityServiceMirrorFilterEssential" {
  description      = "Coralogix STA - Mirror only the very basic"
  network_services = ["amazon-dns"]
  tags             = merge(var.tags, {
    Name                   = "STA - Mirror Filter - Essential"
    Terraform-execution-ID = random_string.id.id
  })
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialEgress1" {
  description              = "Mirror the highest value outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 6
  destination_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialEgress2" {
  description              = "Mirror the highest value outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 2
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 17
  destination_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialIngress1" {
  description              = "Mirror the highest value incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 1
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 6
  destination_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialIngress2" {
  description              = "Mirror the highest value incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 2
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 17
  destination_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialEgress3" {
  description              = "Mirror the highest value outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 3
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 6
  source_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialEgress4" {
  description              = "Mirror the highest value outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 4
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 17
  source_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialEgress5" {
  description              = "Mirror the highest value outgoing traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 5
  rule_action              = "accept"
  traffic_direction        = "egress"
  protocol                 = 1
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialIngress3" {
  description              = "Mirror the highest value incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 3
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 6
  source_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialIngress4" {
  description              = "Mirror the highest value incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 4
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 17
  source_port_range {
    from_port = 1
    to_port   = 79
  }
}
resource "aws_ec2_traffic_mirror_filter_rule" "TrafficMirrorIngressFilterRuleEssentialIngress5" {
  description              = "Mirror the highest value incoming traffic"
  traffic_mirror_filter_id = aws_ec2_traffic_mirror_filter.CoralogixSecurityServiceMirrorFilterEssential.id
  destination_cidr_block   = "0.0.0.0/0"
  source_cidr_block        = "0.0.0.0/0"
  rule_number              = 5
  rule_action              = "accept"
  traffic_direction        = "ingress"
  protocol                 = 1
}

# Coralogix
resource "coralogix_enrichment" "suspicious_ip_enrichment" {
  count = var.CreateCustomEnrichment == true && length(var.AlertsPrivateKey) > 0 ? 1 : 0
  suspicious_ip {
    fields {
      name = "security.source_ip"
    }
    fields {
      name = "security.destination_ip"
    }
  }
}

# Misc
resource "random_string" "id" {
  length  = 8
  upper   = false
  special = false
}
