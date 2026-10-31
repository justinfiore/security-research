# ServiceNow AI Platform: admin sandbox escape and stored plaintext passwords

**Last updated:** 2026-10-31 (America/New_York)

[Main ServiceNow summary](../black-october-2026.md#servicenow-ai-platform-admin-sandbox-escape-and-stored-plaintext-passwords) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

ServiceNow published three issues together on 2026-10-29. Two meet this collection's High/Critical bar. The third does not and is recorded only so it is not confused with the others.

| Issue | Score | Who can use it | What it does |
|---|---|---|---|
| [CVE-2026-103093](https://www.cve.org/CVERecord?id=CVE-2026-103093): Rhino sandbox escape | ServiceNow (CNA) CVSS 4.0 **9.4 Critical** (`AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`) | An authenticated user with the **admin** role | Bypass Rhino sandbox restrictions and execute arbitrary code on the host operating system. |
| [CVE-2026-103094](https://www.cve.org/CVERecord?id=CVE-2026-103094): plaintext password stored in a system table | ServiceNow (CNA) CVSS 4.0 **7.1 High** (`AV:N/AC:L/AT:P/PR:L/UI:N/VC:H/VI:N/VA:N/SC:H/SI:H/SA:N`). The record title says "Cleartext Storage of OAuth Credentials"; the description says a user's plaintext password. | A user who can read that table and otherwise would not be entitled to the password | A user's plaintext password can be persisted in a system table. |
| [CVE-2026-6877](https://www.cve.org/CVERecord?id=CVE-2026-6877): domain separation bypass in the SR – CSM – Task Plan Templates Store app | ServiceNow (CNA) CVSS 4.0 **5.3 Medium** | An authenticated user with a specific role, and only if that Store app is installed | Create records in domains the user cannot access. Below this collection's admission bar. |

NVD lists the records as received and has not published its own scores. CISA's October 29 enrichment records Exploitation "none" for both CVE-2026-103093 and CVE-2026-103094. ServiceNow says it did not identify malicious exploitation.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31) for CVE-2026-103093, CVE-2026-103094, or CVE-2026-6877. ServiceNow reports no evidence of malicious exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | ServiceNow says the issues came from internal testing, customer assessments, or its disclosure and bug-bounty programs. No report date is published. [KB3228994][kb] |
| CVE records published | 2026-10-29 18:54:22 UTC (CVE-2026-103093), 18:40:52 UTC (CVE-2026-103094), 18:49:37 UTC (CVE-2026-6877) | ServiceNow CNA. [CVE-2026-103093][cve093] |
| Public advisory | 2026-10-29; time/TZ unknown | KB3228994 version 1.0, "Initial publication". [KB3228994][kb] |
| CISA exploitation assessment | 2026-10-29 20:36 UTC (CVE-2026-103093) and 20:38 UTC (CVE-2026-103094) | ADP records Exploitation "none". |

## Detection

1. Read the instance family and patch from the instance version, not from a ticket that says "September patching." Hosted instances that already received the September Patching Program builds below include both platform fixes. Self-hosted instances need the same build names installed locally; ServiceNow's self-hosted FAQ (KB3228997) is login-gated, so this guide does not add claims from it.
2. For [CVE-2026-103093][cve093], the CNA lists builds before these as affected: **Yokohama Patch 13 Hot Fix 4a**, **Zurich Patch 10 Hot Fix 3b**, **Zurich Patch 12**, **Zurich Patch 13**, and **Australia Patch 5**. KB3228994 also lists later builds that contain the same fix: Yokohama Patch 13 Hotfix 5a, and Zurich Patch 10 Hotfix 4b.
3. For [CVE-2026-103094][cve094], the fixed floor is wider. The CNA lists builds before: **Xanadu Patch 11 Hot Fix 7a**, **Yokohama Patch 13 Hot Fix 4a**, **Zurich Patch 10 Hot Fix 3a**, **Zurich Patch 11 Hot Fix 1**, **Zurich Patch 11m**, **Zurich Patch 12**, **Zurich Patch 13**, **Australia Patch 2 Hot Fix 3b**, **Australia Patch 4 Hot Fix 1**, **Australia Patch 4m**, and **Australia Patch 5**. A build that fixes only the sandbox escape is not necessarily the password-storage fix on Xanadu or the Australia hotfixes.
4. An instance whose family is older than the ranges above is not automatically safe. The CNA uses "before <fixed build>" inside each named family and does not publish a complete unaffected list for every older family. Treat an unlisted family as unknown until ServiceNow confirms it.
5. [CVE-2026-6877][cve6877] applies only when **SR - CSM - Task Plan Templates** is installed. In the instance, open **now/app-manager**, search for that application, and compare with 2.0.1, 3.0.0, 4.0.0, or 5.0.0. If it is not installed, that Medium issue does not apply. Version 3.0.0 requires Yokohama or later; Xanadu and earlier cannot install it and need a family upgrade. Version 2.0.1 is not a manual install.

There is no public indicator, log query, or scripted check for whether the sandbox escape ran or a password was written to the table. ServiceNow does not name the table. Absence of an alert is unknown, not safe.

## Remediation

1. For hosted instances, confirm the running release is one of the builds in [Detection](#detection). ServiceNow says instances already on those builds need no further platform action for these three CVEs. If it is not, open a Support case with the subject ServiceNow specifies: "October 2026 Batched CVE Release".
2. For self-hosted instances, install the same family build ServiceNow provided to partners and self-hosted customers. Do not invent a patch number from the hosted hotfix list if your delivery package uses a different name; match the CNA's fixed floor for your family.
3. The sandbox escape needs an admin role. Removing unused admin accounts reduces who can reach it, but it is not a substitute for the update, and ServiceNow publishes no configuration workaround.
4. For the password-storage flaw, the update stops the unintended persistence. It does not say whether passwords already written to the table are removed. After the update, treat passwords that may have been readable by a less-privileged user as exposed: reset them and revoke sessions for accounts that could have been read. ServiceNow does not name which accounts or table, so this is a precaution, not a confirmed exposure list.
5. For the Medium Store app, upgrade SR - CSM - Task Plan Templates to 3.0.0 or later, or reach 2.0.1 by upgrading the instance family as KB3228994 describes. Skip this if the app is not installed.

## Verification

- Confirm the instance version string is at or above the fixed floor for its family, for both CVEs, not only the Critical one.
- Sign in and load an admin page you already use. Do not attempt a sandbox escape or a password read.

## Compromise response

ServiceNow says it is not aware of malicious exploitation. If an admin account you do not trust was active before the sandbox-escape fix, preserve instance logs and the admin's activity history before cleanup, and look for unexpected script includes, scheduled jobs, and new admin users. Updating the platform closes the documented path; it does not show whether that path was used.

For the password flaw, identify accounts whose passwords may have been stored where a less-privileged user could read them, reset those passwords at the identity provider or local account, and invalidate existing sessions. A version check cannot show whether a password row was read.

## Sources

- [ServiceNow KB3228994][kb] — October 29, 2026 advisory: scores, the three issues, hosted fixed builds, and the statement of no identified exploitation.
- [CVE-2026-103093][cve093] — ServiceNow CNA, published 2026-10-29 18:54:22 UTC, CVSS 4.0 9.4 Critical, affected floors, CISA ADP Exploitation "none".
- [CVE-2026-103094][cve094] — ServiceNow CNA, published 2026-10-29 18:40:52 UTC, CVSS 4.0 7.1 High, wider affected floors, CISA ADP Exploitation "none".
- [CVE-2026-6877][cve6877] — ServiceNow CNA, CVSS 4.0 5.3 Medium; included so the Store-app issue is not treated as one of the High/Critical flaws.
- [CISA KEV JSON feed][kev] — none of the three CVEs listed (catalog 2026.10.30).

[kb]: https://support.servicenow.com/kb?id=kb_article_view&sysparm_article=KB3228994
[cve093]: https://www.cve.org/CVERecord?id=CVE-2026-103093
[cve094]: https://www.cve.org/CVERecord?id=CVE-2026-103094
[cve6877]: https://www.cve.org/CVERecord?id=CVE-2026-6877
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
