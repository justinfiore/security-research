# Docker Hub: GhostPat - access-token reassignment on account conversion

**Last updated:** 2026-10-26 (America/New_York)

[Main Docker Hub summary](../black-october-2026.md#docker-hub-ghostpat---access-token-reassignment-on-account-conversion) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-105445](https://www.cve.org/CVERecord?id=CVE-2026-105445): Docker (CNA) CVSS 4.0 9.4 Critical (CVSS:4.0/AV:N/AC:L/AT:N/PR:L/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H), CWE-266 Incorrect Privilege Assignment. NVD has added no score of its own; the record is "Awaiting Analysis".** Docker Hub lets a user convert a personal account into an organization and name an existing account as the new owner. Between **2024-08-26 20:33 UTC** and the fix on **2026-09-30 at about 19:10 UTC**, conversion also moved the converted account's **personal access tokens (PATs)** to the named owner. The token secret was not rotated, and the named owner was not asked or notified. [Docker advisory][adv] [CNA][cve]

**Attack:** an attacker with a free account creates a PAT, converts the account to an organization, and names a target user as owner. The attacker's PAT then authenticates to the registry **as the target**. Within the token's scopes it can pull, push or delete images in the target's repositories and in organizations the target belongs to, including private repositories. Docker says it gave no access to the Hub web interface and could not change the target's password, email or two-factor settings. [Docker advisory][adv] [GhostPat site][site]

**Worst case:** an attacker publishes a malicious image under a trusted user's or organization's name, or reads their private images. That is a software supply-chain risk for everyone who pulls those images.

**This is a service-side issue.** Docker fixed it in Docker Hub itself. **There is no software, Docker Engine or Docker Desktop update to install.** Your work is to check tokens and image provenance.

**Exploitation:** Docker reviewed every conversion since 2024-08-26 and about **304,000 pushes** made with transferred tokens. It found **no evidence of exploitation**. Docker notes that an unused transferred token leaves no trace in registry logs. [Docker advisory][adv]

**CISA KEV:** Not listed (catalog 2026.10.23, checked 2026-10-26). Docker reports no evidence of exploitation after reviewing about 304,000 pushes made with transferred tokens. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
  - [Were you notified?](#were-you-notified)
  - [Token and organization review](#token-and-organization-review)
  - [Image provenance (read-only)](#image-provenance-read-only)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

Docker's own timeline is in "U.S. Eastern" time. The blog labels two entries "EST", but these dates fall in daylight-saving time. Only the fix time has a UTC equivalent from Docker; other UTC conversions are not given.

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Flaw introduced | 2024-08-26 20:33 UTC | Conversion begins re-assigning PATs. [Docker advisory][adv] [CNA][cve] |
| Researchers' first reproduction | 2026-09-28; time/TZ unknown | Vector 1, by Peter Molnar and Krisztian Hozak of mptrdev.com. A second, independent reproduction followed on 2026-09-29. [GhostPat site][site] |
| Private report to Docker | 2026-09-30 11:40 U.S. Eastern | Through Docker's Vulnerability Disclosure Program. [Docker advisory][adv] |
| Docker reproduces internally | 2026-09-30 ~13:30 U.S. Eastern | [Docker advisory][adv] |
| **Fix deployed (service-side)** | 2026-09-30 ~15:10 U.S. Eastern (~19:10 UTC) | Conversion no longer transfers PATs. Exposure window ends. [Docker advisory][adv] [CNA][cve] |
| Documentation updated | 2026-09-30 ~15:23 U.S. Eastern | PATs do not transfer; the new owner should create organization access tokens. [Docker advisory][adv] [Docker docs][docs] |
| Affected users and organization owners emailed | 2026-10-02 17:30 U.S. Eastern (Docker labels it EST) | Subject "Docker Hub Vulnerability Identified & Resolved". Each email listed the in-scope tokens. [Docker advisory][adv] |
| CVE reserved | 2026-10-05 13:28:16 UTC | [CNA][cve] |
| Transferred PATs force-deactivated | 2026-10-08 15:45 U.S. Eastern (Docker labels it EST) | Tokens whose holders opted out before the deadline were not deactivated. [Docker advisory][adv] |
| **Public announcement**: Docker advisory | 2026-10-12 09:00 PDT (UTC−07:00), 16:00 UTC | From page publication metadata. The researchers' site also lists public disclosure on 2026-10-12. [Docker advisory][adv] [GhostPat site][site] |
| CVE published | 2026-10-13 17:35:20 UTC | Docker CNA. NVD published it at 2026-10-13 18:17:13 UTC. [CNA][cve] [NVD][nvd] |
| CISA ADP SSVC enrichment | 2026-10-19 12:59:31 UTC | Exploitation "none", Automatable "no", Technical Impact "total". This is not KEV. [CNA ADP][cve] |
| CISA KEV | Not listed (catalog 2026.10.23, checked 2026-10-26) | [KEV feed][kev] |
| Exploitation evidence | None found by Docker | Based on registry authentication logs, usage data and token records. An unused token leaves no trace. [Docker advisory][adv] |

## Detection

There is nothing to scan on your hosts. The vulnerable code ran in Docker Hub. The checks below use the Docker Hub interface and your own build records.

### Were you notified?

Docker says that if you did not receive its 2026-10-02 email, "you and any members of the organizations you administer were not exposed and there are no actions for you to take". Search your mail, including spam folders, for the subject **"Docker Hub Vulnerability Identified & Resolved"**. Check every account that owns or administers Docker Hub organizations. The email lists the affected tokens by description and creation date. [Docker advisory][adv]

Do not treat a look-alike email as genuine. Verify any notice by signing in to Docker Hub directly rather than by following links.

### Token and organization review

1. In Docker Hub, open **Account settings → Personal access tokens**. Compare every token with the list in Docker's email and with tokens you know you created. The researchers warn that **the token name is chosen by the attacker**, so a familiar name proves nothing. [GhostPat site][site]
2. Open the **account switcher** and look for organizations you do not remember owning or joining. A conversion that named you as owner leaves a new organization there. [GhostPat site][site]
3. If your subscription provides organization activity or audit logs, review pushes, tag changes and deletions during the exposure window.

### Image provenance (read-only)

If you received Docker's email, or you cannot tell, compare what the registry serves now with what your CI actually built. Run this from any workstation with Docker Buildx and pull access to the repository. Replace `NAMESPACE/REPO:TAG` with your own image. It only reads registry metadata and has not been tested against an affected account.

```sh
docker buildx imagetools inspect NAMESPACE/REPO:TAG
```

Compare the reported digest with the digest recorded in your CI logs, signatures or attestations (for example cosign or Docker build attestations, if you use them). Look for tags and repositories that no pipeline of yours created. A matching digest for your current tags does not cover deleted tags, images pulled during the window, or private data read with the token.

## Remediation

1. **Nothing to install.** Docker fixed the flaw on 2026-09-30 and deactivated transferred tokens on 2026-10-08, except where the holder opted out. [Docker advisory][adv]
2. **If you were emailed:** revoke every token Docker listed that you have not positively confirmed as yours, including any you opted to keep. Revoke all PATs you do not recognize or no longer need, and issue new ones. [Docker advisory][adv] [GhostPat site][site]
3. **For automation that belongs to an organization,** use organization access tokens rather than one person's PAT. [Docker advisory][adv] [Docker docs][docs]
4. Keep token scopes as narrow as your pipelines allow. Read-only tokens limit what a stolen token can do.

## Verification

- Your PAT list contains only tokens you created and still need.
- The account switcher shows only organizations you expect.
- Pipelines that used a revoked token now authenticate with the replacement token or an organization access token.
- Registry digests for tags you publish match your CI build records or signatures.

## Compromise response

If you find a token you did not create, an unknown organization, or images or tags you did not build:

- Revoke the token, then preserve organization activity logs and the image digests involved before you change anything else.
- Treat unexplained images as malicious. Rebuild from source and push known-good digests, then tell downstream users which digests to stop using.
- Identify systems that pulled affected tags during the window, for example from CI logs, Kubernetes events or registry mirrors. Investigate those hosts.
- Assume private images the target account could read were exposed. Rotate any secrets baked into those images.
- Contact Docker Support at [app.docker.com/support/contact](https://app.docker.com/support/contact).

## Sources

- [Docker Hub security advisory][adv]: mechanism, exposure window, timeline, investigation results and user actions.
- [CVE record (Docker CNA)][cve] and [NVD][nvd]: score, CWE, affected date range and publication times.
- [GhostPat researcher site][site]: attack steps, proof of impact and checks for users.
- [Docker documentation on account conversion][docs]: tokens no longer transfer; use organization access tokens.
- [CISA KEV feed][kev]: not listed in catalog 2026.10.23.

[adv]: https://www.docker.com/blog/docker-hub-security-advisory-cve-2026-105445/
[cve]: https://cveawg.mitre.org/api/cve/CVE-2026-105445
[nvd]: https://services.nvd.nist.gov/rest/json/cves/2.0?cveId=CVE-2026-105445
[site]: https://ghostpat.com/
[docs]: https://docs.docker.com/accounts/organization/setup/convert-account/
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
