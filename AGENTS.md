# AGENTS.md

Guidance for AI coding agents working in this repository.

## Project

AWS IaC blueprint: portfolio/learning template with Terraform modules and
Terragrunt orchestration, fully validatable against LocalStack (no real AWS
account needed). All environments share the same configuration; only
`env.hcl` values differ.

## Layout

- `terraform/modules/`: reusable Terraform modules (no hardcoded values, no provider blocks)
- `terragrunt/_common/`: shared module orchestration logic
- `terragrunt/live/<env>/`: one `env.hcl` per environment (dev, staging, prod)
- `terragrunt/root.hcl`, `global.hcl`: provider, backend and version injection
- `localstack/docker-compose.yml`: local AWS emulation stack

## Commands

```bash
cp .env.example .env
docker-compose -f localstack/docker-compose.yml up -d   # start LocalStack
cd terragrunt/live/dev
terragrunt run-all plan
terragrunt run-all apply
terragrunt run-all destroy                              # clean up when done
```

## Rules for agents

- Never hardcode environment values in modules; everything flows from `env.hcl`
- No `terraform {}` or provider blocks inside modules; Terragrunt injects them
- Validate against LocalStack before any change targeting real AWS
- Do not commit `.env` or `.terraform/` directories
