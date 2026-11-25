# Apache Shiro: a cached LDAP login accepts any password

**Last updated:** 2026-11-25 (America/New_York)

[Main Shiro summary](../black-october-2026.md#apache-shiro-a-cached-ldap-login-accepts-any-password) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Apache Shiro is a Java authentication and authorization library. [CVE-2026-129349](https://www.cve.org/CVERecord?id=CVE-2026-129349) is in `DefaultLdapRealm` and `JndiLdapRealm`. With authentication caching turned on, a user who has logged in once can log in again with any password, because the cache hit skips the LDAP bind and the realm's default credentials matcher accepts anything. Apache is the CNA and rates it **CVSS 4.0 9.1 Critical**. The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:N/SC:N/SI:N/SA:N/S:N/AU:Y/R:U/V:C/RE:L/U:Red`. Caching is off by default. The fix is **3.0.1 or later**.

The same November 13–14 [announcement][oss349] covers seven more flaws. Apache rates three of them Medium and four Low, all below this guide's admission threshold, and all of them are fixed in **3.0.2**. Shiro 2.x reached end of life on 2026-06-29 and does not get the LDAP fix.

**CISA KEV:** Not listed (catalog 2026.11.13, checked 2026-11-15) for any of the eight CVEs. Apache's notices do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [The other seven](#the-other-seven)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Shiro 2.x end of life | 2026-06-29 | The project says only the most recent line receives all security fixes. [Security reports][reports] |
| Shiro 3.0.1 | date not published by the project | Stops installing `AllowAllCredentialsMatcher` by default and fixes the RememberMe session fixation. The advisory names the version and not the release time. [oss-security][oss349] |
| Shiro 3.0.2 published | 2026-11-08 06:26:50 UTC | Fixes the remaining six. The notes describe the behavior changes and do not name the CVE identifiers. [3.0.2][rel302] |
| **Public announcement** | **2026-11-13 23:28:57 UTC through 2026-11-14 05:37:47 UTC** | Lenny Primak posted the eight advisories to oss-security, ending with CVE-2026-129349. [oss-security][oss349] |
| **Project page lists the CVEs** | **2026-11-25; time/TZ unknown** | The security-reports index now names CVE-2026-129349, CVE-2026-129348, CVE-2026-129347, and CVE-2026-129320. The fix versions are unchanged. |
| **Last updated** | **2026-11-25 (America/New_York)** | The project page caught up. The upgrade is still 3.0.2. |

## The other seven

Apache's own scores, from the oss-security posts. None of these meets the High threshold on its own. They ship in the same upgrade.

| CVE | What it is | Apache's score | Fixed |
|---|---|---|---|
| [CVE-2026-74763](https://www.cve.org/CVERecord?id=CVE-2026-74763) | `@RequiresRoles` and `@RequiresPermissions` on an interface are not enforced in `shiro-guice`, `shiro-aspectj`, `shiro-cdi`, and `shiro-jakarta-ee`. A class or superclass annotation can also be missed in the first two. | 6.3 Medium | 3.0.2 |
| [CVE-2026-88019](https://www.cve.org/CVERecord?id=CVE-2026-88019) | Replaying a saved form after login can drop `Secure` and `SameSite` from cookies and send the form to an untrusted host. `shiro-jakarta-ee` only, and form saving is on by default. | 6.0 Medium | 3.0.2 |
| [CVE-2026-74762](https://www.cve.org/CVERecord?id=CVE-2026-74762) | Restoring a subject from a RememberMe cookie keeps the old session id. Session ids were also read from the URL when rewriting was off. RememberMe has to be on. | 5.9 Medium | 3.0.1 |
| [CVE-2026-129348](https://www.cve.org/CVERecord?id=CVE-2026-129348) | `PropertiesRealm` reloads its file but keeps users who were removed and permissions that were narrowed. | 2.3 Low | 3.0.2 |
| [CVE-2026-129347](https://www.cve.org/CVERecord?id=CVE-2026-129347) | An empty stored credential matches an empty submitted password. Only accounts that have an empty credential. | 2.3 Low | 3.0.2 |
| [CVE-2026-114737](https://www.cve.org/CVERecord?id=CVE-2026-114737) | A `ShiroFilterFactoryBean` the application creates itself still matches paths case-sensitively. Version 3.0.1 only, and only for static files on a case-insensitive filesystem. Spring Boot Starter is not affected. | 2.3 Low | 3.0.2 |
| [CVE-2026-129320](https://www.cve.org/CVERecord?id=CVE-2026-129320) | `shiro:principal` tags in Jakarta Pages and Jakarta Faces do not escape output. | 2.1 Low | 3.0.2 |

## Detection

1. Find the Shiro version. In a source tree, `mvn dependency:tree -Dincludes=org.apache.shiro` or `gradle dependencies` shows `shiro-core` and the integration modules. In a deployed image, look for `shiro-core-<version>.jar`. Anything below **3.0.2** is inside at least one of the seven. Anything below **3.0.1** is also inside the Critical flaw when the condition below holds.
2. CVE-2026-129349 applies only when the application uses `DefaultLdapRealm` or `JndiLdapRealm` and sets `authenticationCachingEnabled` to `true`. That is not the default. A deployment that does not set it is outside this one flaw and still inside whichever of the seven its modules use.
3. Apache publishes no log signature. A successful login for a user whose password was changed in LDAP, or a login that succeeds with a password the directory rejects, is the condition to review. Absence of that is not a clean bill.

## Remediation

1. Upgrade every `org.apache.shiro` artifact to **3.0.2 or later**, rebuild, redeploy, and restart. 3.0.1 fixes CVE-2026-129349 and CVE-2026-74762 and leaves the other six. There is no 2.x fix: that line ended on 2026-06-29.
2. Until the upgrade, set `authenticationCachingEnabled` back to `false` on the LDAP realm, or configure a credentials matcher such as `SimpleCredentialsMatcher` that checks the submitted password against the cached authentication. Apache says either closes CVE-2026-129349. Neither fixes the other seven.
3. For CVE-2026-88019 until 3.0.2, set the system properties `org.apache.shiro.form-resubmit-host` and `org.apache.shiro.form-resubmit-port` to the host and port the form may be replayed to. For CVE-2026-114737, call `setCaseInsensitive(true)` on a `ShiroFilterFactoryBean` the application creates itself.

## Verification

- The deployed `shiro-core` jar is **3.0.2** or later, and the process was restarted after the deploy.
- A user can still sign in with the right password. If LDAP caching stays on, confirm in a test environment that a wrong password is rejected after a successful login.
- Do not try a wrong password against a production account to test the bypass.

## Compromise response

Apache publishes no indicator that a login already happened with the wrong password. If the application was reachable with LDAP authentication caching on while it was below 3.0.1, review authentication logs for a successful login that the directory would have rejected, and expire sessions after the upgrade. The upgrade does not show whether such a login already happened.

## Sources

- [oss-security, CVE-2026-129349][oss349] — Lenny Primak, 2026-11-14 05:37:47 UTC. CVSS 4.0 9.1. `shiro-core` before 3.0.1, only with authentication caching on.
- [oss-security, CVE-2026-74763][oss763] — 2026-11-14 04:40:32 UTC. CVSS 4.0 6.3. Fixed in 3.0.2.
- [oss-security, CVE-2026-74762][oss762] — 2026-11-14 04:56:04 UTC. CVSS 4.0 5.9. Fixed in 3.0.1.
- [oss-security, CVE-2026-88019][oss019] — 2026-11-14 03:45:06 UTC. CVSS 4.0 6.0. Fixed in 3.0.2.
- [oss-security, CVE-2026-129347][oss347] — 2026-11-14 05:12:35 UTC. CVSS 4.0 2.3. Fixed in 3.0.2.
- [oss-security, CVE-2026-129348][oss348] — 2026-11-14 05:24:39 UTC. CVSS 4.0 2.3. Fixed in 3.0.2.
- [oss-security, CVE-2026-114737][oss737] — 2026-11-13 23:28:57 UTC. CVSS 4.0 2.3. Version 3.0.1 only, fixed in 3.0.2.
- [Shiro 3.0.2 release][rel302] — published 2026-11-08 06:26:50 UTC. Describes the behavior changes and does not name the CVE identifiers.
- [Shiro security reports][reports] — the project page. It says only the current line receives all fixes, and that 2.x ended on 2026-06-29. Read 2026-11-25, the index lists CVE-2026-129349, CVE-2026-129348, CVE-2026-129347, and CVE-2026-129320. The scores and the fix versions are unchanged.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.13, checked 2026-11-15. None of the eight is listed.

[oss349]: https://seclists.org/oss-sec/2026/q4/705
[oss763]: https://seclists.org/oss-sec/2026/q4/701
[oss762]: https://seclists.org/oss-sec/2026/q4/702
[oss019]: https://seclists.org/oss-sec/2026/q4/700
[oss347]: https://seclists.org/oss-sec/2026/q4/703
[oss348]: https://seclists.org/oss-sec/2026/q4/704
[oss737]: https://seclists.org/oss-sec/2026/q4/698
[rel302]: https://github.com/apache/shiro/releases/tag/shiro-root-3.0.2
[reports]: https://shiro.apache.org/security-reports.html
