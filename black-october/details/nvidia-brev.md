# NVIDIA Brev: customer information may have been affected

**Last updated:** 2026-11-01 (America/New_York)

[Back to NVIDIA Brev summary](../black-october-2026.md#nvidia-brev-customer-information-may-have-been-affected) · [Changelog](../../CHANGELOG.md)

NVIDIA is emailing Brev customers that it identified unauthorized activity on the Brev platform from October 4 through October 20, 2026, and that the recipient's information from the Brev network may have been affected. **This is a platform-side incident, not a vulnerability in software a customer installs.** There is no CVE and no CVSS score. NVIDIA has not published the notice on nvidia.com. The text below is from a screenshot [Kevin Beaumont posted][kb] on October 30; the image cuts off before the list of information involved.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. This is a platform-side incident; the customer email is the notice. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are UTC. The activity window is the range named in the email, not a proof of when access started or ended.

| Date | Event and evidence |
| --- | --- |
| 2026-10-04 through 2026-10-20 | The email: "Our incident investigation identified unauthorized activity affecting the NVIDIA Brev platform from October 4 through October 20, 2026." [Beaumont screenshot][kb] |
| 2026-10-30 20:08 | Kevin Beaumont posts a screenshot of the customer email: "Nvidia is notifying developers who use Brev.dev AI platform that it has been breached." [Beaumont][kb] |
| Customer software patch | Not applicable. There is no Brev package to upgrade for this incident. |

**Evidence limits:** The screenshot ends at "Our analysis determined that the following information was potentially". It does not show which fields NVIDIA named, what NVIDIA says it already rotated, or what it tells the recipient to do. Reports that the email names SSH keys provisioned for VMs are secondhand and are not visible in the posted image, so this guide does not treat them as established. NVIDIA has published no public advisory. Wiz's October 30 roundup of nine AI developer platforms does not include Brev, and nothing reviewed here ties this notice to that campaign.

## Detection

1. If you received the email, keep it. The posted screenshot does not include the section that names the information involved, and that section is the part that says what to look for.
2. List Brev instances, organizations, and SSH keys from a trusted session (`brev list`, `brev ssh-key`). Do not print private key material. The local key Brev manages is `~/.brev/brev.pem`; that path is Brev's own documentation, not a claim that the email names this file.
3. Review instance access and workload logs for October 4 through October 20, and after, for logins you do not recognize. Absence of a suspicious login does not prove the key or other data was not copied.
4. There is no local package version that answers this. The notice is about NVIDIA's platform.

## Remediation

1. Read the full email you received, including the cut-off section of the public screenshot, and follow the actions NVIDIA lists there. This guide cannot repeat instructions that are not in the posted image.
2. Until that list is known, treat credentials Brev held or provisioned for your VMs as in scope: replace the SSH key pair Brev uses for those instances, update `~/.brev/brev.pem` from a fresh login (`brev refresh` after `brev login`), and remove the old public key from instance `authorized_keys`. Also revoke Brev API keys that existed during the window and issue new ones.
3. Do not assume a key NVIDIA may already have rotated is the only secret. The email says "your information from our Brev network may have been affected" and the screenshot does not enumerate it.
4. Wiz's nine-platform list is a separate article. Rotating Northflank or Railway secrets does not cover a Brev VM.

## Verification

- Confirm the old public key no longer authenticates to the instance, and that a new key does.
- Confirm replaced API keys fail and the new key works, without printing either value.
- A successful `brev shell` only shows that some key still works. It does not show that the key from the incident window was retired.

## Compromise response

- **VM access:** If an SSH private key Brev provisioned was copied, anyone holding it can log in as that key allows until the public key is removed. Replacing the local file without removing the old public key leaves the old key valid.
- **Other data:** The email says personal information may be affected and offers resources "to help protect your personal information from possible misuse." The posted image does not show which fields or which resources. Use the copy NVIDIA sent you.
- NVIDIA has not said the attacker is gone, how access was gained, or how many customers were notified. A key replaced while that is unknown may itself need another replacement if NVIDIA later says exposure continued.

## Sources

- [Kevin Beaumont, October 30, 2026: screenshot of the NVIDIA customer email](https://cyberplace.social/@GossiTheDog/117532608839043336)

[kb]: https://cyberplace.social/@GossiTheDog/117532608839043336
