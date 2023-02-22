resource "aws_instance" "cspm-instance" {
  ami                         = lookup(var.ubuntu-amis-map, data.aws_region.current.name)
  instance_type               = length(var.instanceType) > 0 ? var.instanceType : "t3.small"
  key_name                    = var.SSHKeyName
  iam_instance_profile        = aws_iam_instance_profile.CSPMInstanceProfile.id
  associate_public_ip_address = var.public_instance
  subnet_id                   = var.Subnet_ID
  vpc_security_group_ids      = [
    var.security_group_id != "" ? var.security_group_id : aws_security_group.CSPMSecurityGroup[0].id
  ]
  user_data = <<EOT
#!/bin/bash
echo -e \"${local.user-pass}\n${local.user-pass}\" | /usr/bin/passwd ubuntu
apt update
apt-get remove docker docker-engine docker.io containerd runc
apt-get install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null\nsudo apt update
apt update
apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin -y
crontab -l | { cat; echo "*/10 * * * * docker rm snowbit-cspm ; docker rmi coralogixrepo/snowbit-cspm${local.user-provided-version-not-latest} ; docker run --name snowbit-cspm -d -e PYTHONUNBUFFERED=1 -e CLOUD_PROVIDER=aws -e AWS_DEFAULT_REGION=eu-west-1 -e CORALOGIX_ENDPOINT_HOST=${lookup(var.grpc-endpoints-map, var.GRPC_Endpoint)} -e APPLICATION_NAME=${length(var.applicationName) > 0 ? var.applicationName : "CSPM"} -e SUBSYSTEM_NAME=${length(var.subsystemName) > 0 ? var.subsystemName : "CSPM"} -e TESTER_LIST=${var.TesterList} -e API_KEY=${var.PrivateKey} -e REGION_LIST=${var.RegionList} -e ROLE_ARN_LIST=${var.multiAccountsARNs} -e CORALOGIX_ALERT_API_KEY=${var.alertAPIkey} -e COMPANY_ID=${var.Company_ID} -v ~/.aws/credentials:/root/.aws/credentials coralogixrepo/snowbit-cspm${local.user-provided-version-not-latest}"; } | crontab -
usermod -aG docker ubuntu
newgrp docker
docker pull coralogixrepo/snowbit-cspm${local.user-provided-version-not-latest}
EOT
  root_block_device {
    volume_type = length(var.DiskType) > 0 ? var.DiskType : "gp3"
    encrypted   = var.ebs_encryption
  }
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 2
  }
  tags = merge(var.additional_tags,
    {
      Name         = "Snowbit CSPM"
      Terraform-ID = random_string.id.id
    },
  )
}

resource "aws_security_group" "CSPMSecurityGroup" {
  name        = "CSPM-Security-Group-${random_string.id.id}"
  count       = var.security_group_id == "" ? 1 : 0
  vpc_id      = data.aws_subnet.subnet.vpc_id
  description = "A security group for Snowbit CSPM"
  tags        = merge(var.additional_tags,
    {
      Terraform-ID = random_string.id.id
    }
  )
  ingress {
    description = var.SSHIpAddress == "0.0.0.0/0" ?  "SSH from the world" : length(var.SSHIpAddress) > 0 ? "SSH from user provided IP - ${var.SSHIpAddress}" : "SSH from the creators public IP - ${data.http.external-ip-address.response_body}/32"
    cidr_blocks = [
      length(var.SSHIpAddress) > 0 ? var.SSHIpAddress : "${data.http.external-ip-address.response_body}/32"
    ]
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    ipv6_cidr_blocks = []
    prefix_list_ids  = []
    security_groups  = []
    self             = false
  }
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
resource "aws_iam_instance_profile" "CSPMInstanceProfile" {
  name = "CSPM-Instance-Profile-${random_string.id.id}"
  role = aws_iam_role.CSPMRole.name
  tags = merge(var.additional_tags,
    {
      Terraform-ID = random_string.id.id
    }
  )
}
resource "aws_iam_role" "CSPMRole" {
  name = "CSPM-Role-${random_string.id.id}"
  tags = merge(var.additional_tags,
    {
      Terraform-ID = random_string.id.id
    }
  )
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Sid       = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}
resource "aws_iam_policy" "CSPMPolicy" {
  name   = "CSPM-Policy-${random_string.id.id}"
  policy = data.http.policy.response_body
  tags   = merge(var.additional_tags,
    {
      Terraform-ID = random_string.id.id
    }
  )
}
resource "aws_iam_policy" "CSPMAssumeRolePolicy" {
  name   = "CSPM-Assume-Role-Policy-${random_string.id.id}"
  count  = length(var.multiAccountsARNs) > 10 ? 1 : 0
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        "Sid" : "CSPMAssumeRole",
        "Effect" : "Allow",
        "Action" : "sts:AssumeRole",
        Resource : split(",", var.multiAccountsARNs)
      }
    ]
  })
  tags = merge(var.additional_tags,
    {
      Terraform-ID = random_string.id.id
    }
  )
}
resource "aws_iam_policy_attachment" "CSPMPolicy" {
  name       = "CSPMPolicy-attach"
  policy_arn = aws_iam_policy.CSPMPolicy.arn
  roles      = [aws_iam_role.CSPMRole.name]
}
resource "aws_iam_policy_attachment" "CSPMAssumeRolePolicy" {
  count      = length(var.multiAccountsARNs) > 10 ? 1 : 0
  name       = "CSPMAssumeRolePolicy-attach"
  policy_arn = aws_iam_policy.CSPMAssumeRolePolicy[0].arn
  roles      = [aws_iam_role.CSPMRole.name]

}
resource "random_string" "id" {
  length  = 6
  special = false
  upper   = false
}
