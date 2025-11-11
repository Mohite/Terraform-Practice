# ---------- IAM role & instance profile for EC2 so it can read Secrets Manager ----------
resource "aws_iam_role" "ec2_secrets_role" {
  name = "ec2-secrets-role"

  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "allow_get_secret" {
  name = "allow-get-secret"
  role = aws_iam_role.ec2_secrets_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = aws_secretsmanager_secret.rds_credentials.arn
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-secrets-profile"
  role = aws_iam_role.ec2_secrets_role.name
}

# ---------- Secrets Manager secret holding DB credentials ----------
resource "aws_secretsmanager_secret" "rds_credentials" {
  name = "rds/mysql/terraform-example"
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    username = "admin"
    password = "Admin1234"
  })
}

# ---------- Security groups ----------
# Assume aws_vpc.main exists. RDS SG allows access from EC2 SG, EC2 SG allows SSH from your IP.
resource "aws_security_group" "ec2_sg" {
  name        = "ec2-sg"
  vpc_id      = "vpc-003a8437ac4da9e45"
  description = "Allow SSH outbound to RDS"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.2.0/24"]  # replace
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_sg" {
  name        = "rds-sg"
  vpc_id      = "vpc-003a8437ac4da9e45"
  description = "Allow MySQL from EC2"
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ---------- EC2 instance that will run the SQL (in same VPC/subnet) ----------
resource "aws_instance" "sql_runner" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 (update to your region's AMI)
  instance_type          = "t3.micro"
  key_name               = "projectkeypair"                # replace
  subnet_id              = "subnet-0c97712f119e49451"   # ensure same VPC/subnet group as RDS or reachable
  vpc_security_group_ids = [aws_security_group.ec2_sg.id]
  associate_public_ip_address = true  # set false if you want private-only and use bastion/NAT/VPC endpoint

  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y mysql jq
              EOF

  tags = { Name = "SQL Runner" }
}

# ---------- Upload init.sql and run it remotely using remote-exec ----------
resource "null_resource" "remote_sql_exec" {
  depends_on = [aws_secretsmanager_secret_version.rds_secret_value, aws_instance.sql_runner]

  connection {
    type        = "ssh"
    user        = "ec2-user"                          # Amazon Linux default
    private_key = file("~/.ssh/my-key.pem")           # replace with path to your PEM
    host        = aws_instance.sql_runner.public_ip
    timeout     = "8m"
  }

  provisioner "file" {
    source      = "init.sql"
    destination = "/tmp/init.sql"
  }

  provisioner "remote-exec" {
    inline = [
      # Fetch secret JSON, parse username/password, then execute SQL
      "SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${aws_secretsmanager_secret.rds_credentials.name} --query SecretString --output text)",
      "DB_USER=$(echo $SECRET_JSON | jq -r .username)",
      "DB_PASS=$(echo $SECRET_JSON | jq -r .password)",
      "mysql -h terraform-20251110155733531000000001.c6n2os6k2y7d.us-east-1.rds.amazonaws.com -u $DB_USER -p$DB_PASS mydb < /tmp/init.sql"
    ]
  }

  triggers = {
    always_run = timestamp()
  }
}
