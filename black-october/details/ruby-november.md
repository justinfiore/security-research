# Ruby: a string or a pattern corrupts memory

**Last updated:** 2026-11-20 (America/New_York)

[Main Ruby summary](../black-october-2026.md#ruby-a-string-or-a-pattern-corrupts-memory) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On November 19 Ruby published seven flaws in the regular expression engine and in string case conversion, and released Ruby 4.0.10, 3.4.13, and 3.3.14. Ruby's repository rates three Critical and three High. The seventh is Moderate. MITRE has assigned one CVE, at 7.4 High, and Ruby's page for that flaw still says no CVE is known.

**CISA KEV:** Not listed (catalog 2026.11.18, checked 2026-11-19). Ruby does not report exploitation. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [The seven flaws](#the-seven-flaws)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and evidence |
|---|---|
| **Public announcement** | **2026-11-19 00:00 UTC.** The news page is dated November 18. [Ruby advisory][ruby] |
| Releases | 2026-11-18, page date. Ruby 4.0.10, 3.4.13, and 3.3.14. [4.0.10][r40] |
| CVE record | 2026-11-19; time unknown. MITRE published [CVE-2026-132825](https://www.cve.org/CVERecord?id=CVE-2026-132825) at CVSS 3.1 7.4. Ruby's advisory for that flaw still says a CVE has been requested. |
| GitLab packages | 2026-11-20; time/TZ unknown | 19.6.1, 19.5.8, and 19.4.10 bundle the patched Ruby. GitLab.com and Dedicated were already patched. [GitLab][gl] |
| **Last updated** | **2026-11-20 (America/New_York).** GitLab shipped the fixed interpreter in its own packages. |

## The seven flaws

Ruby publishes no numeric score. The labels below are the ones on the repository advisories, read November 19.

| Advisory | Ruby's rating | What it is |
|---|---|---|
| [GHSA-34m4-m9fh-gqp5](https://github.com/ruby/ruby/security/advisories/GHSA-34m4-m9fh-gqp5), [CVE-2026-132825](https://www.cve.org/CVERecord?id=CVE-2026-132825) | Critical. MITRE: 7.4 High | One byte written past the buffer when the case of a string changes, in a single-byte encoding such as ISO-8859-1 or Windows-1252. Ruby knows of a proof that runs code. |
| [GHSA-7x2q-68qv-6p8x](https://github.com/ruby/ruby/security/advisories/GHSA-7x2q-68qv-6p8x) | Critical | A double free while compiling a pattern that uses a character-class intersection (`&&`). Ruby knows of a proof that runs code. |
| [GHSA-3p8q-wmhx-vm2w](https://github.com/ruby/ruby/security/advisories/GHSA-3p8q-wmhx-vm2w) | Critical | The size of a compiled pattern wraps, and Ruby writes past a heap buffer. Ruby knows of a proof that runs code. |
| [GHSA-87fm-7w84-j2px](https://github.com/ruby/ruby/security/advisories/GHSA-87fm-7w84-j2px) | High | A case change whose result exceeds 4 GiB overflows the length and writes past a heap buffer. Ruby knows of a proof that runs code. |
| [GHSA-7whj-cfh7-xgm4](https://github.com/ruby/ruby/security/advisories/GHSA-7whj-cfh7-xgm4) | High | `Regexp#to_s` writes past a heap buffer. Ruby knows of a proof that runs code. |
| [GHSA-wpqw-5qxg-m68r](https://github.com/ruby/ruby/security/advisories/GHSA-wpqw-5qxg-m68r) | High | An out-of-bounds read during case-insensitive matching. Ruby knows of a proof that corrupts memory, and says code execution may follow. |
| [GHSA-pvgc-g7gj-pv6h](https://github.com/ruby/ruby/security/advisories/GHSA-pvgc-g7gj-pv6h) | Moderate | An out-of-bounds read of a case-insensitive backreference. It may disclose memory or crash the process. Ruby does not say it runs code. |

The five that Ruby says can run code need the application to change the case of a string the caller supplies, or to compile a pattern the caller supplies. Matching untrusted text against a pattern the application wrote is a different condition. The 4 GiB case change is the one that needs a result that large.

This is not the [October regex set](gitlab-ruby.md), which is fixed in 4.0.9, 3.4.12, and 3.3.13 and is about compiling attacker-controlled patterns inside GitLab. Those three builds leave all seven of these in place. It is not the [`httpx` gem](ruby-httpx.md).

## Detection

The version that matters is the interpreter the process loaded, not a gem version.

```sh
sh /path/to/black-october/stack-inventory.sh ruby
```

That prints `ruby -v` for the runtime on `PATH`. A container, a worker, and a version manager can each have a different one. Check each.

- **Affected:** 3.3.13 and earlier, 3.4.0 through 3.4.12, and 4.0.0 through 4.0.9.
- **Fixed:** 3.3.14, 3.4.13, and 4.0.10.
- **No fix:** Ruby 3.2 and earlier are end of life. Ruby says they will not receive these fixes.
- A GitLab package that bundles its own Ruby is not settled by the host's `ruby -v`. GitLab's packages that include the November 18 Ruby fixes are **19.6.1, 19.5.8, and 19.4.10**. Anything before 19.4.10, 19.5 before 19.5.8, and 19.6 before 19.6.1 does not. GitLab.com and GitLab Dedicated were already running a patched version. A self-compiled install is not covered by those packages: rebuild it on Ruby **3.3.14 or 3.4.13** or later in that minor series. The [October regex floors](gitlab-ruby.md) are a different set.

Ruby does not say which encodings besides ISO-8859-1 and Windows-1252 take the one-byte path, and it does not say a UTF-8 string is safe. Do not treat an encoding setting as proof the process is outside the flaw.

## Remediation

1. Upgrade to **4.0.10, 3.4.13, or 3.3.14** and restart every process that loaded the old interpreter. Rebuild an image that bakes Ruby in. On self-managed GitLab, upgrade to **19.6.1, 19.5.8, or 19.4.10**. Those packages already contain the patched Ruby. A self-compiled GitLab has to be rebuilt on Ruby 3.3.14 or 3.4.13. GitLab.com and Dedicated need nothing from you.
2. Updating gems, Rails, or the application does not replace the interpreter.
3. Ruby 3.3 is in security maintenance. Move a 3.2 or earlier runtime to a supported line. There is no backport.
4. Ruby publishes no workaround. Avoiding untrusted patterns and untrusted case conversion is a reduction, not a fix.
5. The restart does not show whether a request already ran code.

## Verification

- Each deployed process reports 4.0.10, 3.4.13, or 3.3.14, and it was started after the install. A process that was already running is still the old interpreter.
- Do not send a crafted string or pattern at a production process to confirm the bug.

## Compromise response

Ruby publishes no indicator and does not report exploitation. A crash in a Ruby worker that handles case conversion or compiles patterns from outside input, before the upgrade, is a lead and not proof. Preserve the logs and the process image, and review what that process could reach. The upgrade does not undo either.

## Sources

- [Ruby advisory, multiple vulnerabilities in Regexp and String case conversion][ruby] — published 2026-11-19 00:00 UTC. Seven flaws. Fixes in 4.0.10, 3.4.13, and 3.3.14. Proofs of concept for some of them. CVE identifiers requested and, on this page, not assigned.
- [GHSA-34m4-m9fh-gqp5](https://github.com/ruby/ruby/security/advisories/GHSA-34m4-m9fh-gqp5) — Critical. One-byte heap overflow. Ruby's page says no CVE is known.
- [CVE-2026-132825](https://www.cve.org/CVERecord?id=CVE-2026-132825) — MITRE, published 2026-11-19. CVSS 3.1 7.4, vector `CVSS:3.1/AV:L/AC:H/PR:N/UI:N/S:U/C:H/I:H/A:H`. Same versions.
- [GHSA-7x2q-68qv-6p8x](https://github.com/ruby/ruby/security/advisories/GHSA-7x2q-68qv-6p8x) — Critical. Double free.
- [GHSA-3p8q-wmhx-vm2w](https://github.com/ruby/ruby/security/advisories/GHSA-3p8q-wmhx-vm2w) — Critical. Integer overflow during compilation.
- [GHSA-87fm-7w84-j2px](https://github.com/ruby/ruby/security/advisories/GHSA-87fm-7w84-j2px) — High. Case conversion over 4 GiB.
- [GHSA-7whj-cfh7-xgm4](https://github.com/ruby/ruby/security/advisories/GHSA-7whj-cfh7-xgm4) — High. `Regexp#to_s`.
- [GHSA-wpqw-5qxg-m68r](https://github.com/ruby/ruby/security/advisories/GHSA-wpqw-5qxg-m68r) — High. Case-insensitive match.
- [GHSA-pvgc-g7gj-pv6h](https://github.com/ruby/ruby/security/advisories/GHSA-pvgc-g7gj-pv6h) — Moderate. Backreference read.
- [GitLab 19.6.1, 19.5.8, and 19.4.10][gl] — published 2026-11-20. The only security fix in the release is the bundled Ruby update for CVE-2026-132825 and the rest of the November 18 Ruby advisory. GitLab shows Ruby's Critical rating and notes MITRE's 7.4. Impacted: all versions before 19.4.10, 19.5 before 19.5.8, and 19.6 before 19.6.1. These releases add no new database migrations.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.18, checked 2026-11-20. CVE-2026-132825 is not listed.

[ruby]: https://www.ruby-lang.org/en/news/2026/11/18/multiple-vulnerabilities-in-regexp-and-string/
[r40]: https://www.ruby-lang.org/en/news/2026/11/18/ruby-4-0-10-released/
[gl]: https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-6-1-released/
