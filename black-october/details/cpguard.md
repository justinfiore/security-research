# cPGuard: malicious update collected server credentials

**Last updated:** 2026-11-03 (America/New_York)

[Main cPGuard summary](../black-october-2026.md#cpguard-malicious-update-collected-server-credentials) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OPSSHIELD says an attacker registered as a customer, broke into its billing and licensing server, and used a stolen update key to ship a malicious script through the cPGuard update channel. Versions **5.88.12 through 5.88.19** are the affected updates, installed between **02:08 and 03:20 UTC on 2026-11-02**. **5.88.26 or later** removes the known backdoor, the staged files, and the scheduled task the script left. 5.88.25 removed the backdoor and does not remove the scheduled task. **This is a vendor update-channel compromise, not a CVE in cPGuard's scanner.** There is no CVSS score. Updating does not make a copied password, key, or token unusable.

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
| Billing portal probed | 2026-11-01 15:38 UTC | Attacker starts against manage.opsshield.com. [Disclosure][disc] |
| Customer account registered | 2026-11-01 16:34 UTC | False identity, free trial. [Disclosure][disc] |
| Command execution on the billing server | 2026-11-01 22:58 UTC | How the request succeeded is not in the logs. OPSSHIELD says it patched two possible entry points and has not finished the review. [Disclosure][disc] |
| Fake update uploaded | 2026-11-02 02:04–02:09 UTC | Stolen update-storage key. The first notice said 02:06 UTC. [Disclosure][disc] |
| Fake update installed | 2026-11-02 02:08–03:20 UTC | Versions 5.88.12–5.88.19, running as root. About 2,950 customer servers. [Disclosure][disc] |
| First corrective release | On or before 2026-11-03 03:19 IST (UTC+05:30) | 5.88.25 removes the known backdoor and staged files. It does not remove the scheduled task. [Advisory][adv] |
| Clean-up release | 2026-11-02; time not stated | 5.88.26 removes the backdoor. A later update removes `/etc/cron.d/i93677`. [Disclosure][disc] |
| Incident disclosure | 2026-11-03; time/TZ unknown | Replaces the 32-file estimate with the counts below. [Disclosure][disc] |

## Detection

Read the update log. Do not run the staged script, and do not open `loot.tgz`.

```sh
grep 'Successfully updated' /opt/cpguard/logs/install_log
cpgcli --version
```

An entry for **5.88.12, 5.88.13, 5.88.14, 5.88.15, 5.88.16, 5.88.17, 5.88.18, or 5.88.19** means that server installed an affected update. OPSSHIELD's own examples are 5.88.12, 5.88.15, 5.88.17, 5.88.18, and 5.88.19. The current version can already be 5.88.26; that does not erase the earlier line.

A missing or incomplete log does not show the server was unaffected. Update checks run on an interval, so some servers that were eligible never installed those builds. Absence of the line is not proof.

The November 3 disclosure names these files. After 5.88.26, and the follow-up that removes the scheduled task, they are expected to be gone. Their absence does not show the script never ran:

- `/var/tmp/.cpg91511_sh` — setuid-root shell
- `/etc/cron.d/i93677` and `/var/tmp/.i93677/` — scheduled task
- `/var/tmp/.cpg91511` and `/var/tmp/.cpg91511/loot.tgz` — collection directory and staged archive, from the first notice
- script names `cpguard-v58812-i91511.sh`, `i91511b`, `i91511c`, and `i91511d`

The disclosure also lists a gsocket backdoor and a Go implant. OPSSHIELD says those were on its own server, not on customer servers. Do not treat them as a customer IOC. The operator address it names is `94.183.188.91`.

One operator posted access times of 02:16:01 on `/root/.ssh/authorized_keys`, `id_dsa`, and `id_dsa.pub` in the same minute as an update to 5.88.12. That is one server's observation, not a vendor IOC. [Forum][da]

## Remediation

1. On every cPGuard server, run `cpgcli update --start`. Confirm `cpgcli --version` reports **5.88.26 or later**, and that `/etc/cron.d/i93677` is gone. 5.88.25 removes the backdoor and does not remove that scheduled task. If the update fails, contact OPSSHIELD support. Do not stay on 5.88.12–5.88.19.
2. If the server was online with cPGuard between 02:08 and 03:20 UTC on 2026-11-02, or the log shows 5.88.12–5.88.19, or the log is missing, treat it as potentially compromised even after the new version is installed. The update removes the known files. It does not revoke what was copied.
3. From a trusted recovery environment, reset passwords for **root and every other password-enabled local account**. `/etc/shadow` stores hashes, not plaintext. A hash can still be tested offline. Change any password that was reused, from a device that did not run the affected update.
4. Rotate database passwords, S3 access keys, DigitalOcean tokens, and any secret in root's shell history. Replace SSH private keys that were under `/root/.ssh`, and remove the old public keys from every host that trusts them.
5. Install the later update that removes OPSSHIELD support-access keys. That step is additional. It is not a substitute for the rotations above.
6. OPSSHIELD is not recommending a routine reinstall of the operating system. It says a rebuild may be appropriate if you find further signs of compromise or cannot establish integrity, and that this assessment is provisional.

## Verification

- `cpgcli --version` is 5.88.26 or later, and the install log's newest successful update is that version or newer.
- `/var/tmp/.cpg91511_sh`, `/var/tmp/.i93677/`, and `/etc/cron.d/i93677` are absent. Absence after cleanup is expected and is not proof the script never ran.
- A password reset from before you read the log does not count. Reset again if the reset happened on the affected server.
- An old SSH public key no longer authenticates anywhere it was trusted.

## Compromise response

The advisory says the script collected, and uploaded to OPSSHIELD's licensing server:

- `/etc/shadow` and `/etc/passwd`
- root MariaDB/MySQL configuration (`my.cnf`)
- root shell history
- root SSH authorization and known-hosts files

The November 3 disclosure replaces the earlier 32-file estimate. It says about **2,950** customer servers ran the fake update, and that the copy included password hashes, root SSH keys, the MySQL root password, and shell history. It also says about **7,900** billing-portal accounts were copied: name, company, postal address, email, and a bcrypt password hash. `/root/.s3cfg` was read on a small number of servers. The same disclosure says the attacker also made copies of three OPSSHIELD cloud servers. Those copies are a vendor-side exposure, not a file on a customer server.

A database password or cloud token in those files is usable until you rotate it at the issuer. A local password hash is not itself a login. Replacing cPGuard does not expire either one.

## Sources

- [OPSSHIELD advisory][adv] — published and last updated 2026-11-03 03:19 IST (UTC+05:30). Affected versions 5.88.12–5.88.19 and the first cleanup, 5.88.25. Its 32-file estimate is superseded by the disclosure below.
- [OPSSHIELD incident disclosure][disc] — 2026-11-03. Entry path, the 02:08–03:20 UTC window, 5.88.26, about 2,950 servers, about 7,900 billing accounts, and the file and hash indicators.
- [DirectAdmin forum][da] — OPSSHIELD's first customer notice, and one operator's SSH access-time observation. The forum does not add a fixed version beyond 5.88.25.
- [CISA KEV JSON feed][kev] — catalog 2026.11.03, checked 2026-11-04. Not applicable; no CVE is assigned.

[adv]: https://opsshield.com/notice/cpguard-update-channel-compromise.html
[disc]: https://opsshield.com/notice/security-incident-disclosure-servermanage.html
[da]: https://forum.directadmin.com/threads/cpguard-got-hacked.82860/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
