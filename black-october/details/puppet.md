# Puppet: report deserialization runs code on the server

**Last updated:** 2026-11-04 (America/New_York)

[Main Puppet summary](../black-october-2026.md#puppet-report-deserialization-runs-code-on-the-server) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-115731](https://www.cve.org/CVERecord?id=CVE-2026-115731): Perforce (CNA) CVSS 4.0 9.4 Critical (`CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`).** A client that holds any CA-signed agent certificate can run code on the Puppet Server as the service user by sending a report with a crafted rich-data type. Where the CA autosigns requests without a strong check, an unauthenticated attacker can obtain that certificate. OpenVox's advisory includes a JSON report that runs `touch /tmp/pwned` as the `puppet` user. Code execution as that user can read the CA signing key. [CVE record][cve] [OpenVox][openvox]

The same updates fix [CVE-2026-115732](https://www.cve.org/CVERecord?id=CVE-2026-115732), which Perforce scores CVSS 4.0 9.0 Critical. A certificate whose name is longer or shorter than an authorized hostname can be treated as that host.

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04). Perforce and OpenVox do not report exploitation in the wild. A public proof of concept is not the same as observed exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Private discovery | Unknown | OpenVox credits alain-neodyme. [OpenVox][openvox] |
| CVE records published | 2026-11-03; time/TZ unknown | CVE-2026-115731 published 2026-11-03. CVE-2026-115732 published 2026-11-03. [CVE record][cve] [CVE-2026-115732][cve732] |
| OpenVox advisory | 2026-11-03; time/TZ unknown | GHSA-ffr6-rwpm-p5wq. Includes a report body that runs a shell command. OpenVox's own GHSA page says "No known CVE" even while the text names CVE-2026-115731. [OpenVox][openvox] |
| Puppet Core 9.1.3 notes | Last published 2026-10-30; release "November 2026" | The page says it fixes CVE-2026-115731 and CVE-2026-115732. It does not give a clock time. [Puppet Core 9.1.3][core913] |

## Detection

Read the server and agent versions. Do not send a report to test the flaw.

```sh
puppetserver --version
puppet --version
```

Run `puppet --version` on an agent as well. The agent version is not the server version.

Perforce's CVE dashboard lists the same fixed builds for both CVEs.

| Product | Vulnerable | Fixed |
|---|---|---|
| Puppet Enterprise | 2023.8.0 before 2023.8.13; 2025.0.0 before 2025.12.1; 2026.0.0 before 2026.0.1 | 2023.8.13, 2025.12.1, or 2026.0.1 |
| Puppet Core | before 8.22.2 on the 8 line; before 9.1.3 on the 9 line | 8.22.2 or 9.1.3 |
| OpenVox Server | 8.17.0 and earlier; 9.1.0 and earlier | 8.18.0 or 9.2.0 |
| OpenVox Agent | 8.31.1 and earlier; 9.2.0 and earlier | 8.32.0 or 9.3.0 |

A version the table does not name is **unknown**, not safe. Updating only the agents does not fix the server. The report endpoint is the server's.

Autosign makes CVE-2026-115731 reachable without an existing certificate. With autosign off, the caller still needs a certificate the CA already signed.

## Remediation

1. Upgrade Puppet Enterprise to **2023.8.13, 2025.12.1, or 2026.0.1**, as applicable. Those builds include Puppet Core **8.22.2** (2023.8.13 and 2025.12.1) or **9.1.3** (2026.0.1). Upgrade Puppet Core on its own to **8.22.2 or 9.1.3** when you do not run Puppet Enterprise. Restart Puppet Server after the packages are installed.

2. Upgrade OpenVox Server to **8.18.0 or 9.2.0**, and OpenVox Agent to **8.32.0 or 9.3.0**. The agent packages are part of the fix OpenVox shipped; the code runs on the server.

3. Until the server is upgraded, do not autosign certificate requests without a check you already trust. Red Hat states that limit. It does not cover a client that already holds a signed certificate. Keep the report endpoint reachable only by agents you issued.

4. A compiler, a replica, and a standalone Puppet Server each need the upgrade. An agent upgrade alone is not the server upgrade.

## Verification

- `puppetserver --version` and `puppet --version` on the server are at or above the floor for that product. An agent at 8.22.2 does not tell you the server's version.
- Puppet Server was restarted after the package install.
- Autosign is still off, or it still requires the check you configured. Turning it back on without that check restores the unauthenticated path on an unpatched server.
- Do not confirm the fix by submitting the sample report. That report runs a command.

## Compromise response

The advisory describes code execution as the `puppet` user and access to the CA signing key. It does not describe a log field that proves a report was malicious.

- If a server was reachable by an agent you do not trust while it was still vulnerable, treat the CA key as exposed. Rebuild the CA, reissue agent certificates, and revoke the old ones. Upgrading the package does not replace a key that was copied.
- Look for `/tmp/pwned` only as a leftover of the published proof, not as a sign that a real attacker used that exact command. Review Puppet Server logs for report submissions from agents you did not enroll.
- On Puppet Enterprise, CVE-2026-115732 can impersonate another node and reach certificate-authority administration. Review CA actions and node certificates whose names are prefixes or extensions of a real hostname.

## Sources

- [CVE-2026-115731][cve] — Perforce CNA, published 2026-11-03. CVSS 4.0 9.4 Critical. Puppet Enterprise before 2023.8.13, 2025.12.1, and 2026.0.1.
- [CVE-2026-115732][cve732] — Perforce CNA, published 2026-11-03. CVSS 4.0 9.0 Critical. Certificate-name authorization bypass. Same fixed Enterprise versions.
- [OpenVox GHSA-ffr6-rwpm-p5wq][openvox] — published 2026-11-03. Includes the report JSON. Server 8.18.0 / 9.2.0 and agent 8.32.0 / 9.3.0.
- [Puppet Core 9.1.3 release notes][core913] — last published 2026-10-30; "Released in November 2026." Names both CVEs.
- [Perforce CVE dashboard](https://portal.perforce.com/s/cve-dashboard) — both CVEs dated 2026-11-03, with Puppet Core 8.22.2 and 9.1.3 in the fixed list. The per-CVE portal page did not render the advisory text when checked.
- [CISA KEV JSON feed][kev] — catalog 2026.11.03, neither CVE listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-115731
[cve732]: https://www.cve.org/CVERecord?id=CVE-2026-115732
[openvox]: https://github.com/OpenVoxProject/openvox/security/advisories/GHSA-ffr6-rwpm-p5wq
[core913]: https://help.puppet.com/core/current/Content/PuppetCore/PuppetReleaseNotes/release_notes_puppet_x-9-1-3.htm
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
