# SAP NetWeaver Visual Composer: low-privileged access to backend operations on connected systems

**Last updated:** 2026-10-26 (America/New_York)

[Main SAP NetWeaver Visual Composer summary](../black-october-2026.md#sap-netweaver-visual-composer-low-privileged-access-to-backend-operations-on-connected-systems) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-89110](https://www.cve.org/CVERecord?id=CVE-2026-89110): SAP (CNA) CVSS 3.1 9.9 Critical (CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:C/C:H/I:H/A:H); SAP Patch Day priority HotNews / Critical, CVSS 9.9 (SAP's page links a CVSS 3.0 calculator for the same vector). NVD shows only SAP's score and has added none of its own.** This is a broken access control flaw (CWE-749, exposed dangerous method or function) in **SAP NetWeaver Visual Composer**, component **VC70RUNTIME 7.50** (SAP component EP-VC-RTM). SAP says certain portal functionality does not check authorization sufficiently, so an attacker **with low privileges** can invoke internal operations on a **preconfigured remote system**. Depending on how that remote connection is configured, SAP says this "could lead to a full compromise of the remote system". [SAP Patch Day][sap] [CNA][cve]

**What the fix changes:** Onapsis, which found the issue, says Visual Composer already had a security configuration that allowlists the data services a model may invoke, but it was **not enabled by default**. The patch enables the secure setting by default; SAP Note 3797111 also explains how to enable it manually before patching. RedRays' patch comparison shows the `SecurityMode` property of the `VCBrokerConfiguration` profile changing from `false` to `true`, with the checking code itself unchanged. [Onapsis][onapsis] [RedRays note analysis][redrays]

**Worst case:** The attacker needs only a low-privileged portal account and network access to Visual Composer. The damage is set by the backend: an attacker can call RFC, BAPI or data-service operations on the remote system through the connection Visual Composer uses, with whatever identity and permissions that destination carries. A destination with broad backend rights could lead to full compromise of that backend system. [RedRays note analysis][redrays] [CNA][cve]

**Related item:** The same Patch Day's SAP Cloud SDK for Python flaw, [CVE-2026-89111](https://www.cve.org/CVERecord?id=CVE-2026-89111), is tracked separately in [sap-cloud-sdk-python.md](sap-cloud-sdk-python.md).

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Exposure and backend reach](#exposure-and-backend-reach)
  - [Log review (read-only)](#log-review-read-only)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery/report | Unknown | Onapsis Research Labs says it detected the issue and helped SAP patch it. No report date is published. [Onapsis][onapsis] |
| CVE ID reserved | 2026-09-10 22:24:03 UTC | CNA metadata. [CNA][cve] |
| CVE record published | 2026-10-13 00:24:17 UTC | CNA metadata. NVD published 2026-10-13 01:16:47 (NVD API, UTC). [CNA][cve] [NVD][nvd] |
| SAP Security Patch Day, SAP Note 3797111 and fixes | 2026-10-13; time/TZ unknown | Public announcement. Note 3797111, HotNews, CVSS 9.9, VC70RUNTIME 7.50. RedRays reports the note lists patches for SP30–SP36 (patch level 1, SP32 patch level 2) and patch level 0 entries for SP37 and SP38. The note itself requires an SAP login and was not read directly. [SAP Patch Day][sap] [RedRays note analysis][redrays] |
| CISA ADP SSVC assessment | 2026-10-14 (record update 03:58:55 UTC) | Exploitation: none; Automatable: no; Technical impact: total. [CNA][cve] |
| Exploitation evidence | None found | No vendor, government or researcher report of exploitation was found in the reviewed sources. |
| CISA KEV | Not listed (catalog 2026.10.23) | Checked 2026-10-26 against the live feed. [KEV JSON][kev] |

## Detection

### Inventory

1. List every SAP NetWeaver AS Java / Enterprise Portal system where Visual Composer is deployed, including development, quality, sandbox and disaster-recovery systems.
2. Record the deployed **VC70RUNTIME 7.50** support package (SP) and patch level. In SAP NetWeaver Administrator this is shown under the system's component information; your Solution Manager or landscape inventory may already hold it. Reading it changes no state.
3. Compare the level with the patch table in [SAP Note 3797111][note]. Per RedRays' reading of the note: SP30 PL1, SP31 PL1, SP32 PL2, SP33 PL1, SP34 PL1, SP35 PL1, SP36 PL1, and SP37 or SP38 PL0. Treat this list as secondary and confirm it in the note, because it was not read directly here. [RedRays note analysis][redrays]
4. Systems on support packages older than those in the patch table need an SP upgrade path from SAP; do not assume they are unaffected.

### Exposure and backend reach

- **Who can reach it:** The attacker needs a low-privileged authenticated portal user. List who holds portal accounts that can open Visual Composer content, including partner, external and shared accounts, and from which networks the portal is reachable.
- **What it can reach:** List every backend system alias and destination Visual Composer models use, and record the backend user (fixed technical user or user mapping) and its authorizations. RedRays notes that the connector passes the portal user and system alias to the destination service, so the effective backend identity depends on your destination and user-mapping configuration. Destinations with broad technical users carry the highest risk. [RedRays note analysis][redrays]
- **Secure Mode status:** Check whether Visual Composer Secure Mode is enabled, following SAP's "Setting Secure Mode" instructions referenced from Note 3797111 and [FAQ note 3797831][faq]. If it is off and the SP is below the patch table, treat the system as exposed.

### Log review (read-only)

SAP and the reviewed researchers have published **no indicators of compromise** for this flaw. Useful evidence sources are:

- **AS Java HTTP access logs** for Visual Composer requests from users who do not normally build or run Visual Composer models, from unusual source networks, or at unusual volume.
- **Backend logs for the Visual Composer destinations:** on ABAP backends, the Security Audit Log (transaction `SM20` or `RSAU_READ_LOG`) for RFC function calls made by the destination's user that do not match the functions your Visual Composer models legitimately use. Changes to users, roles or critical tables made through that user are high-priority leads.

The command below only reads files and has not been run on a real SAP system. Run it as a user that can read an **exported copy** of the AS Java HTTP access logs. Replace `VC_ACCESS_LOGS` with the exported log files. It lists requests to Visual Composer paths so you can review the users and sources:

```sh
grep -i -n 'visualcomposer' VC_ACCESS_LOGS
```

The match string is a starting point, not an IOC: the vulnerable request paths are not published, and absence of matches does not prove the system was not abused.

## Remediation

1. **Apply SAP Note 3797111** using the support package patch for your VC70RUNTIME 7.50 SP, following SAP's deployment procedure for AS Java. Read [FAQ note 3797831][faq] first. [SAP Patch Day][sap] [Onapsis][onapsis]
2. **Until you can patch, enable Secure Mode.** SAP documents enabling Visual Composer Secure Mode as the temporary workaround. RedRays reports that the note requires a manual restart of the `com.sap.visualcomposer` application in NetWeaver Administrator after the change; without the restart the procedure is incomplete. Plan the restart in a maintenance window. [Onapsis][onapsis] [RedRays][redrays-overview]
3. **Make sure legitimate models still work.** Secure Mode checks each requested data-service function against the model's permitted-function allowlist. Models whose allowlist does not contain the functions they call will fail after the patch or the workaround. Test business-critical Visual Composer applications in a non-production system first, and fix their allowlists rather than turning Secure Mode off. [RedRays note analysis][redrays]
4. **Reduce backend reach.** Restrict the authorizations of destination users that Visual Composer uses to what the models need, and remove unused destinations and system aliases. This limits damage but does not replace the correction.
5. **Rollback caution:** Rolling back the patch or disabling Secure Mode re-opens the flaw.

## Verification

- Confirm the deployed VC70RUNTIME 7.50 SP and patch level on every AS Java instance (including all cluster nodes) matches or exceeds the patch table in Note 3797111.
- Confirm Secure Mode is effective at runtime (RedRays: `SecurityMode` is `true` after the fix), and that `com.sap.visualcomposer` was restarted after any manual change. [RedRays note analysis][redrays]
- Run your business Visual Composer applications with their normal roles and confirm they still reach the data services they need. Do not attempt to call non-allowlisted backend functions against production as a test.

## Compromise response

- If a system was on an unpatched SP without Secure Mode and had low-privileged portal users, scope the investigation to the **backend systems** behind its destinations, not just the portal.
- On those backends, review changes made by the destination users: new or changed users and roles, changed critical configuration or business data, and unexpected RFC calls. Preserve AS Java and backend audit logs before changing anything.
- Rotate the credentials of technical users used by Visual Composer destinations if abuse is suspected, and review the portal accounts that made unexpected Visual Composer calls.
- Escalate to SAP support and your SAP security team. Patching or enabling Secure Mode does not undo changes already made in a backend.

**Context:** A different Visual Composer flaw, the 2025 unrestricted file upload [CVE-2025-31324](https://www.cve.org/CVERecord?id=CVE-2025-31324) (KEV entry "SAP NetWeaver", added 2025-04-29), was widely exploited. It is not the same issue, but it shows Visual Composer is a known attacker target, and systems that were vulnerable to it should already have been investigated. [KEV JSON][kev]

## Sources

- [SAP Security Patch Day – October 2026][sap]: Note 3797111, CVE, priority, CVSS 9.9, VC70RUNTIME 7.50.
- [CVE record (SAP CNA)][cve] and [NVD][nvd]: description, CWE-749, CVSS 3.1 vector, timestamps, CISA ADP SSVC.
- [SAP Note 3797111][note] and [FAQ note 3797831][faq]: authoritative fix and workaround (SAP login required; not read directly for this guide).
- [Onapsis October 2026 Patch Day analysis][onapsis]: discovery, allowlist configuration, default change.
- [RedRays Note 3797111 analysis][redrays] and [RedRays Patch Day overview][redrays-overview] (researcher, secondary for the note contents): patch table, `SecurityMode` change, Secure Mode restart requirement.
- [CISA KEV JSON feed][kev]: not listed in catalog 2026.10.23.

[sap]: https://support.sap.com/en/my-support/knowledge-base/security-notes-news/october-2026.html
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-89110
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-89110
[note]: https://me.sap.com/notes/3797111
[faq]: https://me.sap.com/notes/3797831
[onapsis]: https://onapsis.com/blog/sap-security-patch-day-october-2026
[redrays]: https://redrays.io/blog/sap-note-3797111-visual-composer-access-control-cve-2026-89110/
[redrays-overview]: https://redrays.io/blog/sap-security-patch-day-october-2026
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
