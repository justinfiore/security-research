# Checkmk: a monitored host writes a file the server runs

**Last updated:** 2026-11-12 (America/New_York)

[Back to Checkmk summary](../black-october-2026.md#checkmk-a-monitored-host-writes-a-file-the-server-runs) · [Changelog](../../CHANGELOG.md)

Checkmk monitors hosts through an agent. [CVE-2026-120495](https://www.cve.org/CVERecord?id=CVE-2026-120495) is in the Robotmk test service: a test-case name from the agent output becomes a folder path, and the path was not checked.

**Checkmk rates it CVSS 4.0 9.4 Critical** (`CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`). The agent output chooses the folder for an HTML log whose contents the same output supplies. A path outside `~/var/robotmk/html_logs` lets that file land where the server will run it, as the site user. Checkmk says exploiting it takes a monitored host whose agent output the attacker can write, which usually means root on that host, and it takes automatic service discovery or a monitoring administrator confirming the new service.

Affected versions are 2.5.0 before 2.5.0p19, 2.4.0 before 2.4.0p40, and 2.3.0. Werk 22624 marks 2.3.0 end of life and lists no fix for it. The fixed builds are 2.5.0p19 and 2.4.0p40, on Checkmk Pro, Checkmk Ultimate, Checkmk Cloud, and Checkmk Ultimate MT. 3.0.0b1 is listed as not yet released.

**CISA KEV:** Not listed (catalog 2026.11.10, checked 2026-11-12). The werk does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Werk dated | 2026-11-02; time unknown | Werk 22624. Checkmk gives no time. [Werk][werk] |
| **Public announcement** | **2026-11-11; time unknown** | The CVE record was published that day and gives no time. [CVE][cve] |
| **Last updated** | **2026-11-12 (America/New_York)** | New item. |

## Detection

1. **Version.** 2.5.0p19, 2.4.0p40, or later on that line is the fix. Anything earlier on 2.4 or 2.5 is inside the range. 2.3.0 is inside it and has no fix.
2. **Robotmk.** A site that does not run the Robotmk test service has nothing for this path to write. Checkmk does not say the flaw exists in another service.
3. **Discovery.** Automatic service discovery, or an administrator confirming new services, is the condition Checkmk names.

## Remediation

1. Upgrade 2.5 to **2.5.0p19** or later, and 2.4 to **2.4.0p40** or later. The werk says the change is compatible and needs no manual interaction.
2. 2.3.0 is end of life. Move off it. There is no fixed 2.3 build.
3. The fixed build refuses a log outside `~/var/robotmk/html_logs` and shows UNKNOWN in the service summary when that happens.
4. The upgrade does not show whether a file was already written.

## Verification

- The site reports 2.5.0p19, 2.4.0p40, or later.
- A Robotmk service that already runs still reports. Do not send crafted agent output.

## Compromise response

Checkmk publishes no indicator.

- Look for HTML files written outside `~/var/robotmk/html_logs` by the site user, and for a Robotmk service you did not add.
- The upgrade does not delete a file already written. Remove it before treating the host as clean.

## Sources

- [Werk 22624][werk] — dated Nov 2, 2026. CVSS 4.0 9.4. Affected 2.5.0, 2.4.0, and 2.3.0 (EOL). Fixed in 2.5.0p19 and 2.4.0p40.
- [CVE-2026-120495][cve] — Checkmk CNA, published 2026-11-11. Same score. Affected from 2.5.0 before 2.5.0p19, from 2.4.0 before 2.4.0p40, and at 2.3.0.
- [CISA KEV][kev] — catalog 2026.11.10, checked 2026-11-12. Not listed.

[werk]: https://checkmk.com/werk/22624
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-120495
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
