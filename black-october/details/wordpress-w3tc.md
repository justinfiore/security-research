# WordPress: W3 Total Cache deletes any file, and a cache key runs code

**Last updated:** 2026-11-28 (America/New_York)

[Main guide](../black-october-2026.md#wordpress-w3-total-cache-deletes-any-file-and-a-cache-key-runs-code)

**Wordfence rates two flaws in W3 Total Cache High.** Wordfence is the CNA. Both records were published 2026-11-27. Wordfence's pages say both are fixed in **2.11.1**. The plugin directory lists 2.11.1, modified 2026-11-26.

- **[CVE-2026-119071](https://www.cve.org/CVERecord?id=CVE-2026-119071)** — file deletion, **CVSS 3.1 8.1 High**, vector `CVSS:3.1/AV:N/AC:L/PR:L/UI:N/S:U/C:N/I:H/A:H`. The record says through **2.11.0**. An Author writes the `w3tc_imageservice` post meta, and `ajax_revert()` deletes the attachment that value names, including one the Author does not own. The record says the revert nonce is shown to anyone who can upload files.
- **[CVE-2026-135616](https://www.cve.org/CVERecord?id=CVE-2026-135616)** — object injection to code execution, **CVSS 3.1 7.5 High**, vector `CVSS:3.1/AV:N/AC:H/PR:L/UI:N/S:U/C:H/I:H/A:H`. The record says through **2.11.0**. A Subscriber reaches it only when Object Cache uses the Memcached method backed by the pecl memcache extension and Minify is enabled. The record says the same key collision first raises that account to Administrator, then a bundled Guzzle chain writes a file.

Wordfence's page for the file deletion is dated November 26. The code-execution page was last updated November 27. Neither record names a fixed version; Wordfence's pages do. No source read for this entry reports exploitation. This is not the [November 27 set](wordpress-nov27.md) or the [November 26 set](wordpress-nov26.md).

**CISA KEV:** Not listed (catalog 2026.11.27, checked 2026-11-28) for either. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Wordfence pages | 2026-11-26; time/TZ unknown | Both entries name 2.11.1. The code-execution page was updated 2026-11-27. |
| Plugin directory | 2026-11-26 08:29 UTC | wordpress.org lists 2.11.1, modified at that time. |
| **Public announcement** | **2026-11-27; time/TZ unknown** | Wordfence published the two CVE records. 8.1 at 04:45 UTC, 7.5 at 01:33 UTC. |
| **Last updated** | **2026-11-28 (America/New_York)** | New item. |

## Detection

On each site, read the installed version of W3 Total Cache (`w3-total-cache`). A site that does not have the plugin is outside both flaws. The range is through 2.11.0. Reading the version changes no state. A version you cannot read is unknown, not safe.

The code-execution path needs three more things, all of which the record names: Object Cache enabled, the Memcached method backed by the pecl memcache extension, and Minify enabled. A site on 2.11.0 or earlier without that combination is still inside the file-deletion flaw. Absence of those settings is not a reason to skip the update.

## Remediation

1. Update W3 Total Cache to **2.11.1 or later**. Wordfence names 2.11.1 for both flaws.
2. The update does not restore an attachment that was already deleted, and it does not remove a file or an administrator account that the cache-key flaw already created.

## Verification

- W3 Total Cache shows 2.11.1 or later.
- Do not send a request to test either flaw.

## Compromise response

No source read for this entry reports exploitation. Look for an attachment the owner did not delete, an administrator the owner did not add, and a PHP file under the uploads directory that the owner did not place there. Updating the plugin does not remove any of those.

## Sources

- [Wordfence, CVE-2026-119071](https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-plugins/w3-total-cache/w3-total-cache-2110-authenticated-author-file-deletion-via-w3tc-imageservice-post-meta) — published 2026-11-26. CVSS 3.1 8.1. Through 2.11.0, patched in 2.11.1. Author or above.
- [CVE-2026-119071](https://www.cve.org/CVERecord?id=CVE-2026-119071) — Wordfence, published 2026-11-27 04:45 UTC. CVSS 3.1 8.1. CWE-22. Through 2.11.0. The record names no fixed version.
- [Wordfence, CVE-2026-135616](https://www.wordfence.com/threat-intel/vulnerabilities/wordpress-plugins/w3-total-cache/w3-total-cache-2110-authenticated-subscriber-php-object-injection-to-remote-code-execution-via-memcached-object-cache-key-collision) — published 2026-11-26, updated 2026-11-27. CVSS 3.1 7.5. Through 2.11.0, patched in 2.11.1. Requires Memcached object cache via pecl memcache and Minify.
- [CVE-2026-135616](https://www.cve.org/CVERecord?id=CVE-2026-135616) — Wordfence, published 2026-11-27 01:33 UTC. CVSS 3.1 7.5. The record names no CWE. Through 2.11.0. The record names no fixed version.
- [WordPress.org plugin directory, W3 Total Cache](https://wordpress.org/plugins/w3-total-cache/) — softwareVersion 2.11.1, dateModified 2026-11-26 08:29 UTC.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.27, checked 2026-11-28. Neither CVE is listed.
