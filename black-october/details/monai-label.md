# MONAI Label: an upload writes any file

**Last updated:** 2026-11-20 (America/New_York)

[Main MONAI Label summary](../black-october-2026.md#monai-label-an-upload-writes-any-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-18 Project MONAI published [GHSA-qc22-rmgc-vg94][ghsa]. The advisory rates it **Critical** and names no number. The CVE record, [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968), was published 2026-11-20 by MITRE and scores it **CVSS 3.1 9.8**. The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. MITRE is the CNA. The record says the `image` parameter of `PUT /datastore/image` writes outside the datastore, through **0.8.5**, and that it was exploited in the wild starting in September 2026.

The project's own advisory is narrower and more specific. `LocalDatastore.add_image()` joins the caller-supplied image ID onto the datastore directory and copies the upload there. `save_label()` (`PUT /datastore/label`) does the same with the image ID and the label tag. Authentication is off by default (`MONAI_LABEL_AUTH_ENABLE=False`). With it on, the `ANNOTATOR` role is enough. The advisory says the fix is pull request 1915, merged to `main` on 2026-10-19, and that it will be in the next release. The advisory's patched-versions line is **None**. 0.8.5 is still the newest release.

The GHSA page itself still says "No known CVE." The CVE record links that GHSA and the pull request.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20). The CVE record says exploitation started in September 2026. That is not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix merged | 2026-10-19; time/TZ unknown | Commit `113527b` on `main`, pull request 1915. No release. [PR 1915][pr] |
| Project advisory | 2026-11-18; time/TZ unknown | GHSA-qc22-rmgc-vg94. Patched versions: None. [Advisory][ghsa] |
| **CVE record** | **2026-11-20; time/TZ unknown** | MITRE. CVSS 3.1 9.8. Says exploited from September 2026. [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968) |

## Detection

A server running the `monailabel` package at **0.8.5 or earlier** is inside the range both the advisory and the CVE record name. Authentication off, the default, means any client that can reach the port can call the upload. Authentication on does not close it for an `ANNOTATOR`.

A checkout of `main` that contains commit `113527b` has the project's fix and is not a release. Confirm the commit from the tree you run, not from the tag.

## Remediation

1. There is no release to install. Do not expose the server to a network you do not trust.
2. Set `MONAI_LABEL_AUTH_ENABLE=True` and do not give `ANNOTATOR` to an account you do not trust. The advisory says that is a workaround, not a fix: an annotator can still write outside the datastore.
3. Run the process as a user that can write only the datastore directory.
4. When a release newer than 0.8.5 ships and its notes name pull request 1915 or this CVE, install that and restart. Until then, a deploy of commit `113527b` or later is the only build that contains the check.
5. The workaround does not show whether an upload already wrote a file outside the datastore.

## Verification

- The listening service is not reachable from an untrusted network.
- `MONAI_LABEL_AUTH_ENABLE` is true on a server that has to stay up.
- Do not send a path outside the datastore.

## Compromise response

The CVE record says the flaw was exploited in the wild from September 2026. A server that was reachable should be reviewed for a file outside the datastore that the process wrote, including application code, a cron entry, and `authorized_keys`. Taking it off the network does not remove one.

## Sources

- [GHSA-qc22-rmgc-vg94][ghsa] — Project MONAI, published 2026-11-18. Critical, no number. Affected through 0.8.5. Patched versions: None. Workaround: authentication on, and do not expose the server.
- [Pull request 1915][pr] — merged to `main` on 2026-10-19 as commit `113527b`.
- [CVE-2026-133968](https://www.cve.org/CVERecord?id=CVE-2026-133968) — MITRE, published 2026-11-20. CVSS 3.1 9.8. Says exploited from September 2026.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. Not listed.

[ghsa]: https://github.com/Project-MONAI/MONAILabel/security/advisories/GHSA-qc22-rmgc-vg94
[pr]: https://github.com/Project-MONAI/MONAILabel/pull/1915
