# Incus: certificate-chain authentication bypass and restricted-project host root

**Last updated:** 2026-11-02 (America/New_York)

[Back to Incus summary](../black-october-2026.md#incus-certificate-chain-authentication-bypass-and-restricted-project-host-root) · [Changelog](../../CHANGELOG.md)

Incus **7.6.0**, released 2026-10-30, fixes 18 security issues. Eight are rated Critical by the project and five High. **No CVE is assigned** on the advisories read for this release. This is not the [LXD](lxd-mtls.md) snap update: LXD's [CVE-2026-112816](https://www.cve.org/CVERecord?id=CVE-2026-112816) is the same certificate-chain bug in Canonical's product, and refreshing the LXD snap does not update Incus.

The certificate-chain issue is [GHSA-xg75-xf37-cph9](https://github.com/lxc/incus/security/advisories/GHSA-xg75-xf37-cph9). Incus rates it **CVSS 3.1 10.0 Critical**. The HTTPS listener requests a client certificate and does not verify the chain, so the handshake proves only that the client holds the private key of the first certificate. Trust checks compared every certificate in the chain with the trust store. Anyone who can reach the listener, and who has the public part of a trusted client, metrics, or server certificate, can authenticate as that identity. Incus says this has been the case since its initial release. A server certificate is returned by every TLS handshake, so obtaining one needs no prior account. Appending the server's own certificate reaches the database gateway; on a cluster, another member's certificate reaches internal cluster access. The same bug covers self-service renewal and deletion of trust-store entries, the host-to-VM agent connection, and the certificate list passed to an authorization scriptlet.

The other Critical advisories in the same release need a low-privileged client, not a reachable API alone:

- [GHSA-3wxw-5gh2-j2x2](https://github.com/lxc/incus/security/advisories/GHSA-3wxw-5gh2-j2x2), CVSS 3.1 9.9. An OCI image `config.json`, or the `oci.entrypoint` and `oci.cwd` keys, is written into LXC configuration without rejecting line breaks, so a value can add host hooks that liblxc runs as root. Since 7.5.0, `config.json` was parsed for any image that contained one, not only OCI images. A restricted project can do this.
- [GHSA-5c64-j5m6-8433](https://github.com/lxc/incus/security/advisories/GHSA-5c64-j5m6-8433), CVSS 3.1 9.9. A restricted client whose project leaves `features.networks` disabled (the default) creates the network in the unrestricted `default` project. `raw.dnsmasq` then disables dnsmasq's AppArmor profile, and dnsmasq starts as root. The same gap covers network ACLs, address sets, zones, profiles, images, custom volumes, and buckets when the matching feature is disabled, and it lets the client read or change inherited resources through `?project=`.
- [GHSA-jcw9-v2ff-8m79](https://github.com/lxc/incus/security/advisories/GHSA-jcw9-v2ff-8m79), CVSS 3.1 9.9. Incus authorizes creation against the project named in the request and creates the object in the effective project. A restricted certificate can therefore create a bridge network in `default` whose `raw.dnsmasq` runs a script as root, or a volume whose `block.create_options` are passed to `mkfs` as root. Buckets, zones, ACLs, and profiles have the same authorization gap without that root primitive.
- [GHSA-5pgx-q9xx-j3qv](https://github.com/lxc/incus/security/advisories/GHSA-5pgx-q9xx-j3qv), CVSS 3.1 9.9. A backup or image whose metadata contains a device node, hard link, or symlink is processed as root.
- [GHSA-p45f-gqqj-6qq3](https://github.com/lxc/incus/security/advisories/GHSA-p45f-gqqj-6qq3), CVSS 3.1 9.6. A custom-volume backup can store a snapshot name that later resolves outside the storage pool, so deleting the volume removes an arbitrary host directory as root.
- [GHSA-q9fc-p923-6vp7](https://github.com/lxc/incus/security/advisories/GHSA-q9fc-p923-6vp7), CVSS 3.1 9.9. A migration source can name dependent volumes so the target creates them at an arbitrary host path. On the `dir` storage driver Incus says that is host compromise. The same path skips `restricted.storage-pools.access`. A malicious target can steer the source, and a mismatched header can crash the daemon.
- [GHSA-cwg9-8mc4-hf7j](https://github.com/lxc/incus/security/advisories/GHSA-cwg9-8mc4-hf7j), CVSS 3.1 9.6. Certificate and cluster-join token secrets are sent to any client allowed to view events in the `default` project. A restricted client trusted for that project can enroll an unrestricted certificate. Any authenticated client who knows the operation UUID can cancel a token operation.

The five High issues are local or restricted-client flaws: VM NBD socket hijack, cross-project reads, a rebuilt container that starts without a user namespace, migration-websocket secret disclosure, and guest API impersonation through a forged cgroup name. Four more are Medium. The release announcement is the list; each GHSA is the detail for that issue.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. The LXD CVE for the certificate-chain bug is not listed either (catalog 2026.10.30, checked 2026-11-02). Incus does not report exploitation of these advisories. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Affected range | Since the initial release, for the certificate-chain bug | Incus advisory. Other issues in the same release have their own introduction points; the OCI `config.json` path widened in 7.5.0. [GHSA-xg75-xf37-cph9][chain] |
| Advisories published | 2026-10-29 | GitHub publication date on each GHSA read. No CVE field is set. |
| Incus 7.6.0 | 2026-10-30 01:50 UTC | Tag time. The release announcement says 18 security issues, eight of them Critical. [Release][rel] [Announcement][ann] |
| LXD fixes for the same certificate check | 2026-10-29; time/TZ unknown | Separate product. See the [LXD guide](lxd-mtls.md). |

Monthly feature releases are supported only until the next one. Incus points operators who want a longer support window at the 7.0 LTS line. The 7.6 announcement does not say that 7.0 LTS has these fixes.

## Detection

1. On the server, `incus version`. Below 7.6.0 is in the affected range for every advisory in this release. A client-only package on a workstation is not the server.
2. The certificate-chain bug is reachable by anyone who can open the HTTPS listener. Check which address it is bound to. A listener you cannot confirm is unknown, not safe. Restricting the listener to trusted hosts is the only workaround Incus gives for that bug, and it is not a fix.
3. The other Critical bugs need a client that can create instances, images, backups, networks, or volumes, including a restricted project. A single-admin server where every client is fully trusted is a different exposure than a host that runs untrusted tenants. It is still below 7.6.0 until you upgrade.
4. Package names differ by distribution. Read the version the running daemon reports, not only the package changelog filename.

## Remediation

1. Upgrade the Incus server to **7.6.0 or later** and restart so the new daemon is the one listening. Upstream publishes a release tarball and client binaries; distribution and Zabbly packages are separate. The announcement said the Zabbly repository was still finishing a build on the day of release.
2. Until 7.6.0 is running, do not expose the HTTPS listener to untrusted networks. Incus publishes no configuration switch that stops the chain comparison.
3. For the restricted-project issues, do not import untrusted images or backups, and do not grant create rights to tenants, until the new daemon is running. Those limits do not close the certificate-chain bug.
4. Do not use a [LXD](lxd-mtls.md) snap refresh as the Incus upgrade.

## Verification

- `incus version` reports 7.6.0 or later, and an existing client you already trust can still connect.
- Do not send a crafted certificate chain, image, or backup to a production daemon to test these bugs.

## Compromise response

If the HTTPS API was reachable on a version before 7.6.0, preserve logs and the trust store before cleanup. Look for trust-store entries you did not add, instances you did not launch, and cluster membership changes. Upgrading stops the chain comparison; it does not show whether a public certificate was already replayed. Remove trust entries you cannot account for and rotate client certificates that may have been observed.

If untrusted tenants could create instances, images, backups, or networks before the upgrade, also look for bridge networks with `raw.dnsmasq` set, custom volumes with `block.create_options`, and metadata files that are not regular files. The advisories name those as the host-root paths.

## Sources

- [Incus 7.6 announcement][ann] — 18 security issues and the support note for monthly releases versus 7.0 LTS.
- [Incus 7.6.0 tag][rel] — published 2026-10-30 01:50 UTC.
- [GHSA-xg75-xf37-cph9][chain] — certificate-chain bypass, CVSS 3.1 10.0, no CVE, fixed in 7.6.0.
- [GHSA-3wxw-5gh2-j2x2](https://github.com/lxc/incus/security/advisories/GHSA-3wxw-5gh2-j2x2) — OCI configuration injection, CVSS 3.1 9.9.
- [GHSA-jcw9-v2ff-8m79](https://github.com/lxc/incus/security/advisories/GHSA-jcw9-v2ff-8m79) — restricted client creates resources in `default`, CVSS 3.1 9.9.
- [GHSA-5pgx-q9xx-j3qv](https://github.com/lxc/incus/security/advisories/GHSA-5pgx-q9xx-j3qv) — host file read and write through backup metadata, CVSS 3.1 9.9.
- [GHSA-p45f-gqqj-6qq3](https://github.com/lxc/incus/security/advisories/GHSA-p45f-gqqj-6qq3) — snapshot-name path traversal, CVSS 3.1 9.6.
- [GHSA-q9fc-p923-6vp7](https://github.com/lxc/incus/security/advisories/GHSA-q9fc-p923-6vp7) — migration path traversal, CVSS 3.1 9.9.
- [GHSA-cwg9-8mc4-hf7j](https://github.com/lxc/incus/security/advisories/GHSA-cwg9-8mc4-hf7j) — token secrets on the event stream, CVSS 3.1 9.6.
- [GHSA-5c64-j5m6-8433](https://github.com/lxc/incus/security/advisories/GHSA-5c64-j5m6-8433) — restricted client creates resources in `default`, CVSS 3.1 9.9.
- [CISA KEV JSON feed](https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json) — no CVE to list (catalog 2026.10.30).

[ann]: https://discuss.linuxcontainers.org/t/incus-7-6-has-been-released/27462
[rel]: https://github.com/lxc/incus/releases/tag/v7.6.0
[chain]: https://github.com/lxc/incus/security/advisories/GHSA-xg75-xf37-cph9
