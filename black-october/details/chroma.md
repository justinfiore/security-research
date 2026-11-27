# Chroma: billing metadata was read

**Last updated:** 2026-11-27 (America/New_York)

[Main Chroma summary](../black-october-2026.md#chroma-billing-metadata-was-read) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Chroma, which hosts a database for AI applications, posted a status incident on 2026-11-27. The page says that on the night of November 26 it identified unauthorized read access to billing metadata, revoked that access, and took the hosted service down. It says it does not believe any payment data or customer data was accessed. It says customers do not need to do anything. No CVE is assigned and no score is published.

The page lists the fields it calls billing metadata. At team level: team UUID, team name, team slug, and billing state (an enumeration such as active or trial with credit). At database level: data-plane database ID, tenant UUID, last size in bytes, last billing emit time, last PostgreSQL commit LSN, last transaction record ID, and last position. It says the size, time, and log-position figures are what Orb uses to calculate bills.

The same page says the service was scheduled to return at 9am ET on Friday, November 27. This guide did not read a later update that says it is back. The components the page lists as a major outage are the API, the dashboard, Package Search MCP, and the hosted embedding service.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Chroma says the access was a read of billing metadata and that it does not believe payment data or customer data was accessed. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Unauthorized read identified | 2026-11-26, "tonight"; time unknown | Chroma's status page, posted 2026-11-27. [Status][status] |
| **Public notice** | **2026-11-27 05:15 UTC** | Status incident marked Identified. Service down. Customers told there is nothing to do. |
| Planned return | 2026-11-27 09:00 ET (UTC−05:00) | The page's schedule. This guide did not confirm the service came back. |

## Detection

There is nothing to inventory on a self-hosted copy. The notice is about Chroma's hosted service. A team name, a team slug, a billing state, a database size, and the identifiers in the list above are the fields Chroma says were readable. The page does not say which customers' rows were read.

## Remediation

1. Nothing to install, and nothing to rotate, on what Chroma has published. The page says there is no action for customers.
2. Do not treat a message that cites this notice as a reason to paste an API key. The notice does not ask for one.

## Verification

- The status page is the check. A green status later does not change what was readable while the access existed.

## Compromise response

Chroma says the access was read-only and that payment data and customer data were not accessed, on its belief. It does not publish an indicator. A secret that was never stored in those billing fields is outside what the page describes.

## Sources

- [Chroma status incident][status] — Identified 2026-11-27 05:15 UTC. Unauthorized read of billing metadata. No payment data or customer data believed accessed. No customer action.

[status]: https://status.trychroma.com/cmwyj38t504rw0wpda1zcg9a4
