## **NewBank Digital Banking Platform**

A high-performance, secure digital banking platform built with a Modular Monolith architecture on AWS. This repository contains infrastructure as code (Terraform), and background workers for the NewBank platform. 

## **📑 Table of Contents**

* Architecture Overview
* Tech Stack
* Infrastructure & Security
* Getting Started
* Monitoring & Observability
* Deployment Strategy

## **🏗 Architecture Overview**

NewBank uses a Modular Monolith approach to balance rapid development with strict domain boundaries. The system is logically divided into specialized modules:
* Identity & Auth: User onboarding and KYC verification.
* Accounts: Balance management and legacy core integration.
* Payments: Transfers and bill payment logic.
* Notifications: Asynchronous alert delivery via SQS/Lambda.
* Audit: High-volume compliance logging.

## **System Diagram / Architecture Diagram**

See the systems/ folder for detailed communication flows, interaction justifications and Overview. 

## **🔒 Infrastructure & Security**

The infrastructure follows the AWS Well-Architected Framework: 
* Network Isolation: All app and data resources are in private subnets.
* Secrets Management: Database credentials and API keys are stored in AWS Secrets Manager.
* IAM Policies: Services use the Principle of Least Privilege. For example, the Notification Worker only has permissions to read and delete from the specific SQS queue. 

## **🚀 Getting Started**

Prerequisites
* Terraform v1.5+
* AWS CLI configured with proper credentials

**Setup**
**Initialize Infrastructure:**
**bash**

* terraform init
* terraform apply

## **📊 Monitoring & Observability**
**To maintain our 99.9% uptime requirement, we use:**

* Amazon CloudWatch: For real-time metrics and alarm triggers.
* AWS X-Ray: For tracing requests across module boundaries.
* Dead Letter Queues (DLQ): To capture and re-process failed notification attempts. 


## **🚢 Deployment Strategy**

Updates are deployed monthly using a Blue/Green strategy to ensure zero downtime.
* CI/CD: GitHub Actions builds the Docker image, pushes to ECR, and updates the ECS Service.
* Versioning: All modules are versioned within the single repository for consistency. 




**Author**: Kadiri George 
**Version**: 1.0.0  
**Last Updated**: April 2026