# OpenSSH: password login on musl accepts any long password

**Last updated:** 2026-11-05 (America/New_York)

[Back to OpenSSH summary](../black-october-2026.md#openssh-password-login-on-musl-accepts-any-long-password) · [Changelog](../../CHANGELOG.md)

Vulnerability Info Site: [sshhole.com](https://sshhole.com/)

OpenSSH calls the workaround in 10.6p2 a **critical** security fix. **MITRE rates [CVE-2026-123158](https://www.cve.org/CVERecord?id=CVE-2026-123158) CVSS 3.1 8.1 High** (`AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`), published 2026-11-05 15:46:26 UTC. OpenSSH's release notes and Alpine's advisory still say no CVE was assigned. On Linux built with musl, when sshd checks passwords itself instead of through PAM, an account whose password field is `*` accepts any password of 257 to 1024 bytes. The attacker needs the account name, a reachable SSH port, and at least one other local account with a `$5$` or `$6$` password hash. Alpine's `openssh-server` package is built without PAM, and password logins are on by default. glibc Linux, OpenBSD, and Dropbear are not affected. The record says the password is "between 256 and 1024 characters" and that every version before 10.6p2 is affected. OpenSSH and Alpine say 257 to 1024 bytes, and the Alpine backports fix older version numbers.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). OpenSSH and The Hacker News report no attacks using the flaw. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| OpenSSH learned of the bug | 2026-11-04 | Damien Miller says the project learned of it the day before the release. |
| Public announcement and fix | 2026-11-05 09:03 UTC | Portable OpenSSH **10.6p2**. Miller's [release post][miller]. |
| Alpine packages | 2026-11-05; time/TZ unknown | [Advisory][alpine] and [point releases][alpine-rel] 3.21.10, 3.22.8, 3.23.8, 3.24.4. Backports through 3.16. |
| musl advisory | 2026-11-05 10:07 EST (UTC−05:00) | Rich Felker: OpenSSH before 10.6p2 on musl, with `UsePAM=no` and `PasswordAuthentication=yes`. |
| OpenWrt package | 2026-11-05 14:26 UTC | [openwrt/packages#31158][openwrt] merged into the 25.12 branch: `openssh` 10.6_p2. OpenWrt's default SSH server is Dropbear, which is not affected. |
| CVE record | 2026-11-05 15:46:26 UTC | MITRE, [CVE-2026-123158][cve], CVSS 3.1 8.1. Updated 17:18:17 UTC the same day. OpenSSH's notes still do not name it. |
| CISA ADP | 2026-11-06 04:56:35 UTC | SSVC Exploitation `poc`. That is a proof-of-concept label, not a report of attacks and not a KEV listing. The description, the score, and the range are unchanged. |
| **Last updated** | **2026-11-05 (America/New_York)** | CVE assigned. The fix is unchanged. |

## Detection

All of the following have to be true. A host that fails any one of them is outside this flaw.

1. **sshd is OpenSSH, built against musl, and it checks passwords itself.** Alpine's `openssh-server` package is built without PAM. `openssh-server-pam` with `UsePAM yes` is not affected; the same package with `UsePAM no` is. A build configured `--with-pam` and then run with `UsePAM no` is also affected: Damien Miller confirmed that reply. glibc distributions (Debian, Ubuntu, Fedora, and the like), OpenBSD, and other non-Linux systems are not affected. Dropbear is not affected. OpenWrt uses Dropbear unless an administrator installed the OpenSSH server.
2. **`PasswordAuthentication` is `yes`.** That is the OpenSSH default. Cloud images configured through cloud-init write `PasswordAuthentication no` and are not affected. A container that does not run sshd is not affected.
3. **Some account has `*` in its password field.** On Alpine that includes `root` (shipped as `root:*` since about 3.16), a key-only user from `adduser` without a password or from `usermod -p '*'`, a directory user reached through musl-nscd, and the `alpine` user on official tiny-cloud images. `PermitRootLogin prohibit-password`, which is the default, keeps root itself out of a password login. An account locked with `!` (`user:!`) cannot log in with a password or a key, and is not the target.
4. **Some other local account has a `$5$` or `$6$` password hash.** One such account is enough. A machine where no account has a `$`-style hash is not affected. The tiny-cloud images (qcow2, VHD, and AMI) from **3.18.11 through 3.24.3** ship the `alpine` user with `*` and passwordless `doas`. They are safe on first boot and become reachable as soon as any `$6$` hash exists, for example a console password or user-data `hashed_passwd`.

The researcher names Alpine, OpenWrt, Buildroot, and Yocto as the musl systems to check. A Buildroot or Yocto image that embeds OpenSSH without PAM is in the same condition; those projects had not published a fixed release when this was written.

## Remediation

1. **If you cannot update yet, turn password logins off and restart sshd.** Miller's instruction is to do that immediately, or to disable SSH, on a musl system that does not use PAM. Confirm a key login works first, and keep the current session open until a new login succeeds. Alpine's default `sshd_config` reads `/etc/ssh/sshd_config.d/` from 3.19 onward; 3.18 and older ignore that directory, so change `/etc/ssh/sshd_config` itself on those releases. The [Alpine advisory][alpine] prints the commands, including the check `sshd -T | grep -i passwordauthentication`, which should print `passwordauthentication no`.
2. **On Alpine, upgrade and restart.** `apk upgrade -U -a` and then `rc-service sshd restart`. Upgrading the package does not replace a running sshd. The fixed package versions are:

   | Branch | Fixed `openssh` |
   |---|---|
   | edge | 10.6_p2-r0 |
   | 3.24 | 10.3_p1-r2 |
   | 3.23 | 10.2_p1-r1 |
   | 3.22 | 10.0_p1-r11 |
   | 3.21 | 9.9_p2-r1 |
   | 3.20 | 9.7_p1-r6 |
   | 3.19 | 9.6_p1-r3 |
   | 3.18 | 9.3_p2-r4 |
   | 3.17 | 9.1_p1-r7 |
   | 3.16 | 9.0_p1-r6 |

   3.21 reached end of support on 2026-11-01. Alpine still published a fixed package for it and for 3.16 through 3.20. The point releases that contain the package are 3.21.10, 3.22.8, 3.23.8, and 3.24.4. Images built from those releases include the fix; an instance built from an earlier point release does not, so update it in place.
3. **A source build** takes portable OpenSSH **10.6p2**. Older stable branches do not get that version number; they need the distribution's backport, which is what the Alpine table above is.
4. **OpenWrt** is affected only where the OpenSSH server package is installed. The 25.12 branch update to `openssh` 10.6_p2 was merged on 2026-11-05. Installing that package and restarting the service is the fix there. Dropbear, the default, needs nothing for this flaw.
5. Turning password logins off does not end a session that already logged in.

## Verification

- `apk info -v openssh` is at or above the branch's fixed package, or `ssh -V` reports OpenSSH **10.6p2** or later on a source build. The package version on a backport branch stays below 10.6; compare it to the table, not to 10.6p2.
- After the upgrade, the sshd process restarted. A package that is new while the old daemon is still the running one is not the fix.
- `sshd -T | grep -i passwordauthentication` prints the setting that is actually in force. `passwordauthentication no` closes the hole even on an old package.
- A glibc host, an `openssh-server-pam` host with `UsePAM yes`, and a Dropbear host are outside this check.

## Compromise response

- Alpine says to look in `/var/log/messages` for sshd lines reading `Accepted password for` an account that has no password (`alpine`, `root`, or a key-only user). Review `doas` use and accounts, authorized keys, and files you cannot account for.
- If that line is present, or you cannot rule a login out, treat the machine as compromised. The upgrade does not remove a key an attacker wrote.
- On a tiny-cloud image, a login as `alpine` can become root through passwordless `doas`. Replacing the image is the clean outcome when that login cannot be ruled out.

## Sources

- [Portable OpenSSH 10.6p2 release notes][rel] — released 2026-11-05. "A critical security workaround" for Linux with musl and PAM disabled. Reported by Özgün Kültekin of Wakefield. OpenSSH says the root cause is outside sshd. No CVE.
- [Damien Miller, release announcement][miller] — 2026-11-05 09:03 UTC. Set `PasswordAuthentication=no` or disable SSH immediately on musl without PAM. Not affected: non-Linux, Linux/glibc, and Linux that uses PAM for password authentication. A later reply: a build with PAM that then sets `UsePAM no` is affected. He learned of the bug the day before.
- [Alpine Linux security advisory][alpine] — 2026-11-05. The four conditions, the account list, the package table back to 3.16, the tiny-cloud note (3.18.11 through 3.24.3), and the log line to look for. No CVE at the time of writing.
- [Alpine 3.21.10, 3.22.8, 3.23.8 and 3.24.4][alpine-rel] — 2026-11-05. The point releases that contain the fixed package. The same post fixes an apk-tools crash, which is a separate issue.
- [Özgün Kültekin, sshhole.com][sshhole] — the conditions, the 257-to-1024-byte password, and the named musl systems (Alpine, OpenWrt, Buildroot, Yocto). glibc, PAM, Dropbear, and OpenBSD are not affected.
- [Rich Felker, musl list][musl] — 2026-11-05 10:07 EST. OpenSSH before 10.6p2 on musl, `UsePAM=no` and `PasswordAuthentication=yes`. Dropbear is not affected. He does not treat it as a musl bug.
- [openwrt/packages#31158][openwrt] — merged 2026-11-05 into the 25.12 branch. `openssh` 10.6_p2. This is the optional OpenSSH package, not Dropbear.
- [The Hacker News][thn] — 2026-11-05. Reports that no attacks using the flaw have been reported, and that no CVE had been assigned that day. MITRE published the CVE later the same day.
- [CVE-2026-123158][cve] — MITRE, published 2026-11-05 15:46:26 UTC. CVSS 3.1 8.1 High. Affected from 0 before 10.6p2 on Linux. The description says 256 to 1024 characters; OpenSSH and Alpine say 257 to 1024 bytes.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-05).

[rel]: https://www.openssh.com/txt/release-10.6p2
[miller]: https://hachyderm.io/@damienmiller/117563026759098135
[alpine]: https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/
[alpine-rel]: https://alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/
[sshhole]: https://sshhole.com/
[musl]: https://www.openwall.com/lists/musl/2026/11/05/4
[openwrt]: https://github.com/openwrt/packages/pull/31158
[thn]: https://thehackernews.com/2026/11/openssh-issues-emergency-fix-for-flaw.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123158
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
