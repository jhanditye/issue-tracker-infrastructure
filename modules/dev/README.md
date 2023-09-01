# Terraform Infrastructure Setup

This repository contains Terraform scripts to set up various AWS resources including an Application Load Balancer (ALB), EC2 Instances, RDS, Route53 DNS settings, and a VPC.

## Table of Contents

- [Application Load Balancer](#application-load-balancer)
- [EC2 Instances](#ec2-instances)
- [RDS Database](#rds-database)
- [Route53 DNS](#route53-dns)
- [VPC Configuration](#vpc-configuration)

---

### Application Load Balancer

The ALB is configured with the following settings:

- Source module: `terraform-aws-modules/alb/aws`
- Version: `8.7.0`
- Configured to listen on port 80 (HTTP).
- The target group is set to route traffic to instances on port `8080` with a health check on the root path.
- Security group configurations for inbound and outbound rules.

[Source Code: `alb.tf`](./alb.tf)

---

### EC2 Instances

The setup includes EC2 instances with:

- A security group allowing inbound traffic from the ALB.
- User data to start a simple HTTP server on port `8080`.
- Instance count can be varied using the `var.instance_count` variable.

[Source Code: `instance.tf`](./instance.tf)

---

### RDS Database

RDS configuration includes:

- PostgreSQL as the database engine.
- Configured security group to allow incoming connections from the EC2 instances.
- Various other RDS configurations such as maintenance windows, backup settings, and performance insights.

[Source Code: `rds.tf`](./rds.tf)

---

### Route53 DNS

Route53 configurations include:

- A new hosted zone with the domain `www.trackitall.org`.
- An A record pointing to the ALB.

[Source Code: (inline in the prompt)](./route53.tf)

---

### VPC Configuration

The VPC setup includes:

- Configuration for public, private, and database subnets.
- Enabled DNS hostnames and support.
- NAT gateway configuration.

[Source Code: `vpc.tf`](./vpc.tf)



**Note**: Make sure to have appropriate AWS credentials set up and ensure you are aware of the costs associated with provisioning these AWS resources before running Terraform commands.

