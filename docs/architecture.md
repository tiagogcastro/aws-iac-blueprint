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

ecr       independent
```

`vpc`, `s3`, `ecr`, and `iam/eks` have no upstream dependency and can run in parallel. ECR remains independent until application publishing and deployment workflows consume its repository URL.

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

`iam/s3` owns the role and least-privilege policy for bucket and object operations. `iam/eks` owns the control-plane role, node role, AWS-managed attachments, and ECR pull policy required by workers.

There is no intermediate IAM composition module.

### ECR

- Repository name: `blueprint-dev-fileflow`.
- Immutable image tags.
- Scan requested after each push.
- AES256 encryption.
- Lifecycle policy retaining the latest 10 images in `dev`.
- `force_delete` enabled only through the environment value for disposable local development.

The repository was provisioned before the FileFlow application so build and deployment steps have a stable image destination.

### EKS

- Kubernetes `1.31`.
- Private VPC subnets.
- Public and private control-plane endpoint access in `dev`.
- Managed node group configured as `t3.medium`, on-demand, desired/minimum 1, maximum 2.

In AWS, a managed node group creates and maintains EC2 worker instances through managed scaling infrastructure. The EKS control plane is AWS-managed and does not appear as EC2 instances in the account. MiniStack represents the local cluster with one k3s Docker container instead of real EC2 instances.

## FileFlow application slice

The initial application is intentionally small enough to explain end to end:

```text
Browser
   ↓ HTTP
FileFlow Go application on EKS
   ├── visual web interface embedded in the Go binary
   ├── file API
   └── AWS SDK access to S3 through workload identity

CI build → ECR image → Kubernetes deployment
```

The implemented application in `applications/fileflow` uses only the Go standard library. One binary embeds the responsive interface and exposes health, upload, list, download, and delete endpoints. The storage interface currently has a filesystem adapter, keeping local execution immediate while establishing the boundary for the future S3 adapter.

One binary and one image match the current `blueprint-dev-fileflow` repository. This avoids creating frontend and backend repositories before the application needs separate release cycles. The frontend can become an independent application and image later without changing the infrastructure layering principles.

The local non-root container is implemented and tested. No ECR image, FileFlow Kubernetes workload, ingress, CI pipeline, or workload identity is provisioned yet. Those cloud-facing elements remain explicitly marked as planned in the target diagram.

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
