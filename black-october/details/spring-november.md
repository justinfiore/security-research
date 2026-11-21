# Spring: an expression matcher runs code

**Last updated:** 2026-11-20 (America/New_York)

[Main Spring summary](../black-october-2026.md#spring-an-expression-matcher-runs-code) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-19 Spring published a batch of advisories. Two are Critical. [CVE-2026-59273](https://www.cve.org/CVERecord?id=CVE-2026-59273) is in Spring Security: `ELRequestMatcher` evaluates a SpEL expression with full reflection, and Spring's data binding turns a string bound to a `RequestMatcher` property into that matcher. An application that binds external input to such a property runs that input as code. Spring's calculator vector for it is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`, which is 9.8. The advisory itself prints Critical and does not print the number.

[CVE-2026-59367](https://www.cve.org/CVERecord?id=CVE-2026-59367) is in the `spring-ldap-test` artifact. `EmbeddedLdapServer` listens on every interface and accepts a fixed administrative password. Spring's vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:L`, which is 9.4. It matters when a test or a shared CI agent starts that server on a reachable host. A production application that never starts it is outside the condition Spring names.

Ten more in the same batch are High. The one that runs code is [CVE-2026-123886](https://www.cve.org/CVERecord?id=CVE-2026-123886) in Spring Data Elasticsearch: an argument to a string `@Query` is substituted before SpEL runs, so untrusted input is evaluated. Spring's vector is `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:H/I:H/A:H`, which is 8.8. The fixes are **6.1.3** and **6.0.9**. The other nine are access-control and denial-of-service flaws; their floors are in the remediation table. Spring does not report exploitation of any of them.

The open-source floors for the Critical pair are Spring Security **7.1.3** and **7.0.9**, and Spring LDAP **4.1.3** and **4.0.7**. Lines 6.5, 6.4, 5.8, 5.7, and the older LDAP lines are fixed only in Enterprise Support builds.

**CISA KEV:** Not listed (catalog 2026.11.20, checked 2026-11-20) for any CVE in this batch. Spring does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-19; time/TZ unknown** | Spring's advisory index. Each page says "Initial vulnerability report published" on that date. [Index][idx] |

## Detection

Read the resolved dependency versions, not the Spring Boot version alone. A Boot release can pull a fixed Security jar, or it can leave the old one.

- Spring Security **7.1.0 through 7.1.2** and **7.0.0 through 7.0.8** are inside CVE-2026-59273. So are **6.5.0 through 6.5.12**, **6.4.0 through 6.4.19**, **5.8.0 through 5.8.28**, and **5.7.26 and earlier**. The flaw needs an application that binds external input to a property of type `RequestMatcher`. An application that never does that is outside the condition Spring names.
- `spring-ldap-test` **4.1.0 through 4.1.2**, **4.0.0 through 4.0.6**, **3.3.0 through 3.3.9**, **3.2.0 through 3.2.19**, and **2.4.6 and earlier** are inside CVE-2026-59367 when something starts `EmbeddedLdapServer` on a reachable host.
- Spring Data Elasticsearch **6.1.0 through 6.1.2** and **6.0.0 through 6.0.8** are inside CVE-2026-123886 when a repository method passes untrusted input to a string `@Query` with positional placeholders.

## Remediation

1. Upgrade Spring Security to **7.1.3 or 7.0.9** or later and restart. Those are the open-source floors for CVE-2026-59273, CVE-2026-59330, and CVE-2026-59331. CVE-2026-59333 is only on 7.1.0 through 7.1.2, fixed in 7.1.3.
2. On 6.5, 6.4, 5.8, and 5.7, the Security fixes are Enterprise Support only: **6.5.13**, **6.4.20**, **5.8.29**, and **5.7.27**.
3. Upgrade Spring LDAP to **4.1.3 or 4.0.7** or later. Older lines are Enterprise Support only: **3.3.10**, **3.2.20**, and **2.4.7**. Until then, do not start `EmbeddedLdapServer` on a host an untrusted party can reach.
4. Upgrade Spring Data Elasticsearch to **6.1.3 or 6.0.9** or later. Until then, reject input that contains `#{` before it reaches a string `@Query`, or build the query with `CriteriaQuery` or `NativeQuery`.
5. The other High floors, all published the same day:

| CVE | Project | Affected | Open-source fix |
|---|---|---|---|
| [CVE-2026-59330](https://www.cve.org/CVERecord?id=CVE-2026-59330) | Spring Security WebAuthn counter | 7.1.0–7.1.2, 7.0.0–7.0.8 | 7.1.3, 7.0.9 |
| [CVE-2026-59331](https://www.cve.org/CVERecord?id=CVE-2026-59331) | Spring Security RSocket allocation | 7.1.0–7.1.2, 7.0.0–7.0.8, 6.5.0–6.5.12, 6.0.0–6.4.19, 5.8.0–5.8.28, 5.7.0–5.7.26 | 7.1.3, 7.0.9; older lines Enterprise only |
| [CVE-2026-59333](https://www.cve.org/CVERecord?id=CVE-2026-59333) | Spring Security IP matcher | 7.1.0–7.1.2 | 7.1.3 |
| [CVE-2026-59338](https://www.cve.org/CVERecord?id=CVE-2026-59338) | Spring AI Tika extraction | 2.0.0–2.0.2, 1.1.0–1.1.9, 1.0.0–1.0.10 | 2.0.3; older lines Enterprise only |
| [CVE-2026-59339](https://www.cve.org/CVERecord?id=CVE-2026-59339) | Spring AI filter parser | same as 59338 | 2.0.3 |
| [CVE-2026-59344](https://www.cve.org/CVERecord?id=CVE-2026-59344) | Spring AI Coherence filter | same as 59338 | 2.0.3 |
| [CVE-2026-59345](https://www.cve.org/CVERecord?id=CVE-2026-59345) | Spring AI text formatter | same as 59338 | 2.0.3 |
| [CVE-2026-59349](https://www.cve.org/CVERecord?id=CVE-2026-59349) | Spring Web Services message size | 5.0.0–5.0.3, 4.1.0–4.1.4, 4.0.0–4.0.19, 3.1.9 and earlier | 5.0.4; older lines Enterprise only |
| [CVE-2026-59361](https://www.cve.org/CVERecord?id=CVE-2026-59361) | Spring AI Redis filter | same as 59338 | 2.0.3 |

6. The upgrade does not show whether an expression already ran.

## Verification

- The resolved `spring-security-web` jar is 7.1.3, 7.0.9, or a later open-source build, or the Enterprise build for the line you run.
- `spring-ldap-test`, if the build pulls it in, is 4.1.3, 4.0.7, or later.
- A request the application should still accept still works. Do not send a SpEL payload.

## Compromise response

Spring does not report exploitation. An application that bound external input to a `RequestMatcher` should be reviewed for a process or a file the owner did not create. A host that ran `EmbeddedLdapServer` on a reachable port should be reviewed for directory entries the tests did not create. The upgrade does not undo either.

## Sources

- [CVE-2026-59273](https://spring.io/security/cve-2026-59273) — Spring, published 2026-11-19. Critical. Spring Security `ELRequestMatcher`. Open-source fixes 7.1.3 and 7.0.9.
- [CVE-2026-59367](https://spring.io/security/cve-2026-59367) — Spring, published 2026-11-19. Critical. `spring-ldap-test` embedded server. Open-source fixes 4.1.3 and 4.0.7.
- [CVE-2026-123886](https://spring.io/security/cve-2026-123886) — Spring, published 2026-11-19. High. Spring Data Elasticsearch. Fixes 6.1.3 and 6.0.9.
- [CVE-2026-59330](https://spring.io/security/cve-2026-59330), [CVE-2026-59331](https://spring.io/security/cve-2026-59331), [CVE-2026-59333](https://spring.io/security/cve-2026-59333) — Spring Security, High, same date.
- [CVE-2026-59338](https://spring.io/security/cve-2026-59338), [CVE-2026-59339](https://spring.io/security/cve-2026-59339), [CVE-2026-59344](https://spring.io/security/cve-2026-59344), [CVE-2026-59345](https://spring.io/security/cve-2026-59345), [CVE-2026-59361](https://spring.io/security/cve-2026-59361) — Spring AI, High, same date. Open-source fix 2.0.3.
- [CVE-2026-59349](https://spring.io/security/cve-2026-59349) — Spring Web Services, High, same date. Open-source fix 5.0.4.
- [Spring advisory index][idx] — the batch listing, read 2026-11-20.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.20, released 2026-11-20T17:48:39.1516Z, checked 2026-11-20. None of these CVEs is listed.

[idx]: https://spring.io/security
