# FOG Project: a host token returns the domain-join password

**Last updated:** 2026-11-28 (America/New_York)

[Main guide](../black-october-2026.md#fog-project-a-host-token-returns-the-domain-join-password)

**The FOG Project rates [GHSA-666x-5fjv-v8j9](https://github.com/FOGProject/fogproject/security/advisories/GHSA-666x-5fjv-v8j9) High, CVSS 3.1 7.4.** The advisory was published 2026-11-27. The vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N`. The weakness is CWE-306. A request that knows a host's MAC address, and only while that host has an active task, gets a one-time token from `status/hostgetkey.php`. Presenting the token to `service/hostinfo.php` returns the host's Active Directory join password in plaintext and its Windows product key. The source-restriction setting `FOG_HOSTKEY_ALLOWED_SOURCES` defaults to empty, which the advisory says means unrestricted. Affected is **1.6.0.118 and earlier**. The advisory says the first fixed build is **1.6.0.119** and the first stable release that contains it is **1.6.0.158**.

VulnCheck published [CVE-2026-137995](https://www.cve.org/CVERecord?id=CVE-2026-137995) the same day for the same flaw and scores it **CVSS 4.0 7.0 High** and **CVSS 3.1 6.1 Medium**. The GitHub advisory still says "No known CVE." The 7.4 is the project's score. VulnCheck's lower 3.1 score is a different issuer's, not a rescore by the project. No source read for this entry reports exploitation.

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-28). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| First fixed build | version 1.6.0.119; date not stated on the advisory | The advisory names 1.6.0.158 as the first stable release that contains it. |
| **Public announcement** | **2026-11-27; time/TZ unknown** | GHSA-666x-5fjv-v8j9, CVSS 3.1 7.4. VulnCheck published CVE-2026-137995 the same day. |
| **Last updated** | **2026-11-28 (America/New_York)** | New item. |

## Detection

On the FOG server, read the installed version. A host that does not run FOG Project is outside this flaw. The range is 1.6.0.118 and earlier. The token is issued only while the named host has an active task, so a server with no queued or running task is not issuing tokens at that moment. That is not a reason to skip the update: the next task opens the window, and the restriction setting defaults to empty. Reading the version changes no state. A version you cannot read is unknown, not safe.

## Remediation

1. Update FOG Project to **1.6.0.158 or later**. The advisory says 1.6.0.119 is the first fixed build and 1.6.0.158 is the first stable release that contains it.
2. Treat the Active Directory join password FOG stored as exposed if a deployment task ran while the server was on 1.6.0.118 or earlier and the web interface was reachable from a network an attacker could join. Rotate that account. The update does not change the password.
3. The advisory names no configuration workaround. Setting `FOG_HOSTKEY_ALLOWED_SOURCES` is the project's own restriction, and the advisory says the default is empty.

## Verification

- The FOG server shows 1.6.0.158 or later.
- Do not request a host token to test the flaw.

## Compromise response

No source read for this entry reports exploitation. If the web interface was reachable during a deployment window, rotate the domain-join account FOG used and review that account's sign-ins. The Windows product key the same response returns is a license key, not a domain credential. Updating FOG does not rotate either.

## Sources

- [GHSA-666x-5fjv-v8j9](https://github.com/FOGProject/fogproject/security/advisories/GHSA-666x-5fjv-v8j9) — published 2026-11-27. High, CVSS 3.1 7.4, vector `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:C/C:H/I:N/A:N`. Through 1.6.0.118. First fixed build 1.6.0.119. First stable release 1.6.0.158. The page says no CVE is known. Credit leediay153.
- [CVE-2026-137995](https://www.cve.org/CVERecord?id=CVE-2026-137995) — VulnCheck, published 2026-11-27. CVSS 4.0 7.0 and CVSS 3.1 6.1. Before 1.6.0.119. CWE-306.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-28. CVE-2026-137995 is not listed.
