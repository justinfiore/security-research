# Grafana Mimir: Alertmanager configuration reads local files

**Last updated:** 2026-11-02 (America/New_York)

[Main Mimir summary](../black-october-2026.md#grafana-mimir-alertmanager-configuration-reads-local-files) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Grafana Mimir's Alertmanager refuses tenant receiver configuration that points at local files. Two HTTP client settings were not in that check: `http_headers.<name>.files` and `basic_auth.username_file`. A tenant who can upload an Alertmanager configuration can point either field at any file the Alertmanager process can read. When a notification is sent, the file's contents go into a header of the outgoing request. Grafana scores **[CVE-2026-81938](https://www.cve.org/CVERecord?id=CVE-2026-81938) CVSS 3.1 7.7 High**. NVD has not scored it. Grafana Enterprise Metrics, which is built on Mimir, is affected too. [CVE][cve] [Release][rel322]

Fixed in **Mimir 3.1.7 and 3.2.2**, and in **GEM 2.17.20**. GEM 2.11 through 2.16 will not be fixed. Those installs move to 2.17.20 or later. The CNA's public date is 2026-09-27; the CVE record was published 2026-11-02. Grafana's advisory URL returned a page that says the page cannot be found, so these claims are from the CNA record and the release notes.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). The record does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public date on the CNA record | 2026-09-27; time unknown | `datePublic` on the CVE record. The record itself was not published that day. [CVE][cve] |
| Mimir 3.1.7 | 2026-10-06 20:59 UTC | Release notes: Alertmanager no longer loads local files from configuration. Resolves CVE-2026-81938. [3.1.7][rel317] |
| Mimir 3.2.2 | 2026-10-07 17:35 UTC | Same fix on the 3.2 line. [3.2.2][rel322] |
| CVE record published | 2026-11-02 18:23 UTC | Grafana CNA. CVSS 3.1 7.7. [CVE][cve] |

## Detection

1. Read the Mimir or GEM version from the image tag or the `-version` output. Mimir **3.0.4 and later before 3.1.7**, and **3.2.0 and 3.2.1**, are in the CNA's affected range. GEM **2.11.0 through 2.16.2**, and **2.17.0 before 2.17.20**, are affected.
2. The path needs a tenant who can write that tenant's Alertmanager configuration. A deployment that does not let tenants upload receiver configuration is outside it.
3. The file is read when a notification is sent, not when the configuration is saved.

## Remediation

1. Upgrade Mimir to **3.1.7 or later** on the 3.1 line, or **3.2.2 or later** on the 3.2 line. 3.2.4 is newer and still contains the fix.
2. Upgrade GEM to **2.17.20 or later**. GEM 2.11 through 2.16 have no fix.
3. The record lists no workaround. Do not grant Alertmanager configuration upload to tenants you do not trust with the process's files.

## Verification

- The running image is one of the fixed versions.
- An existing receiver still sends a test notification. Do not point a receiver at a local file to test this.

## Compromise response

A tenant who could upload configuration could have placed file contents into a header sent to a receiver they control.

- Review Alertmanager configuration history for `username_file` or `http_headers` entries that name paths outside the tenant's own storage.
- Treat files readable by the Alertmanager process as exposed to any tenant who had that permission on an affected version. That includes credentials the process account can read.

## Sources

- [CVE-2026-81938][cve] — Grafana CNA, CVSS 3.1 7.7, published 2026-11-02. Affected ranges and fixed versions.
- [Mimir 3.2.2][rel322] — 2026-10-07. Names the CVE.
- [Mimir 3.1.7][rel317] — 2026-10-06. Names the CVE.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30, not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-81938
[rel322]: https://github.com/grafana/mimir/releases/tag/mimir-3.2.2
[rel317]: https://github.com/grafana/mimir/releases/tag/mimir-3.1.7
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
