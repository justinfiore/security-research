# Twenty: a signup returns someone else's invitation

**Last updated:** 2026-11-26 (America/New_York)

[Main guide](../black-october-2026.md#twenty-a-signup-returns-someone-elses-invitation)

**GitHub rates [GHSA-m4vm-35cw-44rq](https://github.com/twentyhq/twenty/security/advisories/GHSA-m4vm-35cw-44rq) High, CVSS 3.1 7.4.** The vector is `CVSS:3.1/AV:N/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:N`. VulnCheck's [CVE-2026-137584](https://www.cve.org/CVERecord?id=CVE-2026-137584) scores the same issue CVSS 3.1 7.4 and CVSS 4.0 9.1 Critical (`CVSS:4.0/AV:N/AC:H/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`). The weaknesses are CWE-287 and CWE-200. On a multi-workspace install, the public `signUp` mutation creates an account for any email and returns the plaintext `personalInviteToken` of every pending invitation for that email. `signUpInWorkspace` accepts the token, joins the workspace with the invitation's role, including Admin, and marks the email verified. No mailbox and no existing account are required. The GitHub advisory says it tested **v2.47.0** and lists affected versions as **2.47.0 and earlier**, with **no patched version**. The CVE record says **through 2.63.0**. The source of tag `twenty/v2.63.0`, read November 26, still copies `appToken.value` into `personalInviteToken` in the signup response. That tag is the latest release, dated November 24. The GitHub page still says "No known CVE." The advisory says the live Cloud service was not tested. No source read for this entry reports exploitation.

The conditions are the ones the advisory names. Multi-workspace mode has to be on, which is the Cloud setup. A pending invitation, valid 30 days, has to exist for an address that does not yet have an account, on a workspace that is not hidden. The caller has to know that address. A configured CAPTCHA has to be solved.

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
| Advisory published | 2026-10-22; time/TZ unknown | GHSA-m4vm-35cw-44rq, High, CVSS 3.1 7.4. Tested on v2.47.0. Patched versions: none. [GHSA][ghsa] |
| Latest release | 2026-11-24 22:19:18 UTC | `twenty/v2.63.0`. The signup response still returns `personalInviteToken`. [Release][rel] |
| **Public CVE record** | **2026-11-26; time/TZ unknown** | VulnCheck published CVE-2026-137584. CVSS 4.0 9.1 and CVSS 3.1 7.4. Affected through 2.63.0. [CVE][cve] |
| **Last updated** | **2026-11-26 (America/New_York)** | New item. There is no fixed release. |

## Detection

A single-workspace install is outside this flaw. Multi-workspace mode is `IS_MULTIWORKSPACE_ENABLED=true`. Read the running version from the image tag or the release. **Through 2.63.0** is the range the CVE record names, and 2.63.0 is the newest tag as of November 26. An invitation that is not pending cannot be taken this way. Reading the configuration changes no state. A version you cannot read means unknown, not safe.

## Remediation

1. There is **no fixed release**. The GitHub advisory lists no patched version, and 2.63.0 still returns the token.
2. Until one ships, do not leave a pending invitation on an internet-reachable multi-workspace install. Revoke invitations that are no longer needed, and send a new one only when the recipient is ready to accept it the same day.
3. A configured CAPTCHA raises the cost. It does not close the flaw.
4. Turning email verification on does not help. The advisory says `signUpInWorkspace` marks the email verified.
5. Nothing here shows whether an invitation was already consumed.

## Verification

- Pending invitations are revoked, or the install is not multi-workspace.
- When a release newer than 2.63.0 ships, confirm its advisory or its source no longer returns `personalInviteToken` from `signUp` before treating it as the fix.
- Do not call `signUp` with someone else's address to test it.

## Compromise response

Look for a member who joined a workspace without accepting the emailed invitation, especially with the Admin role. The real invitee's invitation is consumed when this works, so an invitation that disappeared without the recipient using it is a lead. An unexpected Admin can export CRM data, create an API key, and add another member. Remove that member, revoke the keys, and review changes made after the join. The advisory publishes no log indicator.

## Sources

- [GHSA-m4vm-35cw-44rq][ghsa] — published 2026-10-22 by charlesBochet. High, CVSS 3.1 7.4. Affected `<= 2.47.0`. Patched versions: none. The page says no CVE is known.
- [CVE-2026-137584][cve] — VulnCheck, published 2026-11-26. CVSS 4.0 9.1 and CVSS 3.1 7.4. Affected through 2.63.0.
- [twenty/v2.63.0][rel] — published 2026-11-24 22:19:18 UTC. Latest release on November 26. `user-workspace.service.ts` still sets `personalInviteToken` from `appToken.value`.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. CVE-2026-137584 is not listed.

[ghsa]: https://github.com/twentyhq/twenty/security/advisories/GHSA-m4vm-35cw-44rq
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-137584
[rel]: https://github.com/twentyhq/twenty/releases/tag/twenty%2Fv2.63.0
