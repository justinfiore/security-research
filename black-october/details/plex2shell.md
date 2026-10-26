# Plex2Shell: detection and recovery for Plex Media Server

**Last updated:** 2026-10-26 (America/New_York)

[Main guide](../black-october-2026.md#5-plex2shell-a-home-server-compromise-chain-is-being-exploited) · [Changelog](../../CHANGELOG.md)

**Scope:** [CVE-2026-96652](https://www.cve.org/CVERecord?id=CVE-2026-96652), [CVE-2026-96654](https://www.cve.org/CVERecord?id=CVE-2026-96654), [CVE-2026-96655](https://www.cve.org/CVERecord?id=CVE-2026-96655) and [CVE-2026-96656](https://www.cve.org/CVERecord?id=CVE-2026-96656) form the researcher’s unauthenticated RCE chain. Its combined CVSS 3.1 score is 9.8, not the score of every constituent CVE. The demonstrated final execution is as the Plex service account, not automatically root. [Research][research]

**Per-CVE ratings from the CNA (CISA, `cisa-cg`):** CVE-2026-96652 Medium, CVSS 3.1 4.3 / CVSS 4.0 5.3; CVE-2026-96654 Medium, 6.5 / 6.9; CVE-2026-96655 Medium, 4.3 / 5.3; CVE-2026-96656 High, 7.2 / 8.6. [CVE records][cve96652] The chain's severity comes from combining them. Plex's [October 19 notice][vendor] labels CVE-2026-96654 as loopback access to internal agent functions and CVE-2026-96655 as admin-token disclosure. The CVE records and [KEV][kev] describe CVE-2026-96654 as encoded-URI plugin-function abuse and CVE-2026-96655 as an authenticated SSRF. Use the CVE IDs together; the patch target is the same.

**CISA KEV:** Listed — all four CVEs added 2026-10-20; federal due date 2026-10-23 for -96654 and -96656, 2026-11-03 for -96652 and -96655. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Establish which server and build are exposed](#establish-which-server-and-build-are-exposed)
  - [Investigate prior exposure](#investigate-prior-exposure)
- [Remediation](#remediation)
  - [Temporary containment](#temporary-containment)
  - [Update the deployment, not just the client](#update-the-deployment-not-just-the-client)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date | Evidence and qualification |
|---|---|---|
| Discovery | Unknown | The researcher does not date the initial discovery. |
| Private report, all four CVEs | 2026-07-27 | Researcher disclosure timeline. [Research][research] |
| Fix available: PMS 1.43.3.10861, Plex Pass beta | 2026-08-03 | Vendor release announcement; includes CompanionProxy and network modification of transcoder preferences fixes. [Releases][releases] |
| Fix available: PMS 1.43.3.10861, general release | 2026-08-04 | Vendor says “available to everyone”; NAS app-store approvals can lag. [Releases][releases] |
| Vendor acknowledgment / bounty | 2026-08-04 | Researcher timeline; not the first patch date. [Research][research] |
| Vendor security notice | 2026-09-01 18:30 UTC | Plex urges updating to 1.43.3 to address “a number of security issues”; CVEs not yet published. [Vendor notice][vendor] |
| CVE assignment, all four | 2026-09-23 | Assignment is distinct from publication of the chain. [Research][research] |
| CISA advisory and CVE records published | 2026-09-23 15:39 UTC (advisory); 16:06–16:07 UTC (CVE records) | CISA CSAF advisory [VA-26-266-01][csaf] and the four CNA records; fixed in 1.43.3.10861. Public CVE details predate the technical write-up. [CVE records][cve96652] |
| Public technical disclosure | 2026-10-16 | Researcher publication. Plex says a public proof of concept was released this day. [Research][research], [Vendor notice][vendor] |
| Exploitation attempts reported from | 2026-10-17 | October 19 reporting says one day after disclosure; not proof that this was the first-ever attack. [Reporting][reporting] |
| Vendor confirms active exploitation | 2026-10-19 20:17 UTC | Plex says the flaws are “actively and widely exploited” against unpatched internet-facing servers, publishes CVE mapping and compromise indicators. [Vendor notice][vendor] |
| CISA KEV addition, all four | 2026-10-20 (date only) | Added “based on evidence of active exploitation.” Due dates differ: **CVE-2026-96654 and -96656: 2026-10-23**; **CVE-2026-96652 and -96655: 2026-11-03**. BOD 26-04 forensic triage required: Yes for -96656 only. Known ransomware use: Unknown. KEV addition is not the exploitation start date. [KEV][kev], [CISA alert][kevalert] |

**KEV required action (identical for all four entries)** [KEV][kev]:

> Apply mitigations in accordance with vendor instructions, ensuring compliance with CISA’s BOD 26-04 Prioritizing Security Updates Based on Risk (see URL in Notes) guidance and CISA’s “Forensics Triage Requirements” (see URL in Notes). Follow applicable BOD 26-04 guidance for cloud services or discontinue use of the product if mitigations are unavailable. Stakeholders are responsible for evaluating each asset's internet exposure and ensuring adherence to BOD 26-04 patching guidelines.

The KEV vendor-instructions link is Plex's [security notice][vendor].

No different release dates for the four constituent fixes were established in the reviewed sources. The vendor release notes describe chain-breaking changes rather than a separate CVE-by-CVE remediation table.

## Detection

### Establish which server and build are exposed

1. In Plex Web, select **each actual server**, then **Settings → General** and record the Media Server version. Do not substitute the Plex Web or player version.
2. Treat builds before **1.43.3.10861** as remediation candidates unless the supplier confirms a backport. Record NAS package origin, container digest, architecture, service identity and persistent data location. [Reporting][reporting]
3. Review Remote Access, manual router forwarding, UPnP mappings, IPv6 firewall rules, reverse proxies and VPN routes. A LAN-reachable server remains reachable to compromised local devices.
4. On trusted Linux hosts, from the `black-october` directory, run the existing [Linux inventory script](../linux-service-inventory.sh):

```sh
sh linux-service-inventory.sh
```

The TCP 32400 result is a local-namespace listener inventory, not an internet scan or Plex version check. Check host-network and bridged containers separately; non-Linux/NAS systems need their management interfaces.

### Investigate prior exposure

The following are **recommended investigation steps**, derived from the chain, not assertions that every installation shows these artifacts:

- Preserve Plex, proxy and firewall logs and the Plex application-data volume before making changes if compromise is suspected. Use clean-host snapshot inspection instead of running tools on the suspect server.
- Correlate unusual companion/player requests, agent/plugin calls and transcoding activity with unexpected outbound HTTP/DNS destinations; ordinary transcoding and metadata downloads are common, so context matters. [Research][research]
- Examine historical changes to `TranscoderH264Options` and `TranscoderH264OptionsOverride`, plus unexpected shared objects in the persistent `Codecs` tree. Compare against trusted packages/download provenance, not filenames alone.
- The research clears its malicious transcoder preference after writing a library: a normal current preference is not clearance. The demonstrated codec loader does not require the executable permission bit. [Research][research]
- Hunt existing telemetry for `x12345`, `myawesomeproxy`, `mylovelyminer`, and unexpected mining/proxy traffic. These are **reported campaign artifacts**, not a complete detection signature. Some Reddit cases cited by the reporting were not conclusively attributed to this chain. [Reporting][reporting]
- Plex's own indicators: unrecognized processes started by Plex Media Server (especially the names above), unfamiliar `.so` or `.dll` files in the Plex `Codecs` folder, outbound connections to `proxystream.st`, sustained high CPU while nothing is playing, and transcoder options in `Preferences.xml` that you did not set. Plex says a server older than 1.43.3.10861 that was reachable from the internet should be assumed possibly compromised. [Vendor notice][vendor]
- Correlate new scheduled jobs, service units, startup changes and outbound connections with the exposure window. A quiet CPU or absent known filename does not rule out a different payload.

## Remediation

### Temporary containment

- Remove unnecessary external forwarding and proxy routes; restrict remaining access to explicitly trusted clients. For suspected compromise, isolate the host/container’s outbound access as well.
- If a fixed package is unavailable, stop serving Plex to untrusted networks; do not rely on requiring Plex login to stop an unauthenticated chain.
- Do not use disabling transcoding, deleting one codec, or resetting a preference as a substitute for the vendor update: earlier chain stages include administrator-token theft. [Research][research]

### Update the deployment, not just the client

1. Back up configuration and library metadata for rollback on a system with no compromise evidence; quarantine suspect backups instead of treating them as trusted recovery media.
2. Install a supported vendor release **at least 1.43.3.10861**, preferably the latest compatible stable build. Fresh vendor release notes also list **1.43.5.11079** as generally available at this review. [Releases][releases]
3. NAS: verify the actual installed PMS build after the package manager finishes; “latest” in a delayed app store is insufficient. Use the NAS/vendor-supported package route.
4. Containers: replace the image with a verified updated digest and recreate the running container. Inspect persistent configuration/codec volumes separately; replacing an image does not clean a mounted volume.
5. Native services: restart PMS and verify the process is using the updated installation. Avoid running the service with root or broad writable mounts; these are operator hardening recommendations, not fixes for the chain.

## Verification

- Reopen each selected server’s version page and record the running PMS build and deployment time; compare with the package or image that was installed.
- Verify exposure from an authorized external vantage and an untrusted internal segment using ordinary connection checks, not exploit requests. Include IPv6 and alternative proxy hostnames.
- After a clean update, test normal playback and transcoding with trusted media, plus library access and metadata retrieval. Do not perform this test on an unreviewed compromised data volume.
- Confirm intentional mount permissions, service identity and forwarding settings survived the update; monitor restart loops and unexpected egress.
- Keep two separate results: **vulnerability remediated** and **historical compromise assessment completed/unknown**. Neither a successful inventory nor a fixed version answers the latter.

## Compromise response

- Isolate first and preserve evidence; do not execute downloaded binaries or suspicious codec files to identify them.
- Rebuild the affected service from trusted media. If host access or privilege escalation cannot be excluded, rebuild the host/NAS using its supported recovery procedure rather than reinstalling only PMS.
- Restore reviewed media and necessary metadata selectively; do not blindly restore old codec/plugin directories, startup configuration or unknown binaries.
- From a clean system, revoke affected Plex sessions/tokens and review account access using Plex-supported controls. Plex's own guidance is to sign out of all devices in the Plex account settings and change the Plex password. If you do not rebuild cleanly, at minimum delete everything in the `Codecs` folder and check `Preferences.xml` for unexpected transcoder options. Plex prefers a clean rebuild over reusing the old data directory. [Vendor notice][vendor] Obtain vendor assistance if owner/server token invalidation is unclear.
- Rotate other credentials reachable by the Plex account, including mounted-share credentials and accessible deployment secrets, after containing the attacker. Audit those systems for subsequent access.
- Updating closes the documented entry path; it does not remove persistence or invalidate secrets already copied. The observed proxy/backdoor payloads make cleanup-only confidence particularly weak. [Reporting][reporting]

## Sources

- [Researcher disclosure and private timeline][research] — full chain, scope and demonstrated execution identity.
- [Plex release announcements][releases] — beta versus public availability and newer releases; no per-CVE fix-date breakdown.
- [October 19 exploitation reporting][reporting] — patch target and reported campaign artifacts, with attribution limitations.
- [Plex security notice and October 19 exploitation update][vendor] — CVE mapping, active-exploitation statement, compromise indicators and recovery steps.
- [CISA KEV catalog feed][kev] and [October 20 KEV alert][kevalert] — date added, due dates, required action and forensic-triage flags.
- [CVE-2026-96652 record][cve96652] (and the corresponding records for [-96654][cve96654], [-96655][cve96655], [-96656][cve96656]) and [CISA advisory VA-26-266-01][csaf] — CNA scores, affected range and publication dates.

[research]: https://zmain.info/blog/plex2shell
[vendor]: https://forums.plex.tv/t/important-security-update-for-plex-media-server-v1-43-2-and-earlier/942319
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[kevalert]: https://www.cisa.gov/news-events/alerts/2026/10/20/cisa-adds-six-known-exploited-vulnerabilities-catalog
[cve96652]: https://cveawg.mitre.org/api/cve/CVE-2026-96652
[cve96654]: https://cveawg.mitre.org/api/cve/CVE-2026-96654
[cve96655]: https://cveawg.mitre.org/api/cve/CVE-2026-96655
[cve96656]: https://cveawg.mitre.org/api/cve/CVE-2026-96656
[csaf]: https://raw.githubusercontent.com/cisagov/CSAF/develop/csaf_files/IT/white/2026/va-26-266-01.json
[releases]: https://forums.plex.tv/t/plex-media-server/30447/712
[reporting]: https://thehackernews.com/2026/10/hackers-exploit-plex2shell-flaws-to.html
