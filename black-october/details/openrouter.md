# OpenRouter: inference providers kept prompts they said they would not

**Last updated:** 2026-11-22 (America/New_York)

[Main summary](../black-october-2026.md#openrouter-inference-providers-kept-prompts-they-said-they-would-not) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OpenRouter routes a customer's AI request to a third-party inference provider. On November 22 it said it had taken three providers off the platform and removed 125 endpoints from Zero Data Retention, after Dragos showed that prompts were copied, stored, or forwarded where the customer's setting said they would not be. OpenRouter says its own systems were not breached. There is nothing to install. A prompt that already left is not recalled by the removal.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at the providers, not a flaw in an application you patch.

Dragos, in a post by HD Moore dated November 19, 2026, says that from July through November it sent about two million prompts carrying unique URLs and canary credentials. It reports three findings. Attackers were copying requests at three hosting providers, the earliest in mid-July, and two of those breaches included requests marked Zero Data Retention. Some stolen keys came from requests the provider rejected before a model ran, which Dragos reads as copying at the provider's front door. One actor used secrets from two of the providers together, from one rented server, and on November 1 added the ARTEX penetration-testing framework; Dragos says the user agents `artex-agent` and `artex-judge-r121` are not on any public indicator list it could find. Separately, marketplace resellers logged customer prompts with ordinary logging and no exploit. Separately again, providers fetched the secret URLs in prompts that were marked not to be retained, including prompts sent to a U.S. provider that a Chinese lab's systems then fetched. Dragos does not name the three compromised providers. It says one of them has published a preliminary notice and another has not disclosed the incident at all.

OpenRouter's announcement, dated November 22, 2026, says the testing did not show a breach or unauthorized access of OpenRouter. It off-boarded three providers, removed 125 endpoints from Zero Data Retention eligibility (the ones researchers flagged, plus others removed as a precaution), and notified potentially affected customers. It links three provider notices and says not every affected provider has posted. The three it links are not identified as the three it off-boarded.

Together AI's notice, published November 21, 2026, is a different path from the front-door copying. Together says an AI coding agent committed a credential for a private Hugging Face repository into its public `xorl` repository, and an unauthorized party downloaded stored prompt samples from that repository. The samples were from requests to MiniMax M3, GLM-5.2, and Kimi K2.6, primarily on June 24, July 4, July 8, and July 14, 2026. Together says five of the credentials the party tested were Dragos canaries, that it has not identified further prompt leakage, and that its review of whether the samples held personal information is still going. It now makes Zero Data Retention the default for new accounts.

Phala's preliminary report, published November 10, 2026, says requests to its deployment of DeepSeek V4 Flash 0731 that OpenRouter routed between October 21, 2026 at 00:00 UTC and November 8, 2026 at 05:35 UTC should be treated as exposed. Phala says canary misuse was confirmed only for requests sent on October 21 and 22, and that it keeps the wider window because the canaries sampled requests rather than seeing every one. It says the attacker chained a legacy internet-facing service with management interfaces that trusted loopback and did not authenticate the caller, created unauthorized confidential virtual machines, and took an inference VM that was serving production traffic without full hardening. Phala says it contained the incident on November 8 at 05:35 UTC and has contacted the one tenant whose virtual-machine credentials were misused.

Novita's notice is a post on X. This guide did not read that post, so it does not repeat a claim about what Novita says happened.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Together sample window | 2026-06-24, 2026-07-04, 2026-07-08, 2026-07-14; times unknown | Stored prompt samples for three models. Together does not date the download. [Together][together] |
| Dragos seeding | 2026-07 through 2026-11; days not all stated | About two million canary prompts. Earliest provider compromise in mid-July. [Dragos][dragos] |
| Phala exposure window | 2026-10-21 00:00 UTC through 2026-11-08 05:35 UTC | DeepSeek V4 Flash 0731 requests routed to Phala. Confirmed canary misuse on October 21 and 22 only. [Phala][phala] |
| **Dragos post** | **2026-11-19 08:00; timezone not stated on the page** | Three provider compromises, reseller logging, and retention failures. Providers not named. |
| **Together notice** | **2026-11-21; time unknown** | Page says Published 11/21/2026. Credential in a public repository; stored samples downloaded. |
| **OpenRouter announcement** | **2026-11-22; time unknown** | Three providers off-boarded. 125 endpoints removed from Zero Data Retention. [OpenRouter][or] |
| **Last updated** | **2026-11-22 (America/New_York)** | New item. Rotate secrets that were inside a prompt. |

## Detection

1. Read the notice OpenRouter sent the account, if one arrived. OpenRouter says it notified potentially affected customers and does not publish the list.
2. For a Together AI account, the requests at risk are the ones Together names: MiniMax M3, GLM-5.2, and Kimi K2.6, primarily on the four dates above. Together says it will contact customers directly and has not published a per-customer list.
3. For a request OpenRouter routed to Phala's DeepSeek V4 Flash 0731 inside the window above, treat the prompt as exposed. Phala says the gateway is notifying those users.
4. A prompt that contained an API key, a token, or a password is the one to rotate. A prompt that did not is still exposed text, and rotating an unrelated key does not address it.
5. Dragos names two user agents, `artex-agent` and `artex-judge-r121`, from the actor who used stolen keys against Dragos's own canary accounts. Those are indicators for the canary accounts, not proof of what happened to a customer key.

## Remediation

There is no customer-side patch.

1. If a prompt in the windows above contained a secret, rotate that secret at the service that issued it. OpenRouter removing an endpoint does not expire it.
2. On Together AI, turn on Zero Data Retention for an account that sends sensitive prompts. Together says that is now the default for new accounts, not for existing ones.
3. On OpenRouter, check the account privacy setting if the account was relying on Zero Data Retention. OpenRouter says an endpoint removed from that list is not eligible again until the provider is revalidated, and it has not published the 125 endpoints.
4. Do not send a new secret through a provider whose notice you have not read. Novita's statement is on X and is not reproduced here.

## Verification

- Secrets that were inside an affected prompt have been rotated, or the account has confirmed that no prompt in the window contained one. Absence of a customer email is not that confirmation.
- Together AI accounts that handle sensitive prompts have Zero Data Retention on.
- Do not send a canary prompt to test whether a provider is still copying traffic. That is the researcher's experiment, not a check of your account.

## Compromise response

A secret that was inside a copied prompt should be treated as exposed from the date of that prompt, not from the date of the notice. Together's review of whether the stored samples held personal information is still open, so a Together customer should not treat "not yet contacted" as "not affected." Phala says one tenant was contacted about virtual-machine credentials; a tenant that was not contacted has no action on that part of Phala's report. Dragos says one compromised provider has still not disclosed the incident and that stolen data was still being used in late October, so a provider name missing from OpenRouter's list is not evidence that provider was clean.

## Sources

- [OpenRouter, Data Processing Incidents on Inference Providers][or] — dated 2026-11-22. Three providers off-boarded, 125 endpoints removed from Zero Data Retention, customers notified. Says OpenRouter itself was not breached. Links Novita, Phala, and Together, and says not every affected provider has posted.
- [Dragos, HD Moore, November 19, 2026][dragos] — about two million canary prompts, July through November. Three unnamed provider compromises, reseller logging, and retention failures, including Zero Data Retention requests. Names the ARTEX user agents.
- [Together AI security event][together] — published 2026-11-21. Stored samples for MiniMax M3, GLM-5.2, and Kimi K2.6 downloaded after a credential reached a public repository. Five tested credentials were Dragos canaries.
- [Phala preliminary incident report][phala] — published 2026-11-10. DeepSeek V4 Flash 0731 exposure window 2026-10-21 00:00 UTC through 2026-11-08 05:35 UTC. Contained 2026-11-08 05:35 UTC.
- [CISA KEV JSON][kev] — catalog 2026.11.20, checked 2026-11-22. No CVE to match.

[or]: https://openrouter.ai/blog/announcements/data-processing-incidents-on-inference-providers
[dragos]: https://www.dragos.com/blog/ai-supply-chain-security-canary-tokens
[together]: https://www.together.ai/blog/security-event-prompt-leakage-for-requests-in-june-and-july-of-2026
[phala]: https://phala.com/posts/phala-november-preliminary-incident-report
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
