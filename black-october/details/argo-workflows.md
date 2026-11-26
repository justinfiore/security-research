# Argo Workflows: an object key writes outside the workspace

[Main guide](../black-october-2026.md#argo-workflows-an-object-key-writes-outside-the-workspace)

**GitHub rates [GHSA-vm9v-p987-xm32](https://github.com/argoproj/argo-workflows/security/advisories/GHSA-vm9v-p987-xm32) High, CVSS 3.1 8.8.** The vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`. VulnCheck's [CVE-2026-137566](https://www.cve.org/CVERecord?id=CVE-2026-137566) scores the same issue CVSS 3.1 8.8 and CVSS 4.0 8.7 (`CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`). The weakness is CWE-22. When a workflow downloads a directory artifact from S3, GCS, Azure Blob, or OSS, the executor joins the object key onto the local path. A key that contains `../` writes a file outside that workspace, inside the workflow pod, and the advisory says that write can run code. The writer needs access to the bucket or prefix the workflow reads, or the ability to name the artifact source. In a shared bucket, a workflow author can choose the output keys. **v4.1.0 before v4.1.4**, **v4.0.0 before v4.0.12**, and **every v3 release** are affected. v3 is not being patched. The GitHub page still says "No known CVE"; the CVE record is the newer statement. No source read for this entry reports exploitation.

A second High flaw shipped in the same v4.1.4 release and is not this one. [GHSA-q65w-j2vp-47c4](https://github.com/argoproj/argo-workflows/security/advisories/GHSA-q65w-j2vp-47c4) is CVSS 3.1 8.5: on v4.1.0 through v4.1.3, a user who can list archived workflows in one namespace reads them in every namespace, including their parameters. v4.0 and v3 do not have that selector. It has no CVE.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-09-18; time/TZ unknown** | GHSA-vm9v-p987-xm32, High, CVSS 3.1 8.8. Fixed in v4.1.4 and v4.0.12. v3 gets no patch. The page names no CVE. [GHSA][ghsa] |
| Same-day companion | 2026-09-18; time/TZ unknown | GHSA-q65w-j2vp-47c4, CVSS 3.1 8.5. Fixed in v4.1.4 only. [IDOR][idor] |
| CVE record | 2026-11-26; time/TZ unknown | VulnCheck published CVE-2026-137566. CVSS 4.0 8.7 and CVSS 3.1 8.8. [CVE][cve] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. Upgrade off v3. |

## Detection

Read the controller image. **v4.1.0 through v4.1.3**, **v4.0.0 through v4.0.11**, and **any v3 release** are inside the range the advisory names. v4.1.4 and v4.0.12 are the first fixed builds. A workflow that never consumes a directory artifact from a bucket someone else can write is outside the condition the advisory names. Reading the image tag changes no state.

## Remediation

1. Upgrade to **v4.1.4 or later**, or to **v4.0.12 or later** on the 4.0 line. v4.1.4 also closes the archive leak.
2. A v3 install has no fix. Move it to v4.
3. Until the upgrade, do not consume a directory artifact from a bucket or prefix an untrusted party can write. The advisory says that is the workaround, and that in a shared bucket any workflow author may choose the output keys.
4. The upgrade does not show whether a key already wrote a file into a pod.

## Verification

- The controller image is **v4.1.4 or later**, or **v4.0.12 or later**.
- No workflow still runs a v3 executor.
- Do not plant an object key to test it.

## Compromise response

No source read for this entry reports an incident. A pod that consumed a directory artifact from a shared bucket before the upgrade could already have run code as the workflow's service account. Rotate a credential that account could read. On v4.1.0 through v4.1.3 with the archive on, a parameter stored on an archived workflow may have been readable from another namespace. The upgrade does not undo a file that was already written.

## Sources

- [GHSA-vm9v-p987-xm32][ghsa] — Joibel, published 2026-09-18. High, CVSS 3.1 8.8. Affected: v4.1.0 before v4.1.4, v4.0.0 before v4.0.12, and all v3. v3 is not patched. The page says no known CVE.
- [GHSA-q65w-j2vp-47c4][idor] — Joibel, published 2026-09-18. High, CVSS 3.1 8.5. v4.1.0 through v4.1.3 only. Fixed in v4.1.4.
- [CVE-2026-137566][cve] — VulnCheck, published 2026-11-26. CVSS 4.0 8.7 and CVSS 3.1 8.8. Affected from 3.0.0 through 3.7.18, 4.0.0 before 4.0.12, and 4.1.0 before 4.1.4. Credits Yeonghyeon Choi and Duyeong Kim.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, released 2026-11-25T19:48:12.4344Z, checked 2026-11-26. Not listed.

[ghsa]: https://github.com/argoproj/argo-workflows/security/advisories/GHSA-vm9v-p987-xm32
[idor]: https://github.com/argoproj/argo-workflows/security/advisories/GHSA-q65w-j2vp-47c4
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137566
