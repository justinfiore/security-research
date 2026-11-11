# Xen Orchestra: an empty login cookie is an administrator

**Last updated:** 2026-11-10 (America/New_York)

[Main Xen Orchestra summary](../black-october-2026.md#xen-orchestra-an-empty-login-cookie-is-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Xen Orchestra is the web console for XCP-ng and Xen. Vates says a REST cookie of `authenticationToken=j:{}` is parsed into an empty object, the token store treats that object as a lookup with no filter, and the first unexpired token's owner is logged in. The authenticated route `/rest/v0/users/me/authentication_tokens` then returns login token IDs that can be reused. Vates rates the impact Critical and says a compromised console can run code on the pools it manages and take an XCP-ng node as root. There is no CVE and no CVSS score.

**Vates classifies [VSA-2026-062](https://docs.vates.tech/security-advisories/advisories/2026/vates-sa-2026-062/) as Critical.** The advisory's CVSS 4.0 cell says "Not available yet." Vates says the vulnerability is actively exploited by a threat actor that first operated from `91.211.251.112:8001` and the Tor service `ustar3rqxgnskzgnwkgpofgtvxevm6cx3lxdbwt4mndtveqyaohid.onion:3333`. The affected line is Xen Orchestra before **6.9.2** on the stable channel and before **6.10.1** on the latest channel, and the Xen Orchestra Appliance. The packages that fix it are `xo-server` **5.211.2** on stable and **5.213.1** on latest. A source install takes the latest `master`, which includes [pull request 10748](https://github.com/vatesfr/xen-orchestra/pull/10748).

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Vates says this vulnerability is actively exploited. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fix** | **2026-11-10; time/TZ unknown** | Vates published VSA-2026-062 and the fixed builds the same day. Severity Critical. CVSS not assigned. Actively exploited. [Advisory][vsa] |
| Forum notice | 2026-11-10; time/TZ unknown | Vates says the flaw was under embargo and the embargo has been lifted. An appliance should move to 6.10.1 (latest) or 6.9.2 (stable). [Forum][forum] |

## Detection

Vates says a successful login leaves no log. The checks below match the one campaign Vates has identified. Another caller using a different address would not match them. Not matching is not proof the console was not entered.

1. Read the Xen Orchestra version. Before 6.9.2 (stable) or 6.10.1 (latest) is inside the affected line. The appliance is affected until it is on one of those builds. A source install is affected until it includes pull request 10748.
2. On a capture of HTTP to the console, look for `authenticationToken=j:%7B%7D` or `authenticationToken=j:{}`. Vates says that is how this exploit looks on the wire.
3. On the pools, look for a VM named `pivot2`, a VM whose platform has `hvm_serial: file`, and these files on an XCP-ng host: `/etc/cron.d/zz-ustar2`, `/etc/cron.d/zz-ustar`, `/.ustar5`, `/.ustar6`, and `/etc/ld.so.preload`. Vates's commands are `xe vm-list params=name-label,platform | grep -B1 'hvm_serial: file'`, `zgrep -- '-serial file:' /var/log/xensource.log*`, and `ls -la /etc/ld.so.preload /.ustar* /etc/cron.d/zz-ustar*`.

## Remediation

1. Update Xen Orchestra to **6.10.1** on the latest channel or **6.9.2** on the stable channel, and restart `xo-server`. The fixing packages are `xo-server` 5.213.1 (latest) and 5.211.2 (stable). A source install updates to the latest `master`, rebuilds, and restarts.
2. Keep the console off the internet, on a management network. Vates says that is a mitigation, not a fix, and that most deployments are already not exposed.
3. If the console was reachable from the internet before the update, revoke every active session and API token, then rotate the secrets the stack uses: the root password of every XCP-ng host, proxy credentials, backup remote credentials, user passwords, and OTP secrets. Vates says configuration theft cannot be ruled out.
4. Blocking the addresses Vates names stops the campaign Vates has seen. It does not close the cookie check. The addresses are `91.211.251.112`, `193.148.56.72`, `37.221.208.216`, `45.66.35.11`, `64.65.0.120`, `64.65.62.160`, `89.47.51.90`, and `92.60.37.247`, plus Tor traffic to the `.onion` name above.

## Verification

- The running build is 6.10.1 or 6.9.2, or a source build that includes pull request 10748, and `xo-server` was restarted after it.
- A user who could sign in before the update can still sign in. Do not send the empty-object cookie to test the check.
- The console is not reachable from the internet.

## Compromise response

If any detection check matches, or the console was on the internet while it was on an affected build, Vates recommends reinstalling rather than cleaning in place. Cleanup does not show that every backdoor is gone.

- Remove the `pivot2` VM and any VM created with `hvm_serial: file` only after you have recorded them.
- Remove `/etc/cron.d/zz-ustar`, `/etc/cron.d/zz-ustar2`, `/.ustar5`, `/.ustar6`, and a tampered `/etc/ld.so.preload`, then reinstall the host. Deleting the files on a host you keep running is not the recommendation.
- Rotate every secret the console could read, from a machine that was not managed by it.

## Sources

- [VSA-2026-062][vsa] — published and updated 2026-11-10. Severity Critical. CVSS 4.0 not available. Affected before 6.9.2 (stable) and 6.10.1 (latest), and the appliance. Fixed in `xo-server` 5.211.2 and 5.213.1. Actively exploited. The detection list and the address list are in this advisory.
- [XCP-ng forum notice][forum] — the flaw was under embargo. Appliance targets are 6.10.1 (latest) and 6.9.2 (stable). Revoke sessions and rotate secrets if the console was exposed.
- [Pull request 10748](https://github.com/vatesfr/xen-orchestra/pull/10748) — the fix for a source install.
- [CISA KEV JSON](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — catalog 2026.11.10. No CVE is assigned, so there is no listing.

[vsa]: https://docs.vates.tech/security-advisories/advisories/2026/vates-sa-2026-062/
[forum]: https://xcp-ng.org/forum/topic/12571/security-vsa-2026-062-critical-xen-orchestra-vulnerability-fixed-please-update
