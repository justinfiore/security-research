# IBM API Connect: unauthenticated command execution and administrative control

**Last updated:** 2026-11-07 (America/New_York)

[Main IBM API Connect summary](../black-october-2026.md#ibm-api-connect-unauthenticated-command-execution-and-administrative-control) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**IBM rates [CVE-2026-17408](https://www.cve.org/CVERecord?id=CVE-2026-17408) CVSS 3.1 9.8 Critical.** NVD has not scored it. IBM says a remote attacker can run arbitrary code because special elements in an OS command are not neutralized. The description does not say a login is required. The same bulletins rate [CVE-2026-17301](https://www.cve.org/CVERecord?id=CVE-2026-17301) 9.8 and say an unauthenticated attacker can bypass authentication because a cryptographic signature is not verified, and [CVE-2026-16720](https://www.cve.org/CVERecord?id=CVE-2026-16720) 9.8 and say a remote attacker can obtain valid access tokens for other users because authentication against a connected directory service is not sufficiently enforced.

The on-premises ranges are API Connect V12 **v12.1.0.0 through v12.1.1.2**, fixed in **v12.1.1.3**, and API Connect **V10.0.8.0 through V10.0.8.12**, fixed in **10.0.8.13**. IBM lists no workaround. The two bulletins were first published 2026-11-05. The CVE records were published 2026-11-07. IBM does not report exploitation.

The V12 bulletin lists 203 CVEs and the V10 bulletin lists 135. IBM scores 46 of the V12 entries and 25 of the V10 entries at 9.0 or higher. Several of the highest unauthenticated scores are on V12 only: [CVE-2026-17360](https://www.cve.org/CVERecord?id=CVE-2026-17360) and [CVE-2026-17340](https://www.cve.org/CVERecord?id=CVE-2026-17340) are both 9.8 (hard-coded credentials to full administrative control, and code execution through path traversal), [CVE-2026-17313](https://www.cve.org/CVERecord?id=CVE-2026-17313) is 9.8 (authentication bypass to gateway configuration), [CVE-2026-17362](https://www.cve.org/CVERecord?id=CVE-2026-17362) is 9.8 (create, modify, or delete tenants), [CVE-2026-16884](https://www.cve.org/CVERecord?id=CVE-2026-16884) is 9.9 (XXE), and [CVE-2026-17331](https://www.cve.org/CVERecord?id=CVE-2026-17331) is 7.5 (read arbitrary files). [CVE-2026-17386](https://www.cve.org/CVERecord?id=CVE-2026-17386), 8.1, is on the V10 bulletin only: a weak random-number generator leading to full administrative control. [CVE-2026-17403](https://www.cve.org/CVERecord?id=CVE-2026-17403), 9.0, is hard-coded credentials on both lines. This guide does not restate every authenticated flaw. The bulletins are the list.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07) for the CVEs named above. IBM does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-05; time/TZ unknown** | Both IBM bulletins. Change history: "05 Nov 2026: Initial Publication." Modified date 05 November 2026. [V12][v12] [V10][v10] |
| CVE records | 2026-11-07 04:32 UTC | IBM CNA. [CVE-2026-17150][cve17150] is one of the records published that morning. |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-07) | [KEV][kev] |

## Detection

This only reads.

On an on-premises manager, the installed version is on the About page of the API Manager, or in the output of the product's version command on the management VM. Compare it with the floors in Remediation.

- V12 from v12.1.0.0 through v12.1.1.2 is inside the V12 bulletin.
- V10 from 10.0.8.0 through 10.0.8.12 is inside the V10 bulletin.
- A version IBM does not list, including a release older than 10.0.8.0, is not cleared by these bulletins. IBM's own disclaimer says an unsupported version omitted from a bulletin is not a finding that the version is unaffected.

IBM API Connect as a managed IBM Cloud service is not a version you upgrade from these bulletins. The affected-product tables name the on-premises releases only.

Do not send a crafted command or a forged signature to check.

## Remediation

1. **API Connect V12 on-premises:** upgrade to **v12.1.1.3 or later**. Fix Central is [node 7290205](https://www.ibm.com/support/pages/node/7290205).
2. **API Connect V10:** upgrade to **10.0.8.13 or later**. IBM's Fix Central link for that line starts from release 10.0.8.12.
3. IBM lists **no workaround**. Keeping the management interface off the internet reduces who can reach it. It does not fix the product.
4. The upgrade does not show whether a command already ran, whether a token for another user was issued, or whether a tenant was created or deleted.

## Verification

- The API Manager About page, or the version command on the management VM, prints v12.1.1.3 or later, or 10.0.8.13 or later.
- A client you already use can still call an API it was allowed to call. Do not send an OS metacharacter or a truncated signature.

## Compromise response

IBM does not publish an indicator. If the management or gateway interfaces were reachable from an untrusted network while the version was inside either range, treat administrative control and command execution as possible.

- Preserve the management and gateway logs from before the upgrade.
- Review new tenants, new users, changed gateway configuration, and files written by the API Connect OS user.
- If you find evidence a command ran or a token for another user was issued, rotate credentials the process could read and rebuild the host. The upgrade does not remove that.

## Sources

- [IBM bulletin 7295635][v12] — V12, published 2026-11-05. Affected v12.1.0.0 through v12.1.1.2. Fix v12.1.1.3. No workaround. 203 CVEs, including the unauthenticated 9.8 scores named above.
- [IBM bulletin 7295637][v10] — V10, published 2026-11-05. Affected 10.0.8.0 through 10.0.8.12. Fix 10.0.8.13. No workaround. 135 CVEs, including CVE-2026-17386.
- [CVE-2026-17408][cve17408] — IBM CNA, published 2026-11-07. CVSS 3.1 9.8. Remote code execution through an OS command.
- [CVE-2026-17301][cve17301] — IBM CNA. CVSS 3.1 9.8. Unauthenticated authentication bypass.
- [CVE-2026-16720][cve16720] — IBM CNA. CVSS 3.1 9.8. Access tokens for other users.
- [CISA KEV][kev] — catalog 2026.11.06. None of the named CVEs is listed.

[v12]: https://www.ibm.com/support/pages/node/7295635
[v10]: https://www.ibm.com/support/pages/node/7295637
[cve17408]: https://www.cve.org/CVERecord?id=CVE-2026-17408
[cve17301]: https://www.cve.org/CVERecord?id=CVE-2026-17301
[cve16720]: https://www.cve.org/CVERecord?id=CVE-2026-16720
[cve17150]: https://www.cve.org/CVERecord?id=CVE-2026-17150
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
