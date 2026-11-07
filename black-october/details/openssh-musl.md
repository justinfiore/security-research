# OpenSSH: password login on musl accepts any long password

**Last updated:** 2026-11-07 (America/New_York)

[Back to OpenSSH summary](../black-october-2026.md#openssh-password-login-on-musl-accepts-any-long-password) · [Changelog](../../CHANGELOG.md)

Vulnerability Info Site: [sshhole.com](https://sshhole.com/)

OpenSSH calls the workaround in 10.6p2 a **critical** security fix. **MITRE rates [CVE-2026-123158](https://www.cve.org/CVERecord?id=CVE-2026-123158) CVSS 3.1 8.1 High** (`AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`), published 2026-11-05 15:46:26 UTC. OpenSSH's release notes and Alpine's advisory still say no CVE was assigned. On Linux built with musl, when sshd checks passwords itself instead of through PAM, an account whose password field is `*` accepts any password of 257 to 1024 bytes. The attacker needs the account name, a reachable SSH port, and at least one other local account with a `$5$` or `$6$` password hash. Alpine's `openssh-server` package is built without PAM, and password logins are on by default. glibc Linux, OpenBSD, and Dropbear are not affected. The record says the password is "between 256 and 1024 characters" and that every version before 10.6p2 is affected. OpenSSH and Alpine say 257 to 1024 bytes, and the Alpine backports fix older version numbers.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-06). Previdian reports honeypot logins, not a compromised customer system. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Containers and other musl systems](#containers-and-other-musl-systems)
- [Checking a host](#checking-a-host)
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
| Honeypot logins | 2026-11-06; clock time not on the page | Previdian. First attempt less than nine hours after the CVE record. Not a KEV listing. [Help Net Security][hns] [Previdian][prev] |
| **Last updated** | **2026-11-07 (America/New_York)** | Added container, distribution, and check guidance. The fix is unchanged. |

## Detection

All of the following have to be true. A host that fails any one of them is outside this flaw.

1. **sshd is OpenSSH, built against musl, and it checks passwords itself.** Alpine's `openssh-server` package is built without PAM. `openssh-server-pam` with `UsePAM yes` is not affected; the same package with `UsePAM no` is. A build configured `--with-pam` and then run with `UsePAM no` is also affected: Damien Miller confirmed that reply. glibc distributions (Debian, Ubuntu, Fedora, and the like), OpenBSD, and other non-Linux systems are not affected. Dropbear is not affected. OpenWrt uses Dropbear unless an administrator installed the OpenSSH server.
2. **`PasswordAuthentication` is `yes`.** That is the OpenSSH default. Cloud images configured through cloud-init write `PasswordAuthentication no` and are not affected. A container that does not run sshd is not affected.
3. **Some account has `*` in its password field.** On Alpine that includes `root` (shipped as `root:*` since about 3.16), a key-only user from `adduser` without a password or from `usermod -p '*'`, a directory user reached through musl-nscd, and the `alpine` user on official tiny-cloud images. `PermitRootLogin prohibit-password`, which is the default, keeps root itself out of a password login. An account locked with `!` (`user:!`) cannot log in with a password or a key, and is not the target.
4. **Some other local account has a `$5$` or `$6$` password hash.** One such account is enough. A machine where no account has a `$`-style hash is not affected. The tiny-cloud images (qcow2, VHD, and AMI) from **3.18.11 through 3.24.3** ship the `alpine` user with `*` and passwordless `doas`. They are safe on first boot and become reachable as soon as any `$6$` hash exists, for example a console password or user-data `hashed_passwd`.

The researcher names Alpine, OpenWrt, Buildroot, and Yocto as the musl systems to check. A Buildroot or Yocto image that embeds OpenSSH without PAM is in the same condition; those projects had not published a fixed release when this was written.

Do not probe by sending a 257-byte password. That is the exploit, and a success is a login. The checks below stop at the conditions.

## Containers and other musl systems

An Alpine base is not enough. The system has to run OpenSSH sshd, with password logins on, and with a real `$5$` or `$6$` hash somewhere. Alpine as a VM is uncommon. Almost all Alpine in the wild is a container base. The machines that do run it are routers and appliances (OpenWrt, Buildroot, Yocto), small VPS boxes, and the official cloud images. Vultr and Hetzner offer Alpine next to Ubuntu and Debian. They do not make it the default. AWS Marketplace listings exist mostly from small vendors rather than Amazon. A Vagrant box for Alpine 3.22 showed on the order of a couple thousand downloads in total when checked on 2026-11-07, against the volume of an Ubuntu box. That count will move. It is a scale marker, not a census.

### Distributions that are not musl

These use glibc, and OpenSSH on them authenticates through PAM. They are outside this flaw.

- **Linux Mint**, including LMDE. Mint is Ubuntu LTS. LMDE is Debian stable. Current Mint tracks glibc 2.39.
- **Amazon Linux 2** ships glibc 2.26, and **Amazon Linux 2023** ships glibc 2.34. That covers the AMIs and the `amazonlinux` container images.
- **Bottlerocket**, the other AWS-built host OS, links against glibc. Its SDK can cross-compile against musl. The OS itself does not use it.
- Debian, Ubuntu, Fedora, RHEL, UBI, and Photon, as already noted.

### Containers

Official `alpine` images do not ship sshd. `alpine`, `alpine:3`, `alpine:3.24`, and the other official tags are a miniroot with musl, BusyBox, and the apk index, about 5–8 MB. There is no `openssh` package. Alpine's advisory lists "Docker and other container users that do not run sshd" as not affected. A later Dockerfile line has to run `apk add openssh` or `apk add openssh-server`, and something has to start sshd.

sshd inside an app container is uncommon, and it is deliberate when it is there. `docker exec` replaced it for debugging. What remains is images whose product is SSH: git-over-SSH and SFTP. Those images publish port 22 on purpose.

Images checked on 2026-11-07 that are not an Alpine sshd, even where the base is Alpine:

| Image | Base | sshd? |
|---|---|---|
| `ghcr.io/emissary-ingress/emissary` 4.x | Distroless Debian | No. 3.x was Alpine plus a bundled glibc (`frolvlad/alpine-glibc`) and also has no sshd. |
| `docker.elastic.co/beats/filebeat` | Red Hat UBI 10 Minimal. Older tags were CentOS 7. The `-wolfi` tag is Wolfi, which is glibc, not musl. | No. |
| `quay.io/strimzi/operator`, `quay.io/strimzi/kafka` | UBI 9 | No. |
| `apache/kafka`, `apache/kafka-native` | Alpine | No. The Dockerfile adds a JRE, bash, and `gcompat`, not openssh. |
| `confluentinc/cp-kafka`, `confluentinc/cp-kafka-connect` | UBI 9. Older tags were UBI 8. | No. |
| `rabbitmq`, including the `-alpine` tag | Debian or Ubuntu for the default tag. The `-alpine` tag is Alpine. Its final `apk add` is `su-exec`, `bash`, `procps`, and `tzdata`. | No. |
| `bitnami/rabbitmq`, Bitnami Kafka | Debian (`bitnami/minideb`) for the older free images. Current Secure Images are Photon, which is glibc. | No. |

Public images that exist to run sshd on Alpine are the ones to check. They are in scope only when password authentication is on, the account layout matches, and the image was built before the fixed Alpine package.

| Image | What it does | This bug |
|---|---|---|
| `lscr.io/linuxserver/openssh-server` | Alpine 3.24. Installs `openssh-server-pam` and sets `PasswordAuthentication no`. Password auth is opt-in through `PASSWORD_ACCESS`. | Not by default. A container started with password access needs `UsePAM` checked. `UsePAM yes` stays outside the flaw. |
| `hermsi/alpine-sshd` | Alpine, rebuilt weekly. Root password login is a documented mode (`ROOT_PASSWORD`). | In scope when that mode is on and the pulled tag predates the fixed package. A weekly rebuild picks up Alpine updates. An old tag does not. |
| `sickp/alpine-sshd` | Last published 2018. Root password is `root`. OpenSSH 7.5 on Alpine 3.7. | Frozen on an Alpine older than the 3.16 `root:*` layout. Nobody is shipping a fix. Treat a copy that is still running as unmaintained SSH on the internet, not as a clean yes or no on this CVE. |
| `atmoz/sftp:alpine` | Installs `openssh-server-pam` and symlinks `sshd.pam` to `sshd`. Users are created with real passwords. The default tag is Debian. | The Alpine tag uses the PAM package. Confirm `UsePAM yes` in a running container before calling it clean. |
| `panubo/sshd` (`quay.io/panubo/sshd`) | Password auth is off unless `SSH_ENABLE_PASSWORD_AUTH=true`. | In scope only when password auth is turned on and the build is the non-PAM package from before the fix. |
| `devdotnetorg/openssh-server`, Alpine tags 3.15–3.20 | Password authentication is a documented feature. Last push was more than two years ago. | The Alpine tags are in scope if they run non-PAM sshd with password logins. The Ubuntu and Debian tags of the same repo are glibc and are not. |
| `praqma/alpine-sshd` | Installs `openssh` and forces `PasswordAuthentication no`. | That setting closes the hole. |

### A git forge image

The official Forgejo root image, `codeberg.org/forgejo/forgejo`, is the shape this bug is about, and a stock container still fails the last condition. The official Gitea image is built the same way.

- The root image is Alpine. It installs the `openssh` package, which pulls in `openssh-server` built without PAM, and s6 starts `/usr/sbin/sshd`.
- The image locks the `git` user with `git:*`. That is the `*` account.
- The accounts in the container are `root`, shipped locked, and `git`. The forge's own user passwords live in its database, and SSH users authenticate with keys in `authorized_keys`. A stock container has no `$5$` or `$6$` hash, so a long password does not get in. It becomes exposed only if someone later sets a real password hash inside that container.
- The `-rootless` tag installs `openssh-client` only and serves git over Forgejo's built-in Go SSH server. That server is not OpenSSH and is not this bug.

The Dockerfile says `apk add openssh` with no version pin, so a newly built copy of an existing tag picks up Alpine's fixed package. Pulling a tag you already have does nothing until the image was rebuilt after 2026-11-05. Compare `apk info -v openssh` inside the running container to the [package table](#remediation). On Alpine 3.24 the fixed package is `10.3_p1-r2`. On 3.23 it is `10.2_p1-r1`.

Stopping the container does not fix an old image. The image already pulled keeps the old sshd until a newly built one is pulled. If the package is still old, turn password logins off. A forge's sshd is there for git, and git clients use keys:

```sh
docker exec CONTAINER sh -c 'mkdir -p /etc/ssh/sshd_config.d && printf "PasswordAuthentication no\n" > /etc/ssh/sshd_config.d/00-no-passwords.conf'
docker restart CONTAINER
```

That file lives in the container's writable layer, not in the data volume, so it disappears when the container is recreated. The pull is the fix that stays.

## Checking a host

### From outside

This shows whether anything is listening and whether that server offers password login. It does not show musl, PAM, the password field, or another account's hash. A banner that says `Ubuntu` or `Debian` is glibc and is not this bug. A bare `OpenSSH_10.2` or `OpenSSH_10.0` is the shape of an Alpine package, but the banner does not carry the Alpine `-r` revision, so it cannot prove the package is the fixed one.

```sh
ssh -v -o BatchMode=yes -o PreferredAuthentications=none -p 22 user@host
```

`Permission denied (publickey)` means passwords are off, and the bug has nothing to submit. `Permission denied (publickey,password)` means passwords are still offered, and the inside check below is what shows whether any account has a real hash. Try the port the service actually publishes. Git and SFTP containers are often mapped to 2222, or to 222, rather than 22.

### On the machine, or inside a container

`ldd` is not always installed. Any one of these separates musl from glibc:

```sh
ldd --version 2>&1 | head -1          # "musl libc" vs "GNU libc"
ls /lib/ld-musl-*.so* /lib/libc.musl* 2>/dev/null
getconf GNU_LIBC_VERSION              # prints a version on glibc; fails on musl
```

Then the sshd side, and the two password-field lists:

```sh
apk info -e openssh-server            # Alpine package without PAM
apk info -e openssh-server-pam        # PAM build; safe only if UsePAM is yes
sshd -T | grep -i -E '^(passwordauthentication|usepam|permitrootlogin) '
awk -F: '$2 == "*" { print $1 " has *" }' /etc/shadow
awk -F: '$2 ~ /^\$[56]\$/ { print $1 " has a real hash" }' /etc/shadow
```

`sshd -T` prints the setting that is actually in force, which is what the [verification](#verification) section compares. The second `awk` is the condition that decides it. If it prints nothing, no account has a real hash and the bug cannot fire, even when everything above it looks bad.

For a container, run the same reads with `docker exec`. That needs the Docker socket on the host, and it only sees a container that is running and still has a shell. A distroless image with no shell fails the exec. That failure is not a finding. For an image you have not started, `docker image history --no-trunc IMAGE | grep -Ei 'openssh|sshd'` shows whether a layer installed it. `openssh-client` alone is the client. It does not run sshd.

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
- Previdian says one honeypot running Alpine and OpenSSH accepted a login and then ran `id`, `uname`, and `hostname` in a non-interactive session. That is a honeypot, not a customer system. The source address Help Net Security and The Hacker News quote is `89.116.89.18`. Previdian's public page does not print that address, and its counts do not match the interview: the page, read again on 2026-11-06, says 7 attempts from 4 addresses in CH, IR, JP, and SG, while the interview says 8 attempts from that one address. The same page still says an attempt is not a successful login. A log line from that address is a lead. It is not, by itself, this flaw.

## Sources

- [Portable OpenSSH 10.6p2 release notes][rel] — released 2026-11-05. "A critical security workaround" for Linux with musl and PAM disabled. Reported by Özgün Kültekin of Wakefield. OpenSSH says the root cause is outside sshd. No CVE.
- [Damien Miller, release announcement][miller] — 2026-11-05 09:03 UTC. Set `PasswordAuthentication=no` or disable SSH immediately on musl without PAM. Not affected: non-Linux, Linux/glibc, and Linux that uses PAM for password authentication. A later reply: a build with PAM that then sets `UsePAM no` is affected. He learned of the bug the day before.
- [Alpine Linux security advisory][alpine] — 2026-11-05. The four conditions, the account list, the package table back to 3.16, the tiny-cloud note (3.18.11 through 3.24.3), and the log line to look for. No CVE at the time of writing.
- [Alpine 3.21.10, 3.22.8, 3.23.8 and 3.24.4][alpine-rel] — 2026-11-05. The point releases that contain the fixed package. The same post fixes an apk-tools crash, which is a separate issue.
- [Özgün Kültekin, sshhole.com][sshhole] — the conditions, the 257-to-1024-byte password, and the named musl systems (Alpine, OpenWrt, Buildroot, Yocto). glibc, PAM, Dropbear, and OpenBSD are not affected.
- [Rich Felker, musl list][musl] — 2026-11-05 10:07 EST. OpenSSH before 10.6p2 on musl, `UsePAM=no` and `PasswordAuthentication=yes`. Dropbear is not affected. He does not treat it as a musl bug.
- [openwrt/packages#31158][openwrt] — merged 2026-11-05 into the 25.12 branch. `openssh` 10.6_p2. This is the optional OpenSSH package, not Dropbear.
- [The Hacker News][thn] — 2026-11-05. Reports that no attacks using the flaw have been reported, and that no CVE had been assigned that day. MITRE published the CVE later the same day.
- [Help Net Security][hns] — 2026-11-06. Ryan Dewhurst of Previdian: the first attempt arrived less than nine hours after the CVE record, and a honeypot running Alpine and OpenSSH accepted a login as root. Eight attempts, all from `89.116.89.18`. The commands were `id`, `uname`, and `hostname`.
- [The Hacker News, exploitation][thn2] — 2026-11-06. The same Dewhurst statement. It is not a CISA KEV listing.
- [Previdian CVE-2026-123158][prev] — reread 2026-11-07. The public page says 14 attempts, 9 addresses, and 3 sensors, first and last observed 2026-11-06, in CH, DK, IR, JP, NL, NO, SG, and US. The chart says updated 2026-11-07. It still says an attempt is not a successful login, and it still does not print the source address. That count disagrees with the interview's eight attempts from one address. Not in CISA KEV.
- [CVE-2026-123158][cve] — MITRE, published 2026-11-05 15:46:26 UTC. CVSS 3.1 8.1 High. Affected from 0 before 10.6p2 on Linux. The description says 256 to 1024 characters; OpenSSH and Alpine say 257 to 1024 bytes.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-06).

[rel]: https://www.openssh.com/txt/release-10.6p2
[miller]: https://hachyderm.io/@damienmiller/117563026759098135
[alpine]: https://alpinelinux.org/posts/2026-11-05-openssh-password-authentication-bypass/
[alpine-rel]: https://alpinelinux.org/posts/alpine-3.21.10-3.22.8-3.23.8-3.24.4-released/
[sshhole]: https://sshhole.com/
[musl]: https://www.openwall.com/lists/musl/2026/11/05/4
[openwrt]: https://github.com/openwrt/packages/pull/31158
[thn]: https://thehackernews.com/2026/11/openssh-issues-emergency-fix-for-flaw.html
[thn2]: https://thehackernews.com/2026/11/hackers-exploited-openssh-sshole-flaw.html
[hns]: https://www.helpnetsecurity.com/2026/11/06/openssh-sshole-cve-2026-123158-exploitation
[prev]: https://previdian.com/CVE-2026-123158
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123158
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
