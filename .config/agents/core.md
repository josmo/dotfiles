---
trigger: always_on
---
# 🌐 Home Ops

Source of truth for environment standards and engineering philosophy. **Keep it simple, easy to understand, and concise.**

## 🛠 Tech Stack

* **Infrastructure:** AWS (AL2023, EKS), GCP (GKE).
* **Languages:** Go, Node.js, Deno, Java, Rust.
* **IaC & Automation:** Terraform, Packer, GitHub Actions.
* **CLIs:** `aws-sso-cli`, `kubeswitch`, `fpm`.
* **Maintenance:** Renovate (dependency updates).

## 🎯 Engineering Principles

1. **KISS (Keep It Simple, Stupid):** Avoid over-engineering. If a shell script works, don't build a microservice.
2. **Automated Security:**
   * Scan everything with Trivy.
   * Hardening (OpenSCAP) is baked into the AMI process.
   * Sign images with Cosign.
3. **Ephemeral Environments:** Cattle, not pets. If it breaks, redeploy from code.
4. **Commits:** Always use conventional commits.

## 🚀 Workflow Standards

* **Networking:** Use `nftables` for modern routing logic.
* **Version Control:** Conventional Commits + `release-please`.
* **Dependencies:** Trust Renovate to keep the stack current; review PRs for breaking changes only.

## 🌊 Personal

* **Style:** Modern Monochrome.
