# Dell Enterprise SONiC: a neighbor runs a command before login

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#dell-enterprise-sonic-a-neighbor-runs-a-command-before-login) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Enterprise SONiC Distribution is Dell's build of the SONiC network operating system for its PowerSwitch line. DSA-2026-451, dated November 19, fixes two Critical flaws in Dell's own code and a long list of third-party packages in the same upgrade.

**Dell rates [CVE-2026-103788](https://www.cve.org/CVERecord?id=CVE-2026-103788) CVSS 3.1 9.6 Critical.** The vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`. Dell is the CNA. An OS command injection lets an unauthenticated attacker on an adjacent network run a command. Dell's sentence is "arbitrary command execution." The advisory calls this one critical because the attacker is not logged in. The record was published 2026-11-23.

**Dell rates [CVE-2026-103782](https://www.cve.org/CVERecord?id=CVE-2026-103782) CVSS 3.1 9.9 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H`. Argument injection lets a low-privileged remote attacker run a command and reach filesystem resources. The record was published the same day.

**Enterprise SONiC Distribution before 4.6.1** is affected. **4.6.1** is the remediated version for both, and for the rest of the advisory. DSA-2026-451 revision 1.0 is dated 2026-11-19. The article's Last Modified is 19 Nov 2026. Dell lists eleven more proprietary flaws in the same build: CVE-2026-101218 and CVE-2026-103783 at 8.2, CVE-2026-103791 at 7.6, CVE-2026-101219 and CVE-2026-103786 at 7.5, and CVE-2026-103789 at 7.5 with a vector Dell scores as adjacent and high complexity. Six more are 5.9 or below. The third-party table includes the kernel package and names CVE-2026-46300 among many others; that row is not a PAN-OS Fragnesia finding, and Dell does not say which kernel build fixed it.

Dell does not report exploitation. The advisory does not name a workaround.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-25) for CVE-2026-103788, CVE-2026-103782, or the other proprietary CVEs in DSA-2026-451. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Advisory** | **2026-11-19; time/TZ unknown** | DSA-2026-451 revision 1.0. Last Modified 19 Nov 2026. [Dell][dsa] |
| CVE records | 2026-11-23; time/TZ unknown | CVE-2026-103788 and CVE-2026-103782. Dell is the CNA. The pages say Published Nov 23 and print no clock time. |
| **Last updated** | **2026-11-25 (America/New_York)** | New item. Install 4.6.1. |

## Detection

1. Read the SONiC version on the switch. Dell's affected range is every Enterprise SONiC Distribution before 4.6.1. A version string that is not Dell's Enterprise build is a different product.
2. The 9.6 flaw is adjacent: a peer that can reach the switch's network, not only a host on the internet. A management VRF that is reachable from untrusted segments is in scope. Dell does not name the port or the command.
3. The 9.9 flaw needs a low-privileged login. An account that can reach the CLI and is not an administrator is enough for that one, on Dell's description.

There is no Dell log line for either flaw. A scanner that only checks the public internet does not see an adjacent neighbor.

## Remediation

Upgrade to **Enterprise SONiC Distribution 4.6.1 or later**. Dell's download is behind the product's drivers page and My Account. The advisory names no workaround and no configuration that takes a switch out of scope.

The upgrade does not show whether a neighbor already ran a command, and it does not expire a credential that command could have read.

## Verification

The switch reports 4.6.1 or a later Dell build. Do not send a command-injection probe to confirm it.

## Compromise response

If the switch was reachable from a network you do not trust while it ran a build before 4.6.1, review administrative logins and configuration changes you did not make. Replace credentials stored on the switch. Dell does not publish an indicator for this advisory.

## Sources

- [DSA-2026-451][dsa] — revision 1.0, 2026-11-19. Critical. Both flaws fixed in 4.6.1. Eleven more proprietary CVEs in the same build.
- [CVE-2026-103788](https://www.cve.org/CVERecord?id=CVE-2026-103788) — Dell, CVSS 3.1 9.6. Adjacent, no login. Published 2026-11-23.
- [CVE-2026-103782](https://www.cve.org/CVERecord?id=CVE-2026-103782) — Dell, CVSS 3.1 9.9. Low privileged, remote. Published 2026-11-23.
- [CISA KEV JSON][kev] — catalog 2026.11.24, checked 2026-11-25. Neither CVE is listed.

[dsa]: https://www.dell.com/support/kbdoc/en-us/000535884/dsa-2026-451-security-update-for-dell-enterprise-sonic-distribution-vulnerabilities
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
