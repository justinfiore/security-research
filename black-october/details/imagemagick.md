# ImageMagick: stack buffer overflow when reading bzip2-compressed images

**Last updated:** 2026-10-26 (America/New_York)

[Main ImageMagick summary](../black-october-2026.md#imagemagick-stack-buffer-overflow-when-reading-bzip2-compressed-images) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-116149](https://www.cve.org/CVERecord?id=CVE-2026-116149) (GHSA-pwpf-8799-94cj) — ImageMagick maintainers (GitHub advisory) CVSS 3.1: 8.1 High (CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:H); VulnCheck (CNA) CVSS 3.1: 8.1 High (same vector) and CVSS 4.0: 7.2 High (CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:N/VI:H/VA:H/SC:N/SI:N/SA:N); Red Hat: Important, CVSS 3.1 7.8 (AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H, marked draft); NVD has not scored it; not in CISA KEV.** ImageMagick's advisory is titled "Stack Buffer Over-Write when reading bzip2 compressed images" and says: "A crafted image that uses bzip2 compression can cause a stack buffer over-write." The CVE record classifies it as a stack-based buffer overflow (CWE-121); the GitHub advisory lists CWE-125, CWE-573 and CWE-787. [GHSA][ghsa] [CNA][cve] [Red Hat][redhat]

**Affected:** ImageMagick 7 **before 7.1.2-33** and ImageMagick 6 **before 6.9.13-58**. Both fixed releases were published on 2026-10-10. [GHSA][ghsa] [CNA][cve]

**Attack conditions:** an attacker must get a crafted bzip2-compressed file read by ImageMagick, for example an uploaded avatar or attachment, a fetched remote image, or a document-conversion or thumbnail job. When ImageMagick opens an input **file** whose first bytes are the bzip2 signature `BZh`, it transparently decompresses it through libbzip2, whatever the image format inside. The fix (commit [`cf40ce9`][fix7]) is in that blob-reading path (`ReadBlob`'s bzip2 branch in `MagickCore/blob.c`), and the path exists only in builds that include the **bzlib** delegate. That code reading is this guide's analysis of the source, not a statement from the advisory. The CVSS vectors differ on the precondition: the maintainers and VulnCheck score it as network-reachable with low privileges (for example, an account that can upload), while Red Hat scores it as local with user interaction (a user opening a crafted file). [Fix commit][fix7] [blob.c at 7.1.2-33][blob]

**Worst case:** crashes or stack memory corruption in the process that decodes the image (CVE description: "overwrite stack memory during decoding, causing crashes or memory corruption"). The maintainers' and VulnCheck's vectors rate integrity and availability High; Red Hat's also rates confidentiality High. No source reviewed demonstrates code execution. Treat a stack overwrite in an internet-facing image pipeline as potentially more than a denial of service. [CNA][cve] [Red Hat][redhat]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). No exploitation or public proof of concept was reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means)

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory every ImageMagick copy](#inventory-every-imagemagick-copy)
  - [Distribution package status](#distribution-package-status)
  - [Input reachability and signals](#input-reachability-and-signals)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | The advisory and CVE record credit DavidKorczynski as reporter; no report date is published. [GHSA][ghsa] [CNA][cve] |
| Fix committed | 2026-09-29 16:29:13 UTC (ImageMagick 7, `cf40ce9`); 2026-09-29 16:28:49 UTC (ImageMagick 6, `9b4d4e0`) | Both commit messages are the GHSA-pwpf-8799-94cj URL. [IM7 commit][fix7] [IM6 commit][fix6] |
| Fixed releases 7.1.2-33 and 6.9.13-58 | 2026-10-10 13:49:53 UTC and 13:49:59 UTC | GitHub release publication times. [7.1.2-33][rel7] [6.9.13-58][rel6] |
| **Public announcement**: GitHub advisory GHSA-pwpf-8799-94cj | 2026-10-10 14:00:15 UTC | Severity High, CVSS 3.1 8.1. No CVE ID on the advisory itself. [GHSA][ghsa] |
| CVE reserved and published | Reserved 2026-10-25 12:22:53 UTC; published 2026-10-25 13:19:58 UTC | VulnCheck as CNA; the record's `datePublic` is 2026-10-10. NVD lists it as published 2026-10-25 14:16:53 (NVD API, UTC), status "Awaiting Analysis". [CVE JSON][cve] [NVD][nvd] |
| Red Hat assessment | Public date 2026-10-25 13:19:58 UTC (as recorded by Red Hat) | Important, CVSS 3.1 7.8 (draft); Bugzilla 2560428. [Red Hat][redhat] |
| CISA KEV | Not listed as of catalog 2026.10.23 (checked 2026-10-26) | [KEV JSON][kev] |

## Detection

### Inventory every ImageMagick copy

ImageMagick is often present without being an obvious dependency. Check hosts, containers, workers and CI images for:

- The command-line tools: `magick -version`, or `convert -version` / `identify -version` on ImageMagick 6. The first line shows the version, for example `Version: ImageMagick 7.1.2-33`. The `Delegates (built-in):` line shows whether **`bzlib`** is compiled in. These commands only print build information.
- Shared libraries used by language bindings: PHP **Imagick**, Python **Wand**, Ruby **RMagick** (MiniMagick shells out to the CLI), Perl **PerlMagick**, Node wrappers that call the CLI. These load the system `libMagickCore`/`libMagickWand`, so check the OS package, for example `dpkg -l 'libmagickcore*' imagemagick*` or `rpm -qa | grep -i imagemagick`.
- Products that **bundle their own copy**, such as .NET's Magick.NET, AppImage/static builds, and vendor appliances. Updating the OS package does not change a bundled copy; check each product's release notes for 7.1.2-33 or later.
- Application images built from a base image: inspect the image, not your laptop.

Compare with the fixed versions: **7.1.2-33+** (ImageMagick 7) or **6.9.13-58+** (ImageMagick 6). Distribution packages may carry backported fixes under older version numbers; use the distribution's tracker (below), not the upstream version alone.

### Distribution package status

Checked 2026-10-26; recheck before relying on it.

| Distribution | Status | Source |
|---|---|---|
| Debian | **Fixed only in unstable (sid)** from `8:7.1.2.33+dfsg1-1`. bookworm (`6.9.11.60` series), trixie (`7.1.1.43` series) and forky (`7.1.2.31`) are listed as **vulnerable**. | [Debian tracker][debian] |
| Red Hat | Important; ImageMagick on **RHEL 6 and RHEL 7** listed as "Affected". No other RHEL products are listed in the CVE data. | [Red Hat][redhat] |
| Ubuntu | **Not established**: Ubuntu's CVE API returned no record for this CVE when checked. | — |
| Others (Alpine, Fedora, SUSE, Homebrew, EPEL) | Not checked for this guide. | — |

### Input reachability and signals

- List every path where untrusted files reach ImageMagick: uploads, avatar and thumbnail generation, fetched URLs, email attachments, PDF/document conversion, and batch jobs over user-supplied archives.
- If `bzlib` is absent from `Delegates (built-in):`, the bzip2 decompression branch that the fix changes is not compiled in. This guide has not confirmed that this alone rules out the CVE; treat it as reduced exposure, not as a clean bill.
- Useful signals: crashes (`SIGSEGV`/`SIGABRT`, "stack smashing detected") or core dumps from `magick`, `convert`, PHP-FPM, Python or Ruby workers that process images, and input files that start with the bytes `BZh` (`head -c3 file`) in upload storage or job queues. The vendor published no indicators of compromise.

No crash or no `BZh` file found does **not** prove the flaw was not triggered: workers restart silently, temporary files are deleted, and memory corruption need not crash.

## Remediation

1. Upgrade to **ImageMagick 7.1.2-33 or later**, or **6.9.13-58 or later** for ImageMagick 6. Where you use distribution packages, install the vendor's fixed package once available. At the time of checking, Debian stable and Red Hat had no fixed package. [GHSA][ghsa] [Debian tracker][debian] [Red Hat][redhat]
2. Rebuild container images and products that bundle ImageMagick, then **restart** every long-running process that loaded the old library (PHP-FPM pools, application servers, queue workers). An updated package does not replace a library already mapped into a running process.
3. **Interim measures (not vendor-validated for this CVE):** until you can upgrade, reject untrusted input files whose first three bytes are `BZh` before they reach ImageMagick, or decompress bzip2 yourself in a separate, sandboxed step. Run image processing as an unprivileged user in a sandbox or container with no secrets and limited network access. Keep a restrictive `policy.xml` that disables coders you do not need. That reduces general attack surface, but this guide has not confirmed that any policy setting blocks this bzip2 path. These measures are this guide's inference, not ImageMagick guidance.

## Verification

- On each host and image, confirm `magick -version` (or `convert -version`) reports 7.1.2-33+ / 6.9.13-58+, or that the distribution package version matches a fixed version in its tracker.
- For language bindings, confirm the version the binding actually loads, for example `php -r 'echo Imagick::getVersion()["versionString"];'` for PHP Imagick or `python3 -c 'import wand.version as v; print(v.MAGICK_VERSION)'` for Wand. Run these against the deployed runtime, not a developer machine.
- Benign functional control: convert a known-good image (and, if your service accepts it, a known-good `.bz2`-compressed image you created yourself) and confirm the output. Do not use crafted crash files from untrusted sources against production.

## Compromise response

- If image workers crashed unexpectedly on untrusted input before patching, preserve core dumps, the triggering files and logs. Hand suspicious inputs only to an isolated analysis environment.
- Because the flaw corrupts stack memory, treat a worker host that processed attacker-supplied files and shows unexplained crashes as possibly compromised. Review it for unexpected processes, outbound connections and new files, and rotate credentials the worker could read (storage keys, database credentials, API tokens).
- Rebuild affected workers from a fixed image rather than patching in place if integrity cannot be established.

## Sources

- [GitHub advisory GHSA-pwpf-8799-94cj][ghsa] — title, description, CVSS 3.1 8.1, CWEs, affected and patched versions, publication 2026-10-10 14:00:15 UTC, reporter credit.
- [VulnCheck CNA record][cve] — CWE-121, CVSS 4.0 7.2 and CVSS 3.1 8.1, affected ranges, `datePublic`, publication time.
- [NVD][nvd] — status "Awaiting Analysis"; displays VulnCheck's scores.
- [VulnCheck advisory][vulncheck] — third-party advisory referenced by the CVE record.
- Fix commits: [ImageMagick 7 `cf40ce9`][fix7], [ImageMagick 6 `9b4d4e0`][fix6]; [`blob.c` at 7.1.2-33][blob] — bzip2 detection and read path.
- Releases: [7.1.2-33][rel7], [6.9.13-58][rel6].
- [Debian security tracker][debian] and [Red Hat CVE data][redhat] — distribution status and Red Hat's rating.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.23).

[ghsa]: https://github.com/ImageMagick/ImageMagick/security/advisories/GHSA-pwpf-8799-94cj
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-116149
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-116149
[vulncheck]: https://www.vulncheck.com/advisories/imagemagick-before-6.9.13-58-and-7-x-before-7.1.2-33-stack-buffer-overflow-via-bzip2-compressed-images
[fix7]: https://github.com/ImageMagick/ImageMagick/commit/cf40ce974c3f780b7f6913bcff7bec27087c9104
[fix6]: https://github.com/ImageMagick/ImageMagick6/commit/9b4d4e065a8518ad90d095ea1a91e6f19c008686
[blob]: https://github.com/ImageMagick/ImageMagick/blob/7.1.2-33/MagickCore/blob.c
[rel7]: https://github.com/ImageMagick/ImageMagick/releases/tag/7.1.2-33
[rel6]: https://github.com/ImageMagick/ImageMagick6/releases/tag/6.9.13-58
[debian]: https://security-tracker.debian.org/tracker/CVE-2026-116149
[redhat]: https://access.redhat.com/security/cve/CVE-2026-116149
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
