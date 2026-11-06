# BTCPay Server: hot-wallet thefts on 2.4.1 and earlier

**Last updated:** 2026-11-06 (America/New_York)

[Back to BTCPay Server summary](../black-october-2026.md#btcpay-server-hot-wallet-thefts-on-241-and-earlier) · [Changelog](../../CHANGELOG.md)

BTCPay Server reported Bitcoin and Litecoin stolen from hot wallets on servers running **2.4.1 (released 23 July 2026) or earlier**. The project says the attackers used a different method to exploit the vulnerability fixed in **2.4.2 (7 August 2026)**. The project calls that vulnerability critical and says it was exploited. It does not publish a CVSS score.

The August advisory described a different result: an unauthenticated attacker could read LND `.macaroon` credential files and move funds on that Lightning node. After review, BTCPay said its own on-chain wallets were not affected by the attacks it had then reviewed. VulnCheck assigned [CVE-2026-119757][cve] to that August flaw on November 5 and rates it **CVSS 4.0 9.3 and CVSS 3.1 9.8 Critical**. The record says versions before 2.4.2, including the 2.4.2 release candidates, are affected, which matches BTCPay's range. BTCPay's August page, last updated November 2 at 2:22:16 PM, still does not name a CVE. The November advisory says the new method stole from hot wallets, which hold spending keys on the server. Wallets whose spending keys stay off the server, including hardware wallets, were not affected by these thefts. Nothing in the November advisory or the CVE record says the hot-wallet thefts are CVE-2026-119757. Those thefts still have no CVE.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-06). BTCPay confirms thefts on 2.4.1 and earlier. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are UTC, from BTCPay's November 2 advisory, unless noted.

