# OPNsense: Google Cloud DNS command injection in the ACME client

**Last updated:** 2026-11-05 (America/New_York)

[Back to OPNsense ACME client summary](../black-october-2026.md#opnsense-google-cloud-dns-command-injection-in-the-acme-client) · [Changelog](../../CHANGELOG.md)

The ACME Client plugin for OPNsense, `os-acme-client` through 4.17, interpolates Google Cloud DNS account and project strings into a shell command. MITRE's CVE record scores [CVE-2026-123025](https://www.cve.org/CVERecord?id=CVE-2026-123025) CVSS 4.0 9.4 Critical. A logged-in user who can issue or renew certificates can run commands as root. The fix is in the plugin source as 4.18. The package repository checked on 2026-11-05 still publishes 4.17, and the maintainer has not set a release date.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). The CVE record does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Fix merged | 2026-11-03 22:21:57 UTC | Pull 5873, merge commit `5a0ac9a`, into `opnsense/plugins` master. The changelog line is "fix command injection in Google Cloud DNS validation", reported by `@cppghoul`. |
| Maintainer on a CVE | 2026-11-03 16:31 UTC | The maintainer wrote they do not plan to publish a GHSA or CVE, and that 4.18 waits on the next OPNsense release, with no date. |
| CVE record | 2026-11-05 | MITRE CNA. CVSS 4.0 9.4. Affected from 0 through 4.17.0. The record does not name a fixed version. |
| Package check | 2026-11-05 | `pkg.opnsense.org` FreeBSD 15 / 26.7 `latest/All` lists `os-acme-client-4.17.pkg` and `os-acme-client-devel-4.17.pkg`. 26.1 lists 4.16. 4.18 is not in either directory. |
| **Last updated** | **2026-11-05 (America/New_York)** | New item. |

## Detection

1. This is the **os-acme-client** plugin, not OPNsense core and not `acme.sh` by itself. On the firewall, System → Firmware → Plugins, or `pkg info os-acme-client`, shows the installed version. Through **4.17** is the range the CVE record names. The plugin Makefile on master says `PLUGIN_VERSION=4.18`; that file is not the package a firewall installs from the firmware page.
2. The vulnerable code is the Google Cloud DNS validation module, `DnsGcloud::prepare()`. It decodes the `dns_gcloud_key` field and places `gcloud_account` and `gcloud_project` into a command passed to `proc_open()` through `LeUtils::run_shell_command()`, with no escaping. A firewall that has never configured Google Cloud DNS validation is outside the path the record describes and is still on a plugin version the record calls affected.
3. The record requires a remote user who can already log in and issue or renew certificates through the WebGUI or API. Privileges Required is Low. An anonymous internet request is not the condition in the record.
4. Neither MITRE nor the maintainer publishes a log signature. A successful certificate renewal is not evidence the command was or was not rewritten.

## Remediation

1. The fixed plugin version in git is **4.18**. Do not install a package that is not in the firmware repository. On 2026-11-05 the 26.7 repository's newest `os-acme-client` and `os-acme-client-devel` packages are both **4.17**. The 26.1 repository is **4.16**.
2. Until 4.18 is the package the firmware page offers, remove or stop using the Google Cloud DNS challenge. The changelog for 4.18 also changes the Selfhost DNS API to an API key; that is a separate breaking change, not this flaw.
3. The maintainer said on 2026-11-03 that 4.18 ships with the next OPNsense release and that they will not publish a GHSA. A firewall that only updates plugins from the GUI will not get 4.18 before that package exists.
4. Updating later does not undo a command that already ran as root.

## Verification

- `pkg info os-acme-client` prints **4.18 or later**, and that package came from the firmware repository rather than a hand-built plugin. A Makefile on GitHub that says 4.18 is not this check.
- While the installed package is 4.17 or earlier, the Google Cloud DNS validation fields are unused. Clearing them is a reduction of the path the record names. It is not a patched plugin.
- A certificate that still renews through a different DNS provider is not evidence the Google Cloud path is fixed.

## Compromise response

- The record says a user who can issue or renew certificates can run commands as root. If an account that can do that was not yours, treat the firewall as a host where a root command may have run, not only as a plugin to upgrade.
- Review accounts that can manage ACME certificates. Remove ones you cannot account for. The plugin update does not expire their sessions.
- The record does not name files read or changed. A quiet certificate log does not show that a shell command did not run.

## Sources

- [CVE-2026-123025][cve] — MITRE, published 2026-11-05. CVSS 4.0 9.4, `CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. Affected `os-acme-client` from 0 through 4.17.0. No fixed version in the record. Reference is pull 5873.
- [Pull 5873][pr] — merged 2026-11-03 by the maintainer. Commit message: fix command injection in Google Cloud DNS validation. Reported by `@cppghoul`. The maintainer's comment the same day: no planned GHSA or CVE, and no release date.
- [Plugin changelog on master][changelog] — 4.18 lists the Google Cloud DNS command-injection fix. The same section's breaking change is the Selfhost API key.
- [Plugin Makefile on master][makefile] — `PLUGIN_VERSION=4.18`.
- [26.7 package directory][pkg267] — `os-acme-client-4.17.pkg` and `os-acme-client-devel-4.17.pkg`, checked 2026-11-05. No 4.18 package.
- [26.1 package directory][pkg261] — `os-acme-client-4.16_1.pkg`, checked 2026-11-05.
- [CISA KEV JSON feed][kev] — CVE-2026-123025 not listed (catalog 2026.11.04, checked 2026-11-05).

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123025
[pr]: https://github.com/opnsense/plugins/pull/5873
[changelog]: https://github.com/opnsense/plugins/blob/master/security/acme-client/pkg-descr
[makefile]: https://github.com/opnsense/plugins/blob/master/security/acme-client/Makefile
[pkg267]: https://pkg.opnsense.org/FreeBSD:15:amd64/26.7/latest/All/
[pkg261]: https://pkg.opnsense.org/FreeBSD:14:amd64/26.1/latest/All/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
