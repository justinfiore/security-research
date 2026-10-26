# PHP2Shell: detection and remediation

**Last updated:** 2026-10-26 (America/New_York)

[Main PHP summary](../black-october-2026.md#1-php2shell-unauthenticated-execution-below-your-application) · [Patch decision guide](../black-october-2026.md#what-should-i-patch-a-stack-based-decision-guide) · [Changelog](../../Changelog.md)

**CVE-2026-109618 / CVE-2026-109619: Critical, CVSS 4.0 9.2.** Memory corruption during request initialization/cleanup can lead to unauthenticated RCE. This guide also covers the distinct, conditional upload-progress issue **CVE-2026-115560**, whose full advisory/score was not yet available in the sources reviewed.

## Timeline

| Event | Date and evidence |
|---|---|
| Private discovery/report | Not established in the cited public notices; do not substitute the CVE publication date |
| Advance release notice | 2026-10-20, [PHP archive](https://www.php.net/archive/2026.php) |
| Public advisories and emergency fixes | 2026-10-21: PHP 8.2.35, 8.3.36, 8.4.27 and 8.5.12; [109618](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w) and [109619](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp) |
| Upload-progress follow-up | 2026-10-23: [PHP](https://www.php.net/archive/2026.php) recommends disabling the feature for the remaining conditional RCE vector; full fix planned for the regular release cycle, not established as available in the notice reviewed |
| Detection guidance | 2026-10-23: [CISA alert](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching) adds Sigma/partner guidance; its no-observed-successful-exploitation statement is explicitly date-bounded |

## Detection

### Inventory the web runtime, not only CLI PHP

From the repository's `black-october/` directory, on a trusted system:

```sh
sh stack-inventory.sh php
```

The [script](../stack-inventory.sh) prints CLI version, INI paths and session settings. Treat it as a starting point, not proof of the Apache/FPM runtime. For each website, record:

- Hosting package/container digest and PHP branch; service account; Apache `mod_php`, FPM, CGI, FrankenPHP or LiteSpeed integration.
- The binary/module actually loaded by the web service, including multiple FPM pools and old replica/container images.
- Vendor package advisory showing both CVEs fixed. An older-looking distribution version can contain the fixes; a newer application version alone cannot.
- Internet/LAN reachability. An application login page is not a reliable boundary for flaws reached before application code.

Do not expose `phpinfo()` publicly. Inspect trusted hosting diagnostics or server configuration locally. `mod_php` is the highest-risk configuration identified by PHP/CISA, but the alert covers the other request-serving integrations too.

### Upload-progress prerequisite check

Inspect the **web** SAPI's INI files, per-site configuration and FPM pool overrides for `session.upload_progress.enabled` and `session.serialize_handler`. Review application code for a runtime switch from `php_binary` or `php_serialize` to `php` before `session_start()`. Upload progress must also be enabled for the described follow-up path. A CLI setting of `0`, or the absence of an obvious upload screen, does not establish the effective web configuration.

### Look for suspicious execution

Use [CISA's Sigma repository](https://github.com/cisagov/SIGMA_Rules) and the partner resources in its alert. Collect process creation/parent-child telemetry around PHP/Apache workers launching shells or download tools, correlate it with web requests, worker crashes, fatal errors and file changes. Baseline legitimate application subprocesses before declaring an alert malicious.

These are investigation signals, not a complete exploit detector. A worker crash can be accidental; no crash or no shell process does not prove no RCE. Protect logs and crash dumps as potentially sensitive, and analyze copies on a clean system if compromise is suspected.

## Remediation

1. Preserve relevant logs and configuration/version evidence. For exposed systems without suspicious activity, prioritize installing the vendor update; for suspected compromise, follow [recovery](#compromise-response) in parallel.
2. Update the actual PHP runtime to **8.2.35 / 8.3.36 / 8.4.27 / 8.5.12**, or a later supported release/backport explicitly fixing both CVEs. A Composer update does not update PHP. Rebuild all images, including workers and scheduled jobs using the same affected runtime.
3. Set `session.upload_progress.enabled=0` in the effective web configuration while the follow-up fix is unresolved, unless you have conclusively established the vendor's nonaffected conditions. This changes progress reporting behavior; test your upload UI. It is **not** a substitute for the two emergency patches.
4. Restart/redeploy the web workers so old PHP code is no longer loaded. In multi-node deployments drain and update every node; record final image/package versions.
5. If a supported fix cannot be installed, CISA recommends taking PHP-based systems offline until they can be patched, including unsupported PHP 8.1 and earlier. WAF filtering is supplemental and does not establish protection against all paths.

Use your distribution/hosting provider's documented package procedure and maintenance window rather than copying a package name from another OS. Do not roll back to a vulnerable runtime to resolve an application regression; isolate the affected feature while resolving compatibility.

## Verification

- Verify the runtime **serving a benign request**, not only files on disk or the CLI. Recheck all nodes/pools after the restart and retain package/backport evidence.
- Confirm the effective web upload-progress setting; exercise ordinary uploads, session login/logout and application health without malicious payloads.
- Check worker restart times and deployment status for stale replicas. Ensure temporary maintenance/WAF changes did not accidentally reopen an unpatched backend.
- Monitor process execution and file integrity after service restoration. Patching stops the vulnerability; it does not erase persistence already installed.

## Compromise response

Restrict access and preserve a snapshot/logs. Determine the PHP account's access to application files, database credentials, cloud credentials, shared mounts and neighboring services. Rebuild from known-clean artifacts, remove persistence through clean replacement rather than just deleting one webshell, and rotate/revoke reachable credentials from a clean system. Revalidate sessions and accounts according to the application. Do not assume that PHP-level compromise automatically means root, or that its reach stops at the website.

## Sources

- [PHP release notices and upload-progress advisory](https://www.php.net/archive/2026.php)
- [CVE-2026-109618 advisory](https://github.com/php/php-src/security/advisories/GHSA-w8hw-w9fx-j79w)
- [CVE-2026-109619 advisory](https://github.com/php/php-src/security/advisories/GHSA-6wmf-4rv5-p3rp)
- [CISA alert, October 23 revision](https://www.cisa.gov/news-events/alerts/2026/10/21/critical-vulnerabilities-php-require-immediate-patching)
