# SAP Cloud SDK for Python: OAuth2 SSRF leaking multi-tenant client credentials

**Last updated:** 2026-10-31 (America/New_York)

[Main SAP Cloud SDK for Python summary](../black-october-2026.md#sap-cloud-sdk-for-python-oauth2-ssrf-leaking-multi-tenant-client-credentials) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-89111](https://www.cve.org/CVERecord?id=CVE-2026-89111) (GHSA-4mv3-jxxm-9cx2): SAP CNA CVSS 3.1 10.0 Critical (CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:N). SAP's GitHub advisory gives the same score and vector. SAP's October 2026 Security Patch Day page also lists 10.0 Critical, but its score links to a CVSS 3.0 calculator vector ending `A:H`, which differs from the CNA record's `A:N`. NVD has not added its own score (status "Awaiting Analysis"). Not listed in CISA KEV.** The pip package `sap-cloud-sdk` (SAP Cloud SDK for Python) has an OAuth2 server-side request forgery (SSRF, CWE-918) flaw that affects **multi-tenant SAP Business Technology Platform (BTP) applications**. If an attacker controls the `tenant_subdomain` value, they can redirect the SDK's OAuth2 token request to a server they control and steal the client credentials. SAP's CNA record, updated 2026-10-30, lists two affected ranges: **before 0.45.2**, and **0.53.0 up to but not including 0.55.1**. The second range is fixed in **0.55.1**, whose notes say `XsuaaAuthProvider._fetch_token` again validates the tenant before substituting it into the token URL. A version at or above 0.45.2 is not safe if it is also below 0.55.1 and at or above 0.53.0. [SAP advisory][ghsa] [CNA][cve] [v0.55.1 release][r0551] [SAP Patch Day][patchday]

**Affected code:** to get a subscriber-tenant token, the SDK inserts the tenant subdomain into the service binding's token URL as plain text, replacing the provider's `identityzone`. Before 0.45.2 the value was not validated. A crafted value could therefore change where the token request goes. In the Destination and DMS code, that request carries the binding's `client_id` and `client_secret`. In the LoB flow, Agent Gateway passes the tenant to the Destination service. The 0.45.2 release notes name three code paths that now validate the value as a single RFC 1123 DNS label:

- `destination.TokenProvider.get_token`, reached through the `tenant=` argument of the Destination, Fragment and Certificate clients.
- `dms.Auth._resolve_token_url`, reached through the Document Management (DMS) client's `tenant=` argument.
- `AgentGatewayClient._resolve_tenant_subdomain`, reached through `agentgateway.create_client(tenant_subdomain=...)`, which the line-of-business (LoB) agent flow requires.

Invalid values now raise `ValueError: Invalid tenant_subdomain: '<value>'`. [v0.45.2 release][r0452] [Fix commit][fix] [Destination guide][destguide] [DMS guide][dmsguide] [Agent Gateway guide][agwguide]

**Who is affected:** applications that pass a tenant value an attacker can influence (for example, one taken from the request host, a header, a query parameter or the request body) into those calls. The advisory limits impact to multi-tenant BTP applications. Calls that pass no tenant use the binding's unmodified token URL, based on the pre-fix source. That conclusion comes from the code; the advisory does not state it. [SAP advisory][ghsa] [Pre-fix Destination source][destsrc] [Pre-fix DMS source][dmssrc]

**Worst case:** the attacker obtains the OAuth client credentials of the service bindings the SDK uses, such as the Destination service or Document Management service. They can then request tokens as the application, outside it, until the credentials are rotated. SAP rates confidentiality and integrity impact High with changed scope. [CNA][cve]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). CISA's ADP SSVC entry in the CVE record (2026-10-14) records "Exploitation: none", and the reviewed sources report no in-the-wild exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Read-only inventory](#read-only-inventory)
  - [Reachability](#reachability)
  - [Log and egress review](#log-and-egress-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private report | Unknown | The SAP advisory credits GitHub user SunandM as reporter. It gives no report date. The CVE record lists discovery as "UNKNOWN". [SAP advisory][ghsa] [CNA][cve] |
| Fix pull request opened | 2026-08-20 16:41:50 UTC | PR #279, "fix: add subdomain validator". [PR #279][pr] |
| Fix merged | 2026-08-21 13:55:48 UTC | Commit `fc67a8f4c0`. Git committer timestamp. [Fix commit][fix] |
| **v0.45.2 released (fixed)** | 2026-08-21 14:04:49 UTC (GitHub release); 14:06:42 UTC (PyPI upload) | Release notes describe input validation as a bug fix ("invalid values were silently used to construct a malformed URL"), not a security fix. [v0.45.2 release][r0452] [PyPI][pypi] |
| CVE reserved | 2026-09-10 22:24:03 UTC | SAP CNA. [CNA][cve] |
| **Public announcement** | **2026-10-13** | SAP Security Patch Day for October 2026 lists GHSA-4mv3-jxxm-9cx2 / CVE-2026-89111. The page gives no time. The earliest timestamped public record is the CVE record, at **00:24:28 UTC**. [SAP Patch Day][patchday] [CNA][cve] |
| NVD published | 2026-10-13 01:16:47 (NVD API, UTC) | Status "Awaiting Analysis"; only the SAP CNA score is present. [NVD][nvd] |
| GitHub global advisory (unreviewed) | 2026-10-13 03:30:30 UTC | GHSA-m3j7-wp2j-mhc3 is generated from NVD. It lists **no package or version range**, and on 2026-10-26 it was still unreviewed, so Dependabot may not alert. [Global advisory][gad] |
| SAP repository advisory published | 2026-10-13 07:33:01 UTC | GHSA-4mv3-jxxm-9cx2 (GitHub API `published_at`). [SAP advisory][ghsa] |
| BleepingComputer report | 2026-10-13 09:51 AM (timezone not stated) | Secondary coverage. [BleepingComputer][bc] |
| CISA ADP SSVC assessment | 2026-10-14 19:14:40 UTC | Exploitation: none; Automatable: yes; Technical Impact: total. [CNA][cve] |
| **v0.55.1 released (second fix)** | 2026-09-18 16:34:56 UTC | Release notes say `_fetch_token` validates `tenant_subdomain` before URL substitution. SAP's CNA record added the `>=0.53.0` and `<0.55.1` range on 2026-10-30. [v0.55.1 release][r0551] [CNA][cve] |
| CISA KEV | Not listed (catalog 2026.10.30, checked 2026-10-31) | [KEV][kev] |
| Exploitation | None reported in reviewed sources | [SAP advisory][ghsa] [BleepingComputer][bc] |

The fix shipped about seven weeks before disclosure. Applications that track recent SDK releases may already be patched. Pinned or long-lived images may not be.

## Detection

### Read-only inventory

Run these as a user that can read each deployed Python environment. Placeholders: `SITE_PACKAGES` (the deployed environment's `site-packages` directory) and `APP_ROOT` (the application source or build directory). These commands **only read files** and do not import the SDK. They were not exercised on a real BTP deployment.

```sh
# Installed version, read from distribution metadata without importing the SDK
# (companion script in the black-october directory; trusted Python 3.8+)
python3 -I -S python-package-inventory.py SITE_PACKAGES
# Equivalent without the script: the metadata directory name
ls -d SITE_PACKAGES/sap_cloud_sdk-*.dist-info
# Pinned or locked version in source and build files
cd APP_ROOT
grep -rniE 'sap[-_]cloud[-_]sdk' --include='requirements*.txt' --include='pyproject.toml' \
  --include='poetry.lock' --include='uv.lock' --include='Pipfile.lock' --include='*.cfg' .
```

On a trusted host, `python3 -m pip show sap-cloud-sdk` in the application's virtual environment gives the same version. Versions **below 0.45.2**, and versions **from 0.53.0 up to but not including 0.55.1**, are in the affected ranges. 0.45.2 through 0.52.x are outside both ranges. Check every deployed artifact: Cloud Foundry droplets, Kyma/Kubernetes images, every app instance, and CI build caches. The GitHub global advisory lists no package, so dependency scanners that rely on it may report nothing. [Global advisory][gad]

### Reachability

Find every place the application passes a tenant to the SDK:

```sh
cd APP_ROOT
grep -rnE 'tenant_subdomain|tenant[[:space:]]*=' --include='*.py' . | grep -v '/site-packages/'
```

For each call, trace where the value comes from. A value read directly from request input (`Host` or `X-Forwarded-Host` header, a custom header, a path or query parameter, or a JSON body) is the condition the advisory describes. A value taken only from your own subscription registry, or from a validated server-side source that the caller cannot set, is much harder to abuse. Agent Gateway's `tenant_subdomain` can also be a callable; inspect what that callable returns. [Agent Gateway guide][agwguide]

### Log and egress review

No vendor IOCs exist.

- **Outbound token requests:** In egress proxy, firewall or service-mesh logs, look for HTTP requests from the application to any host other than the expected token host. The expected host is the one in each binding's token `url`, typically under `authentication.<region>.hana.ondemand.com`. Any token POST to an unknown host suggests credential exposure.
- **SDK debug logs (DMS only):** before 0.45.2, the DMS client logged `Resolving token URL for tenant '<value>'` and `Fetching new token for key '<value>'` at DEBUG level. If DEBUG logging was on, search for values that are not one of your registered tenant subdomains, for example values containing dots, slashes, `@`, `:`, `?` or spaces. [Pre-fix DMS source][dmssrc]
- **After upgrading:** `ValueError: Invalid tenant_subdomain:` in application logs shows that someone sent a malformed tenant value. The attempt failed, but it may indicate earlier probing against older versions.
- **Credential use:** review whatever audit data you have for each binding's client ID being used from outside the application, such as unexpected source IP addresses or unusual API activity in the Destination or DMS service. The reviewed sources name no specific BTP audit event for this flaw.

Many BTP apps do not log egress destinations or SDK debug output. Finding nothing therefore does not prove the credentials were not exfiltrated.

## Remediation

1. **Upgrade `sap-cloud-sdk` to 0.55.1 or later** in every application, for example `pip install --upgrade 'sap-cloud-sdk>=0.55.1'`. 0.45.2 fixes only the first range; 0.53.0 through 0.55.0 are affected again. Update your lock file, rebuild and redeploy. The package requires Python 3.11+. [CNA][cve] [v0.55.1 release][r0551] [PyPI][pypi]
2. **Restart or restage every app instance** so that running processes load the new code. A Cloud Foundry `cf restage`/redeploy or a Kubernetes rollout replaces long-running workers.
3. **Handle the new `ValueError`.** Version 0.45.2 rejects tenant values that are not a single DNS label. Catch the error in request handlers and return a client error instead of a 500. [v0.45.2 release][r0452]
4. **Vendor workaround (if you cannot upgrade immediately):** "validate `tenant_subdomain` against a known allowlist of registered tenant subdomains before passing it to any SDK call." Apply it to every `tenant=` and `tenant_subdomain=` argument found during [reachability](#reachability) review. [SAP advisory][ghsa]
5. **Rotate the binding credentials if exposure is suspected** (see [Compromise response](#compromise-response)). SAP's advisory does not instruct customers to rotate credentials. SAP's BTP documentation says to revoke and regenerate credentials that are exposed or suspected to be compromised. [SAP advisory][ghsa] [Service Manager credential rotation][smrot]

## Verification

- Re-run the inventory on the **deployed** artifact (each droplet or image and each app instance) and confirm **0.55.1 or later**. A version in 0.45.2–0.52.x is outside the published ranges; move it to 0.55.1 or later anyway so a later install cannot land in 0.53.0–0.55.0.
- Confirm the installed SDK contains the validator. This reads a file and does not import it:

  ```sh
  grep -n '_validate_tenant_subdomain' SITE_PACKAGES/sap_cloud_sdk/core/_tenant.py
  ```

- Benign functional control: in a non-production environment, a request for a registered tenant still gets a subscriber-scoped token, and a provider call with no tenant still works. Do not send crafted tenant values aimed at external hosts from production.

## Compromise response

If a vulnerable version handled tenant values that callers could influence, and you cannot rule out abuse:

- **Rotate the OAuth client credentials of every service binding the SDK uses** (Destination service, Document Management service and any binding Agent Gateway uses). For bindings created with the btp CLI, delete and recreate the binding. For Cloud Foundry service keys, delete the affected key and create a new one. Update every dependent application and tool with the new credentials. This SAP guidance is general BTP practice; it was not issued for this flaw. [Service Manager credential rotation][smrot]
- **XSUAA instance secrets:** by default, XSUAA service instances created before 2024-11-12 use one secret for the whole instance. SAP rates this Critical in its BTP security recommendations. It recommends migrating to per-binding secrets (or X.509) so you can rotate one binding's secret without affecting the others. Follow SAP's migration guide. [BTP security recommendations][btpsec] [Migrate to binding secrets][migrate]
- Review what the stolen credentials could access: destinations and their stored credentials, documents in DMS repositories, and agent or tool access through Agent Gateway. Rotate secrets stored in destinations if an attacker could read them.
- Review audit logs for activity by those client IDs from unexpected sources during the exposure window. Preserve egress, application and BTP audit logs before cleanup.

## Sources

- [SAP advisory GHSA-4mv3-jxxm-9cx2][ghsa] ([GitHub API record][ghsaapi]): description, affected and patched versions, CVSS 3.1, workaround, reporter credit, publication time.
- [CVE record (SAP CNA)][cve] and [NVD][nvd]: timestamps, CNA score, CISA ADP SSVC entry.
- [SAP Security Patch Day – October 2026][patchday]: patch day listing and priority.
- [GitHub global advisory GHSA-m3j7-wp2j-mhc3][gad]: unreviewed entry with no package listed.
- Fix: [PR #279][pr], [commit `fc67a8f4c0`][fix], [v0.45.2 release][r0452], [PyPI release history][pypi].
- SDK source and docs: [pre-fix Destination token provider][destsrc], [pre-fix DMS auth][dmssrc], [Destination user guide][destguide], [DMS user guide][dmsguide], [Agent Gateway user guide][agwguide].
- SAP BTP credential guidance: [Service Manager instance and binding (credential revocation and rotation)][smrot], [BTP security recommendations][btpsec], [Migrate from instance secrets to binding secrets][migrate].
- [CISA KEV feed][kev]: not listed.
- Secondary: [BleepingComputer][bc].

[ghsa]: https://github.com/SAP/cloud-sdk-python/security/advisories/GHSA-4mv3-jxxm-9cx2
[ghsaapi]: https://api.github.com/repos/SAP/cloud-sdk-python/security-advisories/GHSA-4mv3-jxxm-9cx2
[gad]: https://github.com/advisories/GHSA-m3j7-wp2j-mhc3
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-89111
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-89111
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
[patchday]: https://support.sap.com/en/my-support/knowledge-base/security-notes-news/october-2026.html
[pr]: https://github.com/SAP/cloud-sdk-python/pull/279
[fix]: https://github.com/SAP/cloud-sdk-python/commit/fc67a8f4c01401fd4f5dd709bf898f0ec345f5d1
[r0452]: https://github.com/SAP/cloud-sdk-python/releases/tag/v0.45.2
[r0551]: https://github.com/SAP/cloud-sdk-python/releases/tag/v0.55.1
[pypi]: https://pypi.org/project/sap-cloud-sdk/#history
[destsrc]: https://github.com/SAP/cloud-sdk-python/blob/v0.45.1/src/sap_cloud_sdk/destination/_http.py
[dmssrc]: https://github.com/SAP/cloud-sdk-python/blob/v0.45.1/src/sap_cloud_sdk/dms/_auth.py
[destguide]: https://github.com/SAP/cloud-sdk-python/blob/v0.45.2/src/sap_cloud_sdk/destination/user-guide.md
[dmsguide]: https://github.com/SAP/cloud-sdk-python/blob/v0.45.2/src/sap_cloud_sdk/dms/user-guide.md
[agwguide]: https://github.com/SAP/cloud-sdk-python/blob/v0.45.2/src/sap_cloud_sdk/agentgateway/user-guide.md
[smrot]: https://help.sap.com/docs/service-manager/sap-service-manager/create-sap-service-manager-instance-and-binding
[btpsec]: https://help.sap.com/docs/btp/sap-btp-security-recommendations-c8a9bb59fe624f0981efa0eff2497d7d/sap-btp-security-recommendations
[migrate]: https://help.sap.com/docs/BTP/65de2977205c403bbc107264b8eccf4b/dcee867db42e48d7b4f3243e41695a7a.html
[bc]: https://www.bleepingcomputer.com/news/security/sap-warns-of-maximum-severity-oauth2-ssrf-security-flaw/
