## 📦 Sandbox

You're running in a smolbento microVM, working on a private clone of the repo.

* Only your commits come back to the host. Commit your work as you go; never push.
* There are no MCP servers here; use the CLI tools in the VM.
* Network access is deny-by-default with an allow list. If a fetch is blocked, say so
  rather than working around it (the host can check `sbt policy log`).
* Host tools such as `aws-sso-cli` and IntelliJ aren't available.
