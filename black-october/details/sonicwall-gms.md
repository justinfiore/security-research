# SonicWall GMS: unauthenticated file read, no patch

**Last updated:** 2026-11-04 (America/New_York)

[Back to SonicWall GMS summary](../black-october-2026.md#sonicwall-gms-unauthenticated-file-read-no-patch) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-109593](https://www.cve.org/CVERecord?id=CVE-2026-109593): SonicWall rates it CVSS 3.1 9.1 Critical.** An unauthenticated attacker who can reach Global Management System (GMS) 9.5.2 or earlier may read internal GMS files. SonicWall's advisory gives the vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:H` and CWE-636 (failing open). The CNA record itself carries no score; NVD shows the 9.1 from CISA-ADP. A second flaw, [CVE-2026-109594](https://www.cve.org/CVERecord?id=CVE-2026-109594), is CVSS 3.1 6.8 Medium: an authenticated attacker can, in specific conditions, read or change the GMS database through SQL injection. GMS is end of life. SonicWall will not release a fix. [SNWLID-2026-0019][adv]

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04) for either CVE. CISA-ADP records Exploitation "none" for CVE-2026-109593. SonicWall does not report attacks. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Advisory published | 2026-11-03; time/TZ unknown | SNWLID-2026-0019, version 1.0, "03-Nov-2026." First Published and Last Updated are both 2026-11-03. [Advisory][adv] |
| CVE-2026-109593 published | 2026-11-03 16:25:11 UTC | SonicWall CNA. `datePublic` 2026-11-03 16:11:00 UTC. Tag `unsupported-when-assigned`. No CVSS in the CNA container. [Record][cve593] |
| CVE-2026-109594 published | 2026-11-03 16:28:35 UTC | SonicWall CNA. `datePublic` 2026-11-03 16:25:00 UTC. The 6.8 score is on the advisory, not in the CNA container. [Record][cve594] |
| **Last updated** | **2026-11-04 (America/New_York)** | New item. |

## Detection

1. GMS is the product. Network Security Manager (NSM) is the replacement and is not named in this advisory. A host running NSM is outside SNWLID-2026-0019.
2. The affected builds are the **Virtual Appliance and Windows** editions, **9.5.2 and earlier**. Read the version from the running appliance, not from an installer left in a download folder.
3. The 9.1 flaw needs network access to GMS and no login. A GMS that answers on a reachable address is in the condition the advisory describes. The 6.8 flaw needs an authenticated user and "specific conditions" SonicWall does not list.
4. SonicWall publishes no indicators of compromise and no log signature. A quiet log does not show the files were never read.

## Remediation

1. Take GMS off the network. SonicWall says no workaround exists and no security update will be released, because the product is end of life.
2. Move firewall management to **Network Security Manager**. That is the product SonicWall names. There is no GMS version to upgrade to.
3. Do not leave 9.5.2 reachable while a migration is planned. The advisory's own status is "Applicable," and the fixed-software cell says a fix version is not available.
4. The 6.8 SQL injection is not a reason to keep an administrator logged in "carefully." The same host has the unauthenticated file read, and neither flaw gets a patch.

## Verification

- No GMS process is listening, and the old virtual appliance or Windows service is powered off or removed. A firewall rule in front of a still-running GMS is not the remediation SonicWall describes.
- The management console operators now use is NSM, not a GMS bookmark.
- A version string of 9.5.2 or earlier on a running host means the flaw is still present. There is no later GMS build that clears it.

## Compromise response

- The 9.1 flaw can expose "sensitive information" in internal GMS files. SonicWall does not name the files. Treat credentials, device inventory, and firewall configuration stored in GMS as exposed if the service was reachable from a network you do not trust.
- Rotate passwords and shared secrets that GMS held for the firewalls it managed, and review firewall configuration changes you cannot account for. Reading the files does not by itself change a firewall; the 6.8 flaw can change the GMS database.
- Replacing GMS with NSM does not undo a configuration an attacker already pushed, and it does not expire a credential copied out of GMS.

## Sources

- [SNWLID-2026-0019][adv] — 9.1 for CVE-2026-109593, 6.8 for CVE-2026-109594. GMS Virtual Appliance and Windows, 9.5.2 and earlier. Workaround: none. Fixed version: not available, product is end of life. Recommends Network Security Manager.
- [CVE-2026-109593][cve593] — published 2026-11-03 16:25:11 UTC. Unauthenticated file read. No CVSS in the CNA container. Tag `unsupported-when-assigned`.
- [CVE-2026-109594][cve594] — published 2026-11-03 16:28:35 UTC. Authenticated SQL injection, "in specific conditions."
- [NVD CVE-2026-109593][nvd] — CISA-ADP 9.1 Critical, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:N/A:H`. NVD has no score of its own.
- [CISA KEV JSON feed][kev] — neither CVE listed (catalog 2026.11.03, checked 2026-11-04).

[adv]: https://psirt.global.sonicwall.com/vuln-detail/SNWLID-2026-0019
[cve593]: https://www.cve.org/CVERecord?id=CVE-2026-109593
[cve594]: https://www.cve.org/CVERecord?id=CVE-2026-109594
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-109593
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
