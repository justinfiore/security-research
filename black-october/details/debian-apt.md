# Debian APT: a resumed download can install a different package as root

**Last updated:** 2026-11-06 (America/New_York)

[Main APT summary](../black-october-2026.md#debian-apt-a-resumed-download-can-install-a-different-package-as-root) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-109518](https://www.cve.org/CVERecord?id=CVE-2026-109518): Ubuntu rates it CVSS 4.0 7.7 High (`CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:P/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`) and priority High. Debian's advisories do not print a score.** APT can merge two different package downloads after an HTTP redirect gives them the same URI. Improper file handling when resuming that download lets an on-path attacker replace a package after verification. The substituted package then installs as root. Ubuntu says the client must follow redirects and retry the download, and that `Acquire::Retries` must be non-zero. The default of 3 starts with Debian 12 and Ubuntu 22.04, so older releases are unaffected in a default configuration. [DSA-6607-1][dsa] [Ubuntu][ubuntu]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-04). Neither Debian nor Ubuntu reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | Debian credits Max Justicz. [DSA-6607-1][dsa] |
| Debian 13 fix | 2026-11-04 12:07:32 UTC | DSA-6607-1. trixie `apt` 3.0.4. The same update addresses several out-of-bounds access issues and does not assign them CVEs. [DSA-6607-1][dsa] |
| Debian 12 fix | 2026-11-04 12:46:36 UTC | [DLA-4880-1][dla-announce]. bookworm `apt` 2.6.2. The same update addresses several out-of-bounds access issues and names no CVE for them. [Tracker][tracker] |
| Ubuntu score | 2026-11-04; time/TZ unknown | CVSS 4.0 7.7 High. [Ubuntu][ubuntu] |
| Maintainer branch list | 2026-11-04 12:00:16 UTC | Julian Andres Klode names the stable-branch fixes, including 2.2.5, 2.4.15, 2.6.2, 2.8.4, 3.0.4, and 3.2.1, and says Ubuntu and Ubuntu Pro packages are being released. [deity][deity] |
| forky now fixed | Tracker read 2026-11-05 | forky and sid are both 3.3.6 fixed. On 2026-11-04 forky was still 3.3.5. [Tracker][tracker] |
| Ubuntu packages | 2026-11-04; time/TZ unknown | USN-8996-1. 26.10 `3.3.3ubuntu0.1`, 26.04 `3.2.1ubuntu0.1`, 24.04 `2.8.4ubuntu0.1`, 22.04 `2.4.15ubuntu0.1`. 20.04, 18.04, 16.04, and 14.04 are Ubuntu Pro. [USN-8996-1][usn] |

## Detection

Read the installed version. Do not fetch a package to test the flaw.

```sh
dpkg-query -W -f '${Package} ${Version}\n' apt
apt-config dump Acquire::Retries
```

Debian's tracker, read 2026-11-04:

| Release | Vulnerable | Fixed |
|---|---|---|
| bookworm (Debian 12) | 2.6.1 | 2.6.2 (bookworm-security, DLA-4880-1) |
| trixie (Debian 13) | 3.0.3 | 3.0.4 (trixie-security, DSA-6607-1) |
| sid | 3.3.5 | 3.3.6 |
| forky | 3.3.5 | 3.3.6, as of the tracker read on 2026-11-05 |

A version below the fixed floor for that release is vulnerable. A version the table does not name is **unknown**, not safe.

USN-8996-1, dated 4 November 2026:

| Ubuntu release | Fixed `apt` |
|---|---|
| 26.10 | 3.3.3ubuntu0.1 |
| 26.04 LTS | 3.2.1ubuntu0.1 |
| 24.04 LTS | 2.8.4ubuntu0.1 |
| 22.04 LTS | 2.4.15ubuntu0.1 |
| 20.04 LTS | 2.0.12+esm1 (Ubuntu Pro) |
| 18.04 LTS | 1.6.19+esm1 (Ubuntu Pro) |
| 16.04 LTS | 1.2.36+esm1 (Ubuntu Pro, Legacy Support) |
| 14.04 LTS | 1.0.1ubuntu2.24+esm4 (Ubuntu Pro, Legacy Support) |

Ubuntu says releases older than 22.04 are unaffected when `Acquire::Retries` is 0, which is their default. A non-zero value on those releases puts them back in scope, and the Pro packages above are the fix for that configuration. Debian's advisory does not state that exception.

HTTPS to the archive does not remove the flaw. Ubuntu includes a malicious mirror or proxy in the attack, and Debian describes an HTTP redirect that makes two downloads share a URI.

## Remediation

1. On Debian 13, upgrade `apt` to **3.0.4 or later**. On Debian 12, upgrade `apt` to **2.6.2 or later**. Both are in the security pocket:

   ```sh
   apt update && apt install --only-upgrade apt
   ```

   Upgrade `apt` before the rest of the system. The same Debian updates also fix several out-of-bounds access issues that have no CVE.

2. On sid and on forky, install `apt` **3.3.6 or later**. The tracker read on 2026-11-05 lists both suites as fixed at that version. On 2026-11-04 forky was still 3.3.5.

3. On Ubuntu 26.10, 26.04, 24.04, and 22.04, a normal update installs the USN-8996-1 package. Upgrade `apt` before other packages:

   ```sh
   apt update && apt install --only-upgrade apt
   ```

   20.04, 18.04, 16.04, and 14.04 get the fix only with Ubuntu Pro (16.04 and 14.04 also need Legacy Support). Without Pro, leave `Acquire::Retries` at 0, which is the default on those releases, and prefer an HTTPS mirror you already trust. Setting retries to 0 on Ubuntu 22.04 and later is not a vendor workaround and is not a substitute for the package.

4. A container image, a chroot, and a build host each have their own `apt`. Upgrading the host does not upgrade them.

## Verification

- `dpkg-query -W apt` prints 3.0.4 or later on Debian 13, or 2.6.2 or later on Debian 12.
- `apt-cache policy apt` shows the security pocket, not a leftover copy of 3.0.3 or 2.6.1.
- On sid and on forky, `dpkg-query -W apt` prints 3.3.6 or later.
- On Ubuntu, `dpkg-query -W apt` prints the version in the table above for that release, or a later one. A Debian version number is not an Ubuntu package.

## Compromise response

The advisory describes replacement of a package after verification. It does not describe a check that shows whether that replacement already happened. If a host fetched packages over an untrusted path while it was still on a vulnerable `apt`:

- Compare installed package versions and file hashes with a host that updated from a mirror you trust. A mismatch is an indicator, not proof of this bug.
- Review `/var/log/apt/history.log` and `/var/log/apt/term.log` for an upgrade you did not start.
- If a package you did not choose is installed, treat the host as compromised: rebuild it, and rotate credentials that lived on it. Upgrading `apt` afterward does not remove a package that already installed.

## Sources

- [DSA-6607-1][dsa] — 2026-11-04 12:07:32 UTC. trixie `apt` 3.0.4. Credits Max Justicz. Also addresses several out-of-bounds access issues, with no separate CVE.
- [Debian security tracker][tracker] — bookworm 2.6.2 fixed (DLA-4880-1); trixie 3.0.4 fixed; forky and sid 3.3.6 fixed. Read 2026-11-05.
- [APT-2026-11-01][deity] — Julian Andres Klode, 2026-11-04 13:00:16 +0100. Names the stable-branch fixes and says Ubuntu and Ubuntu Pro packages are being released. USN-8996-1 is that release.
- [DLA-4880-1][dla-announce] — 2026-11-04 12:46:36 UTC. bookworm `apt` 2.6.2. The announcement also says the update addresses several out-of-bounds access issues, and it names no CVE for those.
- [Ubuntu CVE-2026-109518][ubuntu] — CVSS 4.0 7.7 High, priority High, published 2026-11-04. States the retries and redirect conditions. Fixed versions are in [USN-8996-1][usn], 4 November 2026.
- [CVE-2026-109518][cve] — the identifier both vendors use.
- [CISA KEV JSON feed][kev] — catalog 2026.11.04, not listed.

[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00526.html
[tracker]: https://security-tracker.debian.org/tracker/CVE-2026-109518
[dla]: https://security-tracker.debian.org/tracker/DLA-4880-1
[dla-announce]: https://lists.debian.org/debian-lts-announce/2026/11/msg00004.html
[ubuntu]: https://ubuntu.com/security/CVE-2026-109518
[usn]: https://ubuntu.com/security/notices/USN-8996-1
[deity]: https://lists.debian.org/deity/2026/11/msg00005.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-109518
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
