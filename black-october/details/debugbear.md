# DebugBear: RUM script removed after a registrar DNS compromise

**Last updated:** 2026-11-01 (America/New_York)

[Back to DebugBear summary](../black-october-2026.md#debugbear-rum-script-removed-after-a-registrar-dns-compromise) · [Changelog](../../CHANGELOG.md)

DebugBear told every customer of its Real User Monitoring (RUM) product to remove the embed code from their websites. It later said DNS records were compromised through its domain registrar, that it could not receive email to its domain, and that its initial investigation pointed at one customer's website rather than a compromise of DebugBear's internal systems. **This is a third-party script incident, not a vulnerability in the site that embedded the script.** There is no CVE and no CVSS score. Polymarket, which had embedded that script, says a third-party provider was compromised and that it removed the script; researchers attribute the drained sessions to the DebugBear host. DebugBear has not named that customer.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. This is a vendor-script incident; DebugBear's own posts are the instruction to remove the embed. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Times below are UTC. DebugBear's posts are on X and do not include a root-cause write-up.

| Date | Event and evidence |
| --- | --- |
| 2026-10-29 17:59 | A Polymarket production build records removal of the DebugBear RUM script. Researchers, not Polymarket's status text, tie the drained sessions to a script on `cdn.debugbear.com`. [BleepingComputer][bc] |
| 2026-10-29 18:00 | DebugBear: "We're impacted by an ongoing security incident. If you use our RUM product, please remove the embed code from your website." [DebugBear, Oct 29][db1] |
| 2026-10-29 18:05 | Polymarket's status page puts the international exchange in cancel-only mode and pauses relayer actions. [SecurityWeek][sw] |
| 2026-10-29 18:37 | Polymarket says one of its third-party providers was compromised, that affected users will be made whole, and that it referred the case to law enforcement. It does not name the provider. [SecurityWeek][sw] |
| 2026-10-29 19:05 | Polymarket marks the incident resolved. [SecurityWeek][sw] |
| 2026-10-30 23:11 | DebugBear: DNS server records were compromised through its domain registrar; it cannot receive email to its domain. "Based on our initial investigation this attack targeted the website of a specific customer. We have not seen any indication of a compromise of our internal systems, though we will continue to investigate this." [DebugBear, Oct 30][db2] |
| Customer software patch | Not applicable. Remove the embed. Do not wait for a DebugBear release. |

**Evidence limits:** DebugBear has not published which DNS names changed, for how long, or a list of other customers who were served altered script bytes. "A specific customer" is DebugBear's initial finding, not a proof that no other embed was affected. Polymarket's loss figures come from Polymarket and from researchers; this guide does not treat a wallet balance as a confirmed total. The October 29 instruction to remove the embed was not withdrawn in the October 30 post.

## Detection

1. Search your sites, tag managers, and cached HTML for a DebugBear RUM embed: a script loaded from `cdn.debugbear.com`, `data.debugbear.com`, or another `debugbear.com` host, including a snippet that sometimes loads the full script at a low sample rate.
2. A removed tag in the current deploy is not the whole question. Pages that kept the tag on October 29, and any CDN or browser cache of those pages, could have run whatever that host served.
3. Hudson Rock published a script URL, `cdn.debugbear.com/C7xcKKrjUnXK.js`, and SHA-256 `0755e767504d8103f6c27b9e765a1026507a17c04513242adb503df7777879e5`, as the Polymarket-specific file it reviewed. A match in a saved copy is an indicator for that incident. Absence of that hash does not prove a different response was benign.
4. There is no local package version that answers this. The script runs in visitors' browsers.

## Remediation

1. Remove the DebugBear RUM embed from every site, including tag-manager copies and alternate hostnames, until DebugBear says the embed is safe to put back. DebugBear's October 29 post is the instruction; the October 30 post does not cancel it.
2. Purge CDN and edge caches of HTML that still contains the tag, then confirm a fresh response does not reference the host.
3. Do not treat Polymarket's removal as covering your site. DebugBear asked every RUM customer to remove the embed.
4. If the embed was present on a logged-in origin, review that application's session actions for October 29 and after, not only whether the tag is gone now. What a script could do is whatever the page's session could do.

## Verification

- Fetch the public pages, including ones served to logged-in users if you can do that without printing secrets, and confirm they do not request a DebugBear host.
- Check tag-manager publish history, not only the current container: a rolled-back container can still have been live.
- A DNS failure for `cdn.debugbear.com` at one moment is not a permanent block. A tag left in place loads whatever that name serves when it resolves again.

## Compromise response

- **Logged-in applications:** If the script ran on a page with a session, look for actions the session could take (password changes, exports, payments, sent messages) during the window the tag was live. Removing the tag does not undo those actions.
- **Polymarket traders:** Polymarket said affected users will be made whole and that trading was restored. That reimbursement is Polymarket's, not a general DebugBear customer action.
- DebugBear said it cannot receive email at its domain while the DNS incident continues. Do not send embed IDs or session secrets to an address at that domain until DebugBear says mail works again.

## Sources

- [DebugBear, October 29, 2026: remove the RUM embed](https://x.com/DebugBear/status/2115866496643535293)
- [DebugBear, October 30, 2026: registrar DNS compromise](https://x.com/DebugBear/status/2116306975403250070)
- [SecurityWeek, October 30, 2026: Polymarket status timeline and DebugBear warning](https://www.securityweek.com/2-million-drained-from-polymarket-traders-in-new-supply-chain-attack/)
- [BleepingComputer, October 29, 2026: script host and Polymarket build note](https://www.bleepingcomputer.com/news/security/polymarket-halts-trading-after-crypto-draining-script-breach-25m-traced/)

[db1]: https://x.com/DebugBear/status/2115866496643535293
[db2]: https://x.com/DebugBear/status/2116306975403250070
[sw]: https://www.securityweek.com/2-million-drained-from-polymarket-traders-in-new-supply-chain-attack/
[bc]: https://www.bleepingcomputer.com/news/security/polymarket-halts-trading-after-crypto-draining-script-breach-25m-traced/
