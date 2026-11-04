# WSO2 API Manager: a self-registered user reaches the System REST APIs

**Last updated:** 2026-11-04 (America/New_York)

[Back to WSO2 API Manager summary](../black-october-2026.md#wso2-api-manager-a-self-registered-user-reaches-the-system-rest-apis) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-4052](https://www.cve.org/CVERecord?id=CVE-2026-4052): WSO2 (CNA) CVSS 3.1 9.8 Critical.** The flaw applies only where WSO2 Identity Server is the Resident Key Manager **and** shares a database with API Manager. A user who can self-register obtains a token from the Identity Server token endpoint and calls API Manager's System REST APIs. WSO2 says that can become full administrative account takeover. The advisory page is dated June 18, 2026. The CVE record was published on November 3, 2026. NVD has not scored it. It is not in CISA KEV. [WSO2-2026-5212][adv] [CVE record][cve]

**CISA KEV:** Not listed (catalog 2026.11.03, checked 2026-11-04). Neither WSO2 nor the CVE record reports exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Advisory page | 2026-06-18; time/TZ unknown | WSO2-2026-5212, version 1.0. Git commit message: "Add public announcement June 2026." [Advisory][adv] [Commit][commit] |
| Advisory page names the CVE | 2026-11-04 03:37:07 UTC | Commit `e0c2564670` filled the empty CVE link. The rendered page now titles itself WSO2-2026-5212/CVE-2026-4052 and lists `CVE IDs: CVE-2026-4052`. The fix steps still say "latest U2" and "latest connector" and still do not print 1.8.8. |
| CVE record published | 2026-11-03 08:17:15 UTC | WSO2 CNA. CVSS 3.1 9.8. Names API Manager 4.1.0–4.6.0, API Control Plane 4.5.0 and 4.6.0, and connector `wso2is.key.manager.core` before 1.8.8. [Record][cve] [NVD][nvd] |
| Connector 1.8.8 on Maven Central | 2026-04-13 07:02:14 UTC | `org.wso2.km.ext.wso2is:wso2is.key.manager.core` 1.8.8. 1.8.9 was published 2026-06-02 05:41:17 UTC. The 2.1.x line is a different artifact series (2.1.6 on 2026-06-04). [Maven][maven] |
| Setup page still links 1.7.17 | checked 2026-11-04 | The API Manager 4.6.0 Resident Key Manager page tells the reader to install `wso2is-extensions-1.7.17`, including `wso2is.key.manager.core-1.7.17.jar`. The CVE record says that jar is affected. [4.6.0 setup][setup46] |
| **Last updated** | **2026-11-04 (America/New_York)** | The advisory page now shows the CVE ID. The fix steps are unchanged. |

## Detection

1. This CVE applies only when **both** of these are true: Identity Server is configured as the Resident Key Manager, and API Manager and Identity Server share a database. A deployment that uses API Manager's own key manager, or that does not share that database, is outside the description WSO2 and the CVE record give.
2. The named product versions are API Manager **4.1.0, 4.2.0, 4.3.0, 4.4.0, 4.5.0, and 4.6.0**, and API Control Plane **4.5.0 and 4.6.0**. Read the running product version from the installation, not from a download directory.
3. On the Identity Server host, look in `<IS_HOME>/repository/components/dropins` for `wso2is.key.manager.core-*.jar`. The CVE record says versions **before 1.8.8** are affected. **1.8.8 and 1.8.9** are the later 1.8 releases on Maven Central. A 2.1.x jar is a different series; the CVE record does not say whether 2.1.x is fixed, so do not treat a 2.1 jar as proof of the fix.
4. The API Manager 4.6.0 setup page still links connector **1.7.17**. Finding that version means the documented install steps have not been replaced with the connector the CVE record requires. It does not by itself prove the Resident Key Manager configuration is in use.
5. WSO2 publishes no indicators of compromise. A self-registration followed by a call to a System REST API is the path the advisory describes. Absence of such a log line is not a clean bill.

## Remediation

1. Confirm the configuration in Detection step 1 before changing anything. If it does not match, this CVE does not describe your deployment.
2. Where it does match, do all three of the things [WSO2-2026-5212][adv] lists, then restart Identity Server:
   - Update Identity Server to the latest U2 update for the version you run. WSO2 does not print a U2 number.
   - Update API Manager, or API Control Plane, to the latest U2 update for 4.1.0–4.6.0. WSO2 does not print a fixed product version above 4.6.0.
   - Replace the connector on Identity Server. The CVE record says `wso2is.key.manager.core` before **1.8.8** is affected. Remove the old `wso2is.key.manager.core` and `wso2is.notification.event.handlers` jars from `dropins`, remove `keymanager-operations.war` and its unpacked directory under `webapps`, and install the jars and war from a connector build whose core jar is **1.8.8 or later** (1.8.9 is published).
3. Do not follow the 4.6.0 setup page's download as the fix. When checked, that page still said to install `wso2is-extensions-1.7.17`. The CVE record lists that version as affected. Use the connector version from the CVE record, not the version number printed in that setup step.
4. Turning off self-registration stops the account-creation step the advisory names. It does not fix a connector before 1.8.8, and it does nothing for an account that already exists.

## Verification

- The running API Manager or API Control Plane is on a U2 update WSO2's subscription portal shows as current for that line, and Identity Server is on its current U2. A downloaded pack that is not the running one is not the fix.
- `<IS_HOME>/repository/components/dropins` contains `wso2is.key.manager.core` **1.8.8 or later**, and the process start time is after that file was copied. A 1.7.x jar left beside it is not a clean install.
- `keymanager-operations` under `webapps` is the war from that same connector, not an older unpacked copy.
- A deployment that does not use Identity Server as Resident Key Manager with a shared database is outside this CVE. Confirm that from the configuration, not from the product version alone.

## Compromise response

- WSO2 says the result can be full administrative account takeover. If self-registration is open and the configuration matches, review accounts created since 2026-06-18 and tokens issued to them, and remove administrator roles you cannot account for.
- Replacing the connector does not revoke a token an attacker already obtained, and it does not undo an API, application, or user that account created. Rotate client secrets and administrator passwords that such a session could have read or changed.
- WSO2 publishes no exploit payload and no log signature. Do not treat a quiet log as proof the System REST APIs were never called.

## Sources

- [WSO2-2026-5212][adv] — Critical, CVSS 3.1 9.8. Page dated 2026-06-18. Names API Manager 4.1.0–4.6.0 and API Control Plane 4.5.0 and 4.6.0. The fix steps say "latest U2" and "latest connector" and do not print 1.8.8. As of 2026-11-04 the rendered page shows CVE-2026-4052.
- [Git commit 59defef][commit] — "Add public announcement June 2026," 2026-06-18.
- [CVE-2026-4052][cve] — published 2026-11-03 08:17:15 UTC. Connector `org.wso2.km.ext.wso2is:wso2is.key.manager.core` before 1.8.8.
- [NVD CVE-2026-4052][nvd] — received 2026-11-03. NVD has not added its own score.
- [API Manager 4.6.0 Resident Key Manager setup][setup46] — still links `wso2is-extensions-1.7.17.zip` when checked on 2026-11-04.
- [Maven Central, `wso2is.key.manager.core`][maven] — 1.8.8 and 1.8.9 are published. 2.1.6 is a later, separate line.
- [CISA KEV JSON feed][kev] — not listed (catalog 2026.11.03, checked 2026-11-04).

[adv]: https://security.docs.wso2.com/en/latest/security-announcements/security-advisories/2026/WSO2-2026-5212/
[commit]: https://github.com/wso2/docs-security/commit/59defef50bf07da8b096c69f4f885fe46b346bbd
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-4052
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-4052
[setup46]: https://apim.docs.wso2.com/en/4.6.0/install-and-setup/setup/distributed-deployment/configuring-wso2-identity-server-as-a-key-manager/
[maven]: https://central.sonatype.com/artifact/org.wso2.km.ext.wso2is/wso2is.key.manager.core
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
