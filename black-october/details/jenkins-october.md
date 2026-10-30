# Jenkins: October core security fixes

**Last updated:** 2026-10-30 (America/New_York)

[Main Jenkins summary](../black-october-2026.md#jenkins-october-core-security-fixes) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Jenkins rates the October 28 core advisory's tracked issues High. They affect Jenkins weekly 2.587 and earlier and LTS 2.580.1 and earlier. The group includes deserialization RCE, controller-file reads or writes, privilege escalation, and stored XSS; prerequisites differ by CVE.

**CISA KEV:** Not listed (catalog 2026.10.29, checked 2026-10-30). Jenkins reports no active exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Public advisory and fixes | 2026-10-28; time/TZ unknown | Jenkins published 14 High and two Medium core issues. [Jenkins advisory][jenkins] |
| Fixed weekly and LTS releases | 2026-10-28; time/TZ unknown | Weekly 2.588 and LTS 2.580.2 contain the fixes. [Jenkins advisory][jenkins] |

## Detection

1. Inventory controller versions and release channel from the Jenkins administration interface or package metadata; record weekly versus LTS.
2. Treat weekly 2.587 and earlier, and LTS 2.580.1 and earlier, as affected unless Jenkins explicitly states an exception for the specific issue.
3. Review access to job configuration, agent management, artifact upload and controller filesystem paths. Several issues require existing Item/Configure, Overall/Read, or agent control; CVE-2026-117618 is limited to a setup-wizard race.

## Remediation

1. Upgrade Jenkins core to weekly **2.588** or LTS **2.580.2**. Use the supported package, container, or WAR upgrade method and preserve a tested controller backup.
2. Until every controller is upgraded, restrict administrative and job-configuration permissions, do not accept untrusted job XML or artifacts, and retain Content Security Policy enforcement. These are exposure reductions, not substitutes for the update.
3. Do not enable `hudson.util.XStream2.SUPPRESS_TYPE_PERMISSION` as a workaround unless Jenkins support has directed it for a compatibility incident; it disables an additional protection introduced with the fix.

## Verification

- Confirm the running controller reports 2.588 or 2.580.2 or later and that managed controllers use the same supported train.
- Exercise normal trusted build, agent, and job-configuration workflows in a non-production controller after upgrade. Do not submit crafted XML, paths, or artifacts to test the flaws.

## Compromise response

If an affected controller accepted untrusted configuration, artifacts, or agent input, preserve controller and audit logs, review job/configuration changes and agent records, rotate credentials exposed to the controller, and rebuild controller state from known-good backups where integrity is uncertain.

## Sources

- [Jenkins Security Advisory 2026-10-28][jenkins] — severity, affected releases, prerequisites and fixed versions.
- [CVE-2026-117612][cve-rce] — CNA record for the deserialization issue.
- [CISA KEV JSON feed][kev] — catalog status.

[jenkins]: https://www.jenkins.io/security/advisory/2026-10-28/
[cve-rce]: https://www.cve.org/CVERecord?id=CVE-2026-117612
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
