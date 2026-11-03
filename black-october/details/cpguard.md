# cPGuard: malicious update collected server credentials

**Last updated:** 2026-11-03 (America/New_York)

[Main cPGuard summary](../black-october-2026.md#cpguard-malicious-update-collected-server-credentials) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OPSSHIELD says an attacker used compromised credentials to reach its update distribution and shipped a malicious script through the cPGuard update channel. Versions **5.88.12 through 5.88.19** are the affected updates. **5.88.25 or later** removes the known backdoor and the files the script staged. **This is a vendor update-channel compromise, not a CVE in cPGuard's scanner.** There is no CVSS score. Updating does not make a copied password, key, or token unusable.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. OPSSHIELD published the notice on its own site. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are as the advisory states them. The log timestamps in the examples are the server's clock.

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Update infrastructure accessed | 2026-11-02 02:06 UTC | Compromised credentials. How they were obtained is still under investigation. [Advisory][adv] |
| Malicious updates distributed | 2026-11-02; exact end time not stated | Versions 5.88.12–5.88.19. OPSSHIELD says it detected the attack within 12 hours of those updates launching. [Advisory][adv] |
| Corrective release | On or before 2026-11-03 03:19 IST (UTC+05:30) | 5.88.25 removes the known backdoor and staged files. The advisory does not give a separate build time. [Advisory][adv] |
| Customer notice | 2026-11-03; time/TZ unknown | DirectAdmin forum post from OPSSHIELD. Same actions as the advisory. [Forum][da] |
| Retrieval estimate | 2026-11-03 02:42 IST (UTC+05:30) | Preliminary: the attacker retrieved 32 collected files, each corresponding to one customer server. Not a count of servers that installed the update. [Advisory][adv] |
| Support-key removal | 2026-11-03 03:17 IST (UTC+05:30) | A further update removes OPSSHIELD support-access keys previously added to customer servers. It does not replace credential rotation. [Advisory][adv] |

## Detection

Read the update log. Do not run the staged script, and do not open `loot.tgz`.

```sh
grep 'Successfully updated' /opt/cpguard/logs/install_log
cpgcli --version
```

An entry for **5.88.12, 5.88.13, 5.88.14, 5.88.15, 5.88.16, 5.88.17, 5.88.18, or 5.88.19** means that server installed an affected update. OPSSHIELD's own examples are 5.88.12, 5.88.15, 5.88.17, 5.88.18, and 5.88.19. The current version can already be 5.88.25; that does not erase the earlier line.

A missing or incomplete log does not show the server was unaffected. Update checks run on an interval, so some servers that were eligible never installed those builds. Absence of the line is not proof.

The advisory names these files. After 5.88.25 they are expected to be gone, and their absence does not show the script never ran:

- `/var/tmp/.cpg91511_sh` — backdoor shell
- `/var/tmp/.cpg91511` — collection directory
- `/var/tmp/.cpg91511/loot.tgz` — staged archive
- script name `cpguard-v58812-i91511.sh`

One operator posted access times of 02:16:01 on `/root/.ssh/authorized_keys`, `id_dsa`, and `id_dsa.pub` in the same minute as an update to 5.88.12. That is one server's observation, not a vendor IOC. [Forum][da]

## Remediation

1. On every cPGuard server, run `cpgcli update --start`. Confirm `cpgcli --version` reports **5.88.25 or later**. If the update fails, contact OPSSHIELD support. Do not stay on 5.88.12–5.88.19.
2. If the log shows one of those versions, or the log is missing, treat the server as potentially compromised even after the new version is installed. The update removes the known files. It does not revoke what was copied.
3. From a trusted recovery environment, reset passwords for **root and every other password-enabled local account**. `/etc/shadow` stores hashes, not plaintext. A hash can still be tested offline. Change any password that was reused, from a device that did not run the affected update.
4. Rotate database passwords, S3 access keys, DigitalOcean tokens, and any secret in root's shell history. Replace SSH private keys that were under `/root/.ssh`, and remove the old public keys from every host that trusts them.
5. Install the later update that removes OPSSHIELD support-access keys. That step is additional. It is not a substitute for the rotations above.
6. OPSSHIELD is not recommending a routine reinstall of the operating system. It says a rebuild may be appropriate if you find further signs of compromise or cannot establish integrity, and that this assessment is provisional.

## Verification

- `cpgcli --version` is 5.88.25 or later, and the install log's newest successful update is that version or newer.
- `/var/tmp/.cpg91511_sh` and `/var/tmp/.cpg91511` are absent. Absence after cleanup is expected and is not proof the script never ran.
- A password reset from before you read the log does not count. Reset again if the reset happened on the affected server.
- An old SSH public key no longer authenticates anywhere it was trusted.

## Compromise response

The advisory says the script collected, and uploaded to OPSSHIELD's licensing server:

- `/etc/shadow` and `/etc/passwd`
- root MariaDB/MySQL configuration (`my.cnf`)
- root shell history
- root SSH authorization and known-hosts files

It does not say every listed file left every server. It says the attacker retrieved some of the uploaded data, with a preliminary estimate of 32 files. Beyond that collection and the known backdoor, OPSSHIELD says it has not identified further malicious activity, and that this does not rule activity out.

A database password or cloud token in those files is usable until you rotate it at the issuer. A local password hash is not itself a login. Replacing cPGuard does not expire either one.

## Sources

- [OPSSHIELD advisory][adv] — published and last updated 2026-11-03 03:19 IST (UTC+05:30). Affected versions, 5.88.25, collected files, and the 32-file estimate.
- [DirectAdmin forum][da] — OPSSHIELD's customer notice, and one operator's SSH access-time observation. The forum does not add a fixed version beyond 5.88.25.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30. Not applicable; no CVE is assigned.

[adv]: https://opsshield.com/notice/cpguard-update-channel-compromise.html
[da]: https://forum.directadmin.com/threads/cpguard-got-hacked.82860/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
