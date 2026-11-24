# WHMCS: the shopping cart reads the database

**Last updated:** 2026-11-24 (America/New_York)

[Main summary](../black-october-2026.md#whmcs-the-shopping-cart-reads-the-database) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

WHMCS is the billing platform a web host uses to sell and manage services. Three flaws were disclosed on November 23. The one that needs no login reads the database through the shopping cart.

**HackerOne, the CNA, rates [CVE-2026-82981](https://www.cve.org/CVERecord?id=CVE-2026-82981) CVSS 4.0 8.7 High.** The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. WHMCS says a user who is not logged in can retrieve client personal and support information, and administrator account records including password hashes. WHMCS 9.1.x before **9.1.2** and 9.0.x before **9.0.10** are affected. WHMCS does not say the 8.x line is affected by this one.

**[CVE-2026-82979](https://www.cve.org/CVERecord?id=CVE-2026-82979) is CVSS 4.0 7.1 High**, `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`. A client who is logged in and holds the **View & Manage Contacts** permission can read other clients' personal, billing, and support information, and the same administrator records. 9.1.x before 9.1.2, 9.0.x before 9.0.10, and 8.13.x before **8.13.8** are affected.

**[CVE-2026-93700](https://www.cve.org/CVERecord?id=CVE-2026-93700) is CVSS 3.1 9.0 Critical**, `CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:H`. A logged-in client can read configuration files on the host, including database credentials, and run code on the server. WHMCS says this is in how email campaigns process client-supplied data. The record says user interaction is required and does not say whose. 8.0.0 through 8.13.7, 9.0.0 through 9.0.9, and 9.1.0 through 9.1.1 are affected. The fix exists only for supported versions: an 8.0 through 8.12 install has to move to 8.13.8, 9.0.10, or 9.1.2.

WHMCS credits alakazamspooon for all three and does not report attacks. The Hacker News does not either. None of the three advisories says WHMCS Cloud needs a customer update. The self-hosted administrator installs the build.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-24) for any of the three. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Three advisories** | **2026-11-23; time/TZ unknown** | Each page says Last Updated Nov 23, 2026, and prints no time. [82981][a81], [82979][a79], [93700][a00] |
| CVE records published | 2026-11-23 21:37:09 UTC | CVE-2026-82979 and CVE-2026-93700. CVE-2026-82981 the same day; the page says Published Nov 23 and no clock time. |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Update, then delete the campaigns. |

## Detection

Read the WHMCS version in the admin area. 9.1 before 9.1.2, 9.0 before 9.0.10, and 8.x before 8.13.8 are in scope for at least one of the three. A shopping cart that is not reachable from the internet is still the CVE-2026-82981 target for anyone who can reach it.

## Remediation

Update a self-hosted install to **9.1.2, 9.0.10, or 8.13.8**, on the line you run. WHMCS says to update after the patched release is available. 8.0 through 8.12 has no backport: move to one of those three.

For CVE-2026-93700, do this as well, because the update alone is not the whole fix:

1. Delete every planned or ongoing email campaign. Go to **Utilities > Email Campaigns**, and for each one choose **Delete** from **Manage Campaign** under **Actions**.
2. Empty the template cache. Go to **Utilities > System > System Cleanup** and click **Go** under **Empty Template Cache**.

The update does not show whether the shopping cart already returned administrator hashes, and it does not change a database password that was read out of a configuration file.

## Verification

The admin area reports 9.1.2, 9.0.10, 8.13.8, or a later build on that line. Email Campaigns lists nothing you did not just create. Do not send the shopping cart a crafted request to test it.

## Compromise response

If the install was reachable before the update, treat administrator password hashes and the database credentials in the configuration as exposed. Replace the database password, and require every administrator to set a new password rather than trusting a hash that may already be offline. Review administrator accounts for one you did not create. Deleting the campaigns does not undo a file that was already read.

## Sources

- [WHMCS, CVE-2026-82981][a81] — shopping cart, no login. 9.1.x before 9.1.2 and 9.0.x before 9.0.10. Last Updated Nov 23, 2026.
- [CVE-2026-82981](https://www.cve.org/CVERecord?id=CVE-2026-82981) — HackerOne, CVSS 4.0 8.7 High. The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:N/VA:N/SC:N/SI:N/SA:N`.
- [WHMCS, CVE-2026-82979][a79] — Client Area. Needs View & Manage Contacts. Adds 8.13.x before 8.13.8.
- [CVE-2026-82979](https://www.cve.org/CVERecord?id=CVE-2026-82979) — HackerOne, CVSS 4.0 7.1 High. Published 2026-11-23 21:37:09 UTC.
- [WHMCS, CVE-2026-93700][a00] — email campaigns. A logged-in client reads configuration files and runs code. Delete the campaigns and empty the template cache. A fix exists only for supported versions.
- [CVE-2026-93700](https://www.cve.org/CVERecord?id=CVE-2026-93700) — CVSS 3.1 9.0 Critical, `CVSS:3.1/AV:N/AC:L/PR:L/UI:R/S:C/C:H/I:H/A:H`. 8.0.0 through 8.13.7, 9.0.0 through 9.0.9, 9.1.0 through 9.1.1.
- [CISA KEV JSON][kev] — catalog 2026.11.23, checked 2026-11-24. None of the three is listed.

[a81]: https://help.whmcs.com/m/125386/l/2151347-cve-2026-82981-whmcs-security-update-2026-11-23
[a79]: https://help.whmcs.com/m/125386/l/2151340-cve-2026-82979-whmcs-security-update-2026-11-23
[a00]: https://help.whmcs.com/m/125386/l/2151351-cve-2026-93700-whmcs-security-update-2026-11-23
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
