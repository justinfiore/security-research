# Cyrus SASL: the SRP mechanism accepts any password

**Last updated:** 2026-11-17 (America/New_York)

[Main Cyrus SASL summary](../black-october-2026.md#cyrus-sasl-the-srp-mechanism-accepts-any-password) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Cyrus SASL is the authentication library mail, directory, and other network servers load to offer SASL mechanisms. [CVE-2026-129483](https://www.cve.org/CVERecord?id=CVE-2026-129483) is in the SRP server mechanism, `plugins/srp.c`. The server is supposed to reject a client public value `A` that is a multiple of the group modulus `N`. It only rejects `A` that is zero or negative, so a client that sends `A` equal to `N` forces a shared secret of zero and can compute the proof for any existing SRP user without the password. VulnCheck is the CNA and rates it **CVSS 4.0 9.3 Critical** and **CVSS 3.1 9.1 Critical**. The 4.0 vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`. The 3.1 vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. The reporter's own score is 9.8; the published record is the one above. NVD has not scored it.

SRP is not a default mechanism. Upstream builds it only with `--enable-srp`, and the latest release, **2.1.28** from 2022-02-22, still contains the check. A server that does not advertise `SRP` is outside this flaw. A server that does is not protected by the commit that removed the plugin: that commit is on the project's master branch and is not in any release.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-17). The catalog is still the November 13 release, 1,781 entries, and the CVE is not among them. The reporter published a proof of concept. Neither VulnCheck nor the project reports that it has been used against a real server. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Last upstream release | 2022-02-22 18:03:52 UTC | Cyrus SASL 2.1.28. It still ships `plugins/srp.c`, and SRP is off unless the build passes `--enable-srp`. [2.1.28][rel] |
| Reported to the project | 2026-07-31 | afldl opened the issue with a reproducer that drives the real library. The project did not answer. [issue 896][issue] |
| Plugin removed on master | 2026-11-12 17:52:39 UTC | Ken Murchison deleted `plugins/srp.c` and the `--enable-srp` option. The commit message does not mention the bypass. It is not a release. [commit][commit] |
| **Public announcement** | **2026-11-15** | VulnCheck published [CVE-2026-129483](https://www.cve.org/CVERecord?id=CVE-2026-129483). NVD's published time is 2026-11-15 14:17:27 UTC. The record names no fixed version. |
| Debian and Ubuntu status | 2026-11-16; time unknown | Debian's tracker now says its build passes `--disable-srp`. Ubuntu published a page the same day and marks every release Needs evaluation. Neither ships a fixed package. |
| **Last updated** | **2026-11-17 (America/New_York)** | Debian builds with SRP off. Ubuntu's page exists and has no fix. |

## Detection

1. Ask the server which mechanisms it offers. For a Cyrus IMAP server, `imtest -m SRP -t "" host` either negotiates SRP or the server rejects the mechanism. A Postfix or other server that logs `mech=SRP` in a successful authentication has it on. A configuration line such as `sasl_mech_list` or `mech_list` that names `SRP` is the same fact. A server that does not offer `SRP` is outside this flaw.
2. On the host, `saslpluginviewer` or `pluginviewer` lists the installed plugins. `libsrp.so`, `libsrp.so.2`, or `libsrp.la` under the SASL plugin directory means the build included SRP. Debian and Ubuntu package that file in `libsasl2-modules`; its presence is not the same as the server advertising the mechanism.
3. The library version does not decide this. 2.1.28 is the newest release, and it is affected when SRP is built and advertised. Debian's tracker still marks bookworm, trixie, forky, and sid vulnerable with no fixed version, and it now notes that the Debian build passes `--disable-srp`. The packaging rules for sid `2.1.28+dfsg1-12` and bookworm `2.1.28+dfsg-10` do pass that flag. A Debian package that was not rebuilt with a different option does not include the plugin. Ubuntu's page, dated November 16, marks 26.10, 26.04 LTS, 24.04 LTS, 22.04 LTS, and 20.04 LTS as Needs evaluation and names no package.

## Remediation

1. Stop advertising SRP. Remove `SRP` from `mech_list`, `sasl_mech_list`, or the equivalent setting, and restart the service. A client that was using SRP has to move to a mechanism the server still offers, such as SCRAM or GSSAPI.
2. Where the package split allows it, remove the SRP plugin. On Debian and Ubuntu that file ships inside `libsasl2-modules` together with the other modules, so removing the package removes PLAIN, LOGIN, and the rest. Do not do that to close this one mechanism. Removing `libsrp.so` by hand is undone by the next package update.
3. Do not wait for a 2.1.28 update that contains the fix. Upstream has not tagged a release since 2.1.28, and the November 12 commit removes the plugin instead of correcting the check. Debian's tracker still lists the flaw as vulnerable on bookworm, trixie, forky, and sid, with urgency unimportant and no fixed version. Its note that the Debian build passes `--disable-srp` means a stock Debian build never offered the mechanism. Ubuntu's page, updated 2026-11-16, marks every listed release Needs evaluation and links no notice. SUSE marks its supported lines Affected, state Pending, and has published no announcement. Red Hat's CVE page redirected to a login. Amazon Linux's page returned no erratum.
4. Building current master drops the plugin, which also closes it. That tree is not a release, and it carries other unreleased changes. Treat it as a source change you review, not as a vendor fix.

## Verification

- The running server no longer offers `SRP` in its mechanism list, and a test account can still authenticate with the mechanism you kept.
- Do not send `A = N` to a production server. The reporter's gist is a proof of concept, and running it authenticates as the user.

## Compromise response

A server that advertised SRP accepted a proof computed with no password, and the project publishes no log line that distinguishes that from a normal SRP login. If the mechanism was reachable, review authentication logs for SRP logins you cannot account for, expire sessions, and rotate the secrets of accounts that authenticated that way. Turning the mechanism off does not show whether such a login already happened.

## Sources

- [CVE-2026-129483](https://www.cve.org/CVERecord?id=CVE-2026-129483) — VulnCheck, published 2026-11-15. CVSS 4.0 9.3 and CVSS 3.1 9.1. Affected through 2.1.28. No fixed version.
- [NVD, CVE-2026-129483](https://nvd.nist.gov/vuln/detail/CVE-2026-129483) — published 2026-11-15 14:17:27 UTC. NVD has not scored it.
- [VulnCheck advisory](https://www.vulncheck.com/advisories/cyrus-sasl-through-2.1.28-srp-authentication-bypass-via-plugins-srp-c) — the same scores and the same affected range.
- [cyrus-sasl issue 896][issue] — afldl, opened 2026-07-31. Describes the missing `A % N == 0` check and links a reproducer. The project did not reply.
- [Commit fb3724f][commit] — Ken Murchison, 2026-11-12 17:52:39 UTC. Removes the SRP plugin on master. Not a release, and the message does not mention the bypass.
- [Cyrus SASL 2.1.28][rel] — published 2022-02-22 18:03:52 UTC. The newest tag. SRP is disabled unless `--enable-srp` is passed.
- [oss-security, unfixed Cyrus SASL issues](https://seclists.org/oss-sec/2026/q4/122) — Alan Coopersmith, 2026-10-09. Lists issue 896 among several reports with no maintainer response. The SRP issue had no CVE then.
- [Debian security tracker, cyrus-sasl2](https://security-tracker.debian.org/tracker/CVE-2026-129483) — read 2026-11-17. Vulnerable, unfixed, urgency unimportant, on bookworm, trixie, forky, and sid. The page notes the Debian build passes `--disable-srp`. No fixed version.
- [Debian packaging rules](https://sources.debian.org/src/cyrus-sasl2/2.1.28+dfsg1-12/debian/rules/) — sid `2.1.28+dfsg1-12` and bookworm `2.1.28+dfsg-10` pass `--disable-srp` and `--disable-srp-setpass`. Read 2026-11-17.
- [Ubuntu CVE-2026-129483](https://ubuntu.com/security/CVE-2026-129483) — published and last updated 2026-11-16. Priority Medium. 26.10, 26.04 LTS, 24.04 LTS, 22.04 LTS, and 20.04 LTS are Needs evaluation. No notice and no package.
- [SUSE CVE-2026-129483](https://www.suse.com/security/cve/CVE-2026-129483.html) — read 2026-11-17. Supported `cyrus-sasl` lines Affected, state Pending. No announcement. The page shows no date.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, released 2026-11-13T20:24:18.3008Z, checked 2026-11-17. CVE-2026-129483 is not listed.

[issue]: https://github.com/cyrusimap/cyrus-sasl/issues/896
[commit]: https://github.com/cyrusimap/cyrus-sasl/commit/fb3724f43dc50247ff2bf02135457d6d77031654
[rel]: https://github.com/cyrusimap/cyrus-sasl/releases/tag/cyrus-sasl-2.1.28
