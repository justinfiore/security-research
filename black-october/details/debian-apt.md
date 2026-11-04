# Debian APT: a resumed download can install a different package as root

**Last updated:** 2026-11-04 (America/New_York)

[Main APT summary](../black-october-2026.md#debian-apt-a-resumed-download-can-install-a-different-package-as-root) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-109518](https://www.cve.org/CVERecord?id=CVE-2026-109518): Ubuntu rates it CVSS 4.0 7.7 High (`CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:P/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`) and priority High. Debian's advisories do not print a score.** APT can merge two different package downloads after an HTTP redirect gives them the same URI. Improper file handling when resuming that download lets an on-path attacker replace a package after verification. The substituted package then installs as root. Ubuntu says the client must follow redirects and retry the download, and that `Acquire::Retries` must be non-zero. The default of 3 starts with Debian 12 and Ubuntu 22.04, so older releases are unaffected in a default configuration. [DSA-6607-1][dsa] [Ubuntu][ubuntu]

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04). Neither Debian nor Ubuntu reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Debian 12 fix | 2026-11-04; time/TZ unknown | Tracker: bookworm security `apt` 2.6.2, origin DLA-4880-1. The announcement page did not return the advisory text when checked. [Tracker][tracker] |
| Ubuntu score | 2026-11-04; time/TZ unknown | CVSS 4.0 7.7 High. Every listed release, 14.04 through 26.10, is still Vulnerable. [Ubuntu][ubuntu] |
| Maintainer branch list | 2026-11-04 12:00:16 UTC | Julian Andres Klode names the stable-branch fixes, including 2.2.5, 2.4.15, 2.6.2, 2.8.4, 3.0.4, and 3.2.1, and says Ubuntu and Ubuntu Pro packages are being released. That mail is not a published Ubuntu package. [deity][deity] |
| sid now fixed | Tracker read 2026-11-04 | sid is 3.3.6 fixed. forky is still 3.3.5 vulnerable. [Tracker][tracker] |
| Ubuntu page re-read | 2026-11-04; time/TZ unknown | 14.04 through 26.10 are still Vulnerable. The notice URL cited elsewhere returned HTTP 404. [Ubuntu][ubuntu] |

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
| forky | 3.3.5 | not yet; sid's 3.3.6 is not in forky |

A version below the fixed floor for that release is vulnerable. A version the table does not name is **unknown**, not safe. Ubuntu's page lists 14.04 through 26.10 as Vulnerable and names no fixed package. Ubuntu says releases older than 22.04 are unaffected when `Acquire::Retries` is 0, which is their default. A non-zero value on those releases puts them back in scope. Debian's advisory does not state that exception.

HTTPS to the archive does not remove the flaw. Ubuntu includes a malicious mirror or proxy in the attack, and Debian describes an HTTP redirect that makes two downloads share a URI.

## Remediation

1. On Debian 13, upgrade `apt` to **3.0.4 or later**. On Debian 12, upgrade `apt` to **2.6.2 or later**. Both are in the security pocket:

   ```sh
   apt update && apt install --only-upgrade apt
   ```

   Upgrade `apt` before the rest of the system. The same Debian updates also fix several out-of-bounds access issues that have no CVE.

2. On sid, install `apt` **3.3.6 or later**. On forky, 3.3.5 is still vulnerable. Do not copy the sid version number onto forky until the tracker says that suite is fixed.

3. On Ubuntu, the public CVE page still lists 14.04 through 26.10 as Vulnerable and names no fixed package. The maintainer says Ubuntu and Ubuntu Pro packages are being released, including a trusty Pro update and `3.3.3ubuntu0.1` for 26.10, and a CVE record cites USN-8996-1. That notice URL returned HTTP 404, so those version numbers are not an installed package. A normal `apt upgrade` does not install this fix until the Ubuntu page names one. Prefer an HTTPS mirror you already trust, and do not raise `Acquire::Retries` on a release whose default is 0. Setting it to 0 on Debian 12 or Ubuntu 22.04 and later is not a vendor workaround and is not a substitute for the package.

4. A container image, a chroot, and a build host each have their own `apt`. Upgrading the host does not upgrade them.

## Verification

- `dpkg-query -W apt` prints 3.0.4 or later on Debian 13, or 2.6.2 or later on Debian 12.
- `apt-cache policy apt` shows the security pocket, not a leftover copy of 3.0.3 or 2.6.1.
- On sid, `dpkg-query -W apt` prints 3.3.6 or later. On forky, 3.3.5 is still vulnerable.
- On Ubuntu, the page still says Vulnerable until a fixed version appears. Do not record a Debian version number, or a version from the maintainer's mail, as an installed Ubuntu package.

## Compromise response

The advisory describes replacement of a package after verification. It does not describe a check that shows whether that replacement already happened. If a host fetched packages over an untrusted path while it was still on a vulnerable `apt`:

- Compare installed package versions and file hashes with a host that updated from a mirror you trust. A mismatch is an indicator, not proof of this bug.
- Review `/var/log/apt/history.log` and `/var/log/apt/term.log` for an upgrade you did not start.
- If a package you did not choose is installed, treat the host as compromised: rebuild it, and rotate credentials that lived on it. Upgrading `apt` afterward does not remove a package that already installed.

## Sources

- [DSA-6607-1][dsa] — 2026-11-04 12:07:32 UTC. trixie `apt` 3.0.4. Credits Max Justicz. Also addresses several out-of-bounds access issues, with no separate CVE.
- [Debian security tracker][tracker] — bookworm 2.6.2 fixed (DLA-4880-1); trixie 3.0.4 fixed; sid 3.3.6 fixed; forky 3.3.5 vulnerable. Read 2026-11-04.
- [APT-2026-11-01][deity] — Julian Andres Klode, 2026-11-04 13:00:16 +0100. Names the stable-branch fixes and says Ubuntu and Ubuntu Pro packages are being released. Not a package that `apt upgrade` has installed.
- [DLA-4880-1 tracker entry][dla] — bookworm `apt` 2.6.2. The LTS announcement URL did not return the advisory text when checked.
- [Ubuntu CVE-2026-109518][ubuntu] — CVSS 4.0 7.7 High, priority High, published 2026-11-04. All listed releases Vulnerable. States the retries and redirect conditions.
- [CVE-2026-109518][cve] — the identifier both vendors use.
- [CISA KEV JSON feed][kev] — catalog 2026.11.03, not listed.

[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00526.html
[tracker]: https://security-tracker.debian.org/tracker/CVE-2026-109518
[dla]: https://security-tracker.debian.org/tracker/DLA-4880-1
[ubuntu]: https://ubuntu.com/security/CVE-2026-109518
[deity]: https://lists.debian.org/deity/2026/11/msg00005.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-109518
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
