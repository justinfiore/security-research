# OpenRouter: inference providers kept prompts they said they would not

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#openrouter-inference-providers-kept-prompts-they-said-they-would-not) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

OpenRouter routes a customer's AI request to a third-party inference provider. On November 22 it said it had taken three providers off the platform and removed 125 endpoints from Zero Data Retention, after Dragos showed that prompts were copied, stored, or forwarded where the customer's setting said they would not be. OpenRouter says its own systems were not breached. There is nothing to install. A prompt that already left is not recalled by the removal.

**No CVE is assigned, and no vendor or CNA has published a CVSS score.** This is an incident at the providers, not a flaw in an application you patch.

Dragos, in a post by HD Moore dated November 19, 2026, says that from July through November it sent about two million prompts carrying unique URLs and canary credentials. It reports three findings. Attackers were copying requests at three hosting providers, the earliest in mid-July, and two of those breaches included requests marked Zero Data Retention. Some stolen keys came from requests the provider rejected before a model ran, which Dragos reads as copying at the provider's front door. One actor used secrets from two of the providers together, from one rented server, and on November 1 added the ARTEX penetration-testing framework; Dragos says the user agents `artex-agent` and `artex-judge-r121` are not on any public indicator list it could find. Separately, marketplace resellers logged customer prompts with ordinary logging and no exploit. Separately again, providers fetched the secret URLs in prompts that were marked not to be retained, including prompts sent to a U.S. provider that a Chinese lab's systems then fetched. Dragos does not name the three compromised providers. It says one of them has published a preliminary notice and another has not disclosed the incident at all.

OpenRouter's announcement, dated November 22, 2026, says the testing did not show a breach or unauthorized access of OpenRouter. It off-boarded three providers, removed 125 endpoints from Zero Data Retention eligibility (the ones researchers flagged, plus others removed as a precaution), and notified potentially affected customers. It links three provider notices and says not every affected provider has posted. The three it links are not identified as the three it off-boarded.

Together AI's notice, published November 21, 2026, is a different path from the front-door copying. Together says an AI coding agent committed a credential for a private Hugging Face repository into its public `xorl` repository, and an unauthorized party downloaded stored prompt samples from that repository. The samples were from requests to MiniMax M3, GLM-5.2, and Kimi K2.6, primarily on June 24, July 4, July 8, and July 14, 2026. Together says five of the credentials the party tested were Dragos canaries, that it has not identified further prompt leakage, and that its review of whether the samples held personal information is still going. It now makes Zero Data Retention the default for new accounts.

Phala's detailed report, published November 23, 2026, supersedes its November 10 preliminary report. It shortens the exposure window for DeepSeek V4 Flash 0731 requests OpenRouter routed to Phala: **2026-10-21 02:25 UTC through 2026-11-01 02:03 UTC**, and it counts 152,092 requests in that window. The last recorded canary misuse is **2026-11-07 01:05:17 UTC**, not November 9. It also says the attacker obtained the legacy KMS root key on November 5, and that an application deployed before 2026-11-06 05:02 UTC that derives keys with `getKey()` must move anything those keys protect.

Novita's blog, dated November 22, 2026, says requests to MiniMax models through Novita between **2026-05-28 and 2026-11-11** may have been accessed or retained by a third party, whether the request came directly or through OpenRouter. Novita says it observed no use of the AWS test-key markers.

MiniMax's notice, dated November 24, 2026, says requests reached its API directly from OpenRouter or through Novita, Streamlake, and Atlas Cloud. MiniMax says it has found no evidence that prompt content or model responses were disclosed, that it does not retain the full content of requests or responses, and that it deleted the URLs recorded from the affected requests. It says the activity included requests OpenRouter had marked Zero Data Retention.

Atlas Cloud's notice is now dated November 23, 2026. The actions are unchanged: MiniMax M3, M2.7, and M3.1 Flash prompts in the third quarter and early fourth quarter, and Atlas Cloud took its own models off OpenRouter.

