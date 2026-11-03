# Fastify HTTP proxy: a route parameter rewrites the upstream path

**Last updated:** 2026-11-02 (America/New_York)

[Main Fastify summary](../black-october-2026.md#fastify-http-proxy-a-route-parameter-rewrites-the-upstream-path) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

`@fastify/http-proxy` **9.0.0 through 11.6.5** substitutes a URL-decoded route parameter into `rewritePrefix` and does not re-encode it. An application that uses a parameterized `prefix` and `rewritePrefix` to pin clients to one upstream path can be made to request a different path. A parameter containing an encoded `/` plus `#` or `?` becomes a real separator, and the suffix `rewritePrefix` was supposed to enforce is dropped. The advisory's example is a request to `/tenants/admin%2fmaster-keys%23/public-avatar` forwarded as `GET /admin/master-keys`. OpenJS scores it **CVSS 3.1 9.1 Critical**. The fix is **11.6.6**. There is no workaround. [Advisory][ghsa] [CVE][cve]

Applications that do not use a parameterized `prefix` together with `rewritePrefix` are outside the path the advisory describes.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). The advisory does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private report | Unknown | The advisory says the report was submitted with AI assistance. It does not name a finder. [Advisory][ghsa] |
| Public advisory | 2026-11-02 08:55 UTC | GHSA-h3vp-4jfr-v364, Critical 9.1. Patched in 11.6.6. [Advisory][ghsa] |
| CVE record published | 2026-11-02 11:17 UTC | OpenJS CNA, via NVD. [NVD][nvd] |

## Detection

Read the installed version without starting the app:

```sh
npm ls @fastify/http-proxy --all
```

**9.0.0 through 11.6.5** are affected. Below 9.0.0 is outside the advisory's range. Then search your own route registration for `prefix` containing a parameter and a `rewritePrefix`. A proxy that uses a fixed prefix is not on this path.

## Remediation

1. Upgrade `@fastify/http-proxy` to **11.6.6 or later** and restart the process.
2. The advisory lists no workaround. Do not keep a parameterized prefix in front of an upstream you need to isolate.

## Verification

- `npm ls @fastify/http-proxy` reports 11.6.6 or later in the tree you deploy.
- A normal request through the proxy still reaches the upstream path you configured. Do not send an encoded slash to test this.

## Compromise response

If a parameterized proxy was reachable on an affected version, the upstream saw whatever path the parameter decoded to, as the proxy's own credentials.

- Review upstream access logs for paths outside the prefix you intended.
- If the upstream authorized the proxy rather than the caller, treat that credential as the one that made the request.

## Sources

- [GHSA-h3vp-4jfr-v364][ghsa] — OpenJS, CVSS 3.1 9.1, published 2026-11-02 08:55 UTC. Affected 9.0.0 through 11.6.5. Fixed in 11.6.6.
- [CVE-2026-120213][cve] — OpenJS CNA.
- [NVD][nvd] — published 2026-11-02.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[ghsa]: https://github.com/fastify/fastify-http-proxy/security/advisories/GHSA-h3vp-4jfr-v364
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-120213
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-120213
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
