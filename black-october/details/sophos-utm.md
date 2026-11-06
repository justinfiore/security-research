# Sophos UTM: unauthenticated root command through the email proxy

**Last updated:** 2026-11-05 (America/New_York)

[Back to Sophos UTM summary](../black-october-2026.md#sophos-utm-unauthenticated-root-command-through-the-email-proxy) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-118633](https://www.cve.org/CVERecord?id=CVE-2026-118633): Sophos rates it CVSS 4.0 9.2 Critical and CVSS 3.1 8.1 High.** NVD has not scored it. A path traversal in the SMTP email proxy lets a remote unauthenticated attacker run a command as root, after winning a race by repeating the attempt for a few minutes, when email scanning is enabled. Sophos UTM is end of life. The fix is a manual RPM, not an automatic update. Sophos Firewall (SFOS) is not named. [Advisory][adv] [Record][cve]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). Sophos does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Advisory and CVE published | 2026-10-28; time/TZ unknown | sophos-sa-20261028-utm-rce, article version 1. First Published and Updated are both 2026 Oct 28. The CVE record's updated and published dates are 2026-10-28. [Advisory][adv] [Record][cve] |
| JPCERT/CC weekly report | 2026-11-05; time/TZ unknown | Item 2 of the report covering October 25–31. Says the product is already end of life and the patch is manual. [JPCERT][jpcert] |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. |

## Detection

1. This is Sophos UTM (SG UTM), not Sophos Firewall. A host running SFOS is outside this advisory.
2. The CVE record says every version from 0 through **9.724** is affected. The support article says to be on 9.724 before installing the RPM. A version below 9.724 is still inside the affected range, and 9.724 without the RPM is too.
3. Exposure, as Sophos describes it, is an SMTP gateway with email scanning enabled. The record says "when the email proxy is used with scanning enabled." A UTM that does not accept mail is outside that condition. The record still lists all versions as affected.
4. Sophos publishes no log signature and no indicator of compromise. A quiet mail log does not show the race was never won.

Read the version on the appliance. The support article's check that the RPM is present is the hash of `/usr/bin/cssd`, below.

## Remediation

Sophos says there is no workaround. The product is end of life, so the patch does not arrive through the normal update.

1. Move mail and firewall features to a [supported Sophos Firewall](https://support.sophos.com/support/s/article/KBA-000003353?language=en_US) release when you can. That is the path the advisory lists first.
2. Until that move, install the manual patch from [KBA-000049692][kba]. The article's order is: update the UTM to **9.724**, sign in as `loginuser`, download `ep-cssd-64-9.70-29.g7f03cc7.x86_64.rpm` from `https://download.astaro.com/UTM/v9/patch/`, confirm its SHA-256 is `2f1b5a9cc62b887ddc56d74c42be96b8a98d07ebc7fdac1705347ec52778d3dc`, then `sudo rpm -Uvh --force` that file and `sudo /var/mdw/scripts/cssd restart`.
3. Do not install an RPM whose hash does not match. The article gives one expected thumbprint.
4. A UTM that is still accepting scanned mail, and that has not had this RPM installed, is still in the condition the advisory describes. Taking SMTP off the internet is the mitigation while the RPM is not yet installed. Sophos does not list that as a workaround that fixes the flaw.

## Verification

- `sha256sum /usr/bin/cssd` prints `eb0e7c60f6607df2f1a0448167b13022eec2b80c47c7bef124230a585d64a409`. That is the thumbprint the support article says confirms the fix. A version string of 9.724 without that hash is not the fix.
- `cssd` was restarted after the RPM. The article's command is `sudo /var/mdw/scripts/cssd restart`.
- Sophos Firewall appliances are a different product. Confirming an SFOS version does not clear a UTM that is still on the network.

## Compromise response

- The result Sophos describes is a root command, reached by sustaining the race for a few minutes against the mail proxy. If the UTM was accepting scanned mail from networks you do not trust, treat credentials and mail handled by that appliance as exposed.
- Rotate administrator passwords and any secret the UTM stored for mail scanning, directory services, and the firewalls it fronted. Installing the RPM does not expire a credential already copied, and it does not undo a command that already ran.
- Moving to Sophos Firewall does not clean the old appliance. Power the UTM off after the replacement is passing mail, or keep it only long enough to preserve logs.

## Sources

- [sophos-sa-20261028-utm-rce][adv] — Critical. Unauthenticated root command after a race of a few minutes, when the email proxy is used with scanning enabled. All Sophos UTM versions. No workaround. Manual patch. First Published 2026 Oct 28.
- [KBA-000049692][kba] — RPM `ep-cssd-64-9.70-29.g7f03cc7.x86_64.rpm`, package SHA-256 `2f1b5a9cc62b887ddc56d74c42be96b8a98d07ebc7fdac1705347ec52778d3dc`, installed `/usr/bin/cssd` SHA-256 `eb0e7c60f6607df2f1a0448167b13022eec2b80c47c7bef124230a585d64a409`. Requires 9.724 first. Dated Oct 28, 2026.
- [CVE-2026-118633][cve] — Sophos CNA, 2026-10-28. CVSS 4.0 9.2 and CVSS 3.1 8.1. Affected from 0 through 9.724. Product "SG UTM."
- [JPCERT/CC Weekly Report 2026-11-05][jpcert] — item 2. End of life, manual patch.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.04, checked 2026-11-05).

[adv]: https://www.sophos.com/en-us/security-advisories/sophos-sa-20261028-utm-rce
[kba]: https://support.sophos.com/support/s/article/KBA-000049692
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-118633
[jpcert]: https://www.jpcert.or.jp/wr/2026/wr261105.html
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
