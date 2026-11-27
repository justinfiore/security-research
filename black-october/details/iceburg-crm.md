# Iceburg CRM: a low-privileged user rewrites the administrator

[Main guide](../black-october-2026.md#iceburg-crm-a-low-privileged-user-rewrites-the-administrator)

**VulnCheck rates [CVE-2026-137577](https://www.cve.org/CVERecord?id=CVE-2026-137577) CVSS 4.0 8.6 High and CVSS 3.1 8.1 High.** The vectors are `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N` and `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:N`. The weakness is CWE-639. `POST /data/save` checks that the caller may write the module, and every role may write `ice_users`. It does not check that the `record_id` is the caller's own row. A signed-in user supplies the administrator's id and a new email or password. The password is hashed before it is stored, so the attacker can then sign in as that account. The project does not score it. The report tested **5.0.0**, commit `2becbbcb`, and the CVE record says **through 5.0.0**. 5.0.0 is the newest release tag. GitHub issue 33, opened November 26, is still open and has no maintainer reply. The issue includes a request that the reporter says changed the administrator's email on a local instance. No source read for this entry reports exploitation of a deployment that was not the reporter's.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Report opened | 2026-11-26; time/TZ unknown | GitHub issue 33. Tested on 5.0.0. No maintainer reply. [Issue][issue] |
| **Public announcement** | **2026-11-26; time/TZ unknown** | VulnCheck published CVE-2026-137577. CVSS 4.0 8.6 and CVSS 3.1 8.1. [CVE][cve] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. There is no fixed release. |

## Detection

Read the release tag or `composer.json`. **Through 5.0.0** is the range the record names, and 5.0.0 is the newest tag. A deployment that is not reachable by a signed-in user you do not trust is outside the practical reach of this flaw. The route requires a verified login. Reading the version changes no state. A version you cannot read means unknown, not safe.

## Remediation

1. There is **no fixed release**. Issue 33 is open, and the record names no unaffected version above 5.0.0.
2. Until one ships, do not give an account to anyone who should not be able to change the administrator's password. Taking the site off the internet removes the remote path. It does not fix the check.
3. The reporter's suggested check is not a vendor fix. Do not treat a local patch as the release.
4. Nothing here shows whether an account was already rewritten.

## Verification

- The install is not reachable by untrusted accounts, or a release newer than 5.0.0 says the `record_id` must belong to the caller.
- Do not send a `record_id` for another user to test it.

## Compromise response

Compare `ice_users.updated_at` with a change nobody made, and look for an administrator email or password that changed without that person doing it. A changed email lets the next password reset go to the attacker. If either changed, set a new administrator password, set the email back, and review records saved by other accounts after that time. The issue publishes no log line.

## Sources

- [CVE-2026-137577][cve] — VulnCheck, published 2026-11-26. CVSS 4.0 8.6 and CVSS 3.1 8.1. Affected through 5.0.0.
- [GitHub issue 33][issue] — opened 2026-11-26 by aaronamran. Tested on 5.0.0, commit `2becbbcb`. Still open.
- [v5.0.0 routes/data.php](https://github.com/iceburgcrm/iceburgcrm/blob/v5.0.0/routes/data.php) — the save route checks module write permission and then calls `saveRecord`.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. CVE-2026-137577 is not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137577
[issue]: https://github.com/iceburgcrm/iceburgcrm/issues/33
