# VirtueMart: a storefront request includes a local file

**Last updated:** 2026-11-27 (America/New_York)

[Main guide](../black-october-2026.md#virtuemart-a-storefront-request-includes-a-local-file)

**The Joomla! Project rates [CVE-2026-133335](https://www.cve.org/CVERecord?id=CVE-2026-133335) CVSS 4.0 9.2 Critical.** The vector is `CVSS:4.0/AV:N/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N/E:A`. The weakness is CWE-98. The storefront's main controller built a file name from the `view` request value and included it. The filter rejected a long name, a percent sign, a space, and an asterisk, and it did not reject `.` or `/`. A request with no login can include a local PHP file. The record says that becomes code execution when the server has a useful file, and it names `pearcmd.php` as the example. It also says the issue has been exploited in the wild. **4.0.0 through 4.8.7** are affected. **4.8.8** fixes the loader. The vendor's November 24 notice calls the same flaw an RCE that needs "the right programs" on the server, and it does not mention exploitation.

Two more flaws in the same component are not this one. [CVE-2026-133333](https://www.cve.org/CVERecord?id=CVE-2026-133333) is CVSS 4.0 8.2 High: through 4.8.8, the bundled PayPal Checkout plugin marks the order in the current session as paid without a PayPal capture. A guest can do it. **4.8.10** fixes it. [CVE-2026-133334](https://www.cve.org/CVERecord?id=CVE-2026-133334) is CVSS 4.0 8.2 High: through 4.8.0, one valid download link from the bundled Download Simple plugin downloads other files offered for sale. **4.8.2** fixes it. The vendor has not said whether VirtueMart 3 is affected. The notice now offers two hotfixes: one for VirtueMart **4.6 and above**, and one for a version **lower than 4.6**.

**CISA KEV:** Not listed (catalog 2026.11.25, checked 2026-11-26) for CVE-2026-133335, CVE-2026-133333, or CVE-2026-133334. The Joomla record says the loader flaw has been exploited. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Loader fix | 2026-11-19; time/TZ unknown | VirtueMart 4.8.8. The note says "minor security fixes" and does not name a CVE. [4.8.8][v488] |
| Vendor security notice | 2026-11-24; time/TZ unknown | 4.8.10. The vendor calls 4.8.8 an RCE from a fallback, and 4.8.10 a fake paid order. The hotfix is two packages, split at 4.6. [Notice][notice] |
| **Public announcement** | **2026-11-25; time/TZ unknown** | The Joomla! Project published the three records. CVE-2026-133335 is CVSS 4.0 9.2, and the record says it has been exploited. [CVE][cve] |
| **Last updated** | **2026-11-27 (America/New_York)** | The hotfix is now two packages, split at 4.6. |

## Detection

Read the version in the Joomla administrator under Extensions, Manage, Manage, or in `administrator/components/com_virtuemart/version.php`. **4.0.0 through 4.8.7** is inside the loader flaw. **4.8.8 and 4.8.9** still have the PayPal Checkout flaw. A site that does not run `com_virtuemart` is outside all three. A hotfixed site keeps its old version number, so the version alone does not show the hotfix. Look for a `VirtueMart_patcher` component at 4.8.10. Reading the version changes no state. A missing version file means unknown, not safe.

## Remediation

1. Install the full **4.8.10** package and confirm the component reports 4.8.10. That is the release that contains the loader fix and the PayPal Checkout fix. 4.8.8 leaves the payment flaw in place.
2. If a full update has to wait, install the vendor's **4.8.10 hotfix** for the installed line. The notice links one package for **4.6 and above** and a different package for a version **lower than 4.6**. The reported version does not move, so a scanner will still flag the site.
3. VirtueMart 3 has no named fix. The vendor has not said it is affected. Plan the move to 4.8.10.
4. A store that uses PayPal Checkout and cannot update should turn that method off. That does not close the loader flaw.
5. The update does not show whether a file was already included, or whether an order was marked paid without a capture.

## Verification

- The component reports **4.8.10**, or the `VirtueMart_patcher` component is at 4.8.10.
- PayPal Checkout orders marked paid have a matching capture in the PayPal account.
- Do not send a `view` value with `../` to test the loader.

## Compromise response

Search the web server log for a `com_virtuemart` request whose `view` contains `..` or names a PHP file such as `pearcmd`. A hit is a lead. Compare it with a `200` response and with PHP files created under the site after November 1, 2026. For the payment flaw, an order marked paid with no matching PayPal capture is a lead. The vendor publishes no indicators. If a file was included, treat the Joomla process user as compromised: the database password lives in `configuration.php`. Rebuild rather than only updating.

## Sources

- [CVE-2026-133335][cve] — Joomla! Project, published 2026-11-25. CVSS 4.0 9.2. Affected 4.0.0–4.8.7. Fixed in 4.8.8. The record says it has been exploited.
- [CVE-2026-133333][cve333] — Joomla! Project, published 2026-11-25. CVSS 4.0 8.2. Affected 4.0.0–4.8.8. Fixed in 4.8.10.
- [CVE-2026-133334][cve334] — Joomla! Project, published 2026-11-25. CVSS 4.0 8.2. Affected 4.0.0–4.8.0. Fixed in 4.8.2.
- [VirtueMart 4.8.10 notice][notice] — Max Milbers, published 2026-11-24, reread 2026-11-27. Calls 4.8.8 an RCE and 4.8.10 a fake paid order. The hotfix is now two packages, split at 4.6.
- [VirtueMart 4.8.8 release][v488] — published 2026-11-19. Does not name a CVE.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.25, checked 2026-11-26. None of the three is listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-133335
[cve333]: https://www.cve.org/CVERecord?id=CVE-2026-133333
[cve334]: https://www.cve.org/CVERecord?id=CVE-2026-133334
[notice]: https://virtuemart.net/news/important-security-fix-4-8-10-update-directly-hotfixes-provided
[v488]: https://virtuemart.net/news/98-playwright-tests-later-virtuemart-4-8-8-released-again-with-enhanced-security
