# Standard Upbound Security Policy

This is the Standard Upbound Security Policy for all repositories. Security is a priority, and we are committed to ensuring that the content within our repositories maintains compliance and upholds the best security posture.

## **Orca Security Integration**

Our repositories use the Orca Security tool to identify vulnerabilities and compliance issues in the code and content within our repositories. This includes recognizing risks such as:

- Secret Detection
  - Scanning a pull request for exposed or plain-text secrets.
- Infrastructure-as-code (IaC) Security
  - When scanning infrastructure-as-code (IaC) files, Orca Security analyzes configuration files (such as Terraform, CloudFormation, or Kubernetes manifests) to detect misconfigurations, insecure settings, and policy violations that could introduce security risks.
- Vulnerability Scanning (SCA)
  - During a pull request, Orca Security's Software Composition Analysis (SCA) scanner examines dependencies for known vulnerabilities, outdated packages, and license compliance issues to help ensure the security of the codebase.
- Static Application Security Testing (SAST)
  - Orca Security's SAST scanner analyzes source code for security vulnerabilities, such as injection flaws or insecure coding patterns, before the code is merged.

### **Current Workflow**

- **Automated Security Scans:**  
  Every pull request (PR) triggers Orca Security's GitHub App, a CI/CD integration, which automatically scans the codebase within the pull request for vulnerabilities, secrets, and misconfigurations.

- **GitHub Bot Integration:**  
  The Orca Security GitHub bot posts scan results directly on the PR, highlighting any detected issues and providing remediation guidance. The Orca Security bot also reports these findings to the Orca Security SaaS portal so that security engineers can manage findings and bot behavior.

- **Blocking PRs with Critical Vulnerabilities:**  
  If critical vulnerabilities or exposed secrets are discovered, the Orca Security GitHub bot may block the PR from being merged until the issues are resolved.

- **Developer Remediation:**  
  Developers are expected to address critical issues issues before merging. The bot provides actionable feedback to help resolve findings efficiently.

- **Continuous Monitoring:**  
  All repositories are continuously monitored for new vulnerabilities, ensuring ongoing compliance and security posture. These vulnerabilities are collected into CAS Packs for further review and remediation.

## What to Do If a Vulnerability Is Discovered

If a security vulnerability is discovered, it is important to follow the correct process to ensure the safety and integrity of our codebase. Please review the following scenarios and actions:

- **If a critical security vulnerability is found within a pull request (PR):**

  - The engineer who opened the PR is responsible for fixing the vulnerability.
  - The PR cannot be merged into the _default_ branch until the issue is fully remediated.
  - The Orca Security GitHub bot will automatically block the merge if a critical vulnerability is detected.
  - The bot will provide details and guidance to help resolve the issue.
  - Once the vulnerability is fixed, the PR can proceed through the normal review and merge process.

- **If a vulnerability is discovered outside of a pull request:**
  - This could include vulnerabilities found directly in the codebase, in application behavior, or in infrastructure.
  - Any engineer who discovers such a vulnerability should immediately submit a "CAS Request" in the [#security-help](https://simple-it.slack.com/archives/C04LK3WAMD1) channel on Slack.
  - Submitting a CAS Request ensures that the Cyber Security team is notified and can quickly assess and coordinate a response.
  - Provide as much detail as possible in your request to help the team understand and prioritize the issue.

## Questions, Problems or Suggestions?

We’re always looking for ways to improve and help!

If you run into an unexpected error, or have questions or ideas about enhancing our security posture, please reach out in the [#security-help](https://simple-it.slack.com/archives/C04LK3WAMD1) Slack channel and submit a **CAS Request**, and we'll do our best to help you out.

Version 2, August 14th, 2025
