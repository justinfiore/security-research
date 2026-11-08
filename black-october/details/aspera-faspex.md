# IBM Aspera Faspex: a logged-in user becomes an administrator

**Last updated:** 2026-11-08 (America/New_York)

[Main Faspex summary](../black-october-2026.md#ibm-aspera-faspex-a-logged-in-user-becomes-an-administrator) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

IBM Aspera Faspex 5 is a web application for sending large files. On 5.0.0 through 5.0.19, IBM says an authorized user can craft a message that skips the authorization check and gains full administrative privileges. IBM rates it CVSS 3.1 9.8. The fix is a container image, not a new RPM: `faspex-core` 5.0.19 with Fix Pack 1.

**IBM rates [CVE-2026-123218](https://www.cve.org/CVERecord?id=CVE-2026-123218) CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. The bulletin summary says the user is authenticated. The CVE description and the same score say an authorized user, and the vector sets Privileges Required to None. Both are IBM's. This guide does not pick one: a deployment where any account exists is inside the bulletin's own summary, and a deployment with no accounts is not how Faspex is used. IBM does not name the message, the endpoint, or the check that fails. NVD has not scored it. IBM lists no workaround.

The affected range in both the bulletin and the CVE record is Faspex 5.0.0 through 5.0.19. The bulletin's fix is **5.0.19 PL1** on Linux. The check it names is the running `faspex-core` image: `5.0.19 (1ce4b13, Fix Pack: 1)`. The RPM does not have to move. The bulletin's document page also names Faspex On Demand 3.7, Aspera on Demand, and Aspera Enterprise, and the affected-products table names only Faspex 5.0.0 through 5.0.19. Those other products are not established as affected or as unaffected. Faspex 4 is outside the named range.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-08). The bulletin does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-07; time/TZ unknown** | IBM published the security bulletin. The page's initial publish date is 07 November 2026 and its modified date is 06 November 2026. The change history says "07 Nov 2026: Initial Publication." [Bulletin][bulletin] |
| CVE record | 2026-11-07; time/TZ unknown | IBM published [CVE-2026-123218][cve]. CVSS 3.1 9.8. Affected 5.0.0 through 5.0.19. |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-08) | [KEV][kev] |

## Detection

This reads the image you are running. It does not send the message IBM describes.

On the Faspex host, as root:

```sh
faspexctl version
```

Read the `faspex-core` line.

- `5.0.19 (1ce4b13, Fix Pack: 1)` is the image the bulletin says to validate. A Fix Pack number higher than 1 on 5.0.19 is later than that image. IBM does not print a later one.
- `5.0.19` with any other hash, or any 5.0.0 through 5.0.18 line, is inside the affected range.
- A Faspex 4 install is outside the range the bulletin names. Confirm the major version before treating it as unaffected. `faspexctl` is the Faspex 5 command.

The RPM version is not the check. IBM says the image can move without an RPM upgrade.

## Remediation

1. On the Faspex 5 host, run `faspexctl setup` as root. IBM's patching page says that pulls the current images for the installed tag. You do not need a new Faspex 5 RPM for this.
2. Run `faspexctl version` and confirm `faspex-core` is `5.0.19 (1ce4b13, Fix Pack: 1)` or a later Fix Pack on 5.0.19. The other Faspex images may stay on their own lines; the bulletin names only `faspex-core`.
3. IBM lists no workaround. Restricting who holds an account reduces who can start from the bulletin's "authenticated user" summary. It does not fix the check, and it does not answer the vector's Privileges Required of None.
4. The image update does not show whether an account already became an administrator, and it does not undo a package that account sent or a setting it changed.

## Verification

- `faspexctl version` prints `faspex-core: 5.0.19 (1ce4b13, Fix Pack: 1)` or a later Fix Pack.
- A user who could send a package before the update can still send one. Do not craft the authorization message to test the check.

## Compromise response

IBM does not publish a log line for this flaw. A new administrator, or an ordinary account that changed a shared inbox, a node, or another user's package, is the indicator to look for. The absence of that change is not proof the message was never sent.

If the host was reachable by any Faspex account on 5.0.0 through 5.0.19:

- Review administrator accounts and remove any that nobody created.
- Rotate credentials stored for transfer nodes, and review packages sent by accounts that should not have been able to send them.
- Read the application log for authorization errors that immediately precede an administrative action.

## Sources

- [IBM bulletin 7295921][bulletin] — initial publication 07 November 2026. CVSS 3.1 9.8 from IBM. Affected Faspex 5.0.0 through 5.0.19. Fixed in 5.0.19 PL1. Validate `faspex-core` `5.0.19 (1ce4b13, Fix Pack: 1)`. No workaround.
- [CVE-2026-123218][cve] — IBM CNA, published 2026-11-07. Same score and the same affected range. The description says an authorized user. The vector sets Privileges Required to None.
- [Patching container images][patch] — `faspexctl setup` as root, then `faspexctl version`. The RPM does not have to move.
- [CISA KEV JSON][kev] — catalog 2026.11.06, checked 2026-11-08. CVE-2026-123218 is not listed.

[bulletin]: https://www.ibm.com/support/pages/node/7295921
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-123218
[patch]: https://www.ibm.com/docs/en/aspera-faspex/5.0.x?topic=upgrades-patching-container-images
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
