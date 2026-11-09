# Swarm: bee-js 13.3.0 and Swarm Desktop 0.56.2 were malicious releases

**Last updated:** 2026-11-09 (America/New_York)

[Back to Swarm summary](../black-october-2026.md#swarm-bee-js-1330-and-swarm-desktop-0562-were-malicious-releases) · [Changelog](../../CHANGELOG.md)

**GitHub Advisory Database rates [GHSA-hh7j-5m3j-23pf](https://github.com/advisories/GHSA-hh7j-5m3j-23pf) Critical. There is no CVSS score and no CVE.** The advisory type is malware, and the severity field is `critical`. `@ethersphere/bee-js` 13.3.0 was on npm from 00:09:50 UTC to 01:24:58 UTC on 2026-11-09. Its `postinstall` script downloads and runs code. About half an hour later, the same release identity published Swarm Desktop 0.56.2, which runs the same loader each time the app starts. Both were built by the project's own automation. The maintainer's note says 0.56.2 was published with stolen CI credentials. **13.2.0 is the last clean bee-js release. Swarm Desktop 0.56.3 replaces 0.56.2 and is otherwise the 0.56.1 code.** Removing either release does not remove a backdoor already installed and does not protect a key already sent.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. The GitHub advisory is the listing that exists. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Payload domain registered | 2026-11-06 15:08 UTC | `frameworkmetrics.xyz`. StepSecurity. |
| Malicious bee-js commit | 2026-11-08 23:59:54 UTC | Unsigned commit on `upcoming` under the `bee-worker` identity. The release pull request for 13.3.0 was still open. |
| bee-js 13.3.0 on npm | 2026-11-09 00:09:50 UTC | Published by the project's own workflow. Socket says npm removed it at 01:24:58 UTC. |
| Swarm Desktop 0.56.2 | 2026-11-09, about 00:36 UTC | The Hacker News, citing Socket. Withdrawn about 8.5 hours later. |
| GitHub malware advisory | 2026-11-09 01:25:27 UTC | GHSA-hh7j-5m3j-23pf. Severity `critical`. No CVSS, no CVE. |
| **Clean Swarm Desktop** | **2026-11-09 12:52 UTC** | 0.56.3. The notes say it replaces the compromised 0.56.2 release. |
| **Last updated** | **2026-11-09 (America/New_York)** | New item. Remove 13.3.0 and 0.56.2. |

## Detection

A machine is in scope when either release ran, not when the package is still installed. npm runs `postinstall` unless the install used `--ignore-scripts`.

1. **bee-js.** Search lockfiles, `node_modules`, CI logs, and any npm mirror for `@ethersphere/bee-js@13.3.0`. `@ethersphere/swarm-cli` 3.7.0 depends on `^13.2.0`, and `@ethersphere/bee-dashboard` 0.37.1 and the Swarm Desktop repository depend on `^13.0.0`, so a fresh install during that window could pull 13.3.0 without naming it directly. A lockfile that resolved 13.2.0 did not.
2. **Swarm Desktop.** The app log writes `Bee Desktop version: 0.56.2 (production)` at each launch, before the loader runs. The log is `~/Library/Logs/Swarm Desktop/bee-desktop.log` on macOS, `%LOCALAPPDATA%\Swarm Desktop\Log\` on Windows, and `~/.local/state/Swarm Desktop/` on Linux. The built-in updater could offer 0.56.2 to Windows x64 and Apple Silicon. Intel Macs were not offered it. Linux packages do not auto-update.
3. **Files the loader leaves.** These are the names from The Hacker News and StepSecurity. Their absence after a cleanup is not proof the loader never ran.
   - `~/.solidity/` and, on Linux, the user service `solidity-langsupport-runner.service`
   - on macOS, `~/Library/LaunchAgents/com.solidity.langsupport.runner.plist`
   - on Windows, a service named `ScreenConnect Client (5cbe79c9c25524df)`
4. **Network.** The loader calls `api.frameworkmetrics.xyz`, path `/v1/analytics` from bee-js and `/v1/electron` from Swarm Desktop, with the header `X-Ethersphere: 1`. Wallet files go to `/v1/swarm/report`.

Socket's estimate is about 10 downloads of bee-js 13.3.0, including scanners, and 65 of Swarm Desktop 0.56.2 by 08:27 UTC, including researchers. Those are download counts, not a count of machines that ran the code.

## Remediation

1. **Remove 13.3.0 from every lockfile and pin `@ethersphere/bee-js` to 13.2.0.** Clear caches and mirrors that still hold 13.3.0. There is no patched 13.3.x. The advisory says the package has no patched version.
2. **Install Swarm Desktop 0.56.3.** On Linux, replace the package by hand. The auto-updater moves a 0.56.2 install to 0.56.3 on the platforms it updates. The Hacker News compared 0.56.3 with 0.56.1 and found no code change beyond the version and the release notes.
3. **If 13.3.0 was installed with scripts enabled, or 0.56.2 ever launched, treat that machine as compromised.** Updating or uninstalling does not remove the service, the LaunchAgent, or the ScreenConnect client. Rebuild from a trusted image where you can. Otherwise remove `~/.solidity/`, the `solidity-langsupport-runner` user service, the `com.solidity.langsupport.runner` LaunchAgent, and the ScreenConnect client service named above.
4. **From a different, clean computer, rotate every credential the installing user or CI job could read.** The advisory's instruction is that a computer which installed or ran the package is fully compromised.
5. **If Swarm Desktop's data directory held `config.yaml` and `data-dir/keys/swarm.key`, move the node's funds, chequebook, and stake to a new key** from that clean computer. The password that unlocks the key is stored in `config.yaml`.

## Verification

- No lockfile, installed tree, or CI log still resolves `@ethersphere/bee-js` 13.3.0. 13.2.0 is the pin.
- Swarm Desktop's log and the running app report **0.56.3**, not 0.56.2.
- `~/.solidity/`, the user service, the LaunchAgent, and the named ScreenConnect service are absent. Absence is expected after cleanup and does not show the loader never ran.
- A key rotation done on the machine that ran the release does not count. Rotate from a machine that did not.

## Compromise response

- The loader sends `config.yaml` and `swarm.key` together. With both, the node wallet can be unlocked. No report reviewed here confirms that funds were taken. The Hacker News says no theft of funds had been reported at the time of writing.
- The second stage also installs a remote shell. On Linux and macOS that is a Go binary named evjawbreaker under `~/.solidity/`. On Windows it is a signed ScreenConnect client. Hashes for the Linux binaries, from StepSecurity: `9b73e7cd4e1425e770392549d8df46c706139ef476f4f7b9ac405165dc8d9696` (amd64) and `b601776817363b96295119f7221338a122d5247a35a77a64b04f286e1bbcc565` (arm64).
- Socket ties the payloads to the group behind the SleepyDuck extension campaign. That is Socket's attribution, not a statement from Ethersphere.
- The maintainer's note blames stolen CI credentials. It does not say which credential, or whether the `bee-worker` token has been replaced beyond the new signing requirement on Swarm Desktop. A CI secret that could publish a release should be rotated whether or not you installed the package.

## Sources

- [GHSA-hh7j-5m3j-23pf][ghsa] — GitHub Advisory Database, 2026-11-09 01:25:27 UTC. Type malware, severity `critical`. No CVSS and no CVE. Affects `@ethersphere/bee-js` 13.3.0 only. No patched version.
- [StepSecurity][step] — the commit time, the npm publish time 00:09:50 UTC, the postinstall behavior, the wallet files, and the Linux hashes. The macOS binary and the Windows installer were not retrieved in that report.
- [The Hacker News][thn] — 2026-11-09. Swarm Desktop 0.56.2 at about 00:36 UTC, withdrawn about 8.5 hours later; the maintainer's statement that stolen CI credentials published it; 0.56.3 as the clean release; the log line and the persistence names.
- [Swarm Desktop 0.56.3][rel] — published 2026-11-09 12:52:07 UTC. "replace compromised 0.56.2 release."
- [Socket][socket] — bee-js removed from npm at 01:24:58 UTC. Download estimates: about 10 for 13.3.0 and 65 for 0.56.2 by 08:27 UTC, both including researchers.
- [CISA KEV JSON feed][kev] — not applicable. No CVE is assigned (catalog 2026.11.09, checked 2026-11-09).

[ghsa]: https://github.com/advisories/GHSA-hh7j-5m3j-23pf
[step]: https://www.stepsecurity.io/blog/ethersphere-bee-js-13-3-0-compromise
[thn]: https://thehackernews.com/2026/11/hackers-compromise-etherspheres-bee-js.html
[rel]: https://github.com/ethersphere/swarm-desktop/releases/tag/v0.56.3
[socket]: https://socket.dev/blog/bee-js-compromise
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