| Date | Event and evidence |
| --- | --- |
| 2026-07-23 | BTCPay Server 2.4.1 released. November advisory: attacks targeted this version and earlier. [November advisory][nov] |
| 2026-08-07 | 2.4.2 released, fixing the vulnerability. GitHub tag published 15:31 UTC. The release notes say the vulnerability was being actively exploited and do not assign a CVE. [2.4.2][v242] |
| 2026-08-07 | August advisory: unauthenticated read of LND `.macaroon` files; on-chain BTCPay wallets not affected by the attacks then reviewed. Only LND deployments had that credential risk. The page does not name a CVE. [August advisory][aug] |
| 2026-11-05 | VulnCheck publishes CVE-2026-119757 for the August LND flaw. CVSS 4.0 9.3 and CVSS 3.1 9.8. It names no new fix. [CVE][cve] |
| 2026-10-29 13:48 UTC | 2.4.7 released. It fixes 85 findings from Anthropic's OSS Scanner (1 Critical, 13 High, 52 Medium, 19 Low, using the report's ratings). The November advisory does not say those findings are the hot-wallet attack. [2.4.7][v247] |
| 2026-11-01 13:46 | A wallet drain described in the incident reports. BTCPay has not established when exploitation of this method began. [November advisory][nov] |
| 2026-11-01 20:56 | First email reporting a theft. [November advisory][nov] |
| 2026-11-01 22:25 | Public warning on X: shut down with `./btcpay-down.sh` while the investigation continued. [X warning][xwarn] |
| 2026-11-02 | Investigation update: the attack vector targets 2.4.1 and earlier. No credible hot-wallet drain reports for 2.4.7. [November advisory][nov] |
| 2026-11-02 14:22 UTC | November advisory last updated (page timestamp 2:22:16 PM; timezone not stated on the page, treated as UTC because the advisory's own timeline is labeled UTC). [November advisory][nov] |

**Evidence limits:** BTCPay has not published the vulnerability details, a loss total, or a count of affected servers. It says some activity at the destination addresses it lists predates the thefts in the reports it has, so those balances are not a confirmed loss total. "No credible reports" for 2.4.7 is not a finding that 2.4.7 contains no other vulnerability. The August advisory's statement that on-chain wallets were not affected describes the attacks reviewed then, not the November hot-wallet thefts.

## Detection

1. Log in and read the version in the admin footer. **2.4.1 or earlier is in the attacked range**, including a server updated to a newer release only after the 1 November warning.
2. **2.4.2 or later, already running when the 1 November warning was issued,** is outside the impact BTCPay reports for these attacks.
3. A hot wallet stores spending keys on the server. A hardware wallet or another wallet whose keys stay off the server was not the target of these thefts. An unchanged balance does not rule out an earlier attack: BTCPay says updating later cannot remove access an attacker may already have.
4. There is no public file hash or log signature in the advisory. Compare outgoing transactions you do not recognize with the destination addresses BTCPay lists, and do not treat a match as the full set of thefts.

## Remediation

1. **If the server was on 2.4.1 or earlier on 1 November, including one you updated afterward:** do not treat an in-place update as cleanup. BTCPay's steps are: create a new wallet and a new seed on a trusted device and sweep remaining hot-wallet funds into it; take the old server offline after preserving logs; install the latest release on a new virtual machine and connect the new wallet; do not restore the old server onto the new machine. From a trusted device, revoke hosting, SSH, application, API, and Lightning credentials the old server could access. Do not type new credentials on the old machine.
2. **If the server was already on 2.4.2 or later on 1 November:** BTCPay reports no impact from these attacks. It still says to keep the server updated. 2.4.7 is the release it names as having no credible drain reports. The project has not said that 2.4.2 through 2.4.6 are missing a fix for this attack vector; it says the vulnerability was fixed in 2.4.2.
3. **If funds were stolen or you see unauthorized access:** treat the machine and its secrets as compromised and follow the same rebuild, even if you already updated.
4. Funds whose spending keys were never on the server were not stolen by these thefts. BTCPay still recommends rebuilding an older server. For any hot wallet you keep, leave only the amount daily operations need on the server.
5. The August LND issue, now CVE-2026-119757, is a separate exposure on the same old versions. If that server used LND and was still below 2.4.2, the August advisory's macaroon regeneration applies as well. Updating BTCPay does not close an LND port, reverse proxy, or Tor service you exposed yourself. The CVE does not change the November rebuild.

## Verification

- The new server's admin footer shows the latest release you installed, on a machine that is not the old one, and the wallet seed was created on a trusted device rather than copied.
- Credentials revoked at their issuers no longer authenticate. A password changed only in a config file on the old server is not revoked.
- Do not send the old seed, private keys, or passwords to the project or to anyone offering recovery.

## Compromise response

- Preserve logs and transaction records before wiping the old server. Email [security@btcpayserver.org](mailto:security@btcpayserver.org) with the version, when you last updated, when you noticed the incident (with timezone), and public transaction IDs. BTCPay says not to include seeds, private keys, or passwords, and to strip secrets from logs first. Report a theft to local authorities.
- Destination addresses named in the advisory, which BTCPay says are not a confirmed loss total: Bitcoin `bc1p0f7wmcnesrapznymf9ljdn04pudgmh96sqtrm9vmgqxdh666fh8qvn63r7` and Litecoin `ltc1qp49tmfdueyaqrmgrx0uyx4uegyygt8yt02whee`.
- A hosted instance that the provider took offline still needs the rebuild if it was on 2.4.1 or earlier. BTCPay asked providers, including LunaNode, to take instances offline on 1 November.

## Sources

- [November advisory: versions 2.4.1 and earlier][nov] — attacked range, the different method against the 2.4.2 fix, rebuild steps, and the UTC timeline.
- [August advisory: update to 2.4.2][aug] — LND `.macaroon` exposure, exploited, on-chain wallets not affected in that review. The page still names no CVE. Last updated 2026-11-02 2:22:16 PM (timezone not stated on the page).
- [CVE-2026-119757][cve] — VulnCheck, published 2026-11-05. CVSS 4.0 9.3 and CVSS 3.1 9.8. The August flaw. Not listed in KEV.
- [BTCPay Server 2.4.2 release][v242] — 2026-08-07, vulnerability actively exploited.
- [BTCPay Server 2.4.7 release][v247] — 2026-10-29, 85 scanner findings. Not described as the November attack fix.
- [1 November shutdown warning][xwarn] — shut down while the investigation continued.
- [Maintainer note on updating after the fact](https://x.com/MrKukks/status/2117131261458219471) — updating later is not enough; treat the machine as compromised.

[nov]: https://blog.btcpayserver.org/btcpay-server-security-incident-2-4-1-and-earlier/
[aug]: https://blog.btcpayserver.org/security-advisory-btcpay-server-2-4-2/
[v242]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.2
[v247]: https://github.com/btcpayserver/btcpayserver/releases/tag/v2.4.7
[xwarn]: https://x.com/BtcpayServer/status/2117020340815819262
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-119757
