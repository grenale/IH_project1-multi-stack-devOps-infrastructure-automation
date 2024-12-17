# 🚀 Grenale Application Setup

Welcome to the **Grenale** project! This repository contains all the necessary infrastructure and application code to deploy a full-stack voting application on AWS using **Terraform** and **Ansible**. The application runs with Docker containers and includes components like PostgreSQL, Redis, pgAdmin, and web apps for voting and displaying results.

## 🌐 Architecture Overview

The infrastructure is built using Terraform and includes:
- A **VPC** with a public subnet
- An **EC2 instance** running Docker containers
- A **Security Group** to control access
- An **Internet Gateway** for public access

The application is built with:
- **PostgreSQL** for data storage
- **Redis** for caching
- **pgAdmin** for database management

And it runs pre-built images:
- **Vote App** for submitting votes
- **Result App** for displaying results
- **Worker App** for processing votes
All built from the code provided by [this repo](http://ec2-instance-ip-address:5050)

## 🛠️ Prerequisites

Before you start, make sure you have the following installed:
- **Terraform** (v0.15+)
- **Ansible** (v2.16+)
- **Docker** (for managing containers)
- **AWS CLI** (for AWS authentication)

## ⚙️ Project Structure

```bash
.
├── ansible
│   ├── ansible.cfg          # Ansible configuration
│   ├── inventory/hosts.ini  # EC2 instances inventory
│   ├── main_playbook.yaml   # Ansible playbook to set up the environment
│   ├── pgadmin_servers.json # pgAdmin servers configuration - not included ⛔️
│   └── roles                # Ansible roles for managing Docker installation, network, containers, and authorized keys
├── terraform
│   ├── ec2.tf               # EC2 instance configuration
│   ├── security_groups.tf   # Security group setup for the instances
│   ├── provider.tf          # AWS provider configuration
│   ├── variables.tf         # Terraform variables
│   ├── outputs.tf           # Terraform output for the EC2 public IP
│   ├── vpc.tf               # VPC, subnet, and routing setup
│   └── terraform.tfvars     # Variables for VPC, EC2, S3 and Ansible configuration - not included ⛔️
└── your_aws_key_pair.pem    # SSH private key for EC2 access - not included ⛔️
```

## 🔧 How to Deploy

### Step 1: Clone the Repository
Clone the project repository:

```bash
git clone https://github.com/grenale/ansible-and-terraform-project.git
cd ansible-and-terraform-project
```

### Step 2: Setup Terraform
Initialize Terraform:

```bash
cd terraform
terraform init
```

Now, create your own `terraform.tfvars` file:

```bash
touch terraform.tfvars
```

Add this to your `terraform.tfvars` file (replace all the dummy data with your actual values)

```bash
vpc_cidr      = "10.0.0.0/16"
subnet_cidrs  = { public = "10.0.1.0/24" }
aws_region    = "eu-west-2"
ami_id        = "ami-xxxxxxxxxxxxxxxxx" # Dummy AMI ID
instance_type = "t2.micro"
key_name      = "your_key_name"

# S3 State Backend
s3_bucket_name = "your-state-bucket"
s3_bucket_key  = "your/path/to/terraform.tfstate"
s3_region      = "eu-west-2"
dynamodb_table = "your-lock-table"

# Ansible
ansible_inventory_path = "../ansible/inventory/hosts.ini"
terraform_log_path     = "/path/to/your/terraform-debug.log" # Could be anywhere, as this file will be created
ssh_private_key_path   = "/path/to/your/ssh/private/key" # Your .pem file
ansible_user           = "the-ec2-machine-user"
```

Apply Terraform Plan:

```bash
terraform apply
```

This will create the infrastructure, including the VPC, subnets, EC2 instances, and security groups, and will also update your Ansible hosts file with your EC2 IP address.

### Step 3: Configure EC2 with Ansible
Download your SSH key (the `.pem` file you created on AWS) to the project root folder and set the correct permissions:

```bash
cd ..
chmod 600 yourfile.pem
```

Now, create your own `pgadmin_servers.json`:

```bash
cd ansible
touch pgadmin_servers.json
```

Add this configuration to the file (make sure to replace the dummy data with your actual data):

```bash
{
    "Servers": {
      "1": {
        "Name": "PostgresDB",
        "Group": "Servers",
        "Host": "name-of-your-database",
        "Port": 5432,
        "Username": "your-postgres-username",
        "Password": "your-postgres-password",
        "SSLMode": "prefer",
        "MaintenanceDB": "postgres"
      }
    }
}
```
Update the file `ansible/roles/app_containers/tasks/main.yaml`, search for the keys below and add your actual secrets

```bash
      POSTGRES_USER: your-postgres-username
      POSTGRES_PASSWORD: your-postgres-password
      POSTGRES_DB: name-of-your-database

      PGADMIN_DEFAULT_EMAIL: any-email-you-want
      PGADMIN_DEFAULT_PASSWORD: any-password-you-want
```

Finally, run the Ansible Playbook:

```bash
ansible-playbook main_playbook.yaml
```

This will configure the EC2 instances by installing Docker, setting up networks, and deploying containers (PostgreSQL, Redis, pgAdmin, vote app, result app, worker app).

## Step 4: Access the Application
Once deployed, you can access the application by navigating to the following URLs (replace ec2-instance-ip-address with your actual EC2 instance IP):
- **Vote App**: [http://ec2-instance-ip-address:8080](http://ec2-instance-ip-address:8080)
- **Result App**: [http://ec2-instance-ip-address:8081](http://ec2-instance-ip-address:8081)
- **pgAdmin**: [http://ec2-instance-ip-address:5050](http://ec2-instance-ip-address:5050)