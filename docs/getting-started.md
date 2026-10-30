# Getting started

This guide covers the complete local cycle: start MiniStack, validate the nine Terragrunt units, apply them, deploy FileFlow, inspect AWS and Kubernetes, and clean up.

## Prerequisites

| Tool | Minimum | Purpose |
|---|---:|---|
| Terraform | 1.5 | Provisions the reusable modules |
| Terragrunt | 0.50 | Orchestrates units and environments |
| Docker | Current | Runs MiniStack and the local k3s cluster |
| AWS CLI | Current | Inspects the emulated AWS APIs |
| Git | Any | Required by `get_repo_root()` |

`kubectl` does not need to be installed on the host. The k3s container already includes it.

## Configure the local environment

```bash
cp .env.example .env
source .env
```

The local values are:

```text
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=us-east-1
AWS_ENDPOINT_URL=http://localhost:4566
```

## Start MiniStack

```bash
docker compose -f ministack/docker-compose.yml pull
docker compose -f ministack/docker-compose.yml up -d
docker compose -f ministack/docker-compose.yml ps
curl --fail http://localhost:4566/_ministack/health
```

MiniStack needs access to `/var/run/docker.sock` to create the k3s container used by local EKS. Only use this setup in a trusted development environment.

## Format and validate

```bash
terraform fmt -recursive terraform
terragrunt hcl format --working-dir terragrunt

terragrunt --non-interactive \
  --working-dir terragrunt/live/dev \
  run --all -- validate
```

Terragrunt should discover nine units:

```text
vpc  s3  dynamodb  sqs  iam/s3  iam/eks  iam/fileflow  ecr  eks
```

## Plan and apply

```bash
terragrunt --working-dir terragrunt/live/dev run --all -- plan
terragrunt --working-dir terragrunt/live/dev run --all -- apply
```

The graph applies independent units in parallel and waits for declared dependencies automatically.

## Inspect Terragrunt outputs

```bash
terragrunt --working-dir terragrunt/live/dev/vpc output
terragrunt --working-dir terragrunt/live/dev/s3 output
terragrunt --working-dir terragrunt/live/dev/iam/s3 output
terragrunt --working-dir terragrunt/live/dev/iam/eks output
terragrunt --working-dir terragrunt/live/dev/ecr output
terragrunt --working-dir terragrunt/live/dev/eks output
terragrunt --working-dir terragrunt/live/dev/dynamodb output
terragrunt --working-dir terragrunt/live/dev/sqs output
terragrunt --working-dir terragrunt/live/dev/iam/fileflow output
```

## Inspect AWS APIs

### Network and storage

```bash
aws ec2 describe-vpcs --query 'Vpcs[].{ID:VpcId,CIDR:CidrBlock}'
aws ec2 describe-subnets --query 'Subnets[].{ID:SubnetId,CIDR:CidrBlock,AZ:AvailabilityZone}'
aws s3 ls
aws s3api get-bucket-versioning --bucket blueprint-dev-raw
```

### IAM

```bash
aws iam list-roles --query 'Roles[?contains(RoleName, `blueprint-dev`)].RoleName'
aws iam list-attached-role-policies --role-name blueprint-dev-eks-node-role
aws iam get-role --role-name blueprint-dev-fileflow-api-role
aws iam get-role --role-name blueprint-dev-fileflow-worker-role
```

### ECR

```bash
aws ecr describe-repositories \
  --repository-names blueprint-dev-fileflow \
  --query 'repositories[0].{Name:repositoryName,URI:repositoryUri,Tags:imageTagMutability,Scan:imageScanningConfiguration.scanOnPush,Encryption:encryptionConfiguration.encryptionType}'
```

```bash
aws ecr get-lifecycle-policy \
  --repository-name blueprint-dev-fileflow
```

Build and publish an immutable local image:

```bash
applications/fileflow/scripts/publish-local.sh
```

### EKS

```bash
aws eks describe-cluster \
  --name blueprint-dev \
  --query 'cluster.{Name:name,Status:status,Version:version,Endpoint:endpoint,Subnets:resourcesVpcConfig.subnetIds}'
```

```bash
aws eks describe-nodegroup \
  --cluster-name blueprint-dev \
  --nodegroup-name blueprint-dev-nodes \
  --query 'nodegroup.{Name:nodegroupName,Status:status,Capacity:capacityType,Instances:instanceTypes,Scaling:scalingConfig}'
```

## Inspect Kubernetes

Find the local EKS container:

```bash
docker ps --filter name=ministack-eks --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}'
```

Use its bundled `kubectl`:

```bash
docker exec ministack-eks-000000000000-us-east-1-blueprint-dev kubectl cluster-info
docker exec ministack-eks-000000000000-us-east-1-blueprint-dev kubectl get nodes -o wide
docker exec ministack-eks-000000000000-us-east-1-blueprint-dev kubectl get pods --all-namespaces -o wide
docker exec ministack-eks-000000000000-us-east-1-blueprint-dev kubectl get namespaces
```

In MiniStack, Kubernetes runs in a k3s Docker container. In AWS, the configured managed node group would run worker nodes as EC2 instances.

Deploy and inspect FileFlow:

```bash
applications/fileflow/scripts/deploy-local.sh

docker exec ministack-eks-000000000000-us-east-1-blueprint-dev \
  kubectl get pods,deploy,svc,sa -n fileflow -o wide
```

Use the NodePort URL printed by the script to open the interface or call `/healthz` and `/api/files`.

## Confirm idempotency

```bash
terragrunt --non-interactive \
  --working-dir terragrunt/live/dev \
  run --all -- plan -detailed-exitcode
```

Every unit should report `No changes`.

## Clean up

```bash
terragrunt --working-dir terragrunt/live/dev run --all -- destroy
docker compose -f ministack/docker-compose.yml down
```

To target a real AWS account, unset `AWS_ENDPOINT_URL`, configure AWS credentials normally, review all environment values, and replace the local backend before collaborating with a team.
