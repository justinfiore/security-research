# Security guide changelog

[Main guide](black-october/black-october-2026.md#table-of-contents) · [Maintenance policy](black-october/MAINTENANCE.md#changelog-on-every-run)

Each entry records a run that changed documentation or scripts, not a claim that readers' systems were patched. Item-level **Last updated** dates change only when the corresponding content changes. Runs without content changes leave this file untouched and do not commit or push; their outcomes and coverage gaps stay in their run threads. Historical entries retain the conventions in effect when written.

## 2026-10-26 09:00 EDT (UTC−04:00) — Setup: self-contained job and consistent navigation

**Scope:** Moved the saved maintenance job into the repository and applied the owner's navigation preference. No vulnerability research was performed; item findings and Last updated values are unchanged.

- Consolidated the full job into [MAINTENANCE.md](black-october/MAINTENANCE.md#set-up-the-checkout), including checkout recovery, the [newest-entry/48-hour search window](black-october/MAINTENANCE.md#research-each-run), source review, no-change handling, validation, commit/push verification, and [reporting and conditional archiving](black-october/MAINTENANCE.md#report-and-archive). Each fresh run can execute it without conversation history and must not create other threads. The scheduling thread will replace the saved prompt with a reference to this file after publication.
- Made the [main TOC](black-october/black-october-2026.md#table-of-contents) consistently bulleted without numeric labels and removed numbers from item headings. Explicit legacy anchors preserve shared links and detailed-guide backlinks. Updated [ordering conventions](black-october/MAINTENANCE.md#admission-and-ordering) to retain this style for new items; numbered procedural steps are unchanged.

## 2026-10-26 08:58 EDT (UTC−04:00) — Setup: hourly maintenance policy

**Scope:** Maintenance-policy alignment with the owner's replacement schedule and completion rules; no vulnerability research or discovery cutoff advanced.

- Updated the [schedule description](black-october/MAINTENANCE.md#schedule-and-scope) to hourly Eastern runs in fresh Medium threads under the workspace project. The replacement uses the project-default orb size; **a1.small** remains unverified. The old daily schedule was removed by the scheduling thread.
- Changed [changelog conventions](black-october/MAINTENANCE.md#changelog-on-every-run) so unchanged runs never generate changelog-only commits. Partial/blocked runs report missing coverage in their threads and include it in the changelog only when publishing material changes.
- Added [conditional archiving](black-october/MAINTENANCE.md#validate-and-deliver): complete coverage plus verified publication or no changes permits archiving; errors, incomplete coverage or attention needed keep the run visible and require an owner mention with a specific question. Historical entries below remain unchanged.

## 2026-10-26 08:52 EDT (UTC−04:00) — Setup: diagram readability

**Scope:** Presentation-only follow-up to the targeted additions; no research cutoff advanced.

- Grouped the [Mermaid stack decision branches](black-october/black-october-2026.md#what-should-i-patch-a-stack-based-decision-guide) into four categories after browser inspection showed that eight parallel branches made text too small. The per-stack action table retains individual patch targets, including Authenticator and Tailscale/headscale. No item findings or timestamps changed.

## 2026-10-26 08:47 EDT (UTC−04:00) — Partial: two user-supplied leads

**Scope:** Targeted research into the two supplied X posts and their primary sources on 2026-10-26, including earlier advisory history. This is not a full review of all existing items or a complete new-item sweep; no Complete discovery cutoff is advanced.

- Added [Tailworm to the main guide](black-october/black-october-2026.md#tailworm-tailscale-ssh-and-related-findings-under-review) and a [detailed per-finding guide](black-october/details/tailworm.md#interpret-the-eleven-findings-separately). Preserved researcher-rated severity, prior SSH authorization/forwarding prerequisites, vendor qualifications and non-SSH findings. Tracked the [merged source fixes separately from stable-release availability](black-october/details/tailworm.md#timeline), and included the vendor's [forwarding mitigation](black-october/details/tailworm.md#disable-unnecessary-forwarding-using-the-vendors-mitigation). No blanket “disable Tailscale” recommendation.
- Added [AuthMask / CVE-2026-80097](black-october/black-october-2026.md#authmask-microsoft-authenticator-for-android-token-theft) and [Android detection/remediation guidance](black-october/details/authmask.md#detection). Confirmed Microsoft's **8.6 High** score and corrected fixed build **6.2606.4246**. Distinguished September disclosure from October research, attributed the July release claim, and documented the [Microsoft/researcher interaction disagreement](black-october/details/authmask.md#preserve-the-interaction-disagreement).
- Extended the [stack decision guide](black-october/black-october-2026.md#what-should-i-patch-a-stack-based-decision-guide) for Android Authenticator and Tailscale/headscale. Both new entries include date tables, Back to TOC, detail subsection links and backlinks; existing item dates are unchanged.
- Added the five requested [X accounts to daily source coverage](black-october/MAINTENANCE.md#x-accounts-to-review-each-run): @The_Cyber_News, @IntCyberDigest, @NSACyber, @CISAgov and @TheHackersNews. The existing 04:00 Eastern schedule reads this policy each run; no extra schedule or account-following action was created.
- Recorded [Tailworm's owner-requested tracking exception](black-october/MAINTENANCE.md#admission-and-ordering) without lowering the default vendor/CNA High/Critical admission standard.

**Limits:** No Android device or live Tailscale deployment was tested, no exploit probes were run, and no customer secrets or settings were accessed. Tailscale's complete affected/fixed matrix and an Authenticator exact July rollout date remain unestablished. Reddit JSON timestamp access returned 403 during research, so no precise vendor-post time is asserted. Full source-list discovery and the other items were not refreshed in this targeted run.

## 2026-10-26 08:36 EDT (UTC−04:00) — Setup: readability and navigation

**Scope:** Editorial update using the already sourced timelines; no new research window or completed discovery sweep. The research cutoff is unchanged.

- Replaced all 13 main-guide date paragraphs with **Event / Date and time (timezone) / Notes** tables; see [PHP](black-october/black-october-2026.md#1-php2shell-unauthenticated-execution-below-your-application) for date-only entries and [LiteLLM](black-october/black-october-2026.md#litellm) for verified timestamps and containment windows. Missing times/timezones remain explicitly unknown.
- Added **Back to TOC** immediately below all vulnerability and incident headings, including the [related-incidents group](black-october/black-october-2026.md#related-incidents-these-need-more-than-vulnerability-patching); existing headings and [TOC destinations](black-october/black-october-2026.md#table-of-contents) are preserved.
- Updated [maintenance conventions](black-october/MAINTENANCE.md#document-and-date-conventions) so future runs preserve the tables, timezone precision and return navigation. Revision timestamps describe this editorial change, not fresh vulnerability findings; detailed guides and scripts are unchanged.

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
