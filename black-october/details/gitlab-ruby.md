# GitLab and Ruby: detection and remediation

**Last updated:** 2026-10-30 (America/New_York)

[Main GitLab/Ruby summary](../black-october-2026.md#3-gitlab-and-ruby-regex-compilation-becomes-code-execution) · [Changelog](../../CHANGELOG.md)

The principal GitLab issues **[CVE-2026-97229](https://www.cve.org/CVERecord?id=CVE-2026-97229)** and **[CVE-2026-110264](https://www.cve.org/CVERecord?id=CVE-2026-110264)** are **Critical, CVSS 3.1 10.0**: attacker-controlled regex compilation can lead to unauthenticated server-side code execution under the vendor's described conditions. The same maintenance window should cover **[CVE-2026-15723](https://www.cve.org/CVERecord?id=CVE-2026-15723)** (account takeover, High 8.2) and **[CVE-2026-112212](https://www.cve.org/CVERecord?id=CVE-2026-112212)** (OAuth/OIDC cache poisoning, High 7.5). Ruby's underlying fixes also cover related GitLab-assigned CVEs; this is not a reason to count the same engine flaw twice.

**CISA KEV:** [CVE-2026-97229](https://www.cve.org/CVERecord?id=CVE-2026-97229) is listed — added 2026-10-29, federal due date 2026-11-01. The other tracked GitLab CVEs are not listed. CISA listing establishes active exploitation of CVE-2026-97229. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Establish deployment and affected ranges](#establish-deployment-and-affected-ranges)
  - [Use GitLab's threat detections](#use-gitlabs-threat-detections)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and evidence |
|---|---|
| Private discovery/reports | Exact dates not established by the release notices; GitLab credits its bug bounty reporters and internal research separately |
| CVE-2026-97229 announcement and patches | 2026-10-12: [GitLab 19.4.2 / 19.3.5 / 19.2.8](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-4-2-released/) |
| CVE-2026-110264 and identity-flaw announcement/patches | 2026-10-21: [GitLab 19.5.1 / 19.4.3 / 19.3.6](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-1-released/); additional RCE backports listed below |
| Partial upstream Ruby fix | 2026-10-22: Ruby 4.0.8; not sufficient for the complete set |
| Upstream Ruby complete fix set | 2026-10-23 (source date): [Ruby 4.0.9 / 3.4.12 / 3.3.13](https://www.ruby-lang.org/en/news/2026/10/23/regexp-fixes-for-gitlab-cves/) |
| CISA KEV addition for CVE-2026-97229 | 2026-10-29; time/TZ unknown | CISA reports reliable evidence of active exploitation; federal due date 2026-11-01. [KEV][kev] |

The Ruby notice explains that 4.0.9 completes the repeat-ID overflow fix; 4.0.8 addressed a different compiled-pattern overflow. GitLab can ship a patched bundled Ruby before a corresponding upstream Ruby release. Do not infer its fix state solely from the base interpreter version.

## Detection

### Establish deployment and affected ranges

Use the instance Help page, or the [inventory script](../stack-inventory.sh) on a trusted Linux-package installation, with an absolute script path:

```sh
sudo sh /path/to/black-october/stack-inventory.sh gitlab
```

Record GitLab edition/version, packaging method, node roles and exposed interfaces. For source/Helm installations inspect deployed artifacts rather than assuming the host package manager represents every component.

- **97229:** GitLab 19.2 before 19.2.8; 19.3 before 19.3.5; 19.4 before 19.4.2. CI configuration containing attacker-controlled regex is relevant.
- **110264:** broader range beginning at GitLab 7.0, with fixed boundaries **18.11.13 / 19.0.10 / 19.1.9 / 19.2.9 / 19.3.6 / 19.4.3 / 19.5.1**. A successful October 12 update does not settle it.
- **15723:** versions from 10.1 before supported fixes 19.3.6 / 19.4.3 / 19.5.1, with **both OmniAuth SAML and LDAP auto-linking enabled**. Audit identity linking and email lookup configuration without exporting secrets.
- **112212:** versions from 18.3 before the same supported fixes. Review GitLab's OAuth/OIDC discovery endpoints, the reverse proxy/shared cache, and the endpoint URLs consumers receive. Do not assume this only affects GitLab configured as an external OIDC client.

For separately deployed Ruby apps, run `sh stack-inventory.sh ruby` from `black-october/` using the application's runtime. Trace attacker-controlled strings into `Regexp.new`, `Regexp.compile`, `Regexp.union`, or interpolation into regex literals. Matching untrusted text against fixed developer-written patterns is not the prerequisite for these compilation bugs.

### Use GitLab's threat detections

The [October 12 notice](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-4-2-released/) links six detections: Onigmo native worker crash, GraphQL CI lint hostile regex, oversized non-ASCII CI regex paths, regex guard rejection, CI lint Workhorse worker crash, and scripted-client error bursts. The [October 21 notice](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-1-released/) links Onigmo native worker crash and Org-mode render error burst detections.

Import the vendor's current queries/rules into the relevant log platform after checking prerequisites and field mappings. Correlate Puma/Sidekiq/native crash evidence with Rails/Workhorse requests, CI configuration changes, request IDs and actor/source context. Keep the raw evidence; do not turn a native crash alone into a confirmed RCE verdict. Investigate repeated rejections even on a patched system as possible attempts, not proof of successful compromise.

Review authentication/audit logs for unexpected LDAP account linking, session activity, changed OAuth applications and unauthorized access. Compare cached discovery issuer/endpoint URLs with the intended GitLab origin and proxy configuration. No alerts is inconclusive when logging is disabled, rotated or incomplete.

## Remediation

1. Back up GitLab data, configuration and secrets securely and verify the restore procedure. Preserve evidence first if compromise is suspected. Follow [required upgrade stops](https://docs.gitlab.com/update/upgrade_paths/) for the actual starting version; do not jump blindly from an old release.
2. Prefer **19.3.6 / 19.4.3 / 19.5.1 or a later supported patch** covering the RCE and identity issues. Older listed backports address the RCE but are not a substitute for all supported-branch fixes.
3. Follow package/source/Helm-specific upgrade instructions for every node. GitLab warns that the releases include migrations: single-node installations may require downtime; multi-node operators must follow the documented zero-downtime order. Do not revert binaries over an upgraded database without a supported restore plan.
4. For non-GitLab Ruby apps, install **3.3.13 / 3.4.12 / 4.0.9** or later supported releases, rebuild images and restart app/worker processes. The Ruby advisory recommends avoiding compilation of untrusted patterns if an update cannot be applied. `Regexp.timeout` and pattern-length limits are not reliable mitigations.
5. If GitLab cannot be patched promptly, restrict untrusted access while arranging the vendor-supported update. Disabling a single CI screen is not proof that every vulnerable compilation path is blocked. Treat SAML/LDAP configuration changes as an availability-sensitive temporary control, not a blanket RCE fix.

## Verification

- Verify each deployed GitLab node's version and bundled fix evidence, migrations/health checks, background jobs and representative normal repository/CI activity.
- Confirm SAML/LDAP sign-in and existing account mappings with approved test accounts; check that discovery documents advertise only expected endpoints after the supported upgrade/cache refresh procedure.
- Verify separately deployed Ruby processes actually restarted with the new runtime. Use benign regex compilation and job smoke tests, not hostile patterns on production.
- Re-run vendor threat queries against retained historical logs. A patched process and healthy test pipeline do not establish that older CI secrets were never accessed.

## Compromise response

Restrict access, preserve logs/configuration and snapshots, then investigate repository/CI configuration changes, users and administrator permissions, access/deploy/runner tokens, OAuth applications, webhooks and outbound integrations. Rebuild compromised hosts and revoke reachable credentials from a clean system. Review downstream deployments built during the exposure window: a stolen pipeline credential or altered artifact can outlive the GitLab patch. Coordinate session invalidation and identity-provider investigation for takeover evidence.

## Sources

- [GitLab October 12 advisory and six detections](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-4-2-released/)
- [GitLab October 21 advisory, affected ranges, detections and migration notes](https://docs.gitlab.com/releases/patches/patch-release-gitlab-19-5-1-released/)
- [Ruby fix matrix and exposure conditions](https://www.ruby-lang.org/en/news/2026/10/23/regexp-fixes-for-gitlab-cves/)
- [GitLab upgrade paths](https://docs.gitlab.com/update/upgrade_paths/)
