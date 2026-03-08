terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get available AZs in Singapore region
data "aws_availability_zones" "available" {
  state = "available"
}

# Security Group
resource "aws_security_group" "kubernetes_sg" {
  name        = "kubernetes-security-group-singapore"
  description = "Security group for Kubernetes cluster in Singapore"
  vpc_id      = var.vpc_id

  # SSH access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubernetes API server
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # etcd server client API
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kubelet API
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # NodePort Services
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Frontend (Next.js)
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Backend (NestJS)
  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # MongoDB
  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Grafana
  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Prometheus
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Loki
  ingress {
    from_port   = 3100
    to_port     = 3100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ArgoCD
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ArgoCD API
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "kubernetes-sg-singapore"
    Environment = "production"
    Region      = "Singapore"
    ManagedBy   = "Terraform"
  }
}

# Master Node (Control Plane)
resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = var.master_instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  subnet_id             = var.subnet_id
  #availability_zone      = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name        = "k8s-master-singapore"
    Role        = "master"
    Environment = "production"
    Region      = "Singapore"
    ManagedBy   = "Terraform"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
    delete_on_termination = true
    tags = {
      Name = "k8s-master-root-singapore"
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Master node provisioning in Singapore region..."
    
    # Set timezone to Singapore Time
    timedatectl set-timezone Asia/Singapore
    
    # Update system
    apt-get update -y
    apt-get upgrade -y
    
    # Install basic packages
    apt-get install -y \
      python3 \
      python3-pip \
      curl \
      wget \
      git \
      vim \
      htop \
      net-tools \
      tree \
      jq \
      unzip \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release
    
    # Optimize system for Kubernetes control plane
    echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf
    echo 'net.bridge.bridge-nf-call-iptables=1' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_tw_reuse=1' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_fin_timeout=30' >> /etc/sysctl.conf
    sysctl -p
    
    # Create swap file for additional memory
    fallocate -l 2G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    
    # Set swappiness to lower value for Kubernetes
    echo 'vm.swappiness=10' >> /etc/sysctl.conf
    sysctl -p
    
    # Configure APT to use Singapore mirrors for faster downloads
    sed -i 's/archive.ubuntu.com/ap-southeast-1.ec2.archive.ubuntu.com/g' /etc/apt/sources.list
    
    echo "Master node setup complete for Singapore region"
  EOF
}