GMI Cloud's notice, dated November 24, 2026, is a sixth one. GMI says an unauthorized party reached a logging and monitoring system that supports its inference platform, including the endpoints it serves on OpenRouter. The access was on October 21 and 22, and again from October 27, through two credentials that GMI revoked on November 18. GMI says it has not seen access since November 17. The system kept about three days of request content, so GMI says requests from October 18 through November 18 may be included, prompt and response both. GMI stopped logging that content. A researcher told GMI that test keys placed in prompts during that period were later used. GMI says those were the researcher's own keys.

OpenRouter's page, read November 25, now lists six notices: the earlier three plus Atlas Cloud, MiniMax, and GMI Cloud. It still says three providers were off-boarded and still does not name them.

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
| Phala exposure window | 2026-10-21 02:25 UTC through 2026-11-01 02:03 UTC | Phala's November 23 report shortens the preliminary window and counts 152,092 requests. Last canary misuse 2026-11-07 01:05:17 UTC. [Phala][phala] |
| **Dragos post** | **2026-11-19 08:00; timezone not stated on the page** | Three provider compromises, reseller logging, and retention failures. Providers not named. |
| **Together notice** | **2026-11-21; time unknown** | Page says Published 11/21/2026. Credential in a public repository; stored samples downloaded. |
| **OpenRouter announcement** | **2026-11-22; time unknown** | Three providers off-boarded. 125 endpoints removed from Zero Data Retention. [OpenRouter][or] |
| **Atlas Cloud notice** | **2026-11-22; time unknown** | MiniMax M3, M2.7, and M3.1 Flash prompts in Q3 and early Q4. Atlas Cloud took its own models off OpenRouter. [Atlas Cloud][atlas] |
| Novita blog | 2026-11-22; time unknown | MiniMax requests through Novita, 2026-05-28 through 2026-11-11. [Novita][novita] |
| Phala detailed report | 2026-11-23; time unknown | Supersedes the November 10 report. Shortens the window and adds the KMS key. |
| MiniMax notice | 2026-11-24; time unknown | No evidence of prompt disclosure. URLs deleted from security logs. [MiniMax][minimax] |
| **GMI Cloud notice** | **2026-11-24 16:00 UTC** | Logging system reached October 21–22 and from October 27. Credentials revoked November 18. Requests from October 18 through November 18 may be included. [GMI][gmi] |
| **Last updated** | **2026-11-25 (America/New_York)** | GMI Cloud is the sixth notice. |

## Detection

1. Read the notice OpenRouter sent the account, if one arrived. OpenRouter says it notified potentially affected customers and does not publish the list.
2. For a Together AI account, the requests at risk are the ones Together names: MiniMax M3, GLM-5.2, and Kimi K2.6, primarily on the four dates above. Together says it will contact customers directly and has not published a per-customer list.
3. For a request OpenRouter routed to Phala's DeepSeek V4 Flash 0731 inside the shortened window above, treat the prompt as exposed. An application deployed on Phala before 2026-11-06 05:02 UTC that derives keys with `getKey()` should move what those keys protect.
4. For a request sent through Atlas Cloud to MiniMax M3, M2.7, or M3.1 Flash in the third quarter or early fourth quarter of 2026, treat a secret in that prompt as exposed. Atlas Cloud says it emailed the accounts that used those models.
5. A prompt that contained an API key, a token, or a password is the one to rotate. A prompt that did not is still exposed text, and rotating an unrelated key does not address it.
6. Dragos names two user agents, `artex-agent` and `artex-judge-r121`, from the actor who used stolen keys against Dragos's own canary accounts. Those are indicators for the canary accounts, not proof of what happened to a customer key.

## Remediation

There is no customer-side patch.

1. If a prompt in the windows above contained a secret, rotate that secret at the service that issued it. OpenRouter removing an endpoint does not expire it.
2. On Together AI, turn on Zero Data Retention for an account that sends sensitive prompts. Together says that is now the default for new accounts, not for existing ones.
3. On OpenRouter, check the account privacy setting if the account was relying on Zero Data Retention. OpenRouter says an endpoint removed from that list is not eligible again until the provider is revalidated, and it has not published the 125 endpoints.
4. For a MiniMax request sent through Novita between 2026-05-28 and 2026-11-11, treat the prompt as exposed. Novita says that covers requests routed through OpenRouter.

