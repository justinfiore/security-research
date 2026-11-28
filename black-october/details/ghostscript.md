# Ghostscript: Upload2Shell - a document runs commands

**Last updated:** 2026-11-28 (America/New_York)

[Main Ghostscript summary](../black-october-2026.md#ghostscript-upload2shell---a-document-runs-commands) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Vulnerability Info Site: [pwn.ai](https://pwn.ai/upload2shell)

On 2026-11-09 VulnCheck published [CVE-2026-125396](https://www.cve.org/CVERecord?id=CVE-2026-125396). VulnCheck is the CNA. It rates the flaw **CVSS 4.0 8.5 High** and **CVSS 3.1 7.8 High**. The vectors are `CVSS:4.0/AV:L/AC:L/AT:N/PR:N/UI:P/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N` and `CVSS:3.1/AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`. Both use a local attack vector. pwn.ai's write-up, dated 2026-11-17 and indexed by the CVE record on 2026-11-22, shows remote entry points that hand the document to that local interpreter. Paulos Yibelo and pwn.ai are credited as the finders. Ken Sharp is credited for the fix.

The flaw is in the `.putgstringcopy` procedure in `gs_fonts.ps`. It calls the privileged `.forceput` operator without checking operand types. A PostScript or PDF document triggers a type error, recovers `.forceput` through a custom error handler, and uses a use-after-free across save and restore to run code. pwn.ai says the use-after-free is in the Type 1 font loader and that the document uses it to turn off the state that enforces `-dSAFER`. The command then runs as the account of the process that rendered the file, not as the person who sent it.

Ghostscript before **10.08.0** is the range the record names. Artifex released 10.08.0 on 2026-09-08. The fix is commit `1484854e0c8ddfda1baa4ad4cd965b8a9790aa81`, Artifex bug 709684. A distribution package can carry that commit under an older version number.

The CNA score describes the interpreter. Whether a remote person can reach it depends on what calls Ghostscript. pwn.ai's index, updated 2026-11-18, records these confirmed paths. The case studies and the command-execution proofs are marked not published. One self-contained proof shows native memory control and does not spawn a shell.

| Path | What reached Ghostscript | What ran |
|---|---|---|
| Debian 13 CUPS, Ghostscript 10.05.1~dfsg-1+deb13u1 | An IPP Print-Job to a shared queue that asked for no login | A command on the host as `uid=7(lp)` |
| Roundcube 1.7.2 | An external sender's attachment, thumbnailed when the recipient viewed the message. No click on the attachment. The tested ImageMagick delegate was required | A command as `uid=33(www-data)`, 5 of 5 trials |
| WordPress Core | An upload by a user with `upload_files` (Author and above by default), with Imagick and Ghostscript. WordPress tracked this separately as [CVE-2026-65640](https://www.cve.org/CVERecord?id=CVE-2026-65640) and fixed it in 7.0.4 on 2026-08-12, backported through the 4.7 branch | WordPress confirmed remote code execution. The delegate ran as `uid=33` |
| Forminator 1.55.1 and Essential Addons for Elementor | A public form or registration widget that stored the upload, with no WordPress account | A command as `www-data` |
| Plesk Obsidian 18.0.79 | The Roundcube thumbnail path it ships, with Ghostscript 9.54.0 | A command as `roundcube_sysuser` in component trials. AppArmor blocked the shell in one enforced test. No deployed endpoint was tested |

The same index records MediaWiki with PdfHandler, DokuWiki, Mayan EDMS, and ResourceSpace. Google mitigated its document path on 2026-11-10. Those rows are researcher results on the builds named above, not a claim that every deployment of those products is exposed. Roundcube also restricted unsafe attachment image types under CVE-2026-114727 on 2026-10-19. That is a route closure, not a Ghostscript fix: another caller of the same library is unaffected by it.

pwn.ai does not report exploitation outside its own tests. The flaw is not in CISA KEV.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-27). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Discovery | 2026-07-27; time/TZ unknown | pwn.ai, Type 1 font loader. [Index][pwn] |
| Reported upstream | By 2026-09-02; time/TZ unknown | Artifex bug 709684. [Index][pwn] |
| Ghostscript 10.08.0 | 2026-09-08; time/TZ unknown | The upstream fix. [Release][rel] |
| Debian 13 security update | 2026-09-25 21:17:14 UTC | DSA-6516-1 ships 10.05.1~dfsg-1+deb13u2. The advisory text names CVE-2026-39919. The tracker credits this package, and the current trixie build 10.05.1~dfsg-1+deb13u3, as the fix for CVE-2026-125396. [DSA][dsa] [Tracker][deb] |
| WordPress Core fix | 2026-08-12; time/TZ unknown | 7.0.4, tracked as CVE-2026-65640. Closes WordPress's own upload path. It does not update Ghostscript. [Advisory][wp] |
| **CVE published** | **2026-11-09; time/TZ unknown** | VulnCheck. CVSS 4.0 8.5 and CVSS 3.1 7.8. [CVE][cve] |
| Public write-up | 2026-11-17; time/TZ unknown | pwn.ai. The CVE record gained the link later; NVD shows it by 2026-11-22. [Write-up][research] |
| Debian 12 security update | 2026-11-17; time/TZ unknown | DLA-4914-1. bookworm-security is 10.0.0~dfsg-11+deb12u9. [Tracker][deb] |
| **RHEL packages** | **2026-11-25; time/TZ unknown** | RHSA-2026:103517, RHSA-2026:103523, and RHSA-2026:103524. RHEL 10, 9, and 8. |
| Rocky and AlmaLinux packages | 2026-11-26; time/TZ unknown | RLSA-2026:103517, RLSA-2026:103523, and RLSA-2026:103524, and the matching ALSA errata. Same versions as Red Hat. |

## Detection

Read the Ghostscript the renderer actually loads, not a `gs` binary that happens to be first on `PATH`.

- Upstream before **10.08.0** is inside the range the record names.
- Debian 13 (trixie) is fixed at `ghostscript` **10.05.1~dfsg-1+deb13u3**. Debian 12 (bookworm) is fixed at **10.0.0~dfsg-11+deb12u9** from bookworm-security. The main bookworm repository is still 10.0.0~dfsg-11+deb12u8, which the tracker marks vulnerable. Forky and sid are fixed at 10.08.0~dfsg-2.
- Ubuntu's page, last updated 2026-11-18, marks `ghostscript` **Needs evaluation** on 26.10, 26.04 LTS, 24.04 LTS, 22.04 LTS, and the Pro releases. It names no package. Do not treat an older USN as this fix: USN-8949-1, dated 2026-10-21, does not list CVE-2026-125396.
- SUSE's page, last modified 2026-11-13, rates it important and marks SLES 15 SP7, 16.0, and 16.1 In progress, and openSUSE Leap 16.0 and 16.1 Affected. It lists `ghostscript` 9.52-150000.222.1 for SLES 15 SP7 under packages in QA, which is not a released package, and it names no security announcement. The only released line on that page is openSUSE Tumbleweed `ghostscript` 10.08.0-5.1.
- Red Hat shipped the fix on 2026-11-25. RHEL 10 is `ghostscript` **10.02.1-17.el10_3.1** ([RHSA-2026:103517](https://access.redhat.com/errata/RHSA-2026:103517)). RHEL 9 is `ghostscript` **9.54.0-20.el9_9.1** ([RHSA-2026:103523](https://access.redhat.com/errata/RHSA-2026:103523)). RHEL 8 is `ghostscript` **9.27-21.el8_10** ([RHSA-2026:103524](https://access.redhat.com/errata/RHSA-2026:103524)). Red Hat rates each Important.
- AlmaLinux shipped the Red Hat builds on 2026-11-26: AlmaLinux 10 `ghostscript` **10.02.1-17.el10_3.1** ([ALSA-2026:103517](https://errata.almalinux.org/10/ALSA-2026-103517.html)), 9 `ghostscript` **9.54.0-20.el9_9.1** ([ALSA-2026:103523](https://errata.almalinux.org/9/ALSA-2026-103523.html)), and 8 `ghostscript` **9.27-21.el8_10** ([ALSA-2026:103524](https://errata.almalinux.org/8/ALSA-2026-103524.html)). Its November 23 post had named earlier builds, 10.02.1-16.el10_2.3.alma.1, 9.54.0-19.el9_8.3.alma.1, and 9.27-20.el8_10.alma.1. Those also closed it.
- Rocky Linux shipped the same builds on 2026-11-26: Rocky Linux 10 `ghostscript` **10.02.1-17.el10_3.1** ([RLSA-2026:103517](https://errata.rockylinux.org/RLSA-2026:103517), published 2026-11-26 12:18 UTC), 9 `ghostscript` **9.54.0-20.el9_9.1** ([RLSA-2026:103523](https://errata.rockylinux.org/RLSA-2026:103523), 12:16 UTC), and 8 `ghostscript` **9.27-21.el8_10** ([RLSA-2026:103524](https://errata.rockylinux.org/RLSA-2026:103524), 06:01 UTC). Oracle Linux's ELSA-2026-103517, ELSA-2026-103523, and ELSA-2026-103524 are dated 2026-11-25.
- Amazon Linux 2027 Preview is fixed at `ghostscript` **10.08.0-1.amzn2027.0.2** ([ALAS2027-2026-379](https://alas.aws.amazon.com/AL2027/ALAS2027-2026-379.html), updated 2026-11-23). Amazon Linux 2 and Amazon Linux 2023 are still Pending Fix.

A process that embeds its own Ghostscript, or shells out to a copy outside the system package, does not move when the package does. ImageMagick's `delegates.xml` and PHP Imagick are two ways a file named `.jpg` or `.png` still reaches `gs`. Finding the library does not show that any caller is exposed, and not finding a caller does not show the library is unused.

## Remediation

1. Upgrade Ghostscript to **10.08.0 or later**, or install the distribution package the tracker marks fixed, and restart every process that had the library loaded. On Debian 13, install `ghostscript` **10.05.1~dfsg-1+deb13u3**. On Debian 12, install **10.0.0~dfsg-11+deb12u9** from bookworm-security.
2. Update WordPress to **7.0.4 or later** on the 7.0 line, or the backport on your branch through 4.7. That closes the Author upload path WordPress describes. It leaves every other caller of Ghostscript in place, including a plugin form that does not require an account.
3. A shared CUPS queue that accepts a print job with no login is one of the paths pwn.ai demonstrated. Requiring authentication on that queue blocks the unauthenticated submission. It does not fix Ghostscript.
4. On RHEL 10, Rocky Linux 10, and AlmaLinux 10, install `ghostscript` **10.02.1-17.el10_3.1**. On RHEL 9, Rocky Linux 9, and AlmaLinux 9, install **9.54.0-20.el9_9.1**. On RHEL 8, Rocky Linux 8, and AlmaLinux 8, install **9.27-21.el8_10**. Restart the workers. Oracle republishes the same errata. AlmaLinux's earlier November 23 builds also close it.
5. On Amazon Linux 2027 Preview, install `ghostscript` **10.08.0-1.amzn2027.0.2**. Amazon Linux 2 and 2023 have no package yet.
6. Ubuntu and SUSE have no released package for this CVE yet. Do not assume a Debian or RHEL version is what they shipped.

## Verification

- `gs --version`, for the binary the application runs, is **10.08.0 or later**, or the package is one of the Debian builds named above.
- The workers that render uploads, thumbnails, and print jobs were restarted after the install.
- Do not send a crafted document to test it.

## Compromise response

pwn.ai does not report exploitation outside its own tests. The upgrade does not show whether a render already ran a command. A lead is a render or a print job from outside that landed while the installed Ghostscript was still in the affected range, on a path that thumbnails, converts, or prints attacker-supplied files. The account to look at is the renderer's, such as `lp` or the web user, not the sender's.

## Sources

- [CVE-2026-125396][cve] — VulnCheck, published 2026-11-09. CVSS 4.0 8.5 and CVSS 3.1 7.8. Affected before 10.08.0. CWE-648.
- [pwn.ai, Upload2Shell][pwn] — evidence index, updated 2026-11-18. The paths, the accounts, and the statement that the case studies are not published.
- [pwn.ai, How We Hacked the Pipes][research] — Paulos Yibelo, 2026-11-17. The font-loader use-after-free and the Roundcube, WordPress, and CUPS narratives.
- [Ghostscript 10.08.0][rel] — Artifex, 2026-09-08. Commit `1484854e`.
- [Debian tracker][deb] — read 2026-11-22. trixie fixed at 10.05.1~dfsg-1+deb13u3 (DSA-6516-1). bookworm-security fixed at 10.0.0~dfsg-11+deb12u9 (DLA-4914-1). forky and sid fixed at 10.08.0~dfsg-2.
- [DSA-6516-1][dsa] — Salvatore Bonaccorso, 2026-09-25 21:17:14 UTC. The advisory text names CVE-2026-39919. The tracker is what credits the package for CVE-2026-125396.
- [Ubuntu CVE-2026-125396](https://ubuntu.com/security/CVE-2026-125396) — published 2026-11-10, last updated 2026-11-18. Priority Medium. Every listed release is Needs evaluation.
- [SUSE CVE-2026-125396](https://www.suse.com/security/cve/CVE-2026-125396.html) — last modified 2026-11-13. Important. SLES 15 SP7, 16.0, and 16.1 In progress. `ghostscript` 9.52-150000.222.1 is listed in QA for SLES 15 SP7, not released. No announcement.
- [RHSA-2026:103517](https://access.redhat.com/errata/RHSA-2026:103517), [RHSA-2026:103523](https://access.redhat.com/errata/RHSA-2026:103523), [RHSA-2026:103524](https://access.redhat.com/errata/RHSA-2026:103524) — issued 2026-11-25. RHEL 10, 9, and 8. Important. CVE-2026-125396.
- [ALSA-2026:103517](https://errata.almalinux.org/10/ALSA-2026-103517.html), [ALSA-2026:103523](https://errata.almalinux.org/9/ALSA-2026-103523.html), [ALSA-2026:103524](https://errata.almalinux.org/8/ALSA-2026-103524.html) — AlmaLinux, release date 2026-11-26. Same versions as the Red Hat errata.
- [RLSA-2026:103517](https://errata.rockylinux.org/RLSA-2026:103517), [RLSA-2026:103523](https://errata.rockylinux.org/RLSA-2026:103523), [RLSA-2026:103524](https://errata.rockylinux.org/RLSA-2026:103524) — Rocky Linux, published 2026-11-26. Same versions.
- [AlmaLinux, updated 2026-11-23](https://almalinux.org/blog/2026-11-22-upload2shell-cve-2026-125396/) — the earlier production builds: 9.27-20.el8_10.alma.1, 9.54.0-19.el9_8.3.alma.1, and 10.02.1-16.el10_2.3.alma.1.
- [ALAS2027-2026-379](https://alas.aws.amazon.com/AL2027/ALAS2027-2026-379.html) — Amazon Linux 2027 Preview, `ghostscript` 10.08.0-1.amzn2027.0.2, updated 2026-11-23. Amazon Linux 2 and 2023 remain Pending Fix.
- [WordPress CVE-2026-65640][wp] — the separate Core fix, 7.0.4 on 2026-08-12.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-27. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-125396
[pwn]: https://pwn.ai/upload2shell
[research]: https://pwn.ai/upload2shell/research.html
[rel]: https://github.com/ArtifexSoftware/ghostpdl-downloads/releases/tag/gs10080
[deb]: https://security-tracker.debian.org/tracker/CVE-2026-125396
[dsa]: https://lists.debian.org/debian-security-announce/2026/msg00429.html
[wp]: https://github.com/WordPress/wordpress-develop/security/advisories/GHSA-8vr3-7mxf-gx8w
