# Hickory DNS: a signed record from one zone is accepted for another

**Last updated:** 2026-11-08 (America/New_York)

[Main Hickory DNS summary](../black-october-2026.md#hickory-dns-a-signed-record-from-one-zone-is-accepted-for-another) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Hickory DNS is a DNS resolver and server written in Rust. Its DNSSEC validator checked a signature against the key of whatever name the signature itself named, and it did not check that the name was the zone the record belongs to. Anyone who controls one correctly signed zone can then sign a record in a different zone, and a resolver that validates will accept it. The project rates that High. The same 0.26.2 release, on 2026-09-03, fixes a large set of other DNSSEC and denial-of-service flaws. The project calls it the first release after that batch, and says most of the reports came from LLM-based workflows.

**The project rates [GHSA-2vgh-3wfw-qj7c](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-2vgh-3wfw-qj7c) High.** It publishes no CVSS vector of its own. VulnCheck assigned [CVE-2026-123605](https://www.cve.org/CVERecord?id=CVE-2026-123605) on 2026-11-08 and scores it CVSS 4.0 8.7 and CVSS 3.1 8.8. The GitHub page still says no CVE is known. `hickory-proto` 0.1 through 0.25.0-alpha.3 and `hickory-net` before 0.26.2 are affected. The fix is 0.26.2. An attacker who controls any secure zone can produce a signature that resolvers, recursors, and clients using `DnssecDnsHandle` accept as authenticated for a record in an unrelated zone.

The same release fixes more flaws the project rates High. VulnCheck published CVE records for several of them on 2026-11-08. The GitHub pages still say no CVE is known, and several of the project pages publish no score:

- [CVE-2026-123596](https://www.cve.org/CVERecord?id=CVE-2026-123596), [GHSA-3r6v-f3jh-vvqm](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-3r6v-f3jh-vvqm). The project rates this one Medium. VulnCheck rates it CVSS 4.0 8.7 and CVSS 3.1 8.8. A parent zone's NSEC record is accepted as proof that a name below the zone cut does not exist, so a resolver caches a forged NXDOMAIN. The project and VulnCheck disagree, and both scores stay.
- [GHSA-qw83-5pm2-ggp5](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-qw83-5pm2-ggp5), High, no CVE found. A wraparound NSEC record forges a proof of nonexistence. `hickory-net` 0.26.0 through 0.26.1.
- [GHSA-588m-chg6-8jqj](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-588m-chg6-8jqj), High, no CVE found. An inverted NSEC3 comparison forges a proof of nonexistence.
- [GHSA-p2jv-r3m3-7wf4](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-p2jv-r3m3-7wf4), CVSS 3.1 7.5. The NSEC3 record name is not checked, so a proof of nonexistence can be forged.
- [GHSA-5j98-2g5x-46v6](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-5j98-2g5x-46v6), CVSS 3.1 7.5. `Resolver::lookup()` and `Resolver::lookup_ip()` hide a DNSSEC validation failure, so a caller treats a bogus answer as a normal one. Every version before 0.26.2.
- [GHSA-cx5j-p54p-q756](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-cx5j-p54p-q756) and [GHSA-6h5c-jjg5-wj59](https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-6h5c-jjg5-wj59), both High, no score published. A referral loop, or a glueless referral, makes the recursor do an unbounded amount of work.

The 0.26.2 notes list 42 advisories in all, most of them Medium or Low. 0.26.3, released 2026-09-10, fixes regressions from 0.26.2, including DNSSEC verification, and does not add another floor. 0.26.3 is the current release when checked on 2026-11-08. A crate that does not validate DNSSEC is outside the forgery flaws. It is not outside the denial-of-service flaws, which are in the parser and the recursor.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Hickory DNS 0.26.2 | 2026-09-03 19:34 UTC | Fixes the batch. The notes say most reports came from LLM-based workflows. [Release][rel] |
| **Public announcement** | **2026-09-03 20:34 UTC** | The project published the advisories with the release. The signer-name one is 20:34:44 UTC. [GHSA-2vgh-3wfw-qj7c][ghsa605] |
| Hickory DNS 0.26.3 | 2026-09-10 14:17 UTC | Fixes regressions from 0.26.2, including DNSSEC verification. Not a new floor. [Release][rel3] |
| CVE records | 2026-11-08 01:38 UTC | VulnCheck published CVE-2026-123605 and CVE-2026-123596, among others. The GitHub pages still say no CVE is known. [CVE-2026-123605][cve605] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the version you built against. It does not send a DNS query.

```sh
cargo tree -p hickory-resolver -i --prefix none 2>/dev/null | head -5
grep -R --include='Cargo.lock' -n 'name = "hickory-resolver"' -A 2 Cargo.lock
```

Read the `version` line under `hickory-resolver`, `hickory-proto`, and `hickory-net`. A lockfile that does not name them means this binary does not use them.

- **0.26.2 or later** is the fix for the High flaws above. 0.26.3 is current and is the release that also fixes the 0.26.2 regressions, so use 0.26.3.
- Anything older is inside at least the signer-name flaw, which starts at 0.1.
- A program that vendors the crates without a lockfile line needs its own version check. The version in `Cargo.toml` is not the version that was compiled until the lockfile says so.

## Remediation

1. Upgrade `hickory-resolver`, `hickory-proto`, `hickory-net`, and `hickory-recursor` to **0.26.3**, and rebuild every binary that links them. 0.26.2 is the security floor. 0.26.3 fixes regressions in that release, including DNSSEC verification, so a binary left on 0.26.2 has the security fixes and the regressions.
2. The advisories list no workaround. Turning DNSSEC validation off avoids the forgery flaws and also abandons the check those flaws break. It does not avoid the denial-of-service flaws.
3. The upgrade does not show whether a resolver already cached a forged answer. Restart the process after the rebuild so it drops its cache.

## Verification

- `Cargo.lock` shows 0.26.3 for each Hickory crate the binary uses, and the rebuilt binary is the one running.
- A name your users already resolve still resolves. Do not send a forged signature to test the check.

## Compromise response

A forged DNSSEC answer is a cached lie, not a file on disk. After the upgrade, restart the resolver so the cache is gone. If the resolver was authoritative for a zone you sign, the flaw is in the validator, not in your zone data. A resolver that forwarded its answers to a stub resolver you do not control may have handed that stub a cached forgery; the stub keeps it until its own TTL.

## Sources

- [GHSA-2vgh-3wfw-qj7c][ghsa605] — the project, published 2026-09-03. High, no CVSS vector. `hickory-proto` through 0.25.0-alpha.3 and `hickory-net` before 0.26.2. The page says no CVE is known.
- [CVE-2026-123605][cve605] — VulnCheck, published 2026-11-08. CVSS 4.0 8.7 and CVSS 3.1 8.8.
- [GHSA-3r6v-f3jh-vvqm][ghsa596] — the project rates it Medium. [CVE-2026-123596][cve596] — VulnCheck rates it CVSS 4.0 8.7 and CVSS 3.1 8.8.
- [GHSA-qw83-5pm2-ggp5][ghsa83], [GHSA-588m-chg6-8jqj][ghsa588], [GHSA-p2jv-r3m3-7wf4][ghsa7wf4], [GHSA-5j98-2g5x-46v6][ghsa5j98], [GHSA-cx5j-p54p-q756][ghsacx5j], [GHSA-6h5c-jjg5-wj59][ghsa6h5c] — the other High advisories in the same release.
- [Hickory DNS 0.26.2][rel] and [0.26.3][rel3] — release notes.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. None of these CVEs is listed.

[ghsa605]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-2vgh-3wfw-qj7c
[ghsa596]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-3r6v-f3jh-vvqm
[ghsa83]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-qw83-5pm2-ggp5
[ghsa588]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-588m-chg6-8jqj
[ghsa7wf4]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-p2jv-r3m3-7wf4
[ghsa5j98]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-5j98-2g5x-46v6
[ghsacx5j]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-cx5j-p54p-q756
[ghsa6h5c]: https://github.com/hickory-dns/hickory-dns/security/advisories/GHSA-6h5c-jjg5-wj59
[cve605]: https://www.cve.org/CVERecord?id=CVE-2026-123605
[cve596]: https://www.cve.org/CVERecord?id=CVE-2026-123596
[rel]: https://github.com/hickory-dns/hickory-dns/releases/tag/v0.26.2
[rel3]: https://github.com/hickory-dns/hickory-dns/releases/tag/v0.26.3
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
