# Next.js: unauthenticated RCE in use cache and Image Optimization

**Last updated:** 2026-10-26 (America/New_York)

[Main Next.js summary](../black-october-2026.md#nextjs-unauthenticated-rce-in-use-cache-and-image-optimization-ghsa-673q-mjm6-r5xr-and-cve-2026-96889) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Two Critical unauthenticated remote code execution (RCE) advisories, both fixed in Next.js 16.4.1 (and the second also in 15.5.28), published 2026-10-14. Vercel rates each Critical, CVSS 4.0 9.5, in its GitHub repository advisories. The Image Optimization issue maps to the librsvg flaw [CVE-2026-96889](https://www.cve.org/CVERecord?id=CVE-2026-96889), which Red Hat (the CVE's CNA) scores lower: CVSS 3.1 7.8 High, with a local attack vector. NVD has added no score of its own. Not listed in CISA KEV (catalog 2026.10.23, checked 2026-10-26).** [GHSA-673q][ghsa-cache] [GHSA-2464][ghsa-img] [Next.js blog][blog] [CNA][cve-img] [KEV][kev]

| Issue | Component | Vercel rating | Affected `next` | Fixed `next` | Workaround |
|---|---|---|---|---|---|
| **GHSA-673q-mjm6-r5xr** (no CVE) | App Router with Cache Components; a `use cache` function that returns multiple typed arrays | Critical, CVSS 4.0 9.5 (`AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:N`) | 16.0.0 through 16.4.0 | **16.4.1** | None |
| **GHSA-2464-fhr4-w9xw** / CVE-2026-96889 | Image Optimization API decoding SVG through `sharp` → bundled librsvg, on **glibc-based Linux** | Critical, CVSS 4.0 9.5 (`AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`) | 10.0.0 through 15.5.27; 16.0.0 through 16.4.0 | **15.5.28**, **16.4.1** | `sharp` ≥ **0.35.5** |
| GHSA-p3m5-59mp-jv5r / [CVE-2026-94482](https://www.cve.org/CVERecord?id=CVE-2026-94482) (same release, DoS) | App Router with at least one Server Action | High, CVSS 4.0 8.2 | 13.0.0 through 15.5.27; 16.0.0 through 16.4.0 | **15.5.28**, **16.4.1** | None |

**Worst case:** An unauthenticated attacker runs code in the Next.js server process. That gives access to whatever the process can reach, such as environment secrets, database credentials and internal services.

**Attack conditions:**

- **use cache:** The application must use the App Router with Cache Components and have a `use cache` function that returns multiple typed arrays. The upstream React advisory calls this "extremely rare". Vercel still says to upgrade "even if your application does not have similar functions". [GHSA-673q][ghsa-cache] [React GHSA-xqc2][react-rce]
- **Image Optimization:** The advisory says only that a memory-safety flaw in an upstream library "can lead to possible remote code execution (RCE) when Next.js runs on glibc-based Linux". It lists no other preconditions. Next.js does not optimize SVG unless `images.dangerouslyAllowSVG` is `true` ([Next.js docs][img-docs]), and secondary reports treat that setting as the trigger. The primary advisory does not confirm this, so treat any affected glibc deployment as exposed until it is patched. [GHSA-2464][ghsa-img] [CSA note][csa]
- **Root cause upstream:** The `use cache` flaw comes from React Server Components packages (`react-server-dom-webpack`, `-parcel` and `-turbopack` 19.0.0–19.0.8, 19.1.0–19.1.9, 19.2.0–19.2.8 and 19.3.0; fixed in 19.0.9, 19.1.10, 19.2.9 and 19.3.1). Other RSC frameworks need the React fix too. The SVG flaw is a librsvg use-after-free that `sharp` 0.35.5 fixes by bundling librsvg 2.63.2. [React GHSA-xqc2][react-rce] [sharp GHSA][sharp-ghsa]

**Vercel-hosted vs self-hosted:** The reviewed Vercel and Next.js sources (advisories, blog post and Vercel changelog) do **not** say whether deployments hosted on Vercel are protected. Do not assume they are. Upgrade the `next` dependency and redeploy wherever you deploy.

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory (read-only)](#inventory-read-only)
  - [Reachability](#reachability)
  - [Logs and indicators](#logs-and-indicators)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery or report (Next.js advisories) | Unknown | Not stated. The advisories credit unnamed finders. [GHSA-673q][ghsa-cache] [GHSA-2464][ghsa-img] |
| librsvg flaw reported to Red Hat | 2026-09-23 09:29:12 UTC | Red Hat credits Rafael B. Dias. [CNA][cve-img] |
| librsvg flaw made public; CVE-2026-96889 published | 2026-09-23 12:00 UTC (made public); CVE record 19:40:14 UTC | Red Hat CNA: Important; CVSS 3.1 7.8 (`AV:L/AC:L/PR:N/UI:R/S:U/C:H/I:H/A:H`). CISA ADP SSVC (2026-09-25): exploitation "poc". [CNA][cve-img] |
| `sharp` 0.35.5 released (librsvg 2.63.2) | 2026-09-27 13:46 UTC (npm) | Workaround version for the SVG issue. [npm registry][npm-sharp] [sharp-libvips 1.3.4][libvips] |
| Next.js September release postpones two fixes | 2026-09-30 | Postponed "due to upstream dependency delays". [Next.js blog][blog] |
| sharp advisory GHSA-wq5f-xc86-pv6w | 2026-10-06 13:43:57 UTC | High, CVSS 4.0 8.9 (sharp maintainers). [sharp GHSA][sharp-ghsa] |
| Advance notice of an out-of-band release | 2026-10-08 | Announced "two Critical and one High" for 2026-10-14, with no details. [Pre-announcement][pre] |
| `next` 15.5.28 and 16.4.1 published to npm | 2026-10-14 17:36:08 UTC and 17:43:55 UTC | Patch availability per branch. No fix is listed for lines older than 15.5. [npm registry][npm-next] |
| React RSC advisories GHSA-xqc2-xf4c-x3h3 and GHSA-h3gv-c5rc-p453 | 2026-10-14 17:08 UTC | Upstream fixes in 19.0.9, 19.1.10, 19.2.9 and 19.3.1. [React GHSA-xqc2][react-rce] |
| **Public announcement:** Next.js advisories published | **2026-10-14 17:46:48 UTC** (GHSA-2464), 17:47:07 UTC (GHSA-673q), 17:47:43 UTC (GHSA-p3m5) | Repository advisories, with the blog post the same day. [GHSA-2464][ghsa-img] [GHSA-673q][ghsa-cache] [Next.js blog][blog] |
| GitHub Advisory Database (reviewed) entries | 2026-10-22 15:50–16:42 UTC | Needed for `npm audit` and SCA tools. CSA reported on 2026-10-15 that the advisories were missing from npm's feed. [GitHub DB][ghdb-img] [CSA note][csa] |
| CVE-2026-94482 (DoS) published | 2026-10-22 15:22:10 UTC | GitHub CNA, CVSS 4.0 8.2. [CVE-2026-94482 record][cve-dos] |
| CISA KEV | Not listed | Checked catalog 2026.10.23 on 2026-10-26. [KEV][kev] |
| Exploitation evidence | None found | CSA found no public exploitation reports as of 2026-10-15. Absence from KEV does not prove there has been no exploitation. [CSA note][csa] |

**Source discrepancies:** The repository advisory GHSA-2464 shows the 16.x range as "> 16.0.0", while the reviewed GitHub Advisory Database entry says ">= 16.0.0". Treat 16.0.0 as affected. GHSA-673q has no CVE. The global GitHub Advisory Database entry for GHSA-2464 does not list the CVE-2026-96889 alias, so CVE-only scanners may miss it.

## Detection

### Inventory (read-only)

Run these from each application's repository root as an unprivileged user. They only read lockfiles and installed package metadata, and they were not run against a real deployment. Repeat them in every built image or container, because the **deployed** `node_modules` is what counts.

```sh
# Resolved next, sharp and React RSC versions (npm; use `pnpm why` or `yarn why` for other package managers)
npm ls next sharp react-server-dom-webpack react-server-dom-turbopack react-server-dom-parcel --all

# Installed versions read directly from package.json (no native code is loaded)
node -p "require('next/package.json').version"
node -p "try{require('sharp/package.json').version}catch(e){'sharp not installed'}"

# C library of the runtime: a glibc version string means glibc; null suggests musl (e.g. Alpine)
node -p "process.report.getReport().header.glibcVersionRuntime || null"
```

Check whether a globally installed librsvg is used instead of the copy bundled with `sharp`. If it is, it must be **2.63.2** or later. [sharp GHSA][sharp-ghsa]

### Reachability

Run from the application's source root as an unprivileged user. These commands have no placeholders and only read source and config files.

```sh
# Image Optimization accepting SVG
grep -rn --exclude-dir=node_modules --include='next.config.*' -e 'dangerouslyAllowSVG' -e 'unoptimized' .
# Cache Components / use cache
grep -rn --exclude-dir=node_modules --include='next.config.*' -e 'cacheComponents' -e 'useCache' .
grep -rln --exclude-dir=node_modules --exclude-dir=.next -e "'use cache'" -e '"use cache"' .
# Server Actions (DoS issue)
grep -rln --exclude-dir=node_modules --exclude-dir=.next -e "'use server'" -e '"use server"' .
```

- A 16.x App Router app with Cache Components is in scope for GHSA-673q, even if no function obviously returns typed arrays.
- A self-hosted app on glibc Linux with `sharp` below 0.35.5 is in scope for GHSA-2464. `dangerouslyAllowSVG: true` makes SVG reachable. Its absence lowers the likelihood, but the vendor does not say it removes the risk.
- An app with `images.unoptimized: true` everywhere does not run the optimizer. Confirm this, rather than assuming it.

### Logs and indicators

No vendor IOCs have been published. Review the following from **2026-09-23** (when the librsvg flaw became public) onward:

- Requests to `/_next/image` whose `url=` parameter points to `.svg` files or to unexpected remote hosts.
- Next.js worker crashes, restarts and segmentation faults.
- CPU spikes on App Router servers (the DoS issue).
- Unexpected child processes or outbound connections from the Node.js process.

Finding nothing does not prove the server was not exploited. Memory-corruption exploits may leave nothing in HTTP logs.

## Remediation

1. **Upgrade `next`** to **16.4.1** (16.x) or **15.5.28** (15.x), then reinstall so that `sharp` resolves to 0.35.5 or later. 16.4.1 requires `^0.35.5`, and 15.5.28 allows `^0.34.3 || ^0.35.5`. On 15.x, **check that the resolved `sharp` is 0.35.5 or later** and do not assume it. [npm registry][npm-next]
2. Lines **older than 15.5** have no listed fix: move to a supported line. [Next.js blog][blog]
3. **Rebuild and redeploy** every image, serverless bundle and standalone output (`.next/standalone` carries its own `node_modules`). Restart long-running Node processes.
4. **If you cannot upgrade immediately:**
   - For the SVG issue, pin `sharp` to 0.35.5 or later, or block SVG decoding in code you control with `sharp.block({ operation: ["VipsForeignLoadSvg"] })`, which sharp documents. [sharp GHSA][sharp-ghsa] Also set `dangerouslyAllowSVG` to `false` unless you need it.
   - There is **no workaround** for the `use cache` RCE or the Server Actions DoS. [GHSA-673q][ghsa-cache] [GHSA-p3m5][ghsa-dos]
5. If you use React Server Components outside Next.js, upgrade `react-server-dom-*` to 19.0.9, 19.1.10, 19.2.9 or 19.3.1. [React GHSA-xqc2][react-rce]
6. Running `node` as a Position Independent Executable makes the librsvg flaw harder to exploit. sharp warns that the "official" Node.js binaries are not built that way. This hardening does not fix the flaw. [sharp GHSA][sharp-ghsa]

**Rollback caution:** Rolling back to a pre-16.4.1 or pre-15.5.28 build brings the vulnerabilities back. Keep the old artifacts out of deployment pipelines.

## Verification

- In each **running** container or host, re-run the read-only `package.json` checks above. Confirm `next` is 16.4.1+ or 15.5.28+ and `sharp` is 0.35.5+.
- Confirm the lockfile and the deployed artifact agree. A patched lockfile with a stale image is a common gap.
- Benign functional check: load a normal page and an optimized raster image (for example a PNG through `/_next/image`) on an instance you own, and confirm both work. **Do not** send crafted SVGs or RSC payloads.

## Compromise response

- If an affected server reached SVG optimization or used Cache Components while it was exposed, treat its secrets as possibly exposed. Rotate environment variables, API keys, database credentials and deployment tokens.
- Look for unexpected files in the app directory and `/tmp`, new cron or systemd units, unexpected child processes and outbound connections from the Node process. Compare running images with your registry digests.
- Rebuild from clean sources rather than patching a possibly compromised host in place. Review cloud audit logs for use of the server's credentials.

## Sources

- [GHSA-673q-mjm6-r5xr][ghsa-cache], [GHSA-2464-fhr4-w9xw][ghsa-img] and [GHSA-p3m5-59mp-jv5r][ghsa-dos] (Vercel repository advisories): scores, ranges, fixes and workarounds.
- [Next.js security update, 2026-10-14][blog] and [advance notice, 2026-10-08][pre].
- [CVE-2026-96889 record (Red Hat CNA)][cve-img], [CVE-2026-94482 record][cve-dos], [NVD CVE-2026-96889][nvd-img].
- [React GHSA-xqc2-xf4c-x3h3][react-rce], [sharp GHSA-wq5f-xc86-pv6w][sharp-ghsa], [sharp-libvips 1.3.4][libvips].
- [GitHub Advisory Database entry][ghdb-img], [npm registry: next][npm-next], [npm registry: sharp][npm-sharp], [Next.js Image docs][img-docs].
- [CISA KEV feed][kev] (no entry).
- Secondary: [Cloud Security Alliance research note][csa] (exploitation status and reachability claims).

[ghsa-cache]: https://github.com/vercel/next.js/security/advisories/GHSA-673q-mjm6-r5xr
[ghsa-img]: https://github.com/vercel/next.js/security/advisories/GHSA-2464-fhr4-w9xw
[ghsa-dos]: https://github.com/vercel/next.js/security/advisories/GHSA-p3m5-59mp-jv5r
[ghdb-img]: https://github.com/advisories/GHSA-2464-fhr4-w9xw
[blog]: https://nextjs.org/blog/nextjs-security-update-october-14-2026
[pre]: https://nextjs.org/blog/upcoming-nextjs-security-update-october-2026
[cve-img]: https://cveawg.mitre.org/api/cve/CVE-2026-96889
[cve-dos]: https://cveawg.mitre.org/api/cve/CVE-2026-94482
[nvd-img]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-96889
[react-rce]: https://github.com/facebook/react/security/advisories/GHSA-xqc2-xf4c-x3h3
[sharp-ghsa]: https://github.com/advisories/GHSA-wq5f-xc86-pv6w
[libvips]: https://github.com/lovell/sharp-libvips/releases/tag/v1.3.4
[npm-next]: https://www.npmjs.com/package/next?activeTab=versions
[npm-sharp]: https://www.npmjs.com/package/sharp?activeTab=versions
[img-docs]: https://nextjs.org/docs/app/api-reference/components/image#dangerouslyallowsvg
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[csa]: https://labs.cloudsecurityalliance.org/wp-content/uploads/2026/10/CSA_research_note_nextjs_use_cache_librsvg_rce_20261016-csa-styled.pdf
