# MONAI Label: an upload writes any file

**Last updated:** 2026-11-22 (America/New_York)

[Main MONAI Label summary](../black-october-2026.md#monai-label-an-upload-writes-any-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-18 Project MONAI published [GHSA-qc22-rmgc-vg94][ghsa]. The advisory rates it **Critical** and names no number. The CVE record, [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968), was published 2026-11-20 by MITRE and scores it **CVSS 3.1 9.8**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. MITRE is the CNA. The record says the `image` parameter of `PUT /datastore/image` writes outside the datastore, through **0.8.5**, and that it was exploited in the wild starting in September 2026.

The project's own advisory is narrower and more specific. `LocalDatastore.add_image()` joins the caller-supplied image ID onto the datastore directory and copies the upload there. `save_label()` (`PUT /datastore/label`) does the same with the image ID and the label tag. Authentication is off by default (`MONAI_LABEL_AUTH_ENABLE=False`). With it on, the `ANNOTATOR` role is enough. The advisory says the fix is pull request 1915, merged to `main` on 2026-10-19. Its patched-versions line is still **None**, and the page still says "No known CVE." The release is newer than that text.

**0.8.6**, published 2026-11-22 01:29:24 UTC, is the security release. Its notes say every MONAI Label server should upgrade, name CVE-2026-133968 and GHSA-qc22-rmgc-vg94, and say both upload endpoints are fixed in pull request 1915. The same notes disclose a second path traversal the advisory does not: `PUT /session/?uncompress=true` extracts a tar archive without checking member names, and session IDs are used as paths. It affects every version through 0.8.5, it is fixed in pull request 1942, and the notes assign it no CVE. Authentication off means both were reachable by any client that can connect.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-22). The CVE record says exploitation started in September 2026. That is not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Release 0.8.6** | **2026-11-22 01:29:24 UTC** | Security release. Names the CVE and a second path traversal, in session upload, with no CVE. [0.8.6][rel] |

## Detection

A server running the `monailabel` package at **0.8.5 or earlier** is inside the range the release notes name, for both the datastore upload and the session upload. **0.8.6** is the first release that contains both fixes. Authentication off, the default, means any client that can reach the port can call either one. Authentication on does not close the datastore upload for an `ANNOTATOR`.

A checkout of `main` that contains commit `113527b` has the datastore fix and does not by itself have the session fix from pull request 1942. Confirm both from the tree you run, not from the tag.

## Remediation

1. Upgrade to **0.8.6 or later** and restart the server. The release notes say every deployment should upgrade.
2. Set `MONAI_LABEL_AUTH_ENABLE=True` and do not give `ANNOTATOR` to an account you do not trust. The release notes still say not to expose the server to a network you do not trust, and to run it as a user that can write only the datastore directory.
3. The advisory's patched-versions line still says None. The release is the newer statement. A deploy of commit `113527b` alone fixes the datastore upload and leaves the session upload in place.
4. The upgrade does not show whether an upload already wrote a file outside the datastore.

## Verification

- The installed `monailabel` is **0.8.6 or later**.
- The server was restarted after the upgrade.
- Do not send a path outside the datastore.

## Compromise response

The CVE record says the flaw was exploited in the wild from September 2026. A server that was reachable should be reviewed for a file outside the datastore that the process wrote, including application code, a cron entry, and `authorized_keys`. Taking it off the network does not remove one.

## Sources

- [GHSA-qc22-rmgc-vg94][ghsa] — Project MONAI, published 2026-11-18. Critical, no number. Affected through 0.8.5. Patched versions: None. Workaround: authentication on, and do not expose the server.
- [Pull request 1915][pr] — merged to `main` on 2026-10-19 as commit `113527b`.
- [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968) — MITRE, published 2026-11-20. CVSS 3.1 9.8. Says exploited from September 2026.
- [MONAI Label 0.8.6][rel] — published 2026-11-22 01:29:24 UTC. Fixes the datastore upload in pull request 1915 and the session upload in pull request 1942. The session issue has no CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-22. Not listed.

[ghsa]: https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-qc22-rmgc-vg94
[pr]: https://github.com/Project-MONAI/MONAILabel/pull/1915
[rel]: https://github.com/Project-MONAI/MONAILabel/releases/tag/0.8.6
