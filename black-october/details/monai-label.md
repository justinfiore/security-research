# MONAI Label: an upload writes any file

**Last updated:** 2026-11-25 (America/New_York)

[Main MONAI Label summary](../black-october-2026.md#monai-label-an-upload-writes-any-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-18 Project MONAI published [GHSA-qc22-rmgc-vg94][ghsa]. The advisory rates it **Critical** and names no number. The CVE record, [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968), was published 2026-11-20 by MITRE and scores it **CVSS 3.1 9.8**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. MITRE is the CNA. The record says the `image` parameter of `PUT /datastore/image` writes outside the datastore, through **0.8.5**, and that it was exploited in the wild starting in September 2026.

The project's own advisory is narrower and more specific. `LocalDatastore.add_image()` joins the caller-supplied image ID onto the datastore directory and copies the upload there. `save_label()` (`PUT /datastore/label`) does the same with the image ID and the label tag. Authentication is off by default (`MONAI_LABEL_AUTH_ENABLE=False`). With it on, the `ANNOTATOR` role is enough. The advisory says the fix is pull request 1915, merged to `main` on 2026-10-19. Its patched-versions line is still **None**, and the page still says "No known CVE." The release is newer than that text.

**0.8.6**, published 2026-11-22 01:29:24 UTC, fixes the datastore upload. Its notes also disclose a second path traversal: `PUT /session/?uncompress=true` extracts a tar archive without checking member names. That one is now [GHSA-5c65-q9f6-h62q](https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-5c65-q9f6-h62q), rated high, fixed in 0.8.6, and still has no CVE.

**0.8.8**, published 2026-11-25 09:04:08 UTC, is the release to install. [GHSA-gfjg-c3x6-24gw](https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-gfjg-c3x6-24gw) rates a bundle-inference flaw **Critical, CVSS 3.1 9.8**, `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Request values were copied into the bundle configuration, and a string starting with `$` is evaluated as Python. It affects **0.7.0 through 0.8.7**, so 0.8.6 does not close it. No CVE is assigned. The same release notes rate [GHSA-xhxp-5f3g-gxxx](https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-xhxp-5f3g-gxxx) critical, through 0.8.7, and publish no numeric score: a tracking value, a scribble parameter, and an image id can reach a command line or a local path. **0.8.7**, published 2026-11-25 03:32:03 UTC, fixed a different critical flaw, [GHSA-j5c7-p3x5-gw2x](https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-j5c7-p3x5-gw2x): a client-supplied `bundle_path` was added to `PYTHONPATH`, on 0.6.0 through 0.8.6. 0.8.8 includes that fix. Authentication off, the default, means a client that can connect can send the request.

**CISA KEV:** Listed — [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968) added 2026-11-23, federal due date 2026-11-26. Ransomware use Unknown. Forensic triage is required. Catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z. The CVE record's statement that exploitation started in September 2026 is the vendor record, not the KEV date. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix merged | 2026-10-19; time/TZ unknown | Commit `113527b` on `main`, pull request 1915. The datastore upload only. [PR 1915][pr] |
| Project advisory | 2026-11-18; time/TZ unknown | GHSA-qc22-rmgc-vg94. Patched versions: None. [Advisory][ghsa] |
| **CVE record** | **2026-11-20; time/TZ unknown** | MITRE. CVSS 3.1 9.8. Says exploited from September 2026. [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968) |
| **Release 0.8.6** | **2026-11-22 01:29:24 UTC** | Datastore upload and session upload. The session issue is now GHSA-5c65-q9f6-h62q and still has no CVE. [0.8.6][rel] |
| **Release 0.8.7** | **2026-11-25 03:32:03 UTC** | `bundle_path` on the task `PYTHONPATH`, GHSA-j5c7-p3x5-gw2x, critical, through 0.8.6. [0.8.7][rel7] |
| **Release 0.8.8** | **2026-11-25 09:04:08 UTC** | Request values evaluated as Python, GHSA-gfjg-c3x6-24gw, CVSS 3.1 9.8, through 0.8.7. No CVE. [0.8.8][rel8] |
| **CISA KEV** | **2026-11-23; time/TZ unknown** | Added. Federal due date 2026-11-26. Ransomware use Unknown. Forensic triage required. [KEV](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) |

## Detection

A server at **0.8.7 or earlier** is inside GHSA-gfjg-c3x6-24gw if it runs a bundle task. **0.8.5 or earlier** is also inside the datastore and session traversals. **0.8.8** is the first release that contains the bundle-configuration fix. Authentication off, the default, means any client that can reach the port can call either upload. Authentication on does not close the datastore upload for an `ANNOTATOR`.

A checkout of `main` that contains commit `113527b` has the datastore fix and does not by itself have the session fix from pull request 1942. Confirm both from the tree you run, not from the tag.

## Remediation

1. Upgrade to **0.8.8 or later** and restart the server. The 0.8.8 notes say every deployment should upgrade, including the Python client and the 3D Slicer plugin. 0.8.6 and 0.8.7 leave the bundle-configuration flaw in place.
2. Set `MONAI_LABEL_AUTH_ENABLE=True` and do not give `ANNOTATOR` to an account you do not trust. The release notes still say not to expose the server to a network you do not trust, and to run it as a user that can write only the datastore directory.
3. The advisory's patched-versions line still says None. The release is the newer statement. A deploy of commit `113527b` alone fixes the datastore upload and leaves the session upload in place.
4. The upgrade does not show whether an upload already wrote a file outside the datastore.

## Verification

- The installed `monailabel` is **0.8.8 or later**.
- The server was restarted after the upgrade.
- Do not send a path outside the datastore.

## Compromise response

The CVE record says the flaw was exploited in the wild from September 2026. A server that was reachable should be reviewed for a file outside the datastore that the process wrote, including application code, a cron entry, and `authorized_keys`. Taking it off the network does not remove one.

## Sources

- [GHSA-qc22-rmgc-vg94][ghsa] — Project MONAI, published 2026-11-18. Critical, no number. Affected through 0.8.5. Patched versions: None. Workaround: authentication on, and do not expose the server.
- [Pull request 1915][pr] — merged to `main` on 2026-10-19 as commit `113527b`.
- [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968) — MITRE, published 2026-11-20. CVSS 3.1 9.8. Says exploited from September 2026.
- [MONAI Label 0.8.6][rel] — published 2026-11-22 01:29:24 UTC. Fixes the datastore upload in pull request 1915 and the session upload in pull request 1942. The session issue has no CVE.
- [GHSA-gfjg-c3x6-24gw](https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-gfjg-c3x6-24gw) — published 2026-11-25. Critical, CVSS 3.1 9.8. 0.7.0 through 0.8.7. Patched in 0.8.8. No CVE.
- [MONAI Label 0.8.8][rel8] — published 2026-11-25 09:04:08 UTC.
- [MONAI Label 0.8.7][rel7] — published 2026-11-25 03:32:03 UTC. `bundle_path`, through 0.8.6.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.23, released 2026-11-23T19:43:55.7979Z, checked 2026-11-23. CVE-2026-133968 added 2026-11-23, due 2026-11-26. Ransomware use Unknown. Forensic triage Yes.

[ghsa]: https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-qc22-rmgc-vg94
[pr]: https://github.com/Project-MONAI/MONAILabel/pull/1915
[rel]: https://github.com/Project-MONAI/MONAILabel/releases/tag/0.8.6
[rel7]: https://github.com/Project-MONAI/MONAILabel/releases/tag/0.8.7
[rel8]: https://github.com/Project-MONAI/MONAILabel/releases/tag/0.8.8
