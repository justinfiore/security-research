# Amazon SSM Agent: Windows instances share one registration key

**Last updated:** 2026-11-24 (America/New_York)

[Main plugin summary](../black-october-2026.md#amazon-ssm-agent-windows-instances-share-one-registration-key) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-23 AWS published security bulletin 2026-197-AWS for [CVE-2026-134069](https://www.cve.org/CVERecord?id=CVE-2026-134069). Amazon is the CNA.

**Amazon rates it High, CVSS 3.1 7.3 and CVSS 4.0 8.2.** The CVSS 3.1 vector is `CVSS:3.1/AV:L/AC:L/PR:L/UI:N/S:C/C:H/I:L/A:N`. The CVSS 4.0 vector is `CVSS:4.0/AV:L/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:H/SI:L/SA:N`. AWS-provided Windows Server AMIs released before 2026-09-09 shipped Amazon SSM Agent with one instance registration key, and every instance launched from the same AMI kept that key. On an instance managed through Default Host Management Configuration, a local user who is not an administrator might obtain that instance's Default Host Management Configuration role credentials. AWS says those credentials allow limited Systems Manager actions by default. A person needs a local login on the instance. This is not a request from the internet.

**Amazon SSM Agent before 3.3.5226.0, on an AWS Windows Server AMI released before 2026-09-09, is affected.** The fix is in agent **3.3.5226.0**, which AWS says is in Windows Server AMIs released on or after 2026-09-09. An instance launched from an affected AMI keeps the shared key after an in-place agent upgrade, so the version number on a running instance does not show whether it is fixed. AWS says to replace the instance with one launched from an AMI released on or after 2026-09-09. Deleting the agent's Vault is not a fix, and AWS says it breaks an instance managed through Default Host Management Configuration. Until the instance is replaced, limit local access by users who are not administrators. AWS does not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-24). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Fixed AMIs | 2026-09-09; time/TZ unknown | AWS says Windows Server AMIs released on or after this date include agent 3.3.5226.0. [Bulletin][aws] |
| **Public announcement** | **2026-11-23 13:30 PST (UTC−08:00)** | Bulletin 2026-197-AWS. The CVE record was published the same day. [Bulletin][aws] |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Replace the instance. |

## Detection

1. List Windows EC2 instances and the AMI each one was launched from. An AWS-provided Windows Server AMI released before 2026-09-09 is the condition AWS names. An instance you built yourself, and a Linux instance, are outside it.
2. Read the installed Amazon SSM Agent version. A version below 3.3.5226.0 on one of those AMIs is inside the range. A version at or above 3.3.5226.0 does not clear an instance that was launched from an affected AMI: the upgrade leaves the shared key.
3. Note whether the instance is managed through Default Host Management Configuration. AWS says that is where a local user might obtain the role credentials.

Reading the AMI and the agent version changes no state. The agent version alone does not show whether the key is the shared one.

## Remediation

1. Replace an affected instance with one launched from an AWS Windows Server AMI released on or after 2026-09-09. Upgrading the agent in place does not replace the key.
2. Do not delete the agent's Vault. AWS says that is not a supported fix and that it breaks an instance managed through Default Host Management Configuration.
3. Until the instance is replaced, limit local access by users who are not administrators, on an instance that is managed through Default Host Management Configuration and was launched from an affected AMI.

## Verification

- The running instance was launched from an AWS Windows Server AMI released on or after 2026-09-09, or it was not launched from an AWS-provided Windows AMI.
- The installed agent is 3.3.5226.0 or later. That check is necessary and, on an instance launched earlier, not sufficient.

## Compromise response

A local user who was not an administrator may already have the instance's Default Host Management Configuration role credentials. Review Systems Manager activity for that instance, and for the role those credentials assume, starting before 2026-11-23. Replacing the instance does not show whether the credentials were used. AWS does not report exploitation.

## Sources

- [AWS security bulletin 2026-197-AWS][aws] — published 2026-11-23 13:30 PM PST. Affected: Amazon SSM Agent before 3.3.5226.0 on AWS Windows Server AMIs released before 2026-09-09. An in-place upgrade leaves the key. Replace the instance. Do not delete the Vault.
- [GHSA-rfpp-9v45-jjv4](https://github.com/aws/amazon-ssm-agent/security/advisories/GHSA-rfpp-9v45-jjv4) — published 2026-11-23. CVSS 3.1 7.3. The same affected range and the same remediation. Credits The YOSS Platform.
- [CVE-2026-134069](https://www.cve.org/CVERecord?id=CVE-2026-134069) — Amazon, published 2026-11-23. CVSS 3.1 7.3 and CVSS 4.0 8.2. CWE-1394.
- [CISA KEV JSON][kev] — catalog 2026.11.24, released 2026-11-24T17:47:46.199Z, checked 2026-11-24. Not listed.

[aws]: https://aws.amazon.com/security/security-bulletins/2026-197-aws/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
