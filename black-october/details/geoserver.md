# GeoServer: a stored query reads a file, then a default key is the administrator

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#geoserver-a-stored-query-reads-a-file-then-a-default-key-is-the-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-129245](https://www.cve.org/CVERecord?id=CVE-2026-129245): GeoServer CVSS 4.0 9.2 Critical.** The remember-me cookie is signed with a key that the release data directory ships as `geoserver`. Anyone who also has an administrator password digest can forge an administrator cookie. Two High flaws get that digest with no login: [CVE-2026-129243](https://www.cve.org/CVERecord?id=CVE-2026-129243) (CVSS 4.0 8.8) lets a prefixed service name skip service-security rules, and [CVE-2026-120705](https://www.cve.org/CVERecord?id=CVE-2026-120705) (CVSS 3.1 8.6) injects XML into the built-in WFS GetFeatureById query and returns a local file. [CVE-2026-120704](https://www.cve.org/CVERecord?id=CVE-2026-120704) (CVSS 3.1 7.2) then lets that administrator session load a native library. Eye Security says the three combine to unauthenticated remote code execution on a default install.

The same October builds fix more issues the project rates High. The ones in core are [CVE-2026-129242](https://www.cve.org/CVERecord?id=CVE-2026-129242) (CVSS 4.0 8.6, administrator deserialization) and [CVE-2026-129293](https://www.cve.org/CVERecord?id=CVE-2026-129293) (stored XSS). The rest need an extension or a community module: [CVE-2026-120706](https://www.cve.org/CVERecord?id=CVE-2026-120706) (CVSS 4.0 8.2, WPS plus native GDAL), [CVE-2026-120701](https://www.cve.org/CVERecord?id=CVE-2026-120701) (CVSS 3.1 7.5, WPS Download), [CVE-2026-120710](https://www.cve.org/CVERecord?id=CVE-2026-120710) (GeoWebCache), [CVE-2026-120707](https://www.cve.org/CVERecord?id=CVE-2026-120707) (GeoFence), [CVE-2026-120708](https://www.cve.org/CVERecord?id=CVE-2026-120708) (ACL), [CVE-2026-120703](https://www.cve.org/CVERecord?id=CVE-2026-120703) (JWT community module), and [CVE-2026-129294](https://www.cve.org/CVERecord?id=CVE-2026-129294) (OGC API Styles). [CVE-2026-129244](https://www.cve.org/CVERecord?id=CVE-2026-129244) is Medium (CVSS 4.0 6.9): an overlong stored-query id returns the data-directory path, which the chain uses. Four more Medium issues are in the same builds.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-25). watchTowr says its honeypot saw probes for [CVE-2026-120705](https://www.cve.org/CVERecord?id=CVE-2026-120705) and [CVE-2026-129243](https://www.cve.org/CVERecord?id=CVE-2026-129243) on November 25: attackers created and invoked stored queries to test whether the server was vulnerable. That is not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Report to GeoServer | 2026-09-29; time unknown | Eye Security says it reported the file-read chain that day. [Eye Security][eye] |
| **Fixed releases** | **2026-10-19; time unknown** | 3.0.2, 2.28.6, and 2.27.7. The announcements said details would follow. [GeoServer][gs] |
| **Advisories published** | **2026-11-23; time unknown** | Nineteen advisories. The project rates the remember-me key Critical. [Post][gs] |
| Eye Security write-up | 2026-11-24; time unknown | Says the chain works on a default 3.0.1 install. [Eye Security][eye] |
| **Honeypot probes** | **2026-11-25 11:09 UTC** | watchTowr, for CVE-2026-120705 and CVE-2026-129243. [Post][wt] |
| **Last updated** | **2026-11-25 (America/New_York)** | New item. |

## Detection

1. Open **About GeoServer**. The version is under Build Information. 3.0.0 and 3.0.1, 2.28.0 through 2.28.5, and 2.27.6 and earlier are in the affected range the advisories name. 2.27 is end of life; 2.27.7 is a bridge, not a supported line.
2. A data directory that still has `rememberMeKey` set to `geoserver` in `security/config.xml` has the default key. The upgrade stops reading that key. Changing it by hand does not help if the same file disclosure also returns the new value.
3. Look in `wfs/query` and `workspaces/*/wfs/query` for a stored query nobody created. The service-name bypass is how an anonymous caller creates one.
4. The WPS, GDAL, GeoFence, ACL, printing, and OGC API Styles issues apply only when that extension or module is installed. A core install is still in the file-read and remember-me chain.

## Remediation

Upgrade to **3.0.2** on the stable line or **2.28.6** on the maintenance line. A site already on 2.27.x can use **2.27.7** only until it moves to a supported line. Install matching versions of the extensions. Back up the data directory first.

After the upgrade:

1. Existing remember-me cookies stop working. Users sign in again. A cluster sets `GEOSERVER_REMEMBERME_KEY` to one shared random value, or each node signs with its own key.
2. If the data directory may have been read, change the administrator passwords. The stored digest is what the cookie is signed with, so a password change is what invalidates a digest taken before the upgrade.
3. Until the new build is what is running, remove `rememberme` from the `web` filter chain, and block a `service` parameter that contains `/`. Neither replaces the upgrade.

## Verification

- **About GeoServer** shows 3.0.2, 2.28.6, or 2.27.7 (as a bridge only).
- An old remember-me cookie is rejected and the user signs in again.
- A stored query that was not created by an administrator is gone from `wfs/query`.

Do not send a stored-query request to test the flaw.

## Compromise response

Treat an internet-facing instance below the floor as exposed from the October 19 release, and again from the November 23 publication. A stored query you did not create, a new JDBC security service, or a native library written under the data directory is a reason to preserve the data directory and the logs, rotate administrator passwords, and rebuild the service rather than only upgrading it. The upgrade does not remove a query or a library already written.

## Sources

- [GeoServer Security Update, November 23, 2026][gs] — the list of CVEs fixed in 3.0.2, 2.28.6, and 2.27.7, and the five-step chain.
- [GHSA-hgm3-wq4h-8vvq](https://github.com/geoserver/geoserver/security/advisories/GHSA-hgm3-wq4h-8vvq) — CVE-2026-129245, CVSS 4.0 9.2, default key `geoserver`.
- [GHSA-rv5g-g2r9-58rj](https://github.com/geoserver/geoserver/security/advisories/GHSA-rv5g-g2r9-58rj) — CVE-2026-129243, CVSS 4.0 8.8.
- [GHSA-39mw-5chv-jh47](https://github.com/geoserver/geoserver/security/advisories/GHSA-39mw-5chv-jh47) — CVE-2026-120705, CVSS 3.1 8.6.
- [GHSA-wc3v-48j7-xf57](https://github.com/geoserver/geoserver/security/advisories/GHSA-wc3v-48j7-xf57) — CVE-2026-120704, CVSS 3.1 7.2.
- [GHSA-9wf2-fcgq-vxhq](https://github.com/geoserver/geoserver/security/advisories/GHSA-9wf2-fcgq-vxhq) — CVE-2026-129242, CVSS 4.0 8.6.
- [GHSA-4v26-c537-jvxc](https://github.com/geoserver/geoserver/security/advisories/GHSA-4v26-c537-jvxc) — CVE-2026-129244, CVSS 4.0 6.9.
- [GHSA-3x82-qq72-g4p3](https://github.com/geoserver/geoserver/security/advisories/GHSA-3x82-qq72-g4p3) — CVE-2026-120701, CVSS 3.1 7.5, WPS Download extension.
- [GHSA-5v3x-f56f-2xm8](https://github.com/geoserver/geoserver/security/advisories/GHSA-5v3x-f56f-2xm8) — CVE-2026-120706, CVSS 4.0 8.2, needs native GDAL.
- [Eye Security, November 24, 2026][eye] — the file-read, cookie, and JDBC chain on a default install. Reported September 29.
- [watchTowr, November 25, 2026, 11:09 UTC][wt] — honeypot probes for CVE-2026-120705 and CVE-2026-129243.
- [CISA KEV JSON][kev] — catalog 2026.11.25, checked 2026-11-25. None of these CVEs is listed.

[gs]: https://geoserver.org/vulnerability/2026/11/23/cve-update.html
[eye]: https://labs.eye.security/unauthenticated-remote-code-execution-vulnerability-in-geoserver/
[wt]: https://x.com/watchtowrcyber/status/2125547398021693623
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
