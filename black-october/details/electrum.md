# Electrum Bitcoin wallet: malicious server swaps broadcast transactions so a fee bump pays the attacker

**Last updated:** 2026-10-26 (America/New_York)

[Main Electrum summary](../black-october-2026.md#electrum-bitcoin-wallet-malicious-server-swaps-broadcast-transactions-so-a-fee-bump-pays-the-attacker) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[GHSA-6jp4-8v48-cc5v][ghsa]: rated High by the Electrum maintainers. [CVE-2026-117601][cve] assigns CVSS 4.0 9.3; it identifies Electrum < 4.8.3 and 4.8.3 as fixed. Exploited in the wild, with at least one confirmed loss of funds.** Electrum is a light client: by documented design, it trusts its main server for unconfirmed (mempool) transactions. A malicious server can exploit this as follows: [Advisory][ghsa]

1. When the user broadcasts a payment (tx1), the server swallows it and never relays it to the Bitcoin network.
2. It inserts a **conflicting tx2 with invalid signatures** into the wallet's history. Tx2 spends the same inputs to an attacker address, ground so that its last four characters match the legitimate recipient's.
3. The wallet shows tx2 as a pending outgoing transaction, and tx1 disappears.
4. If the user **fee-bumps tx2 with RBF**, Electrum signs a valid, higher-fee version of it, and the funds go to the attacker. In the reported loss case, the server made tx2 zero-fee, apparently to prompt a fee bump. [Advisory][ghsa]

**Affected:** Electrum **< 4.8.3** on all platforms, including desktop and Android. **Not affected:** clients that connect only to servers they trust, such as their own. **Fixed:** **4.8.3**. Merge commit `90fe308` makes the client verify signatures of the wallet's own (`is_mine`) inputs on mempool transactions before adding them to history. The fix is deliberately limited: incoming transactions and inputs from other wallets are still not validated before confirmation. [Advisory][ghsa] [Fix][fix]

**CISA KEV:** Not listed (catalog 2026.10.28, checked 2026-10-28). The maintainers state that "some servers are performing this attack in the wild" and report a user who lost funds after fee-bumping. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Inventory](#inventory)
  - [Wallet history review](#wallet-history-review)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| First private report (user1) | 2026-10-11; time/TZ unknown | user1 noticed that the history showed a different transaction. The fee-bump vector was "not realised" at this point. [Advisory][ghsa] |
| Second private report with lost funds (Raju-K12) | 2026-10-18; time/TZ unknown | The user fee-bumped tx2 and lost money. [Advisory][ghsa] |
| Exploitation in the wild | Unknown start; on or before 2026-10-18 | "Some servers are performing this attack in the wild." [Advisory][ghsa] |
| Fix merged | 2026-10-23 13:33:26 UTC | Merge commit `90fe308` ("verify_sigs"). [Fix][fix] |
| 4.8.3 tagged | 2026-10-23 17:19:56 UTC | Signed tag. The release notes call it a "security update". [Tag][tag] [Release notes][notes] |
| 4.8.3 binaries released | 2026-10-24; time/TZ unknown | Per the advisory timeline. [Advisory][ghsa] [Downloads][dl] |
| Advisory published (public announcement) | 2026-10-24 12:52:42 UTC | GitHub advisory, published by SomberNight. Last updated 2026-10-25 14:45:58 UTC. [Advisory][ghsa] |
| CVE published | 2026-10-27; time/TZ unknown | VulnCheck assigned CVE-2026-117601, CVSS 4.0 9.3, for Electrum <4.8.3. [CVE record][cve] |
| CISA KEV | Not listed (catalog 2026.10.28, checked 2026-10-28) | Absence from KEV is not evidence that exploitation has not occurred. |

## Detection

### Inventory

Find every Electrum install: desktop on Windows, macOS or Linux, portable and AppImage builds, the Android app, and any wallet software or forks that bundle Electrum's Python package. Then check:

- **Version:** **Help → About** in the desktop GUI, or the app info on Android. The CLI command below is **read-only** and was not exercised on a real wallet. Run it as the wallet's user.

```sh
electrum --offline version
```

- **Server trust:** In **Tools → Network** (desktop), check whether the client auto-connects to public servers or is pinned to a server you operate. With the CLI, `electrum --offline getconfig server` and `electrum --offline getconfig oneserver` report the configured values without connecting. Only a self-run or otherwise trusted server removes exposure on old versions. [Advisory][ghsa]

### Wallet history review

There are no network IOCs. The attack shows only in what the wallet displays. For every recent **outgoing unconfirmed** transaction, especially any created since early October 2026, check for these signs:

- The recipient address shown in history differs from the one you entered, even if the last characters match. The attacker grinds the last four characters to match. [Advisory][ghsa]
- The pending transaction shows a **zero or unexpectedly low fee**, or a different txid from the one shown when you signed and broadcast.
- The transaction you broadcast cannot be found on an independent source, such as your own Bitcoin node or a block explorer you trust. Looking up addresses on a public explorer discloses them to that operator.

A clean history does not prove a different server was honest. The fix still does not validate incoming or non-wallet inputs before confirmation. [Advisory][ghsa]

## Remediation

1. **Upgrade to Electrum 4.8.3** from electrum.org, and verify the GPG signatures on the download. [Downloads][dl]
2. **Until upgraded, and as a habit afterwards:** before signing **any** transaction, including an RBF fee bump or "cancel", check the full output address and amount against the intended payment. The maintainers give this as the workaround. [Advisory][ghsa]
3. Do not fee-bump a pending transaction you did not create exactly as shown. If history changed after broadcast, stop and verify independently.
4. Where practical, connect only to a server you trust or operate, for example your own Electrum server backed by your own node. [Advisory][ghsa]

## Verification

- Confirm **Help → About** shows 4.8.3 or later on every device. Run the release you downloaded and verified; an old installation may still be on the PATH or start menu.
- As a benign check, send a small payment between two of your own wallets and confirm that the txid and outputs shown after broadcast match what you signed and what an independent source shows.

## Compromise response

- If funds were sent to an unexpected address, record the txids, addresses, server hostname and timestamps (the Network dialog and logs, if enabled), and report it to the Electrum maintainers through GitHub security reporting. Bitcoin transactions cannot be reversed.
- Stop using the server the wallet was connected to, upgrade, and re-check the remaining unconfirmed transactions.
- The described attack does not expose seeds or private keys. If you also suspect malware on the device, move funds from a clean device to a new wallet.

## Sources

- [GHSA-6jp4-8v48-cc5v][ghsa]: description, affected and fixed versions, exploitation remarks, timeline and credits.
- [CVE-2026-117601][cve]: CVSS 4.0 score and affected/fixed version assignment.
- [Fix merge commit 90fe308][fix]; [4.8.3 tag][tag]; [4.8.3 release notes][notes]; [download directory][dl].

[ghsa]: https://github.com/spesmilo/electrum/security/advisories/GHSA-6jp4-8v48-cc5v
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-117601
[fix]: https://github.com/spesmilo/electrum/commit/90fe30822561e515a9d2d6e5a352cc07780999eb
[tag]: https://github.com/spesmilo/electrum/tree/4.8.3
[notes]: https://github.com/spesmilo/electrum/blob/4.8.3/RELEASE-NOTES
[dl]: https://download.electrum.org/4.8.3/
