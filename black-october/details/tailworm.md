# Tailworm: Tailscale SSH and related findings under review

**Last updated:** 2026-10-26 (America/New_York)

[Main Tailworm summary](../black-october-2026.md#tailworm-tailscale-ssh-and-related-findings-under-review) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**Researcher-rated High for several findings; no Tailworm-specific CVE, vendor CVSS rating or complete fixed-release matrix established.** Erica Windisch's report covers **11 numbered findings across Tailscale SSH, Serve/Funnel, an experimental connector and headscale/DERP**—not 11 independently confirmed Tailscale SSH RCEs. Included at the owner's request as a developing disclosure; this does not change the normal admission threshold for new High/Critical vulnerabilities.

The principal SSH chains claim root-level execution or privileged socket/file operations from **already-authorized Tailscale SSH access with applicable forwarding enabled**. A compromised permitted device can therefore threaten reachable targets and credentials in the demonstrated configurations. This is not unauthenticated internet-wide RCE, and ordinary OpenSSH carried over the Tailscale network is a different implementation. [Research][research] [Vendor response][vendor]

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Initial discovery/private reporting | Unknown | No exact discovery timestamp established; do not assume coordinated disclosure occurred. |
| Research testing window | 2026-10-22–24; time/TZ unknown | Tailscale **1.104.2**, headscale **0.29.5**; tested builds, not complete affected ranges. [Research][research] |
| headscale 0.29.6 released | 2026-10-24 10:29:04 UTC | Release notes do not identify Tailworm fixes. [Release][headscale] |
| Serve correction merged | 2026-10-25 00:39:53 UTC | PR **21931**, cross-mount app-capability leakage, corresponding to finding 11. Source merge is not a stable release. [PR][serve-fix] |
| Public circulation | 2026-10-25; time/TZ unknown | User's X lead and vendor response; exact first-publication timestamp of the report unestablished. [Lead][lead] [Vendor][vendor] |
| SSH forwarding correction merged | 2026-10-26 03:08:59 UTC | PR **21942**, forwarding operations moved to authenticated local-user credentials; not proof every finding is fixed. [PR][ssh-fix] |
| Stable fix status checked | 2026-10-26 12:44 UTC | Tailscale **1.104.2** remained the latest stable version found. No Tailworm-specific stable fix/bulletin identified; follow subsequent releases. [Changelog][changelog] [Bulletins][bulletins] |

The earlier **TS-2026-004 / 1.98.9** Unix-socket symlink fix is not a fix-version claim for these later race findings. Neither Tailscale 1.104.2's October 21 release nor headscale 0.29.6 establishes remediation here. **“No patch exists” is also stale:** relevant source fixes have merged, but a complete released remediation matrix was not established.

## Detection

### Inventory the implementation and authorization boundaries

1. Record the running Tailscale version with `tailscale version` on trusted hosts, plus deployed image/package provenance. For headscale, record its server release through your management/package tooling. Do not execute suspect binaries during forensics; inspect a snapshot from a clean host.
2. Determine whether the host uses **embedded Tailscale SSH** or conventional `sshd` reachable over the tailnet. A TCP 22 listener, a Tailscale installation, or ordinary SSH use alone does not establish the vulnerable feature.
3. Review network grants/ACLs **and SSH policy**: which source identities/devices may reach which target and local OS user? Determine whether TCP, Unix-socket or agent forwarding is enabled, including headscale policy behavior and daemon environment overrides. Avoid copying internal `SSHAction` fields into unsupported policy JSON.
4. Inventory Serve/Funnel configuration, privileged Unix-socket backends, multiple HTTP/2 mounts with different app-capability requirements, experimental `conn25` deployments, custom DERP relays and exposed headscale registration endpoints. The companion scripts do not assess these policies or feature prerequisites.
5. Treat version matches as triage. Full introduction dates, platform coverage and affected-version bounds are unconfirmed; neither “older” nor “latest” is a standalone verdict.

### Interpret the eleven findings separately

All severity labels in this table are **the researcher's**, not vendor or CNA CVSS assessments. The vendor has not validated every claim/configuration. [Research][research] [Vendor][vendor]

| Findings | Researcher severity | Prerequisites and claimed impact |
|---|---|---|
| 1–3: SSH Unix forwarding / path races | High each | Authorized SSH access and applicable forwarding; privileged socket access/replacement, file permission changes or root execution in the lab. |
| 4: experimental conn25 connector | High | Connector entitlement and experimental deployment; attacker-selected metadata/LAN/cluster destinations. Kubernetes API reachability with HTTP 401 does not bypass API authentication. |
| 5: SSH session exhaustion | High | Authorized SSH session; `tailscaled` memory exhaustion. |
| 6: headscale / DERP sub-findings | Medium–High | Embedded-DERP growth needs an authenticated insider; registration-cache eviction is pre-authentication; client memory bomb requires hostile relay positioning/configuration. Different prerequisites. |
| 7: Serve TCP to LocalAPI socket | High | Local Serve configuration access plus ACL-authorized remote peer; dangerous privileged-socket exposure, not default internet access. |
| 8: Serve Unix path race | Medium, contained | Local ability to replace backend path; privileged socket access claimed, but the report's LocalAPI test returns 403. |
| 9: Funnel entitlement | Medium, threat-model finding | Local configuration/ingress capabilities. Stock headscale cannot mint the ingress capability; actual Funnel traffic fails closed. Positive control used a test knob. |
| 10: Serve all-interfaces knob | Configuration note | Non-default `TS_SERVE_ALLOW_ALL_INTERFACES`; source inspection, not reproduced in a LAN lab. |
| 11: HTTP/2 cross-mount capabilities | Medium with header authorization; otherwise Low–Medium | TLS/h2, multiple mounts and a capability-bearing peer; same-peer capability bleed, not arbitrary other-user impersonation. Relevant source fix merged. |

The report's rogue-node enrollment was demonstrated with **Tailnet Lock disabled**. Capturing material in a lock-enabled lab is not evidence of successfully disabling the lock. Its attempted connector-to-tailnet bridge was refuted by its own testing. **CVE-2025-14282 is a Dropbear precedent cited by the report, not a Tailscale CVE.**

### Hunt behavior without running the proof of concept

Preserve daemon/SSH/session logs, process telemetry, socket ownership/mode baselines, headscale logs and control-plane device/policy history. Investigate abnormal socket replacement or rapid directory renames, unexpected daemon child processes, new nodes/routes, enrollment-key use, endpoint identity changes, RSS growth and registration failures. These are **heuristics requiring context**, not a complete detector. No in-the-wild exploitation evidence was established in the reviewed primary sources; lab demonstrations do not prove a campaign, and absent logs do not prove safety.

## Remediation

### Disable unnecessary forwarding using the vendor's mitigation

Tailscale's VP Engineering recommends **`TS_SSH_DISABLE_FORWARDING=1` in the `tailscaled` service environment**, followed by a daemon restart, where forwarding is not needed. This is implemented in released 1.104.2 and takes precedence over policy forwarding allowances, including headscale. It narrows the forwarding chains, **not all eleven findings**. [Vendor mitigation][mitigation]

For a systemd-managed Linux host, preserve an alternate administrative path first. An authorized operator can use `sudo systemctl edit tailscaled` and add this drop-in configuration (not a command to paste into a shell):

```ini
[Service]
Environment=TS_SSH_DISABLE_FORWARDING=1
```

Then restart `tailscaled` through your normal service-management procedure; this can interrupt current Tailscale SSH sessions. Confirm the effective service environment includes the setting and test an **ordinary, nonprivileged forwarding request** that must now fail while an approved shell login still works. Exporting the variable only in an interactive shell does not configure an already-running daemon. For containers/other supervisors, configure the daemon's actual environment and recreate/restart it. No live Tailscale deployment was available to exercise this procedure here.

### Restrict exposure and track released fixes

- Tighten SSH source/target/user scope to necessary access. Check-mode reauthentication is an extra barrier, **not a repair for post-authorization escalation**. Denying root login alone is insufficient for a reported escalation from another permitted OS user.
- If embedded SSH is unnecessary, disable it through supported settings after ensuring another access path. **The vendor does not recommend universally disabling Tailscale SSH or the entire VPN** based on this report.
- Remove unnecessary Serve mappings to privileged sockets; restrict connector entitlements and destinations using controls effective for the actual networking mode. Review headscale/DERP exposure separately; forwarding mitigation does not cover its denial-of-service claims.
- Track official [bulletins][bulletins] and [release notes][changelog] for builds covering the applicable findings, including PRs 21931/21942. Do not deploy an arbitrary development build as a blanket fix or call every finding resolved because one PR merged.

## Verification

- Confirm deployed daemon versions and supplier fix evidence on every target/control-plane node; distinguish source merge, package availability and actual rollout.
- Check the forwarding override in the running service, restart completion and ordinary forwarding rejection. Verify permitted shell sessions still work and denied source/target combinations remain denied, using accounts/devices you control.
- Test normal Serve routes, capability-based authorization and intended connector destinations with benign requests in staging. Confirm no privileged backend is exposed by an overlooked mount or alternate route.
- Review device enrollment, routes, keys and policies after mitigation. Never exercise race payloads, socket clobbering, rogue enrollment or resource-exhaustion probes on production to declare the host safe.

## Compromise response

Preserve evidence and isolate affected access through a trusted control plane. Investigate newly enrolled devices, routes, administrator/policy changes, copied enrollment keys and downstream application credentials. Revoke compromised device identities and credentials using supported procedures, rebuild hosts with credible root compromise, and restore reviewed configuration. Reimaging alone does not invalidate copied keys or unauthorized nodes. Tailnet Lock and tightened policy can constrain enrollment/access but do not retroactively undo compromise.

## Sources

- [Researcher report][research] — all findings, tested versions, limitations and claimed severity.
- [Tailscale engineering response][vendor], [forwarding mitigation][mitigation], and [ordinary sshd clarification][sshd] — vendor scope and current advice.
- [Serve fix PR][serve-fix] and [SSH fix PR][ssh-fix] — merged code and timestamps, not stable-release guarantees.
- [Security bulletins][bulletins], [release changelog][changelog], [SSH documentation][docs], and [headscale release][headscale].
- [User-supplied X lead][lead] — discovery context; not independent confirmation of every claim.

[research]: https://tailworm.com/
[vendor]: https://www.reddit.com/r/Tailscale/comments/1xeoj1l/recent_tailscale_vulnerability_reports/
[mitigation]: https://www.reddit.com/r/Tailscale/comments/1xeoj1l/comment/19rnk0ct2vkdc/
[sshd]: https://www.reddit.com/r/Tailscale/comments/1xeoj1l/comment/19rmx9cbecxk3/
[serve-fix]: https://github.com/tailscale/tailscale/pull/21931
[ssh-fix]: https://github.com/tailscale/tailscale/pull/21942
[bulletins]: https://tailscale.com/security-bulletins
[changelog]: https://tailscale.com/changelog
[docs]: https://tailscale.com/docs/features/tailscale-ssh
[headscale]: https://github.com/juanfont/headscale/releases/tag/v0.29.6
[lead]: https://x.com/IntCyberDigest/status/2114291878720151623
