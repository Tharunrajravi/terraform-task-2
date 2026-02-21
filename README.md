project: Multi-Region EC2 with Nginx using Terraform

infrastructure_managed_by_terraform:
  - Configured AWS providers for two regions (ap-south-1 and us-east-1).
  - Created Security Groups in both regions allowing HTTP (80) and SSH (22).
  - Retrieved latest Ubuntu AMIs dynamically using Terraform data sources.
  - Launched two EC2 instances (t3.micro) in different regions.
  - Installed and started Nginx automatically using Terraform user_data script.
  - Displayed public IP addresses using Terraform output variables.

verification:
  - Accessed Nginx web server using the public IP printed in terminal.
