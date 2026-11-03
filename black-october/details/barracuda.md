# Barracuda: configuration restore without a login, and a root command

**Last updated:** 2026-11-03 (America/New_York)

[Main Barracuda summary](../black-october-2026.md#barracuda-configuration-restore-without-a-login-and-a-root-command) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Two flaws, published together on 2026-11-02. Mandiant is the CNA. Barracuda's advisory and Mandiant's CVE record do not describe the first flaw the same way.

**[CVE-2026-116606](https://www.cve.org/CVERecord?id=CVE-2026-116606): Mandiant CVSS 4.0 9.3 Critical (`AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`).** Email Security Gateway before **9.4.0.030**. Mandiant says an unauthenticated remote attacker can call a configuration-import function and restore a crafted backup, which replaces the appliance's global configuration. Barracuda's own advisory titles this a pre-authentication authorization bypass, scores it 9.3, and then says "Authentication Required: Yes, administrative access." The CVE record is the one that says no login. Barracuda names patches **BNSF-40425** on firmware 9.4.017 and later, and **BNSF-40430** below 9.4.017. It does not print 9.4.0.030 as the fixed version. [Mandiant][m42] [Barracuda][bar]

**[CVE-2026-111560](https://www.cve.org/CVERecord?id=CVE-2026-111560): Mandiant CVSS 4.0 8.6 High (`AV:N/AC:L/AT:N/PR:H/UI:N/VC:H/VI:H/VA:H/SC:N/SI:N/SA:N`).** An authenticated administrator can put shell metacharacters in the timezone field. The appliance runs the resulting command as root. Mandiant's affected ranges are ESG through **9.4.0.27**, Load Balancer ADC through **6.4.0**, Web Application Firewall through **11.0.1**, and Web Security Gateway through **16.1.100.100**. Barracuda's table also lists Message Archiver (patch **BNMA-32468**) and WAF Control Center (patch **BNWF-60060**). Those two are not in the CVE record's product list. Barracuda's patch IDs for the others are **BNADC-16586** (ADC and WAF) and **BNYF-24789** (WSG). A Barracuda Campus page says WSG firmware **15.0.0.009 through 16.1.003** was updated and that 15.0 and below should move to 15.0.0.009 or later. That page does not match the CVE ceiling of 16.1.100.100. [Mandiant][m41] [Campus][wsg]

Barracuda says chaining the two "could allow an attacker to bypass authorization controls and obtain root access." It also says exploitation requires access to the administrative interface. Mandiant says the import does not require authentication and the command injection does. Neither source reports exploitation.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03) for either CVE. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Mandiant | 2026-10-15 (command injection); 2026-10-22 (configuration import) | Dates only. [MNDT-2026-0041][m41] [MNDT-2026-0042][m42] |
| Barracuda advisory and CVE records | 2026-11-02; time/TZ unknown | Advisory published and updated the same day. CVE records published 2026-11-02. [Barracuda][bar] |

## Detection

1. Read the firmware version on the appliance. Barracuda says the device shows the latest available version. A version several releases behind may need more than one update.
2. For Email Security Gateway, Mandiant's floor for the configuration import is anything before **9.4.0.030**. Barracuda's patch names are BNSF-40425 at 9.4.017 and later, and BNSF-40430 below that. Confirm the installed patch, not only the firmware train.
3. For the command injection, compare the product with Mandiant's ceilings: ESG through 9.4.0.27, ADC through 6.4.0, WAF through 11.0.1, WSG through 16.1.100.100. Message Archiver and WAF Control Center are in Barracuda's table and absent from that CVE product list, so a missing CVE row is not a clearance.
4. Check whether the administrative interface is reachable from the internet. Barracuda says an interface that is not public is less exposed. Reachability is not a patch.

## Remediation

1. Apply the patch for the product, or install the firmware that contains it. If automatic patching is off, turn it on after this update. Barracuda's manual steps are on [Campus][campus].
2. Keep the administrative interface on a trusted network. That is Barracuda's exposure reduction. It does not fix either flaw.
3. Do not treat Barracuda's "authentication required" line as cancelling Mandiant's unauthenticated import. The CVE record is the one that says no login is needed for CVE-2026-116606.

## Verification

- The appliance reports a firmware version and patch at or past the row for that product. ESG before 9.4.0.030 is still inside Mandiant's range for the import, even if a patch number is harder to read.
- The administrative interface is not reachable from an untrusted network you control. Test with a connection only. Do not send a backup or a timezone value.

## Compromise response

A restored configuration can replace administrator accounts and policy. A command that already ran as root is not undone by the patch. If the administrative interface was reachable, preserve the configuration history and the admin audit log before you upgrade, and review accounts and policy changes you did not make. Neither Barracuda nor Mandiant reports that this has happened.

## Sources

- [Barracuda advisory][bar] — 2026-11-02. Scores 9.3 and 8.6, product table, patch IDs, and the "authentication required" line that disagrees with the CVE record.
- [Mandiant MNDT-2026-0042][m42] — CVE-2026-116606, unauthenticated configuration import, ESG before 9.4.0.030, CVSS 4.0 9.3.
- [Mandiant MNDT-2026-0041][m41] — CVE-2026-111560, authenticated administrator, root command, CVSS 4.0 8.6, and the four product ceilings.
- [Barracuda Campus, Web Security Gateway][wsg] — says firmware 15.0.0.009 through 16.1.003 was updated. That range is not the CVE ceiling.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30. Neither CVE is listed.

[bar]: https://trust.barracuda.com/security/pre-authentication-authorization-bypass-command-injection
[m42]: https://github.com/mandiant/Vulnerability-Disclosures/blob/master/2026/MNDT-2026-0042.md
[m41]: https://github.com/mandiant/Vulnerability-Disclosures/blob/master/2026/MNDT-2026-0041.md
[wsg]: https://documentation.campus.barracuda.com/wiki/spaces/BWFv60/pages/963706956/Command+Injection+Vulnerability+in+Certain+Barracuda+Networks+Products
[campus]: https://documentation.campus.barracuda.com/wiki/x/n4BGOQ
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
