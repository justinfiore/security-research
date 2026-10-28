# TeamViewer clients: crafted screen images can execute code

**Last updated:** 2026-10-28 (America/New_York)

[Main TeamViewer summary](../black-october-2026.md#teamviewer-clients-crafted-screen-images-can-execute-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-92372](https://www.cve.org/CVERecord?id=CVE-2026-92372) and [CVE-2026-111585](https://www.cve.org/CVERecord?id=CVE-2026-111585) — TeamViewer (CNA) CVSS 3.1: 8.8 High. [CVE-2026-92374](https://www.cve.org/CVERecord?id=CVE-2026-92374) — 7.8 High local privilege escalation.** TeamViewer says these client-side flaws are resolved in 15.83 and supported legacy releases. The remote-code-execution paths require a user to connect to an attacker-controlled or compromised remote-control session, or, for CVE-2026-92372, open a crafted `.tvs` recording; they are not unauthenticated attacks against a TeamViewer Host listening on the Internet.

**CISA KEV:** Not listed (catalog 2026.10.27, checked 2026-10-28) for any of the three CVEs. TeamViewer reported no known active exploitation when it published the bulletin. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | The bulletin does not establish a private-report date. |
| Public bulletin and fixed releases | 2026-10-27; time/TZ unknown | TeamViewer published TV-2026-1011 and lists 15.83/current supported releases. [Bulletin][bulletin] |
| CVE records published | 2026-10-27; time/TZ unknown | TeamViewer CNA records for the three flaws. [CVE-2026-92372][cve92372] |

## Detection

1. Inventory **TeamViewer clients**, not only unattended Hosts: Full Client, Portable, Remote Control App, and macOS Host. Use the product's About/version display or managed-software inventory; a web account listing does not prove the installed binary was updated.
2. Treat Full Client versions earlier than **15.83** on Linux or macOS as affected by CVE-2026-92372. The CVE is in the screen-image decoder and requires a crafted remote-control session or recording.
3. Treat Full Client, Portable, and Remote Control App versions earlier than **15.83** as potentially affected by CVE-2026-111585. The bulletin says impact can range from denial of service to potential code execution with the viewer process's privileges, depending on platform.
4. On macOS, Full Client and Host versions earlier than **15.83** are also affected by CVE-2026-92374's privileged-helper package-verification bypass. This requires a local low-privilege attacker; do not recast it as a remote session attack.

Missing device inventory, unsupported legacy installations, or a version reported by a management console without a recent device check-in is **unknown**, not safe. The vendor did not publish indicators of compromise for these flaws.

## Remediation

1. Update every affected TeamViewer product through TeamViewer's official download/update channel to **15.83 or later**, or the supported legacy fixed builds listed in TV-2026-1011: 15.64.10 (Windows 7/8), 14.7.48868, 13.2.36231 (Windows), 13.2.154008 (Linux), and 13.2.154007 (macOS), as applicable.
2. Restart the client after the update and confirm the deployed executable rather than assuming a downloaded installer updated every user profile.
3. Until update completion, do not open unexpected `.tvs` recordings and require users to verify the remote party before starting a session. These reduce the documented interaction paths but do not replace the update.
4. Remove unsupported clients where a vendor-supported fixed release is unavailable. Do not install binaries from third-party mirrors to reach a version threshold.

## Verification

- Confirm each managed endpoint reports the intended installed version and publisher, then perform a normal authorized support session with a known system.
- Confirm macOS clients/Hosts still start and accepted support workflows work after the update.
- Do not use crafted screen images, `.tvs` files, or proof-of-concept data to test production clients.

## Compromise response

If a vulnerable client connected to an untrusted remote host or opened an unexpected recording, preserve TeamViewer connection history, endpoint telemetry, downloaded recordings, and process/network logs before cleanup. Investigate activity under the affected viewer user's privileges, including newly created persistence, credential access, and remote-control-session history. Revoke or rotate credentials exposed on the endpoint as the investigation establishes; updating prevents the documented path but cannot establish that earlier sessions were benign.

## Sources

- [TeamViewer bulletin TV-2026-1011][bulletin] — affected products, fixed releases, CVSS scores, prerequisites, and vendor exploitation statement.
- TeamViewer CNA records: [CVE-2026-92372][cve92372], [CVE-2026-92374][cve92374], and [CVE-2026-111585][cve111585].
- [CISA KEV JSON feed][kev] — catalog 2026.10.27 status.

[bulletin]: https://www.teamviewer.com/en/resources/trust-center/security-bulletins/tv-2026-1011
[cve92372]: https://www.cve.org/CVERecord?id=CVE-2026-92372
[cve92374]: https://www.cve.org/CVERecord?id=CVE-2026-92374
[cve111585]: https://www.cve.org/CVERecord?id=CVE-2026-111585
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
