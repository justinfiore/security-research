# Pillow: detection and remediation

**Last updated:** 2026-10-26 (America/New_York)

[Main Pillow summary](../black-october-2026.md#4-pillow-untrusted-images-reach-native-memory-corruption-and-command-execution) · [Changelog](../../CHANGELOG.md)

Pillow **13.0.0** fixes multiple independent native-memory, argument-injection and resource-exhaustion problems. An image-processing service can be exposed through uploaded files, fetched images, queued thumbnails or document conversions. The five highlighted issues below have different prerequisites; do not treat one format filter as a complete fix. Severity disagreements in the [main table](../black-october-2026.md#4-pillow-untrusted-images-reach-native-memory-corruption-and-command-execution) remain attributed rather than flattened into a single score.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Covers all five CVEs in this guide; no exploitation reported in the reviewed sources. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Locate every processing environment](#locate-every-processing-environment)
  - [Map each issue to an actual operation](#map-each-issue-to-an-actual-operation)
  - [Signals worth investigating](#signals-worth-investigating)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and evidence |
|---|---|
| Private discovery/reports | Exact dates not established in the cited release notices; individual advisories credit their researchers |
| Fixed release and public release notes | 2026-10-16: [Pillow 13.0.0](https://pillow.readthedocs.io/en/stable/releasenotes/13.0.0.html) |
| Individual advisory publication | 2026-10-17 (UTC): the five linked advisories below were published after the release |
| Advisory revisions | FPX, EPS, TIFF encoder and lossless-JPEG advisory records updated 2026-10-19 (UTC); an advisory update is not a new package release |

## Detection

### Locate every processing environment

From `black-october/`, use a trusted interpreter against the application's actual package directory:

```sh
python3 -I -S python-package-inventory.py /path/to/worker/site-packages
```

The [metadata inventory](../python-package-inventory.py) lists Pillow and `olefile` without importing them. Repeat for each worker, container, virtual environment and scheduled converter. It cannot discover manually vendored code or attest that binaries match metadata. If compromise is suspected, run this on a read-only snapshot from a clean host, not the suspect environment's interpreter.

### Map each issue to an actual operation

| Issue | Affected package range in advisory | Exposure to investigate |
|---|---|---|
| **[CVE-2026-96639](https://www.cve.org/CVERecord?id=CVE-2026-96639)** — Critical 9.8, multi-frame storage reuse | 11.0.0–12.3.0 | Seeking/iterating through untrusted frames whose modes change; single-image checks may miss later frames |
| **[CVE-2026-112398](https://www.cve.org/CVERecord?id=CVE-2026-112398)** — Critical, FPX/JPEG overflow | Through 12.3.0 | FlashPix decoding with optional `olefile`; MIME/extension filtering does not prevent format recognition from content |
| **[CVE-2026-112900](https://www.cve.org/CVERecord?id=CVE-2026-112900)** — maintainer Moderate, CVE 9.2, EPS filename injection | 2.6.0–12.3.0 | Ghostscript subprocess rendering with attacker-influenced filenames, not just EPS content |
| **[CVE-2026-112393](https://www.cve.org/CVERecord?id=CVE-2026-112393)** — maintainer High, CVE 9.2, TIFF encoder overflow | Through 12.3.0 | Saving compressed TIFF to file-like objects such as `BytesIO`; output encoding can be exposed even when upload decoding is constrained |
| **[CVE-2026-112403](https://www.cve.org/CVERecord?id=CVE-2026-112403)** — maintainer High, CVE 9.2 Critical, lossless JPEG overflow | Through 12.3.0 | `draft()`/thumbnail paths on crafted lossless JPEGs; demonstrated crash does not by itself establish RCE |

Review calls to `Image.open`, frame iteration/`seek`, `thumbnail`, `draft` and TIFF `save`, including wrappers in document pipelines. Trace the source of filenames and output tags. Check Ghostscript via `command -v gs` as the worker user on Linux/macOS and inspect any configured absolute executable paths. An absent dependency only narrows its specific path.

The release notes list additional High/Critical fixes in WMF/EMF, TIFF, JPEG, PDF and other paths. Upgrade the full package rather than deciding that an application is safe solely because it does not use these five examples.

### Signals worth investigating

Correlate native crashes, repeatable worker failures, unusual Ghostscript child processes, unexpected output bytes, abnormal memory use and outbound connections with job IDs and source files. Preserve original inputs and logs without reopening suspicious files in a desktop viewer. Some defects disclose memory without a crash; no error log is not a clean bill of health. Treat output artifacts produced during a suspected disclosure as potentially sensitive.

## Remediation

1. Update to **Pillow 13.0.0 or a later supported release**, or a vendor package explicitly backporting all applicable fixes. Update lockfiles and deploy the resulting artifacts to every processing environment, not just the upload frontend.
2. Plan for **Python 3.11+**: Pillow 13 drops Python 3.10. Test package compatibility in a clean build; do not bypass dependency constraints to force an unsupported runtime combination.
3. Review the release's API changes, especially saving `I`-mode PNG images and removed APIs used by your pipeline. Compare benign conversion output against known expected files; a successful import is not sufficient.
4. Rebuild containers and restart long-running workers. Native library state remains loaded in existing processes. If building from source, verify the dependency versions and vendor fixes for linked image libraries too.
5. While awaiting an update, stop the affected untrusted processing path or restrict it to trusted input. Removing optional FPX/EPS support, normalizing server-generated filenames and disabling TIFF output can narrow particular paths but do not fix the whole vulnerability set. Apply CPU/memory/time limits and least-privilege isolation as additional containment, not memory-safety fixes.

Do not reinstall packages inside an environment suspected of arbitrary code execution as a substitute for clean recovery. Do not use a failed install as justification to restore a vulnerable public image processor.

## Verification

- Read the running deployment's package/build metadata after restart; make sure all old replicas are gone.
- Exercise benign multi-frame mode transitions, approved image formats, thumbnailing and each enabled output format. Include a normal single-frame control, file-backed and in-memory TIFF outputs where used, and the application's actual filename-handling path.
- Confirm unwanted formats are rejected before reaching a disabled decoder and that resource limits fail jobs cleanly without taking down the service. Do not run exploit images on production.
- Retain evidence of runtime, Pillow and linked-library versions, container digests and deployment time. Review queued work: old workers can still process queued malicious files during a staggered rollout.

## Compromise response

Isolate affected workers and snapshot evidence. Map accessible storage, cloud/API credentials, databases and shared queues. Replace compromised worker images from a clean build and revoke reachable secrets as indicated by the investigation. Assess whether returned image/document artifacts could contain disclosed process memory. A low-privilege worker can still expose customer data or tokens; a crash alone does not establish compromise.

## Sources

- [Pillow 13.0.0 security and compatibility notes](https://pillow.readthedocs.io/en/stable/releasenotes/13.0.0.html)
- [Multi-frame storage advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-v9pv-5gc8-w2m6)
- [FPX/JPEG advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-5x8w-8jj5-q52h)
- [EPS filename advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-w889-685w-c8fh)
- [TIFF encoder advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-332p-7hrc-92wf)
- [Lossless JPEG advisory](https://github.com/python-pillow/Pillow/security/advisories/GHSA-8g5g-8vmr-9782)
