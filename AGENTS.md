# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project

AWS IaC blueprint: portfolio/learning template with Terraform modules and
Terragrunt orchestration, fully validatable against MiniStack (no real AWS
account needed). Modules and orchestration are shared; environment-specific
values live in each environment's `env.hcl`.

## Layout

- `terraform/modules/`: reusable Terraform modules (no hardcoded values, no provider blocks)
- `terragrunt/_common/`: shared module orchestration logic
- `terragrunt/live/<env>/`: one `env.hcl` per environment (dev, staging, prod)
- `terragrunt/root.hcl`, `global.hcl`: provider, backend and version injection
- `ministack/docker-compose.yml`: local AWS emulator with EKS backed by k3s

## Commands

```bash
cp .env.example .env
source .env
docker compose -f ministack/docker-compose.yml up -d
terragrunt --non-interactive --working-dir terragrunt/live/dev run --all -- validate
terragrunt --non-interactive --working-dir terragrunt/live/dev run --all -- plan
terragrunt --non-interactive --working-dir terragrunt/live/dev run --all -- apply -auto-approve
terragrunt --non-interactive --working-dir terragrunt/live/dev run --all -- destroy -auto-approve
```

## Rules for agents

- Never hardcode values that vary by environment in modules; flow them from `env.hcl`
- No `terraform {}` or provider blocks inside modules; Terragrunt injects them
- Validate against MiniStack before any change targeting real AWS
- Do not commit `.env` or `.terraform/` directories
- Do not install host tools such as `kubectl` without explicit approval