## Verification

- Secrets that were inside an affected prompt have been rotated, or the account has confirmed that no prompt in the window contained one. Absence of a customer email is not that confirmation.
- Together AI accounts that handle sensitive prompts have Zero Data Retention on.
- Do not send a canary prompt to test whether a provider is still copying traffic. That is the researcher's experiment, not a check of your account.

## Compromise response

A secret that was inside a copied prompt should be treated as exposed from the date of that prompt, not from the date of the notice. Together's review of whether the stored samples held personal information is still open, so a Together customer should not treat "not yet contacted" as "not affected." Phala says one tenant was contacted about virtual-machine credentials; a tenant that was not contacted has no action on that part of Phala's report. Dragos says one compromised provider has still not disclosed the incident and that stolen data was still being used in late October, so a provider name missing from OpenRouter's list is not evidence that provider was clean.

## Sources

- [OpenRouter, Data Processing Incidents on Inference Providers][or] — dated 2026-11-22, read again 2026-11-25. Three providers off-boarded, 125 endpoints removed from Zero Data Retention. The page now lists six notices: Novita, Phala, Together, Atlas Cloud, MiniMax, and GMI Cloud. It still does not name the three.
- [GMI Cloud, November 24, 2026][gmi] — a logging and monitoring system was reached on October 21 and 22 and from October 27. Prompts and responses from October 18 through November 18 may have been retained. The credentials were revoked November 18.
- [Atlas Cloud, November 22, 2026][atlas] — MiniMax's official API. Prompts to MiniMax M3 and M2.7 through Atlas Cloud in Q3 and early Q4 2026. Treat secrets sent to M3, M2.7, or M3.1 Flash as exposed. Atlas Cloud took its own models off OpenRouter.
- [Dragos, HD Moore, November 19, 2026][dragos] — about two million canary prompts, July through November. Three unnamed provider compromises, reseller logging, and retention failures, including Zero Data Retention requests. Names the ARTEX user agents.
- [Together AI security event][together] — published 2026-11-21. Stored samples for MiniMax M3, GLM-5.2, and Kimi K2.6 downloaded after a credential reached a public repository. Five tested credentials were Dragos canaries.
- [Phala detailed incident report][phala] — published 2026-11-23. Supersedes the November 10 report. Window 2026-10-21 02:25 UTC through 2026-11-01 02:03 UTC. 152,092 requests. Legacy KMS root key taken November 5.
- [Novita, November 22, 2026][novita] — MiniMax requests through Novita, 2026-05-28 through 2026-11-11, including requests routed by OpenRouter.
- [MiniMax, November 24, 2026][minimax] — requests arrived from OpenRouter, Novita, Streamlake, and Atlas Cloud. Says no prompt content was disclosed, and that the recorded URLs were deleted.
- [CISA KEV JSON][kev] — catalog 2026.11.24, checked 2026-11-24. No CVE to match.

[or]: https://openrouter.ai/blog/announcements/data-processing-incidents-on-inference-providers
[gmi]: https://www.gmicloud.ai/en/blog/security-incident-affecting-gmi-cloud-endpoints-on-openrouter
[dragos]: https://www.dragos.com/blog/ai-supply-chain-security-canary-tokens
[together]: https://www.together.ai/blog/security-event-prompt-leakage-for-requests-in-june-and-july-of-2026
[phala]: https://phala.com/posts/phala-november-detailed-incident-report
[novita]: https://novita.ai/blog/minimax-requests-privacy-notice/
[minimax]: https://www.minimax.io/blog/update-on-url-access-in-forwarded-api-requests-20261124
[atlas]: https://www.atlascloud.ai/blog/ai-updates/security-and-privacy-commitment
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
