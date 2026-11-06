# Zyxel GS1900: unauthenticated command execution from the LAN

**Last updated:** 2026-11-05 (America/New_York)

[Back to Zyxel GS1900 summary](../black-october-2026.md#zyxel-gs1900-unauthenticated-command-execution-from-the-lan) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-107441](https://www.cve.org/CVERecord?id=CVE-2026-107441): Zyxel (CNA) rates it CVSS 3.1 8.8 High. Binarly rates the same flaw 9.8 Critical.** An out-of-bounds write in the CGI program of GS1900 series firmware can let an attacker with no login run operating-system commands through a crafted HTTP request. Zyxel's vector is `CVSS:3.1/AV:A/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`: adjacent network, not the internet. Binarly's is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`, because the request is ordinary HTTP and the only limit is being able to reach the management service. Binarly also says the result is root. Zyxel says operating-system commands and does not name the user. Zyxel's advisory, dated 2026-11-03, lists ten models and a patched build for each. The CVE record's description names only the GS1900-24E ceiling; the record's product list matches the advisory's ten models. NVD has not scored it. CISA-ADP records Exploitation "none." [Advisory][adv] [Binarly][bin]

Binarly says the ten June firmware builds that fixed [CVE-2026-7273](https://www.cve.org/CVERecord?id=CVE-2026-7273) still contain this flaw. Those builds are the 2.90 releases whose parenthetical ends in `.2`. The check Zyxel added counts parameters only after the copy, so a long parameter still overwrites the counter. GreyNoise's September report of 996 switches attributed the theft of configurations and hashed root credentials to CVE-2026-7273, which CISA listed on 2026-09-21. Binarly says the captured exploit matches this parser bug, not the stack overflow Zyxel described for the June CVE. Zyxel has not said that in its own advisory.

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). CVE-2026-7273 is a different record and is listed. Zyxel's advisory does not report exploitation of CVE-2026-107441. Binarly says the exploit GreyNoise observed is this flaw. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| CVE record published | 2026-11-03 01:41:52 UTC | Zyxel CNA. CVSS 3.1 8.8. Record updated 2026-11-04 04:56:27 UTC; the product list still matches the advisory. [Record][cve] |
| Binarly public disclosure | 2026-11-03; time/TZ unknown | BRLY-2026-057. The June `.2` builds still contain the flaw. Binarly's score is 9.8, attack vector Network. [Binarly][bin] |
| Advisory | 2026-11-03; time/TZ unknown | Revision history: "2026-11-3: Initial release." Patches for ten models still in the vulnerability support period. [Advisory][adv] |
| Binarly blog | 2026-11-03; time/TZ unknown | Same day as the advisory. The recovered exploit is `gs1900_bundle.tar.gz` on an open directory, and it carries addresses for a June `.2` build. [Blog][blog] |
| **Last updated** | **2026-11-05 (America/New_York)** | Binarly's blog adds the exploit bundle and the JITTERLY and SIXZUT hashes. The `.3` fix is unchanged. |

## Detection

The flaw is in the switch firmware's CGI program. It is reachable from the LAN, without a login. It is not an internet-facing flaw unless someone has bridged the management interface out.

Zyxel says on-market products not in this table are not affected. Read the firmware string from the running switch.

| Model | Affected | Install |
|---|---|---|
| GS1900-8 | 2.90(AAHH.2)C0 and earlier | 2.90(AAHH.3)C0 |
| GS1900-8HP | 2.90(AAHI.2)C0 and earlier | 2.90(AAHI.3)C0 |
| GS1900-10HP | 2.90(AAZI.2)C0 and earlier | 2.90(AAZI.3)C0 |
| GS1900-16 | 2.90(AAHJ.2)C0 and earlier | 2.90(AAHJ.3)C0 |
| GS1900-24 | 2.90(AAHL.2)C0 and earlier | 2.90(AAHL.3)C0 |
| GS1900-24E | 2.90(AAHK.2)C0 and earlier | 2.90(AAHK.3)C0 |
| GS1900-24EP | 2.90(ABTO.2)C0 and earlier | 2.90(ABTO.3)C0 |
| GS1900-24HPv2 | 2.90(ABTP.2)C0 and earlier | 2.90(ABTP.3)C0 |
| GS1900-48 | 2.90(AAHN.2)C0 and earlier | 2.90(AAHN.3)C0 |
| GS1900-48HPv2 | 2.90(ABTQ.2)C0 and earlier | 2.90(ABTQ.3)C0 |

The CVE record prints the 24HPv2 product name as `GS1900-HPv2`. The advisory's model name is GS1900-24HPv2, and both use the build code ABTP. Treat ABTP as that model.

Zyxel publishes no indicators. A switch whose management interface answers HTTP from the LAN is in the condition the advisory describes. Absence of a logged request is not a clean bill.

## Remediation

1. Install the build in the table for that model. The patched build is the same 2.90 train with the third letter bumped (`.2` to `.3`). A `.2` build is the June firmware for CVE-2026-7273, and Binarly says the exploit still works on it. A newer-looking string from a different model does not apply.
2. Zyxel does not list a workaround. Keeping the management interface off networks you do not trust reduces who can send the request. It does not fix the CGI program. Binarly's score treats reachability, not LAN membership, as the limit.
3. Models Zyxel says are outside the vulnerability support period are not in the table and get no patch on this page. The advisory says on-market products not listed are not affected. It does not say an older, unsupported GS1900 is unaffected; it says those models were not given a patch here. If you run one, confirm with Zyxel rather than treating silence as a fix.

## Verification

- The running firmware string matches the "Install" column for that model, not merely a 2.90 build. `2.90(AAHK.2)C0` is still affected on the GS1900-24E.
- The string is from the switch that is forwarding traffic, not from a firmware file staged for later.
- A model not in the table is not cleared by installing some other model's `.3` build.

## Compromise response

- The result Zyxel names is operating-system command execution on the switch, with no login, from the LAN. Binarly says the same bug yields root and that the attacker only needs to reach the management service. A switch whose management interface was reachable may already have had its configuration read or changed.
- Installing the `.3` build does not restore a configuration an attacker changed and does not remove an administrative credential they added. Review the admin accounts and the running configuration after the upgrade.
- GreyNoise reported theft of configurations and hashed root credentials from 996 switches and named CVE-2026-7273. Binarly says that exploit is this flaw, and that the June `.2` firmware did not stop it. A switch that was still on `.2` or earlier while its management interface was reachable is in the population that report describes. Rotate the admin credentials. Zyxel's own advisory does not report exploitation.
- Binarly's November 3 blog says the exploit it recovered, `gs1900_bundle.tar.gz` containing `exp.py`, was on an open directory at `p2.981666.xyz` port 18081, and that the script has addresses for firmware `2.90(AAHL.2)C0`, a June `.2` build. It also publishes hashes for the JITTERLY backdoor and the SIXZUT rootkit it says that operator used. Those hashes identify that malware. They do not show that a given switch ran it. The blog does not print a date for the open directory.

## Sources

- [Zyxel GS1900 advisory][adv] — 2026-11-03 initial release. Ten models, affected ceilings, and the patched build for each. LAN-based, unauthenticated, OS commands through a crafted HTTP request.
- [CVE-2026-107441][cve] — published 2026-11-03 01:41:52 UTC, updated 2026-11-04 04:56:27 UTC. CVSS 3.1 8.8, Zyxel CNA. Description names GS1900-24E; the product list has all ten.
- [NVD CVE-2026-107441][nvd] — NVD has no score of its own. Shows the CNA 8.8.
- [Binarly BRLY-2026-057][bin] — public 2026-11-03. The unbounded copy lands before the parameter-count check, so the ten June `.2` builds are still affected. Score 9.8, vector Network, result root. Disclosure timeline: confirmed 2026-09-28, reported 2026-09-29, Zyxel reserved the CVE 2026-10-11, firmware 2026-10-22, advisory 2026-11-03.
- [Binarly blog][blog] — 2026-11-03. `gs1900_bundle.tar.gz` / `exp.py` from `p2.981666.xyz:18081`, with GOT and stack modes, and addresses including `2.90(AAHL.2)C0`. JITTERLY SHA-256 `82d072ab03d90c0131b06a576eadf2c986a51f0de986d50db4e49be01bf125cb`, `663a8088faca8e126a11648f5671fcf4eaf96435e10daf63a1d1b17d8385154c`, `0f6e757e82c4d91df5bd249f775b9970b59dee42cc0dfe40f879d77fc16821c6`. SIXZUT SHA-256 `295133156b6a7d95b9c92f832f49e35235f1fbd3906e75c9202ef4cd65d1018c`, `64677002011bc2e4bc642a4154a20fdb95620ebd0144b98fc60f917901ec8b92`, `728810b07e911b235f6450e784391e39f68819a0a5d209662162916ffea25146`.
- [GreyNoise, Open Season on Kapibala][grey] — 2026-09-21. Exploitation against 996 GS1900 switches, attributed there to CVE-2026-7273. Binarly says the captured exploit is this flaw.
- [CISA KEV JSON feed][kev] — CVE-2026-107441 is not listed (catalog 2026.11.04, checked 2026-11-05). CVE-2026-7273 is a different record and is listed. CISA-ADP Exploitation "none" for CVE-2026-107441.

[adv]: https://www.zyxel.com/global/en/support/security-advisories/zyxel-security-advisory-for-out-of-bounds-write-vulnerability-in-gs1900-series-switches-11-03-2026
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-107441
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-107441
[bin]: https://www.binarly.io/advisories/brly-2026-057
[blog]: https://www.binarly.io/blog/zyxel-gs1900-rce-cve-2026-107441
[grey]: https://www.greynoise.io/blog/open-season-on-kapibala-attacker-steals-government-records-wordpress-exploitation
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
