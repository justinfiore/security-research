# SEPPmail: unauthenticated command execution and file deletion

**Last updated:** 2026-11-07 (America/New_York)

[Main SEPPmail summary](../black-october-2026.md#seppmail-unauthenticated-command-execution-and-file-deletion) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**NCSC.ch (CNA) rates two flaws CVSS 4.0 9.2 Critical.** NVD has not scored them. On SEPPmail Secure Email Gateway before **15.1.1**, a remote sender can run operating-system commands as root when an address-replacement rule uses text taken from the message, and can make Large File Transfer read, move, or delete a file when that feature is on. A third flaw, 8.7 High, lets an unauthenticated caller fill the disk and the worker pool through the file-upload interface. A fourth, 8.3 High, lets an unauthenticated attacker take over an unregistered GINA account whose initial password is empty. The vendor's revision history prints those last two scores on each other's CVE. [Revision history][history]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). The CVE records do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix released | 2026-11-03; time/TZ unknown | Patch release 15.1.1. The revision history, read 2026-11-07, dates the release that day and lists the five CVEs under Security. An earlier reading of the same page said 2026-10-27. [Revision history][history] |
| CVE records published | 2026-11-04 08:28–08:42 UTC | NCSC.ch. [CVE-2026-114424][cve424] at 08:28:20 UTC, [CVE-2026-114425][cve425] at 08:29:55 UTC, [CVE-2026-114426][cve426] at 08:33:13 UTC, [CVE-2026-114420][cve420] at 08:41:15 UTC, [CVE-2026-114421][cve421] at 08:42:22 UTC. |
| **Last updated** | **2026-11-07 (America/New_York)** | The revision history now dates 15.1.1 as 2026-11-03. The fixed version is unchanged. |

## Detection

This is the SEPPmail Secure Email Gateway appliance, not a mail client and not a separate GINA-only product.

Read the running version in the admin GUI (the revision history is the vendor's version record). The CNA's affected range for every CVE in this cluster is **before 15.1.1**.

| Running release | Status |
|---|---|
| Before 15.1.1, including 15.1.0 and 15.1.0.1 | Vulnerable to all five CVEs. |
| 15.1.1 and later | Fixed, per the revision history and the CNA records. |

Two of the Critical flaws have an extra condition the version check does not show:

- [CVE-2026-114424](https://www.cve.org/CVERecord?id=CVE-2026-114424) runs only when an active sender or recipient replacement rule uses replacement text taken from the message, and that rule's search matches. The CNA's vector sets attack requirements to Present (`AT:P`). The revision history says the result is an arbitrary command. The CNA says the worker that ran it was root.
- [CVE-2026-114425](https://www.cve.org/CVERecord?id=CVE-2026-114425) needs Large File Transfer enabled, and the message has to reach the secure-mail path that reads attachment metadata. The CNA says the workers that ran were root, and that the caller can disclose, move, or delete an accessible regular file.

[CVE-2026-114426](https://www.cve.org/CVERecord?id=CVE-2026-114426) has no such condition: the v1 file-upload interface processed the body before it checked authentication, and it had no absolute size limit. [CVE-2026-114421](https://www.cve.org/CVERecord?id=CVE-2026-114421) needs a GINA account that was created and not yet registered, with an empty initial password.

## Remediation

1. **Upgrade the gateway to 15.1.1 or later.** The revision history, read 2026-11-07, dates that patch release 2026-11-03. An earlier reading of the same page said 2026-10-27. One upgrade covers all five CVEs. There is no workaround in the revision history or the CVE records.
2. **Do not trust the scores printed next to the GINA CVEs in the revision history.** It assigns 6.9 to [CVE-2026-114421](https://www.cve.org/CVERecord?id=CVE-2026-114421) and 8.3 to [CVE-2026-114420](https://www.cve.org/CVERecord?id=CVE-2026-114420). The NCSC.ch records, which are the CNA scores, are the other way around: 8.3 High for 114421 (account takeover) and 6.9 Medium for 114420 (email-address enumeration). The 9.2 and 8.7 lines match the records.
3. The upgrade does not show whether a command already ran, whether a file was read or deleted, or whether a GINA password was reset.

## Verification

- The admin GUI reports **15.1.1 or later**. A host still on 15.1.0 or 15.1.0.1 is not fixed.
- After the upgrade, a replacement rule that inserts message text no longer evaluates that text as Perl. The revision history says rule values are now escaped and the rule engine was hardened against code execution.
- Large File Transfer, if you use it, rejects attachment metadata that names a path. The revision history says metadata is validated before any file is accessed.
- The v1 file-upload interface asks for authentication before it writes the body, and it limits the upload size.

## Compromise response

- If the gateway was reachable and running a release before 15.1.1, review the mail log and admin log for commands, file paths, or worker crashes you cannot account for. The CNA says the mail-processing worker ran as root, so a successful command is not confined to the mail spool.
- For [CVE-2026-114425](https://www.cve.org/CVERecord?id=CVE-2026-114425), look for files that moved or disappeared on a host where Large File Transfer was enabled. The upgrade does not restore a deleted file.
- For [CVE-2026-114421](https://www.cve.org/CVERecord?id=CVE-2026-114421), review GINA accounts that were created and not registered. An attacker who set a password on one of them can sign in as that account until the password is recovered. The revision history says recovery now asks only registered users who configured security questions.
- [CVE-2026-114426](https://www.cve.org/CVERecord?id=CVE-2026-114426) is availability only: workers occupied and temporary storage filled. Clearing `/tmp` after the upgrade does not tell you whether one of the other flaws was used in the same window.

## Sources

- [SEPPmail revision history][history] — patch release 15.1.1, dated 2026-11-03 on the page read 2026-11-07. An earlier reading said 2026-10-27. Five CVEs under Security, with fix descriptions. The page prints 6.9 on CVE-2026-114421 and 8.3 on CVE-2026-114420; the CNA records swap those two scores.
- [CVE-2026-114424][cve424] — NCSC.ch, published 2026-11-04 08:28:20 UTC. CVSS 4.0 9.2 Critical (`AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`). Address-replacement rules evaluate message text as Perl. The worker context was root. Credit: Dario Weiss of InfoGuard Labs.
- [CVE-2026-114425][cve425] — NCSC.ch, published 2026-11-04 08:29:55 UTC. CVSS 4.0 9.2 Critical (same vector shape, `AT:P`). Large File Transfer trusts a path in attachment metadata and can disclose, move, or delete a regular file. Workers ran as root. Credit: Dario Weiss of InfoGuard Labs.
- [CVE-2026-114426][cve426] — NCSC.ch, published 2026-11-04 08:33:13 UTC. CVSS 4.0 8.7 High (`AT:N`, availability High only). The v1 file interface writes the upload before it authenticates the caller, with no absolute size limit.
- [CVE-2026-114421][cve421] — NCSC.ch, published 2026-11-04 08:42:22 UTC. CVSS 4.0 8.3 High (`AT:P`, `VC:L/VI:H/VA:L`). Password recovery for an unregistered GINA account with an empty initial password. Credit: Synack, Inc. The revision history prints 6.9 on this CVE.
- [CVE-2026-114420][cve420] — NCSC.ch, published 2026-11-04 08:41:15 UTC. CVSS 4.0 6.9 Medium. Unauthenticated LDAP metacharacters in a GINA account lookup enumerate email addresses. Below the High bar on its own; included because the same release fixes it. The revision history prints 8.3 on this CVE and repeats the account-takeover description.
- [CISA KEV JSON feed][kev] — none of these CVEs is listed (catalog 2026.11.04, checked 2026-11-05).

[history]: https://docs.seppmail.com/en/20_revision-history.html
[cve424]: https://www.cve.org/CVERecord?id=CVE-2026-114424
[cve425]: https://www.cve.org/CVERecord?id=CVE-2026-114425
[cve426]: https://www.cve.org/CVERecord?id=CVE-2026-114426
[cve421]: https://www.cve.org/CVERecord?id=CVE-2026-114421
[cve420]: https://www.cve.org/CVERecord?id=CVE-2026-114420
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
