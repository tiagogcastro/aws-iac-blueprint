# Architecture

## Design goals

The repository is intentionally structured to demonstrate four ideas:

1. Terraform modules should be reusable and independent of environments.
2. Terragrunt should own orchestration, dependency wiring, and environment values.
3. IAM should be organized by the service that consumes each permission set.
4. Local validation should exercise real provider APIs and a real Kubernetes API before using a paid AWS account.

## Configuration layers

```text
terragrunt/global.hcl
└── project-wide identity: project name and owner

terragrunt/live/<env>/env.hcl
└── values that vary by environment or client

terragrunt/_common/<unit>/terragrunt.hcl
└── Terraform source, input mapping, and dependencies

terraform/modules/<unit>
└── reusable resource implementation and outputs
```

Terraform modules do not declare providers or backends. `terragrunt/root.hcl` generates the provider, version constraints, default tags, and backend for every unit.

## Dependency graph

```text
vpc ────────────────┐
                    ├──→ eks
iam/eks ────────────┘

s3 ───────────────────→ iam/s3

s3 ──────────────┐
dynamodb ────────┼──→ iam/fileflow
sqs ─────────────┤
eks (OIDC) ──────┘

ecr       image publishing target
```

`vpc`, `s3`, `dynamodb`, `sqs`, `ecr`, and `iam/eks` can start independently. `iam/fileflow` waits for the workload resources and the EKS OIDC issuer before creating API and worker identities.

## Terraform units

### VPC

- DNS support and hostnames enabled.
- Public and private subnet tiers across two availability zones.
- Internet Gateway and public default route.
- Private route table with no internet route.

### S3

- Versioning controlled by the environment.
- AES256 server-side encryption.
- Complete public-access block.
- Data-layer classification tag.

S3 does not have a configured disk size. Capacity grows with stored objects; lifecycle, retention, replication, and storage classes control behavior and cost.

### IAM

`iam/s3` owns the general bucket role. `iam/eks` owns the control-plane role, node role, AWS-managed attachments, and ECR pull policy. `iam/fileflow` creates separate workload roles: the API can manage objects, metadata, history, and publish jobs; the worker can read objects, update processing state, and consume jobs.

There is no intermediate IAM composition module.

### ECR

- Repository name: `blueprint-dev-fileflow`.
- Immutable image tags.
- Scan requested after each push.
- AES256 encryption.
- Lifecycle policy retaining the latest 10 images in `dev`.
- `force_delete` enabled only through the environment value for disposable local development.

The repository was provisioned before the FileFlow application so build and deployment steps have a stable image destination.

### DynamoDB and SQS

- The files table stores metadata, status, category, checksum, and owner-based ordering.
- The events table stores immutable processing history per file.
- The processing queue retries failed work three times before redriving to the DLQ.
- The worker deletes an SQS message only after processing succeeds.

### EKS

- Kubernetes `1.31`.
- Private VPC subnets.
- Public and private control-plane endpoint access in `dev`.
- Managed node group configured as `t3.medium`, on-demand, desired/minimum 1, maximum 2.

In AWS, a managed node group creates and maintains EC2 worker instances through managed scaling infrastructure. The EKS control plane is AWS-managed and does not appear as EC2 instances in the account. MiniStack represents the local cluster with one k3s Docker container instead of real EC2 instances.

## FileFlow application slice

The initial application is intentionally small enough to explain end to end:

```text
Browser → NodePort → Go API (2 replicas)
                         ├── S3 file bytes
                         ├── DynamoDB metadata + history
                         └── SQS processing job
                                  ↓
                           Go worker (independent deployment)
                                  ├── reads S3 object
                                  └── writes SHA-256 + status + events

Docker build → immutable ECR image
```

The application uses the AWS SDK for Go v2 behind small domain interfaces. `files.Service` coordinates the use cases without importing AWS packages; S3, DynamoDB, and SQS adapters implement its ports. One binary embeds the temporary interface and starts as either `fileflow api` or `fileflow worker`.

One binary and one image match the current `blueprint-dev-fileflow` repository. This avoids creating frontend and backend repositories before the application needs separate release cycles. The frontend can become an independent application and image later without changing the infrastructure layering principles.

The non-root image, local ECR publication, Kubernetes deployments, probes, resources, NodePort, and separate Service Account role annotations are implemented and tested. Local pods use fake credentials because MiniStack ignores IAM credentials; AWS should use IRSA without those local credential variables. Ingress, authentication, autoscaling, CI/CD, and the React interface remain future work.

## Environment values

`terragrunt/live/dev/env.hcl` is the single place for choices that can vary by environment:

```hcl
vpc_cidr = "10.0.0.0/16"

ecr_image_tag_mutability = "IMMUTABLE"
ecr_max_image_count      = 10

eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 1
eks_node_min_size       = 1
eks_node_max_size       = 2
```

A production environment can use different CIDRs, stricter endpoint access, larger instances, a larger scaling range, longer image retention, and `force_delete = false` without changing a Terraform module.

## Tags

Provider default tags apply `Project`, `Environment`, `Owner`, and `ManagedBy` to supported resources. Environment-specific tags such as `CostCenter` flow through `resource_tags`, while each resource defines its own `Name` tag.

## Local and real AWS

When `AWS_ENDPOINT_URL=http://localhost:4566`, the generated AWS provider routes S3, IAM, EC2, ECR, EKS, and STS to MiniStack. Without that variable, the provider uses normal AWS endpoints.

The local environment currently uses a local Terraform backend per Terragrunt unit. A shared AWS deployment should add remote state, locking, stricter deletion controls, private connectivity, secrets management, observability, and cost controls before production use.
