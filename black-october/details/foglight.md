# Quest Foglight: unauthenticated remote code execution

**Last updated:** 2026-11-04 (America/New_York)

[Back to Foglight summary](../black-october-2026.md#quest-foglight-unauthenticated-remote-code-execution) · [Changelog](../../CHANGELOG.md)

**ZDI rates three flaws CVSS 3.0 9.8 Critical, all fixed in Foglight 8.3.** [CVE-2026-92190](https://www.cve.org/CVERecord?id=CVE-2026-92190) deserializes untrusted data in the `baseRmiServiceExporter` bean. [CVE-2026-92189](https://www.cve.org/CVERecord?id=CVE-2026-92189) uses a caller-supplied path in `writeTopologySectionToFile`. [CVE-2026-92188](https://www.cve.org/CVERecord?id=CVE-2026-92188) reaches `ForgeMBeanServerSupport` with no authentication. None of the three needs a login. ZDI says each runs as SYSTEM. The CVE records name Foglight for Databases 8.2.0. ZDI's own line is "Fixed in Foglight 8.3" and does not print an affected range. NVD has not scored them. ZDI published the advisories on November 3, 2026. [ZDI-26-851][z851]

Thirteen more ZDI advisories the same day cover the same product and the same fix. Eight are 8.8 High and need a login. Two are local privilege escalation, 7.8, and need code already running on the host. Two are unauthenticated information disclosure, 7.2 and 8.2. One authenticated information disclosure is 6.5. The table is below.

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04) for any of these CVEs. ZDI does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Reported to Quest | 2026-04-30 and later; times unknown | ZDI-26-851 says reported 2026-04-30. Other advisories in the set have their own report dates. |
| Coordinated publication | 2026-11-03; time/TZ unknown | Sixteen ZDI advisories, ZDI-26-851 through ZDI-26-866. Each says "Advisory Updated" the same day. |
| **Last updated** | **2026-11-04 (America/New_York)** | New item. |

## Detection

ZDI's fixed line is Foglight **8.3**. The CVE records name Foglight for Databases **8.2.0** and do not say whether 8.1 and earlier are affected. Treat a Foglight for Databases install below 8.3 as in need of the upgrade, and confirm an older major version with Quest rather than assuming the record's single version is the whole range.

The three that need no login:

| CVE | ZDI | Score | What it is |
|---|---|---|---|
| [CVE-2026-92190](https://www.cve.org/CVERecord?id=CVE-2026-92190) | [ZDI-26-851][z851] | 9.8 | `baseRmiServiceExporter` deserializes untrusted data |
| [CVE-2026-92188](https://www.cve.org/CVERecord?id=CVE-2026-92188) | [ZDI-26-854][z854] | 9.8 | `ForgeMBeanServerSupport` has no authentication |
| [CVE-2026-92189](https://www.cve.org/CVERecord?id=CVE-2026-92189) | [ZDI-26-861][z861] | 9.8 | `writeTopologySectionToFile` uses a caller-supplied path |

The rest, same fix:

| CVE | ZDI | Score | Needs |
|---|---|---|---|
| [CVE-2026-92187](https://www.cve.org/CVERecord?id=CVE-2026-92187) | ZDI-26-852 | 8.8 | A login. Directory traversal in `extractAndCreateUploadInfoList`. |
| [CVE-2026-92192](https://www.cve.org/CVERecord?id=CVE-2026-92192) | ZDI-26-855 | 8.8 | A login. Directory traversal in `installLicense`. |
| [CVE-2026-92195](https://www.cve.org/CVERecord?id=CVE-2026-92195) | ZDI-26-856 | 8.8 | A login. Directory traversal in `loadEvolveLicense`. |
| [CVE-2026-92194](https://www.cve.org/CVERecord?id=CVE-2026-92194) | ZDI-26-857 | 8.8 | A login. Directory traversal in `loadManageServerLicense`. |
| [CVE-2026-92186](https://www.cve.org/CVERecord?id=CVE-2026-92186) | ZDI-26-858 | 8.8 | A login. Directory traversal in `paFnUploadFileAndCreateInfo`. |
| [CVE-2026-92191](https://www.cve.org/CVERecord?id=CVE-2026-92191) | ZDI-26-859 | 8.8 | A login. `runScript` does not check authorization. |
| [CVE-2026-92197](https://www.cve.org/CVERecord?id=CVE-2026-92197) | ZDI-26-860 | 8.8 | A login. Directory traversal in `unzipFile`. |
| [CVE-2026-92196](https://www.cve.org/CVERecord?id=CVE-2026-92196) | ZDI-26-866 | 7.2 | A login. Server-side template injection in `renderTemplateString`. |
| [CVE-2026-92198](https://www.cve.org/CVERecord?id=CVE-2026-92198) | ZDI-26-864 | 8.2 | No login. XML external entity in `getSource`. Information disclosure. |
| [CVE-2026-92185](https://www.cve.org/CVERecord?id=CVE-2026-92185) | ZDI-26-862 | 7.2 | No login. XML external entity in `AbstractParser`. Information disclosure. |
| [CVE-2026-92193](https://www.cve.org/CVERecord?id=CVE-2026-92193) | ZDI-26-853 | 6.5 | A login. `FileServlet` reads a caller-supplied path. |
| [CVE-2026-92200](https://www.cve.org/CVERecord?id=CVE-2026-92200) | ZDI-26-865 | 7.8 | Code already running on the host. The installer leaves a folder with the wrong permissions. |
| [CVE-2026-92199](https://www.cve.org/CVERecord?id=CVE-2026-92199) | ZDI-26-863 | 7.8 | Code already running on the host. `symmetricDecrypt` uses a hard-coded key. ZDI spells it "Encyption" in the title. |

No Quest security advisory for this set was found. ZDI is the primary source, and ZDI says the publication was coordinated, which is its way of saying a fix exists.

## Remediation

1. Upgrade Foglight for Databases to **8.3 or later**. ZDI gives no other fixed build and no workaround.
2. Until 8.3 is running, do not expose the Foglight service to a network you do not trust. That limits who can reach the three unauthenticated flaws. It does not fix them, and it does nothing for the local privilege escalations.
3. A login-gated 8.8 flaw is not a reason to leave the service up. The 9.8 flaws do not need that login.

## Verification

- The running Foglight version is 8.3 or later, read from the installed product rather than from an installer in a download folder.
- A host still reporting 8.2.0 is the version the CVE records name.
- ZDI does not say a Foglight product other than Foglight for Databases is fixed by 8.3. Do not treat a different Quest product's version as this fix.

## Compromise response

- The 9.8 flaws run as SYSTEM and need no login. A Foglight service that was reachable from a network you do not trust, on a version below 8.3, may already have run attacker-supplied code.
- Upgrading to 8.3 does not remove a service, account, or file an attacker created, and it does not expire a credential the process could read.
- ZDI publishes no indicators. A quiet log is not a clean bill.

## Sources

- [ZDI-26-851][z851] — CVE-2026-92190, CVSS 3.0 9.8, no authentication, fixed in Foglight 8.3. Published 2026-11-03.
- [ZDI-26-854][z854] — CVE-2026-92188, CVSS 3.0 9.8, missing authentication in `ForgeMBeanServerSupport`.
- [ZDI-26-861][z861] — CVE-2026-92189, CVSS 3.0 9.8, path in `writeTopologySectionToFile`.
- [ZDI published advisories][zdi] — ZDI-26-851 through ZDI-26-866, all dated 2026-11-03, all Foglight for Databases, all fixed in 8.3.
- [CVE-2026-92190](https://www.cve.org/CVERecord?id=CVE-2026-92190) — ZDI CNA. Affected version in the record is 8.2.0. The record does not name 8.3.
- [CISA KEV JSON feed][kev] — none of these CVEs listed (catalog 2026.11.03, checked 2026-11-04).

[z851]: https://www.zerodayinitiative.com/advisories/ZDI-26-851/
[z854]: https://www.zerodayinitiative.com/advisories/ZDI-26-854/
[z861]: https://www.zerodayinitiative.com/advisories/ZDI-26-861/
[zdi]: https://www.zerodayinitiative.com/advisories/published/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
