---
trigger: always_on
---
# 🌐 Home Ops

Source of truth for engineering practices, by area. **Keep it simple, easy to understand, and concise.**

## 🎯 Principles

* **KISS:** Avoid over-engineering. If a shell script works, don't build a microservice.
* **Cattle, not pets:** Environments are ephemeral. If it breaks, redeploy from code.
* **Secure by default:** Security is automated and baked in, not bolted on.

## 🔁 Flow & Improvement

* **Skills first:** At the start of each task, load the `using-superpowers` skill if it's available and not already in context.
* **Improvement kata:** For non-trivial changes, state current condition → target condition → next step → what we expect to see.
* **Blameless 5 whys:** Bugs and incidents get a root-cause pass and a fix to the system, not just the symptom.
* **YAGNI:** No speculative features, abstractions, or config for needs that don't exist yet.
* **Decide late:** Defer irreversible decisions; prefer choices that are cheap to change.
* **Build quality in:** Tests and automation ship with the change.
* **Simplify before done:** Before claiming a non-trivial change is complete, review your diff for anything to delete, flatten, or simplify without changing behavior (staying within your diff in client repos), then re-verify.
* **Finish before starting:** Limit work in progress; close the current task before opening new threads.
* **Small PRs:** One concern per PR, reviewable in minutes.
* **Trunk-based + flags:** Short-lived branches, merge often, ship incomplete work dark behind flags.
* **Fastest check first:** Run quick tests and lint before slow suites; keep CI around 10 minutes.
* **Deploy often:** Every merge can reach prod through an automated pipeline.

## 🏗 Infrastructure

* **Clouds:** AWS (AL2023), GCP. Authenticate via `aws-sso-cli`.
* **IaC:** Terraform; images built with Packer.
* **Hardening:** OpenSCAP baked into the AMI process.
* **Networking:** `nftables` for routing logic.

## 🚢 Platform

* **Kubernetes:** EKS, GKE; switch contexts with `kubie`.
* **CI/CD:** GitHub Actions.
* **Supply chain:** Scan everything with Trivy; sign images with Cosign.
* **Dependencies:** Renovate keeps the stack current; review its PRs for breaking changes only.
* **Agent packages (APM):** Keep global installs to daily drivers and add domain packs per project. Pin hook-heavy packages, and repair their hooks in `.apm/scripts/fix-apm-hooks.py` after each install.

## 🛠 Development

* **Languages:** Go, Node.js, Java, Rust.
* **Commits:** Conventional Commits, released with `release-please`.
* **Packaging:** `fpm`.
* **Spec over implementation:** When a published spec exists, conform to it rather than to a reference implementation's observed behaviour; record the differences.

## 📦 Product

* **Problem first:** State the user problem and what success looks like before proposing a solution.
* **Hypotheses, not facts:** Name the assumption behind a feature and how it gets validated.
* **Cheapest test first:** Validate with the lowest-cost experiment (mock, spike, manual process) before a full build.
* **Thin slices:** Ship the smallest useful vertical slice; avoid big-bang releases.
* **Buy before build:** Prefer managed services, SaaS, or existing OSS over custom code.
* **Measure it:** Each feature ships with how we'll know it worked.
* **Evidence over opinion:** Prefer user data, interviews, and usage signals.
* **Pivot or persevere:** After a slice ships and is measured, decide: continue, change course, or kill.
* **ADRs for one-way doors:** Write a short decision record for hard-to-reverse choices.
* **Docs are part of done:** README/runbook updated in the same change.
* **Plain-language updates:** Stakeholder writing leads with impact and skips jargon.

## 🧭 Repo Modes

Repo mode decides how strictly the practices above apply.

* **Owned repos** (`pelotech`, `josmo` orgs, excluding forks of others' projects): Improve as you go — fix stale patterns, upgrade, refactor toward these practices, and say what changed.
* **Everything else** (client, forked, and unknown repos): Match the repo's existing patterns; consistency first. Suggest improvements, don't make them unasked.

## ♻️ Keep This Current

* When you notice a stale rule, a gap, or a practice we keep repeating, end your reply with a **proposed** edit to the relevant section of this file, `host.md`, or the private notes. Don't edit these files unless the user asks or approves.

## 🌊 Personal

* **Style:** Modern Monochrome.
