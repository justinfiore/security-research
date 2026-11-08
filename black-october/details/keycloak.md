# Keycloak: a signed SAML message covers a different message than the one processed

**Last updated:** 2026-11-07 (America/New_York)

[Main Keycloak summary](../black-october-2026.md#keycloak-a-signed-saml-message-covers-a-different-message-than-the-one-processed) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Keycloak's SAML HTTP-Redirect binding verifies the signature of one query parameter and then processes a different one. An attacker who can obtain one validly signed redirect-binding message from a brokered identity provider can log in as any federated user.

**Red Hat rates [CVE-2026-117691](https://www.cve.org/CVERecord?id=CVE-2026-117691) CVSS 3.1 9.1 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:N`. Red Hat's product impact rating is Important, which is a different scale. NVD has not scored it. The server decodes a percent-encoded parameter name such as `%53AMLResponse` before it processes the message, and the signature check looks up the literal name `SAMLResponse`. A request that carries both can make the signature check succeed on the signed message while the broker parses the unsigned one. Red Hat says that is a full takeover of a federated user's account, roles, and data. It does not describe code execution. Availability impact is None.

The attacker does not need a Keycloak account. The attacker does need an account at the external identity provider, one signed redirect-binding message issued for that account, and a broker login the attacker started. The realm has to broker that provider over the HTTP-Redirect binding, with signature validation on. When "Want Assertions Signed" is on, Keycloak rejects the unsigned crafted assertion. That setting is not the fix: it only helps when the provider signs assertions, and it changes the trust contract.

Community Keycloak **26.8.2**, released 2026-11-05, contains the fix commit. The issue tracker also labels **26.6.9** and **26.4.18**. Those git tags exist, and neither tag contains the fix commit. The fix is on the `release/26.6` and `release/26.4` branches, in commits dated 2026-11-05 and 2026-11-06, and those commits are not in the tags. No community release after 26.8.2 was published when checked on 2026-11-08. Red Hat Build of Keycloak is affected. [RHSA-2026:96040](https://access.redhat.com/errata/RHSA-2026:96040), issued 2026-11-07, says Red Hat build of Keycloak 26.6.9 packages fix this CVE. That is a Red Hat package, not the community tag of the same number. Red Hat Single Sign-On 7 is not affected: the record says the vulnerable code is not present. Red Hat lists no workaround that meets its criteria.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07). CERT Santé's November 6 notice says exploitation was not observed and that an open-source proof of concept exists. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Reported to Red Hat | 2026-10-26 20:13 UTC | CNA timeline. The reporter is Mayssen Aidoudi (Think-it GmbH). [CVE JSON][cvejson] |
| **Public announcement** | **2026-11-05 13:27 UTC** | Red Hat published the CVE record. `datePublic` is 2026-11-05 with no time of day. [CVE][cve] |
| Fix commit | 2026-11-05 15:19 UTC | `cbda2bfd35` on the 26.8 line. "Verify the SAML redirect binding message that is processed." [Commit][commit] |
| Keycloak 26.8.2 | 2026-11-05 16:00 UTC | The release notes list issue 54714. [Release][rel2682] |
| Branch backports | 2026-11-05 15:21 UTC and 2026-11-06 06:07 UTC | The same commit message is on `release/26.6` and `release/26.4`. It is not in the 26.6.9 or 26.4.18 tags. [26.6 commit][c266] [26.4 commit][c264] |
| Red Hat packages | 2026-11-07; time/TZ unknown | RHSA-2026:96040, Red Hat build of Keycloak 26.6.9. [RHSA][rhsa] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-07) | [KEV][kev] |

## Detection

This only reads the version you are running. It does not send a SAML message.

On the host, or inside the container:

```sh
/opt/keycloak/bin/kc.sh --version
```

A container that does not have a shell on `PATH` still has the script:

```sh
docker exec CONTAINER /opt/keycloak/bin/kc.sh --version
```

Replace `CONTAINER` with the name from `docker ps`. An image name is not the running version until the container was recreated from it.

- Community **26.8.0 and 26.8.1** are affected. **26.8.2** is the fixed community release.
- Community **26.6.9 and 26.4.18** are not fixed releases of this flaw. The tags do not contain the fix, and no later community tag on those lines was published.
- Anything older than 26.8.2 that still brokers a SAML identity provider over the HTTP-Redirect binding has no published community fix. Move it to 26.8.2.
- **Red Hat build of Keycloak** follows RHSA-2026:96040, which names 26.6.9 packages. A community `26.6.9` tag does not satisfy that advisory, and a Red Hat package does not satisfy the community check.
- **Red Hat Single Sign-On 7** is not affected.
- A realm that does not broker a SAML identity provider, or that uses only the POST or artifact binding, is outside the account-takeover path. The version check still matters if the configuration can be changed to redirect binding.

A realm export is the way to see the binding and the "Want Assertions Signed" flag. Do not print client secrets from it. The flag being on reduces exposure and is not a patched version.

## Remediation

1. Upgrade community Keycloak to **26.8.2 or later**. Pull `quay.io/keycloak/keycloak:26.8.2` and recreate the container. A running container keeps the old image. For a ZIP install, back up the configuration and the database, then replace the installation and follow the [migration guide](https://www.keycloak.org/docs/latest/upgrading/).
2. On Red Hat build of Keycloak, install the **26.6.9** packages from [RHSA-2026:96040](https://access.redhat.com/errata/RHSA-2026:96040). Back up the installation first, as the advisory says. Do not treat the community git tag `26.6.9` as that package.
3. Red Hat Single Sign-On 7 needs no change for this CVE.
4. Red Hat lists no workaround that meets its criteria. Turning on "Want Assertions Signed" rejects the unsigned crafted assertion only when the identity provider signs assertions. Rejecting a repeated or percent-encoded `SAMLResponse`, `SAMLRequest`, `RelayState`, `SigAlg`, or `Signature` at a reverse proxy is the same idea as the fix, and it can break a client that encodes those names. Neither replaces the upgrade.
5. The upgrade does not show whether a broker login already succeeded as another user, and it does not end sessions created before it.

## Verification

- `kc.sh --version` prints 26.8.2 or later for a community install, after the container or process was restarted.
- A Red Hat install shows the 26.6.9 packages from RHSA-2026:96040, not the community tag of that number.
- A login your users already make through the broker still succeeds. Do not send a second `SAMLResponse` to test the check.

## Compromise response

No indicator has been published. The public description gives one lead: a request to the broker endpoint whose query string contains both a percent-encoded SAML parameter name and the literal name, or the same parameter twice.

If the reverse proxy keeps query strings, search its access log for `%53AMLResponse`, `%53AMLRequest`, and for two `SAMLResponse` parameters in one request. A hit is a lead. A client can encode a name for a benign reason. A log that stores the decoded query will not show the encoding, and a log that drops the query string will not show the attempt. Absence of a hit does not mean it did not happen.

If that search hits, or a brokered application shows a session the user did not start:

- Preserve the proxy log and Keycloak's event log from before the upgrade.
- Revoke sessions for the affected realm and require those users to sign in again.
- Review what the federated account could reach in connected applications. The advisory's impact follows the victim's roles.

## Sources

- [CVE-2026-117691][cve] — Red Hat CNA, published 2026-11-05 13:27 UTC. CVSS 3.1 9.1 Critical. Red Hat impact Important. Red Hat Build of Keycloak affected. Red Hat Single Sign-On 7 unaffected.
- [CVE JSON][cvejson] — reported 2026-10-26 20:13 UTC. No workaround meeting Red Hat's criteria.
- [RHSA-2026:96040][rhsa] — issued 2026-11-07. Red Hat build of Keycloak 26.6.9 packages fix CVE-2026-117691.
- [Keycloak 26.8.2][rel2682] — published 2026-11-05 16:00 UTC. Lists issue 54714 under security fixes.
- [Commit cbda2bfd35][commit] — 2026-11-05 15:19 UTC. Decodes parameter names before the signature check, rejects a repeated redirect parameter, and compares the signed value with the value being processed.
- [Issue 54714][issue] — labels `release/26.8.2`, `release/26.6.9`, and `release/26.4.18`. The 26.6.9 and 26.4.18 tags do not contain the fix commit.
- [NVD][nvd] — awaiting enrichment. Shows the Red Hat 9.1 score. No NIST score.
- [CISA KEV][kev] — catalog 2026.11.06. Not listed.

[cve]: https://www.cve.org/CVERecord?id=CVE-2026-117691
[cvejson]: https://cveawg.mitre.org/api/cve/CVE-2026-117691
[rhsa]: https://access.redhat.com/errata/RHSA-2026:96040
[rel2682]: https://github.com/keycloak/keycloak/releases/tag/26.8.2
[commit]: https://github.com/keycloak/keycloak/commit/cbda2bfd35e2eb182942996832b819c35780b121
[c266]: https://github.com/keycloak/keycloak/commit/f133b77df6dd
[c264]: https://github.com/keycloak/keycloak/commit/af68ba83746c
[issue]: https://github.com/keycloak/keycloak/issues/54714
[nvd]: https://nvd.nist.gov/vuln/detail/CVE-2026-117691
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
