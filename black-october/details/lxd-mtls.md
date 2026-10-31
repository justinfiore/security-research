# LXD: client certificate chain authenticates as another trusted client

**Last updated:** 2026-10-31 (America/New_York)

[Main LXD summary](../black-october-2026.md#lxd-client-certificate-chain-authenticates-as-another-trusted-client) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-112816](https://www.cve.org/CVERecord?id=CVE-2026-112816) — Canonical (CNA) CVSS 4.0 10.0 Critical** (`AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`). Ubuntu's CVE page lists the same issue at priority Medium and does not publish a competing CVSS score. NVD has not scored it. CISA's enrichment records Exploitation "none" and Automatable "yes".

The LXD HTTPS API's mutual-TLS check compared every certificate in the client chain with the trust store. Only the leaf certificate proves the client holds the matching private key. An attacker who can reach the API, and who has another trusted client's **public** certificate, can present that certificate as an intermediate and authenticate as that client. Canonical says the result can be full access to the cluster and its virtual machines, and root on the host if the impersonated client had that privilege.

The same flaw affects MicroCloud, where an attacker can intercept a joining member's public TLS certificate and then authenticate as that member. MicroCloud's fixed snaps are 3.4.1 and 2.1.5. No separate CVE is assigned for MicroCloud in the sources read.

The CNA's affected ranges are LXD **4.0.14 before 4.0.15**, **5.0.10 before 5.0.11**, **5.21.8 before 5.21.9**, and **6.9.0 before 6.10.1**. The description text says "6.9 before 6.10.1". Builds outside those ranges are the CNA's default status, unaffected. The API has to be reachable by the attacker; a listener bound only to a trusted network is not the same as a fix.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31). Canonical does not report exploitation in the wild. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Report | Date not published | Canonical says the Incus project referred the issue and it was confirmed in LXD. Credit: Stéphane Graber. [Discourse][discourse] |
| Public advisory | 2026-10-28 17:50 UTC | Discourse post time. [Discourse][discourse] |
| Fixed snaps | 2026-10-29; time/TZ unknown | LXD 6.10.1, 5.21.9, 5.0.11, 4.0.15; MicroCloud 3.4.1 and 2.1.5. Point releases were still rolling from candidate to stable when the advisory was posted. [Discourse][discourse] |
| CVE record published | 2026-10-30 16:42:06 UTC | Canonical CNA, CVSS 4.0 10.0. [CVE][cve] |

## Detection

1. On each LXD host, `snap list lxd` (or the package version, if not a snap). Affected snaps are 4.0.14, 5.0.10, 5.21.8, and 6.9.x before 6.10.1. Fixed floors are 4.0.15, 5.0.11, 5.21.9, and 6.10.1.
2. For MicroCloud, `snap list microcloud`. Fixed floors are 3.4.1 on the 3/stable channel and 2.1.5 on the 2/stable channel.
3. The flaw is reachable only if the attacker can open the HTTPS API. Check which address the LXD listener is bound to. A public listener is exposed; a listener you cannot confirm is unknown, not safe.
4. Ubuntu's archive packages for this CVE are marked "not in release" or "not affected" on the releases Ubuntu lists. That does not clear a snap installed from the LXD channels above.

## Remediation

1. Refresh the snaps and restart so the new daemon is the one listening:

   ```sh
   sudo snap refresh lxd
   sudo snap refresh microcloud
   ```

   Confirm the running version is at or above the floor for that channel. Canonical warned that the point releases were still moving from candidate to stable; a refresh that does not change the version has not picked up the fix yet.
2. Until the fixed snap is running, do not expose the LXD or MicroCloud HTTPS API to untrusted networks. That is containment, not a patch. Canonical publishes no configuration workaround for the certificate comparison.
3. MicroCloud clusters need both products updated. Updating only LXD leaves the MicroCloud join path Canonical described.

## Verification

- `snap list lxd` and `snap list microcloud` show a fixed version, and `lxc cluster list` or an existing API client you already trust still connects.
- Do not send a crafted certificate chain to a production listener to test the bypass.

## Compromise response

If the HTTPS API was reachable on an affected version, preserve LXD's logs and the trust store before cleanup. Look for trusted clients you did not add, new instances, and changed cluster membership. Updating stops the chain comparison; it does not show whether a public client certificate was already replayed. Remove trust entries you cannot account for and rotate client certificates that may have been observed, including MicroCloud join certificates.

## Sources

- [Canonical Discourse advisory][discourse] — 2026-10-28 17:50 UTC: the mutual-TLS comparison, MicroCloud join interception, fixed snap versions, and the refresh commands.
- [CVE-2026-112816][cve] — Canonical CNA, published 2026-10-30 16:42:06 UTC, CVSS 4.0 10.0 Critical, affected ranges. CISA ADP Exploitation "none".
- [Ubuntu CVE page][ubuntu] — priority Medium; archive packages not in release or not affected. No second CVSS score.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.30).

[discourse]: https://discourse.ubuntu.com/t/security-advisory-critical-vulnerability-found-in-canonical-lxd-and-microcloud/90557
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-112816
[ubuntu]: https://ubuntu.com/security/CVE-2026-112816
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