# Worker Node 1 (Frontend Primary - Next.js)
resource "aws_instance" "worker_1" {
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  subnet_id             = var.subnet_id
  #availability_zone      = data.aws_availability_zones.available.names[0]
  
  tags = {
    Name        = "k8s-worker-1-singapore"
    Role        = "worker"
    Environment = "production"
    Region      = "Singapore"
    Workload    = "frontend-primary"
    ManagedBy   = "Terraform"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
    delete_on_termination = true
    tags = {
      Name = "k8s-worker-1-root-singapore"
    }
  }

  # Additional EBS volume for Next.js build cache and static assets
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = var.frontend_cache_volume_size
    encrypted   = true
    delete_on_termination = true
    tags = {
      Name = "k8s-worker-1-frontend-cache-singapore"
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Worker node 1 (Frontend Primary) provisioning in Singapore region..."
    
    # Set timezone to Singapore Time
    timedatectl set-timezone Asia/Singapore
    
    # Update system
    apt-get update -y
    apt-get upgrade -y
    
    # Configure APT to use Singapore mirrors
    sed -i 's/archive.ubuntu.com/ap-southeast-1.ec2.archive.ubuntu.com/g' /etc/apt/sources.list
    apt-get update -y
    
    # Install basic packages
    apt-get install -y \
      python3 \
      python3-pip \
      curl \
      wget \
      git \
      vim \
      htop \
      net-tools \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release \
      build-essential
    
    # Format and mount additional volume for frontend cache
    mkfs.ext4 /dev/xvdf
    mkdir -p /var/lib/frontend-cache
    mount /dev/xvdf /var/lib/frontend-cache
    echo '/dev/xvdf /var/lib/frontend-cache ext4 defaults 0 0' | tee -a /etc/fstab
    
    # Optimize for Next.js frontend workloads
    echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.conf
    echo 'fs.inotify.max_user_instances=512' >> /etc/sysctl.conf
    echo 'fs.inotify.max_queued_events=16384' >> /etc/sysctl.conf
    echo 'net.core.somaxconn=1024' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_max_syn_backlog=1024' >> /etc/sysctl.conf
    echo 'net.core.rmem_max=16777216' >> /etc/sysctl.conf
    echo 'net.core.wmem_max=16777216' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_rmem=4096 87380 16777216' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_wmem=4096 65536 16777216' >> /etc/sysctl.conf
    sysctl -p
    
    # Create swap file for additional memory
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    
    # Set swappiness
    echo 'vm.swappiness=30' >> /etc/sysctl.conf
    sysctl -p
    
    # Create directory for Next.js build cache
    mkdir -p /var/lib/frontend-cache/nextjs
    chmod 755 /var/lib/frontend-cache/nextjs
    
    # Install Node.js 18.x for potential local builds
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
    apt-get install -y nodejs
    
    echo "Worker node 1 (Frontend Primary) setup complete for Singapore region"
  EOF
}

# Worker Node 2 (Backend + MongoDB)
resource "aws_instance" "worker_2" {
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  subnet_id             = var.subnet_id
  #availability_zone      = data.aws_availability_zones.available.names[1]
  
  tags = {
    Name        = "k8s-worker-2-singapore"
    Role        = "worker"
    Environment = "production"
    Region      = "Singapore"
    Workload    = "backend-mongodb"
    ManagedBy   = "Terraform"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
    delete_on_termination = true
    tags = {
      Name = "k8s-worker-2-root-singapore"
    }
  }

  # Additional EBS volume for MongoDB
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = var.mongodb_volume_size
    encrypted   = true
    delete_on_termination = false  # Keep MongoDB data even if instance terminates
    tags = {
      Name = "k8s-worker-2-mongodb-data-singapore"
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Worker node 2 (Backend + MongoDB) provisioning in Singapore region..."
    
    # Set timezone to Singapore Time
    timedatectl set-timezone Asia/Singapore
    
    # Update system
    apt-get update -y
    apt-get upgrade -y
    
    # Configure APT to use Singapore mirrors
    sed -i 's/archive.ubuntu.com/ap-southeast-1.ec2.archive.ubuntu.com/g' /etc/apt/sources.list
    apt-get update -y
    
    # Install basic packages
    apt-get install -y \
      python3 \
      python3-pip \
      curl \
      wget \
      git \
      vim \
      htop \
      net-tools \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release
    
    # Format and mount MongoDB volume
    mkfs.ext4 /dev/xvdf
    mkdir -p /data/mongodb
    mount /dev/xvdf /data/mongodb
    echo '/dev/xvdf /data/mongodb ext4 defaults 0 0' | tee -a /etc/fstab
    
    # Optimize for MongoDB
    echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    echo 'kernel.pid_max=4194303' >> /etc/sysctl.conf
    echo 'fs.file-max=98000' >> /etc/sysctl.conf
    echo 'vm.swappiness=1' >> /etc/sysctl.conf
    echo 'vm.dirty_ratio=15' >> /etc/sysctl.conf
    echo 'vm.dirty_background_ratio=5' >> /etc/sysctl.conf
    echo 'net.core.somaxconn=4096' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_max_syn_backlog=4096' >> /etc/sysctl.conf
    sysctl -p
    
    # Set ulimits for MongoDB
    echo 'ubuntu soft nofile 64000' >> /etc/security/limits.conf
    echo 'ubuntu hard nofile 64000' >> /etc/security/limits.conf
    echo 'ubuntu soft nproc 32000' >> /etc/security/limits.conf
    echo 'ubuntu hard nproc 32000' >> /etc/security/limits.conf
    
    # Create swap file
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    
    # Create MongoDB data directory
    mkdir -p /data/mongodb
    chmod 755 /data/mongodb
    
    # Install MongoDB tools
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-6.0.list
    apt-get update -y
    apt-get install -y mongodb-org-shell mongodb-org-tools
    
    echo "Worker node 2 (Backend + MongoDB) setup complete for Singapore region"
  EOF
}

# Worker Node 3 (Frontend Replica + Monitoring)
resource "aws_instance" "worker_3" {
  ami                    = var.ami_id
  instance_type          = var.worker_instance_type
  key_name              = var.key_name
  vpc_security_group_ids = [aws_security_group.kubernetes_sg.id]
  subnet_id             = var.subnet_id
  #availability_zone      = data.aws_availability_zones.available.names[2]
  
  tags = {
    Name        = "k8s-worker-3-singapore"
    Role        = "worker"
    Environment = "production"
    Region      = "Singapore"
    Workload    = "frontend-monitoring"
    ManagedBy   = "Terraform"
  }

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
    delete_on_termination = true
    tags = {
      Name = "k8s-worker-3-root-singapore"
    }
  }

  # Additional EBS volume for monitoring data (Prometheus/Grafana/Loki)
  ebs_block_device {
    device_name = "/dev/sdf"
    volume_type = "gp3"
    volume_size = var.monitoring_volume_size
    encrypted   = true
    delete_on_termination = true
    tags = {
      Name = "k8s-worker-3-monitoring-data-singapore"
    }
  }

  user_data = <<-EOF
    #!/bin/bash
    echo "Worker node 3 (Frontend Replica + Monitoring) provisioning in Singapore region..."
    
    # Set timezone to Singapore Time
    timedatectl set-timezone Asia/Singapore
    
    # Update system
    apt-get update -y
    apt-get upgrade -y
    
    # Configure APT to use Singapore mirrors
    sed -i 's/archive.ubuntu.com/ap-southeast-1.ec2.archive.ubuntu.com/g' /etc/apt/sources.list
    apt-get update -y
    
    # Install basic packages
    apt-get install -y \
      python3 \
      python3-pip \
      curl \
      wget \
      git \
      vim \
      htop \
      net-tools \
      apt-transport-https \
      ca-certificates \
      gnupg \
      lsb-release
    
    # Format and mount monitoring volume
    mkfs.ext4 /dev/xvdf
    mkdir -p /data/monitoring
    mount /dev/xvdf /data/monitoring
    echo '/dev/xvdf /data/monitoring ext4 defaults 0 0' | tee -a /etc/fstab
    
    # Optimize for both frontend and monitoring workloads
    echo 'fs.inotify.max_user_watches=524288' >> /etc/sysctl.conf
    echo 'fs.inotify.max_user_instances=512' >> /etc/sysctl.conf
    echo 'vm.max_map_count=262144' >> /etc/sysctl.conf
    echo 'net.core.somaxconn=1024' >> /etc/sysctl.conf
    echo 'net.ipv4.tcp_max_syn_backlog=1024' >> /etc/sysctl.conf
    sysctl -p
    
    # Create swap file
    fallocate -l 4G /swapfile
    chmod 600 /swapfile
    mkswap /swapfile
    swapon /swapfile
    echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
    
    # Set swappiness
    echo 'vm.swappiness=20' >> /etc/sysctl.conf
    sysctl -p
    
    # Create directories for monitoring data
    mkdir -p /data/monitoring/{prometheus,grafana,loki}
    chmod 755 /data/monitoring/{prometheus,grafana,loki}
    
    # Create directory for frontend cache replica
    mkdir -p /var/lib/frontend-cache-replica/nextjs
    chmod 755 /var/lib/frontend-cache-replica/nextjs
    
    # Install monitoring tools
    curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /usr/share/keyrings/grafana.gpg
    echo "deb [signed-by=/usr/share/keyrings/grafana.gpg] https://apt.grafana.com stable main" | tee /etc/apt/sources.list.d/grafana.list
    apt-get update -y
    
    echo "Worker node 3 (Frontend Replica + Monitoring) setup complete for Singapore region"
  EOF
}

# Elastic IP for Master Node (optional - for consistent access)
resource "aws_eip" "master_eip" {
  instance = aws_instance.master.id
  domain   = "vpc"
  
  tags = {
    Name        = "k8s-master-eip-singapore"
    Environment = "production"
    Region      = "Singapore"
  }
}

# Outputs
output "master_public_ip" {
  value = aws_eip.master_eip.public_ip
  description = "Master node public IP with Elastic IP for consistent access"
}

output "master_private_ip" {
  value = aws_instance.master.private_ip
  description = "Master node private IP"
}

output "worker_1_public_ip" {
  value = aws_instance.worker_1.public_ip
  description = "Worker node 1 (Frontend Primary) public IP"
}

output "worker_1_private_ip" {
  value = aws_instance.worker_1.private_ip
  description = "Worker node 1 (Frontend Primary) private IP"
}

output "worker_2_public_ip" {
  value = aws_instance.worker_2.public_ip
  description = "Worker node 2 (Backend + MongoDB) public IP"
}

output "worker_2_private_ip" {
  value = aws_instance.worker_2.private_ip
  description = "Worker node 2 (Backend + MongoDB) private IP"
}

output "worker_3_public_ip" {
  value = aws_instance.worker_3.public_ip
  description = "Worker node 3 (Frontend Replica + Monitoring) public IP"
}

output "worker_3_private_ip" {
  value = aws_instance.worker_3.private_ip
  description = "Worker node 3 (Frontend Replica + Monitoring) private IP"
}

output "aws_region" {
  value = var.aws_region
  description = "AWS Region (Singapore - ap-southeast-1)"
}

output "availability_zones" {
  value = data.aws_availability_zones.available.names
  description = "Available AZs in Singapore region"
}

output "security_group_id" {
  value = aws_security_group.kubernetes_sg.id
  description = "Security Group ID"
}

output "instance_ids" {
  value = {
    master  = aws_instance.master.id
    worker1 = aws_instance.worker_1.id
    worker2 = aws_instance.worker_2.id
    worker3 = aws_instance.worker_3.id
  }
  description = "Instance IDs of all nodes"
}

# Connection information for easy reference
output "connection_info" {
  value = {
    master = {
      public_ip  = aws_eip.master_eip.public_ip
      private_ip = aws_instance.master.private_ip
      user       = "ubuntu"
      ssh_key    = var.key_name
    }
    worker1 = {
      public_ip  = aws_instance.worker_1.public_ip
      private_ip = aws_instance.worker_1.private_ip
      user       = "ubuntu"
      ssh_key    = var.key_name
      workload   = "Frontend Primary"
    }
    worker2 = {
      public_ip  = aws_instance.worker_2.public_ip
      private_ip = aws_instance.worker_2.private_ip
      user       = "ubuntu"
      ssh_key    = var.key_name
      workload   = "Backend + MongoDB"
    }
    worker3 = {
      public_ip  = aws_instance.worker_3.public_ip
      private_ip = aws_instance.worker_3.private_ip
      user       = "ubuntu"
      ssh_key    = var.key_name
      workload   = "Frontend Replica + Monitoring"
    }
  }
  description = "Connection information for all nodes"
}

# Application endpoints
output "application_endpoints" {
  value = {
    frontend_primary   = "http://${aws_instance.worker_1.public_ip}:3000"
    frontend_replica   = "http://${aws_instance.worker_3.public_ip}:3000"
    backend           = "http://${aws_instance.worker_2.public_ip}:5000"
    mongodb           = "${aws_instance.worker_2.private_ip}:27017"
    argocd            = "https://${aws_eip.master_eip.public_ip}:443"
    grafana           = "http://${aws_instance.worker_3.public_ip}:3001"
    prometheus        = "http://${aws_instance.worker_3.public_ip}:9090"
    loki              = "http://${aws_instance.worker_3.public_ip}:3100"
  }
  description = "Application endpoints"
}

# Network performance metrics
output "network_info" {
  value = {
    region              = "ap-southeast-1 (Singapore)"
    region_description  = "Southeast Asia - Singapore"
    latency_optimized   = "Optimized for Southeast Asian users"
    available_azs       = data.aws_availability_zones.available.names
  }
  description = "Network information for Singapore region"
}