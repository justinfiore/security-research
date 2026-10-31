# Assent: Sign in with Apple callback overrides verified identity

**Last updated:** 2026-10-31 (America/New_York)

[Main Assent summary](../black-october-2026.md#assent-sign-in-with-apple-callback-overrides-verified-identity) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-117656](https://www.cve.org/CVERecord?id=CVE-2026-117656) — Erlang Ecosystem Foundation (CNA) CVSS 4.0 9.3 Critical** (`AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N`). NVD has not published its own score. [GHSA-9fr5-g44g-9526](https://github.com/pow-auth/assent/security/advisories/GHSA-9fr5-g44g-9526) repeats Critical 9.3.

Assent's Sign in with Apple strategy merges the callback's unsigned `user` form parameter over the claims of the verified ID token. An attacker who completes Sign in with Apple with their own Apple ID, then edits that parameter, can replace `sub`, `email`, and any other claim. Applications that look up, link, or authorize accounts by the returned subject or email then treat the attacker as that user. The returned map also marks `email_verified` true.

Only apps that call `Assent.Strategy.Apple` are on this path. Other Assent strategies are not this flaw. Versions before 0.1.25 are outside the affected range the CNA published.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-10-31). The advisory does not report in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | GHSA credits NotAFlightRisk (Iain). No report date is published. |
| Fix commit | Commit `18898bd`; date not taken from the advisory | Default behavior ignores the `user` parameter. [Commit][fix] |
| Public advisory and CVE | 2026-10-30 23:55:23 UTC | EEF CNA published the record; GHSA-9fr5-g44g-9526 the same calendar day. [GHSA][ghsa] [CNA page][eef] |

## Detection

1. In the application that handles Sign in with Apple, read the locked `assent` version from `mix.lock` (or the Hex dependency). Affected is **0.1.25 up to but not including 0.3.2**. A git pin from `a2d331e` before `18898bd` is the same range.
2. Confirm the app actually uses `Assent.Strategy.Apple`. A dependency on Assent with only Google, GitHub, or another strategy does not exercise this callback. Do not treat "we have the package" alone as proof the Apple path is reachable, and do not treat an unused strategy as proof a future config change is safe.
3. There is no log signature in the advisory. A successful login through the Apple strategy on an affected version is not, by itself, evidence of impersonation.

## Remediation

1. Upgrade `assent` to **0.3.2 or later**, rebuild, and redeploy every node that serves the Apple callback. Version 0.3.2 ignores the callback `user` parameter by default. If you set `include_unverified_name: true`, only `given_name` and `family_name` are taken from it, and verified claims are merged over them so `sub` and `email` cannot be replaced.
2. Until the upgrade is deployed, delete the parameter before the strategy runs: `Map.delete(params, "user")` and then `Assent.Strategy.Apple.callback/2`. The user's name is then unavailable, because Apple delivers it only through that parameter. This is a temporary mitigation, not the release.
3. After upgrading, review accounts linked or created from Apple `sub` or `email` while an affected version was in production. The advisory does not provide a way to distinguish a forged callback from a real one after the fact.

## Verification

- Confirm the running release resolves `assent` 0.3.2 or later, then complete a normal Sign in with Apple flow you already use.
- Do not intercept a production callback or submit a forged `user` parameter to test the flaw.

## Compromise response

If an affected Apple strategy was reachable, preserve authentication logs for the period the affected version was deployed. Look for accounts whose Apple subject or email changed without a matching support action, new links to existing emails, and sessions created for users who did not sign in. Upgrading stops the merge; it does not show whether an earlier callback was edited. Reset sessions for accounts that look linked to the wrong Apple identity, and unlink those identities before the user signs in again.

## Sources

- [GHSA-9fr5-g44g-9526][ghsa] — Critical 9.3, affected range 0.1.25 through before 0.3.2, the `user`-parameter merge, the 0.3.2 behavior, and the `Map.delete` workaround.
- [EEF CNA record][eef] and [CVE-2026-117656][cve] — published 2026-10-30 23:55:23 UTC; CVSS 4.0 9.3; the unsigned parameter overwrites verified `sub` and `email`.
- [Fix commit 18898bd][fix] — the patch the CNA cites.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.10.30).

[ghsa]: https://github.com/pow-auth/assent/security/advisories/GHSA-9fr5-g44g-9526
[eef]: https://cna.erlef.org/cves/CVE-2026-117656.html
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-117656
[fix]: https://github.com/pow-auth/assent/commit/18898bde0296152165ae470078490e5798329b1b
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
