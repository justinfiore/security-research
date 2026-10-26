# Security guide changelog

[Main guide](black-october/black-october-2026.md#table-of-contents) · [Maintenance policy](black-october/MAINTENANCE.md#changelog-on-every-run)

Each entry records a documentation/research run, not a claim that readers' systems were patched. Item-level **Last updated** dates change only when the corresponding content changes. A complete review with no substantive changes records **No Changes this run.** Incomplete reviews report their coverage gaps instead.

## 2026-10-26 08:22 EDT (UTC−04:00) — Setup

**Scope:** Expanded and refreshed the existing ten vulnerability groups and three related incidents using their cited advisory, release, research and incident sources. Historical event windows vary by item and are recorded in each timeline; sources were reviewed on 2026-10-26. This was setup and a targeted refresh, **not a complete new-vulnerability discovery sweep**. No Complete research cutoff is established; the first daily discovery run starts from 2026-10-01.

### Guide structure and automation

- Added detailed detection, remediation, verification, compromise-response and sourced timeline sections for all 13 existing items. Added dates, direct subsection links and incident navigation in the [main guide](black-october/black-october-2026.md#table-of-contents), with backlinks from each detail guide. Preserved existing numbered section anchors and the Mermaid patch decision tree.
- Defined [daily research and source coverage](black-october/MAINTENANCE.md#research-each-run), [High/Critical admission and newest-first ordering](black-october/MAINTENANCE.md#admission-and-ordering), [date semantics](black-october/MAINTENANCE.md#document-and-date-conventions), and [validated commits/pushes to main](black-october/MAINTENANCE.md#validate-and-deliver).
- Configured daily **04:00 America/New_York**, following DST, in a dedicated **Medium / a1.small** orb. First scheduled run: **2026-10-27 04:00 EDT (08:00 UTC)**. The schedule was saved and read back; no scheduled maintenance run was executed during setup.
- Existing inventory scripts remain separate and unchanged; their output is explicitly inventory evidence, not proof of patch status or absence of compromise.

### Findings and operational guidance incorporated

- **PHP:** [timeline](black-october/details/php2shell.md#timeline) separates October 21 emergency releases from the October 23 upload-progress mitigation; [detection](black-october/details/php2shell.md#look-for-suspicious-execution) links CISA's process/Sigma guidance.
- **Brotli:** [timeline](black-october/details/brotli.md#timeline) distinguishes upstream, runtime, Python and proxy release dates; [remediation](black-october/details/brotli.md#remediation) covers unsupported proxy branches, downstream encoded-byte forwarding and outbound-client exposure.
- **GitLab/Ruby:** [detection](black-october/details/gitlab-ruby.md#use-gitlabs-threat-detections) includes vendor threat rules and shared-cache/OIDC scope; [timeline](black-october/details/gitlab-ruby.md#timeline) distinguishes incomplete Ruby 4.0.8 from the complete fixes.
- **Pillow:** [per-issue detection](black-october/details/pillow.md#map-each-issue-to-an-actual-operation) records affected ranges and distinct processing prerequisites; [timeline](black-october/details/pillow.md#timeline) separates package release from individual advisory publication/revision.
- **Plex:** [timeline](black-october/details/plex2shell.md#timeline) distinguishes August 3 beta and August 4 general availability; [recovery](black-october/details/plex2shell.md#compromise-response) covers persistent codec volumes and stolen tokens.
- **Nextcloud CODE:** [migration guidance](black-october/details/nextcloud-code.md#patch-or-migrate) warns that “latest compatible” on EOL Nextcloud can remain vulnerable; [timeline](black-october/details/nextcloud-code.md#timeline) attributes September fix dates and separates community warning from formal disclosure.
- **KSMBD:** [timeline](black-october/details/ksmbd.md#timeline) now tracks the posted/reviewed October 23 SMB Direct patch without claiming a released distribution fix; [detection](black-october/details/ksmbd.md#evaluate-the-two-prerequisites-independently) includes software RDMA and distinguishes demonstrated disclosure/crashes from potential RCE.
- **WPSplinter:** [timeline](black-october/details/wpsplinter.md#timeline) and [mitigation](black-october/details/wpsplinter.md#temporary-mitigation-must-remove-the-radio-attack-path) incorporate the October 20 ISP-specific update without generalizing it to ordinary WPS toggles.
- **Header Accordions:** [timeline](black-october/details/header-accordions.md#timeline) records older per-project reports and releases; [component scope](black-october/details/header-accordions.md#component-specific-interpretation) includes quic-go clients and Wireshark's capture-decryption prerequisites.
- **BeyondTrust:** [timeline](black-october/details/beyondtrust.md#timeline) separates August exploitation, October 8 patching and October 15 disclosure; [recovery](black-october/details/beyondtrust.md#compromise-response) covers rebuilds, enrollments, sessions and brokered credentials.
- **eMudhra:** [corrected timeline](black-october/details/emudhra.md#timeline) records October 17 discovery, October 18 revocations, October 19 Go releases and the Android follow-up; [verification](black-october/details/emudhra.md#verification) distinguishes CA revocation from actual client enforcement.
- **LiteLLM:** [registry timeline](black-october/details/litellm.md#timeline) and [detection](black-october/details/litellm.md#detection) cover corrected entry point, different registry windows, cached artifacts and the private-release exception; [verification](black-october/details/litellm.md#verification) explains why official signing alone was insufficient.
- **Railway:** [timeline](black-october/details/railway.md#timeline) records October 20 detection and preliminary scope/source discrepancies; [recovery](black-october/details/railway.md#remediation) covers issuer-side revocation, old sessions, private registries and commits not queued during the pause.

### Coverage limits

- No complete new-item sweep of X, Wiz, NSA, CISA KEV or NVD was performed in this setup run. Their roles and partial-run handling are defined in the [maintenance sources](black-october/MAINTENANCE.md#sources). **CISA KEV**, not NVD, is the known-exploitation catalog.
- BeyondTrust's full KB0024066 requires customer login; its public notice was accessible. Header Accordions' fresh source still labels its matrix “as of October 20”; it does not prove later fixes do not exist.
- No universal KSMBD/NAS or WPSplinter firmware fix matrix was established. Missing private-discovery dates and unresolved incident findings are labeled, not inferred.
- No reader infrastructure, customer logs or credential systems were tested or changed. These are sourced procedures, not independent exploit reproductions or confirmation of any reader's remediation.
