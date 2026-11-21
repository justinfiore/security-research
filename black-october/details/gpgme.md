# GPGME: a long OpenPGP user ID frees memory twice

**Last updated:** 2026-11-21 (America/New_York)

[Main GPGME summary](../black-october-2026.md#gpgme-a-long-openpgp-user-id-frees-memory-twice) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-20 at 19:01:51 CET, Werner Koch announced GPGME 2.3.1. GnuPG calls the bug it fixes a critical security bug. The CVE record, [CVE-2026-129975](https://www.cve.org/CVERecord?id=CVE-2026-129975), is still reserved, so no CNA has published a CVSS score. The advisory is the source of the severity word.

An OpenPGP key with a crafted, very long user ID triggers a double free in two internal readers, the status-line reader and the key-listing reader. GnuPG says that double free can be used to exfiltrate data from an application, for example by sending signed data, and that using it for remote code execution cannot be ruled out. Johan Carlsson found it. GitLab told GnuPG on 2026-11-12. The coordinated date was 2026-11-25; GitLab moved its own update earlier because of Ruby2Shell, and GnuPG disclosed the same day.

The readers start with a 1024-byte buffer and reallocate it when the line is longer. The new pointer is written back to the context only at the end of the function. An early return leaves the context holding the freed block, and releasing the context frees it again.

Affected is every GPGME before 2.3.0, as a shared library, a Windows DLL, or linked into the program. 2.3.0 was never published. The advisory names Gpg4win, GnuPG Desktop, GnuPG VS-Desktop, most mail clients, many XMPP clients, Samba, and Flatpak. GPGMEPP and GPGMEQT do not need their own update. A program that never hands an outside key to GPGME is outside the path the advisory describes.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-21). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to GnuPG | 2026-11-12; time/TZ unknown | Johan Carlsson, through GitLab. Planned disclosure was 2026-11-25. [Advisory][adv] |
| GPGME 2.3.1 tagged | 2026-11-19; time/TZ unknown | The changelog date. Not the public announcement. [Advisory][adv] |
| **Public announcement** | **2026-11-20 19:01:51 CET (UTC+01:00)** | Werner Koch, gnupg-announce. Gpg4win 5.1.2 the same day. [Advisory][adv] |
| Debian | 2026-11-20 | DSA-6646-1 at 21:36:59 UTC fixes trixie. DLA-4924-1 fixes bookworm. Forky has no package. [Tracker][tracker] |

## Detection

Read the installed library, not the `gpg` binary. On Debian and Ubuntu, `dpkg -l gpgme1.0 libgpgme11` shows the package. On other systems, `gpgme-config --version` or the shared-object name does. A version below 2.3.1 is inside the range the advisory names, including 2.2.0. Debian's fixed packages keep their old upstream numbers: trixie security is `1.24.2-3+deb13u1` and bookworm security is `1.18.0-3+deb12u1`. The main trixie and bookworm repositories are still the vulnerable builds. Forky 2.2.0-2 is still vulnerable. Sid is fixed at 2.3.1-1.

A program that links GPGME statically, or ships its own copy, does not move when the system package does. The advisory names that case and does not list the programs. Reading the package version changes no state.

## Remediation

1. Update the shared library to **GPGME 2.3.1**. On Windows, install **Gpg4win 5.1.2**, which carries the fixed DLL. On Debian 13 (trixie), install `gpgme1.0` **1.24.2-3+deb13u1** from trixie-security (DSA-6646-1). On Debian 12 (bookworm), install **1.18.0-3+deb12u1** from bookworm-security (DLA-4924-1). Restart the programs that had the library loaded.
2. Rebuild anything linked against GPGME statically, against 2.3.1.
3. The legacy line is **1.24.4**. GnuPG says it cannot guarantee that line will see every later security patch.
4. If the library cannot be updated, the announcement carries a patch GnuPG says likely applies to old versions. There is no configuration workaround.
5. Debian testing (forky) has no fixed package. The tracker still lists 2.2.0-2 as vulnerable.

## Verification

- The running library is 2.3.1 or later, or the Debian package is the security build named above, or Gpg4win is 5.1.2 or later.
- A program you rebuilt reports the new library, not a copy it still ships.
- Do not feed a crafted key to test the bug.

## Compromise response

GnuPG does not report exploitation. An application that imported or listed keys from outside, while it was still on a library before 2.3.1, should be reviewed for data it should not have sent. The update does not show whether that happened.

## Sources

- [GnuPG announcement][adv] — Werner Koch, gnupg-announce, 2026-11-20 19:01:51 CET. Critical, in GnuPG's words. No CVSS score. Fixed in GPGME 2.3.1 and Gpg4win 5.1.2. 2.3.0 was never published. Checksum `1134a407b50204ee6fb9efaa6e1451c2460e543e` for `gpgme-2.3.1.tar.bz2`.
- [CVE-2026-129975](https://www.cve.org/CVERecord?id=CVE-2026-129975) — reserved. No CNA description and no score, checked 2026-11-21.
- [DSA-6646-1](https://www.debian.org/security/2026/dsa-6646) — 2026-11-20 21:36:59 UTC. Trixie `1.24.2-3+deb13u1`. Debian says information disclosure, denial of service, and potentially arbitrary code.
- [Debian security tracker][tracker] — checked 2026-11-21. Bookworm security `1.18.0-3+deb12u1` (DLA-4924-1) fixed. Trixie security fixed. Forky `2.2.0-2` vulnerable. Sid `2.3.1-1` fixed.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-21. Not listed.

[adv]: https://lists.gnupg.org/pipermail/gnupg-announce/2026q4/000517.html
[tracker]: https://security-tracker.debian.org/tracker/CVE-2026-129975
