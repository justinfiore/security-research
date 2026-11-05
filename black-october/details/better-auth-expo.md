# Better Auth: the Expo plugin signs a value it did not issue

**Last updated:** 2026-11-05 (America/New_York)

[Back to Better Auth summary](../black-october-2026.md#better-auth-the-expo-plugin-signs-a-value-it-did-not-issue) · [Changelog](../../CHANGELOG.md)

GitHub rates [GHSA-4wq4-2ppv-q3hg][ghsa] **Critical, CVSS 3.1 9.1**. MITRE publishes the same vector on [CVE-2026-121802][cve], also 9.1 Critical. A server that registers the `expo()` plugin from `@better-auth/expo` exposes a public endpoint that signs a caller-supplied `state` value with the application secret. An attacker who knows a user's email address can sign in as that user and change the email, with no action from the user. The same secret signs email-verification links and, when enabled, the session cookie cache. The GitHub advisory was published on 2026-11-03 and says "No known CVE." The CVE record was published on 2026-11-04.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). The advisory does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| GitHub advisory | 2026-11-03; time/TZ unknown | [GHSA-4wq4-2ppv-q3hg][ghsa], published by Bekacru. Critical, CVSS 3.1 9.1. The page says "No known CVE." |
| Patched releases | 2026-11-03; time/TZ unknown | `@better-auth/expo` and `better-auth` **1.7.16**, and **1.8.0-beta.5** on the beta line. |
| CVE record | 2026-11-04; time/TZ unknown | [CVE-2026-121802][cve], MITRE, CVSS 3.1 9.1. The record's affected range is 0 before 1.7.16, which is wider than the advisory. |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. |

## Detection

1. The server registers `expo()` from `@better-auth/expo`. The advisory says no other setting is required for the signing flaw. A Better Auth server that does not load that plugin is outside it.
2. Affected packages are `@better-auth/expo` **1.4.0-beta.6 through 1.7.15**, and **1.8.0-beta.0 through 1.8.0-beta.4**. The advisory lists the same floor and ceiling for the `better-auth` package, and also lists `better-auth` below 1.7.16. MITRE's record says Better Auth from 0 before 1.7.16 and does not name the beta line. Use the advisory's ranges for the plugin; the record's wider range is what MITRE published.
3. Two further problems in the same endpoint need extra configuration. The open redirect needs the endpoint to be reachable. A wildcard `trustedOrigins` entry, such as `myapp://*` or `https://*.example.com`, is what makes the wildcard match too much. Those are not the condition for the account takeover.
4. The attacker needs a user's email address for the email-change outcome. With the session cookie cache enabled, the advisory says a user's ID is enough.

## Remediation

1. Upgrade **both** `@better-auth/expo` and `better-auth` to **1.7.16**, or to **1.8.0-beta.5** on the 1.8 beta line. Upgrading only one of the two packages is not what the advisory says to do.
2. After the upgrade, **rotate the application secret** if the endpoint was reachable. Signatures issued before the fix stay valid until the secret changes. The CVE record repeats that note.
3. If Expo sign-in through an SSO identity provider fails after the upgrade, add that provider's origin to `trustedOrigins`.
4. If you do not use Expo social sign-in, remove the `expo()` server plugin. That is the advisory's workaround.
5. Otherwise, block requests to `/expo-authorization-proxy`, under the auth base path, whose `authorizationURL` carries a `state` value that is not exactly 32 characters from `A-Z`, `a-z`, `0-9`, `-`, and `_`. The advisory says Better Auth's own state values always have that form, and that this block stops the signing problem only. It does not stop the open redirect or the wildcard match.
6. Rotating the secret does not tell you which account's email was already changed.

## Verification

- The installed `@better-auth/expo` is **1.7.16 or later**, or **1.8.0-beta.5 or later** on the beta line, and `better-auth` is on the same floor. A lockfile that names only one of the two is not the advisory's fix.
- The application secret in the running process is not the secret that was in use while an affected plugin was reachable. A deploy that keeps the old secret leaves old signatures valid.
- A server that no longer registers `expo()` is outside the signing flaw. Confirm the running process, not only the repository.

## Compromise response

- The advisory's outcome is an email change and a sign-in as the user. Review account email changes you cannot account for, and sessions issued while the affected plugin was reachable.
- Rotating the secret invalidates signatures and cached cookies made with the old secret. It does not restore an email address that was already changed.
- The advisory does not name a log line. An unchanged email on one account does not show that another account was not changed.

## Sources

- [GHSA-4wq4-2ppv-q3hg][ghsa] — published 2026-11-03 by Bekacru. Critical, CVSS 3.1 9.1, vector `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. Affected `@better-auth/expo` from 1.4.0-beta.6 before 1.7.16, and from 1.8.0-beta.0 before 1.8.0-beta.5. The page says "No known CVE." Reporter: bearsyankees.
- [CVE-2026-121802][cve] — MITRE, published 2026-11-04. CVSS 3.1 9.1 Critical. Affected from 0 before 1.7.16. The record says to rotate the application secret after updating, and does not name the 1.8 beta line.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-05).

[ghsa]: https://github.com/better-auth/better-auth/security/advisories/GHSA-4wq4-2ppv-q3hg
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-121802
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
