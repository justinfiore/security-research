# pam-mysql: a passwordless account accepts any password

**Last updated:** 2026-11-20 (America/New_York)

[Main pam-mysql summary](../black-october-2026.md#pam-mysql-a-passwordless-account-accepts-any-password) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

pam-mysql (`libpam-mysql`) is a PAM module that checks a password against a MySQL or MariaDB table. Mail, FTP, and web panels use it so `sshd` and other services can authenticate accounts that live in a database.

[CVE-2026-124749](https://www.cve.org/CVERecord?id=CVE-2026-124749) inverts the `PAM_DISALLOW_NULL_AUTHTOK` flag at both `pam_sm_authenticate` call sites. An application that asks PAM to refuse a passwordless account gets the permissive branch instead. On a stock `sshd`, `PermitEmptyPasswords` is `no`, and OpenSSH sets that flag exactly then. A network client with no account authenticates as any user whose stored password column is SQL NULL, and the typed password is never compared. Setting `PermitEmptyPasswords yes` hides this one path and opens OpenSSH's own empty-password path. It is not a workaround.

The researcher, Andrey Vasilevsky, scores it **CVSS 3.1 9.8** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`) and says a reading that prices the schema precondition into attack complexity gives 8.1. The CVE record is still reserved, so there is no CNA score. NVD has not scored it. Red Hat assigned the identifier and has published no page. On the 1.0 line an empty stored password takes the same branch, so the schema precondition largely disappears there and the 9.8 reading is the one that fits.

On 0.8.x the exploitable row is a nullable password column. On the 1.0 betas the guard is `if (row[0] && row0len)`, so an empty string takes the same inverted branch. A `NOT NULL DEFAULT ''` column, which is what a careful schema uses, is the exposed one on 1.0 and the safe one on 0.8.x. Every released version carries the defect, including the 1.0.0 betas. Upstream's newest tag is still **1.0.0-beta3**.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-20). The researcher published measurements against a real `sshd` and did not report use against someone else's server. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Found and reproduced | 2026-10-23 | On Debian trixie. [oss-security][oss] |
| Reported privately | 2026-10-24 | To upstream and to Debian. |
| Upstream confirmed | 2026-10-26 | Nigel Cunningham approved a fix and held the commits. |
| CVE assigned | 2026-11-09 | Red Hat assigned CVE-2026-124749. The record is still reserved. |
| Debian trixie upload | 2026-11-17 | Reached security-master before the embargo lift. |
| **Public announcement** | **2026-11-19 14:00 UTC** | Embargo lift. Upstream pushed to master at 16:37 UTC. [oss-security][oss] |
| Debian trixie advisory | 2026-11-19 20:18:29 UTC | DSA-6643-1, `pam-mysql` 0.8.2-2.1+deb13u1. [DSA-6643-1][dsa] |
| Debian bookworm advisory | 2026-11-19 22:25:05 UTC | DLA-4919-1, `pam-mysql` 0.8.2-2+deb12u1. [DLA-4919-1][dla] |
| **Last updated** | **2026-11-20 (America/New_York)** | New item. Install the Debian package, or stop using a NULL password row. |

## Detection

This reads the package and the database. It does not attempt a login.

1. See whether the module is installed:

```sh
dpkg -l pam-mysql libpam-mysql 2>/dev/null
rpm -q pam_mysql 2>/dev/null
```

No package means this module is not how that host authenticates. A service that never names `pam_mysql.so` in `/etc/pam.d` or `/etc/pam.d` fragments is not using it, even when the package is present.

2. Compare the installed version with the table below. A version string alone is not enough on Debian: the tracker and the advisory disagree about bookworm, and the advisory is the one that shipped the fix.

3. Find passwordless rows in the table the module reads. The column name is whatever `passwdcolumn` is set to; `password` is the usual one:

```sql
SELECT username FROM users WHERE password IS NULL OR password = '';
```

On 0.8.x a NULL row is the exposed one. On a 1.0 beta an empty string is exposed too. A row that has a hash is outside this flaw.

## Remediation

| Line | Fixed package | Source |
|---|---|---|
| Debian 13 trixie | `pam-mysql` 0.8.2-2.1+deb13u1 | [DSA-6643-1][dsa] |
| Debian 12 bookworm | `pam-mysql` 0.8.2-2+deb12u1 | [DLA-4919-1][dla] |
| Debian testing and unstable | No package. 0.8.2-3 is still vulnerable. | [Debian tracker][deb] |
| Upstream 1.0 line | No tag. Commits `6e2c52eb` and `46175520` are on master. The newest tag is 1.0.0-beta3. | [oss-security][oss] |
| Upstream 0.8 branch | Not updated. Its head still dates from 2021. | [oss-security][oss] |
| Ubuntu | No page. The researcher's survey lists 18.04, 20.04, and 22.04 as shipping 0.8.x. | [Ubuntu search][ubu] |
| Fedora, Nix, Mageia, Rosa, ALT | Ship a 1.0 beta. No fixed release. | [oss-security][oss] |

1. On Debian trixie, install `pam-mysql` **0.8.2-2.1+deb13u1** or later. On Debian bookworm, install **0.8.2-2+deb12u1** or later. The package is a shared library; a long-running daemon keeps the copy it loaded, so restart `sshd` and every other service that loaded it.
2. Do not set `PermitEmptyPasswords yes`. OpenSSH sets the flag that this bug inverts only when that option is `no`, which is the default. Turning it on makes this module deny a NULL row and turns off OpenSSH's own empty-password check.
3. Delete credential-less rows, then make the password column `NOT NULL` with no empty-string default. On 0.8.x that column shape is outside the flaw. On a 1.0 beta it is the exposed one, so the package still has to be fixed there.
4. Leave `nullok` off. The Debian update adds it, default off. Turning it on restores NULL-password authentication unless the caller sets the flag. `pam_unix` uses the same name for the same idea.
5. Debian testing and unstable, Ubuntu, and the distributions that ship a 1.0 beta have no fixed package. Until one exists, the rows are the mitigation. Do not build master and call it a release: the two commits are the fix, and the tree carries everything else that has landed since 1.0.0-beta3.

## Verification

- `dpkg -l pam-mysql` shows 0.8.2-2.1+deb13u1 or later on trixie, or 0.8.2-2+deb12u1 or later on bookworm, and `sshd` was restarted after the install.
- A NULL password row no longer exists in the table the module reads, or that account is no longer reachable through this module.
- Do not try a login against a NULL row on a production host. The researcher's measurement shows that login succeeds on an unfixed build.

## Compromise response

OpenSSH logs a bypass and a real login the same way. Both lines read `Accepted password for <user>`. Nothing in the line marks which one it was.

The discriminator is the database. An accepted password login for an account whose stored password was NULL or empty could not have been a real one, because no password would have matched. Start from the credential-less rows and correlate those names with `Accepted password for` lines. A column that was filled in later hides this, so a backup or the binary log from the period is the source, not today's table.

The module's own audit table is off by default (`log.enabled` defaults to 0). When it is on, the failure string is misspelled `AUTHENTICATION FALURE`, so a query for `FAILURE` misses those rows. The researcher treats a lone success with no preceding failure as a weak hint only.

Expire sessions for any account that shows such a login, and set a real password. The package update does not end a session that already exists.

## Sources

- [oss-security, CVE-2026-124749][oss] — Andrey Vasilevsky, posted 2026-11-19. The defect, the 9.8 and 8.1 readings, the measured `sshd` results, the shipping fix, and the distribution survey.
- [DSA-6643-1][dsa] — Salvatore Bonaccorso, 2026-11-19 20:18:29 UTC. Debian 13 trixie, `pam-mysql` 0.8.2-2.1+deb13u1.
- [DLA-4919-1][dla] — Emilio Pozuelo Monfort, 2026-11-19 22:25:05 UTC. Debian 12 bookworm, `pam-mysql` 0.8.2-2+deb12u1.
- [Debian security tracker][deb] — read 2026-11-20. trixie (security) fixed at 0.8.2-2.1+deb13u1. bookworm and bookworm (security) both listed vulnerable, including at 0.8.2-2+deb12u1. forky and sid vulnerable at 0.8.2-3. The bookworm row disagrees with DLA-4919-1.
- [CVE-2026-124749](https://www.cve.org/CVERecord?id=CVE-2026-124749) — reserved. No description and no score.
- [Ubuntu CVE search][ubu] — searched 2026-11-20. No page for CVE-2026-124749.
- [Red Hat CVE API](https://access.redhat.com/hydra/rest/securitydata/cve/CVE-2026-124749.json) — 404 on 2026-11-20. No published score.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-20. CVE-2026-124749 is not listed.

[oss]: https://www.openwall.com/lists/oss-security/2026/11/19/7
[dsa]: https://www.debian.org/security/2026/dsa-6643
[dla]: https://lists.debian.org/debian-lts-announce/2026/11/msg00045.html
[deb]: https://security-tracker.debian.org/tracker/CVE-2026-124749
[ubu]: https://ubuntu.com/security/cves?q=CVE-2026-124749
