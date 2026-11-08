# Gitea 28.3.0: Actions secret theft, archived-repo writes, and stored XSS

**Last updated:** 2026-11-07 (America/New_York)

[Back to Gitea 28.3.0 summary](../black-october-2026.md#gitea-actions-secret-theft-archived-repo-writes-and-stored-xss) · [Changelog](../../CHANGELOG.md)

Gitea 28.3.0, released 2026-11-01, fixes seven High flaws that affect **28.2.0 and earlier**. They are not the built-in SSH authentication bypass ([CVE-2026-103059](https://www.cve.org/CVERecord?id=CVE-2026-103059)), which 28.0.0 already fixed. A host that stopped at 28.0.0, 28.1.0, or 28.2.0 is still exposed to all seven. The same tag also fixes more Medium flaws. They are not a second upgrade. The GitHub release notes do not list them. The [28.3.0 blog post](https://blog.gitea.com/release-of-28.3.0) does.

| CVE | Score | Who can do it | Result |
| --- | --- | --- | --- |
| [CVE-2026-118386](https://www.cve.org/CVERecord?id=CVE-2026-118386) | GitHub advisory CVSS 3.1 **8.1 High**. No CNA score in the record checked. | A user with **read** access, a runner, and one same-repository pull request. | Their workflow runs as the repository's own: no approval, the repository's and owner's Actions secrets, and a `GITEA_TOKEN` that can commit. |
| [CVE-2026-116296](https://www.cve.org/CVERecord?id=CVE-2026-116296) | GitHub advisory CVSS 3.1 **8.1 High**. | A user with ordinary **write** access to an **archived** repository. | Replace release binaries at the same tag and URL, delete releases, and edit milestones and labels. The archived-repository guard is missing on those routes. |
| [CVE-2026-113429](https://www.cve.org/CVERecord?id=CVE-2026-113429) | GitHub advisory CVSS 3.1 **8.7 High**. | A user who can run one Actions job. The download URL needs only Actions read, so it is anonymous on a public repository. | Stored XSS on the Gitea origin. The victim must open the direct artifact URL. Chromium renders `video/mp4,text/html` as HTML after Gitea drops the sandbox CSP. |
| [CVE-2026-120263](https://www.cve.org/CVERecord?id=CVE-2026-120263) | GitHub advisory **High**. No numeric score on the advisory. | Anyone who can sign in through a configured OAuth2 provider, and only when `ACCOUNT_LINKING = auto`. The default is `login`, which is not this bug. | The link-account form takes a user name the attacker types and signs them in as that account, including an administrator, without the password. The link stays after logout. |
| [CVE-2026-117635](https://www.cve.org/CVERecord?id=CVE-2026-117635) | GitHub advisory CVSS 3.1 **8.1 High**. | A **public-only** token that belongs to a site administrator. | The admin API ignores that restriction: list every user's email, create private organizations and runner tokens, and create a new administrator. Revoking the token does not remove that new account. |
| [CVE-2026-119441](https://www.cve.org/CVERecord?id=CVE-2026-119441) | GitHub advisory CVSS 3.1 **8.1 High**. | A **public-only** token of an organization owner. The route exists from 1.27.0. | `DELETE /api/v1/orgs/{org}/repos` deletes every repository in the organization, including private ones. The deletion runs in the background and cannot be cancelled. |
| [CVE-2026-117685](https://www.cve.org/CVERecord?id=CVE-2026-117685) | GitHub advisory CVSS 3.1 **7.1 High**. | A **public-only** package token whose owner can already read a private package. | Mount a private OCI blob into a public package, then download it from the public URL. |

The same 28.3.0 tag also fixes more Medium flaws, all patched in 28.3.0. They do not change the upgrade. The [blog post](https://blog.gitea.com/release-of-28.3.0) lists them; the GitHub release notes do not. GitHub labels each Medium. The seven already checked, published 2026-11-01 09:42 UTC, are below. The blog names others in the same release, including [CVE-2026-116289](https://www.cve.org/CVERecord?id=CVE-2026-116289) and [CVE-2026-117649](https://www.cve.org/CVERecord?id=CVE-2026-117649). Those were not scored separately here:

| CVE | Score | What it does |
| --- | --- | --- |
| [CVE-2026-116474](https://www.cve.org/CVERecord?id=CVE-2026-116474) | Medium; no numeric score on the advisory | An Actions token can spoof an instance-signed commit by adding a GPG key. |
| [CVE-2026-112887](https://www.cve.org/CVERecord?id=CVE-2026-112887) | 6.5 | An Actions task token can call the REST API with no token scope. |
| [CVE-2026-119533](https://www.cve.org/CVERecord?id=CVE-2026-119533) | 5.3 | A public project board can show a private pull request's title. |
| [CVE-2026-118394](https://www.cve.org/CVERecord?id=CVE-2026-118394) | 4.3 | OIDC userinfo skips the public-only scope when the token is a query parameter. |
| [CVE-2026-119627](https://www.cve.org/CVERecord?id=CVE-2026-119627) | 4.3 | Profile and feed routes bypass the public-only scope. |
| [CVE-2026-118504](https://www.cve.org/CVERecord?id=CVE-2026-118504) | 6.5 | The API issue-archive restriction can be bypassed. |
| [CVE-2026-114199](https://www.cve.org/CVERecord?id=CVE-2026-114199) | 4.3 | A contribution heatmap leaks private-repository counts to a public-only token. |
| [CVE-2026-119625](https://www.cve.org/CVERecord?id=CVE-2026-119625) | 5.3 | A token with an unrelated scope, sent as HTTP Basic, reads the owner's private activity feed. A public-only token sees private repositories and organizations on the profile pages. |
| [CVE-2026-116289](https://www.cve.org/CVERecord?id=CVE-2026-116289) | Medium; no numeric score on the blog | A public-only token with `write:organization`, held by an organization owner, creates an organization runner token. A runner registered with it receives jobs, including secrets, from the organization's private repositories. |
| [CVE-2026-117646](https://www.cve.org/CVERecord?id=CVE-2026-117646) | 4.3 | The repositories, stars, and watching tabs of a user profile, and the organization home page, show private repositories to a public-only token. |
| [CVE-2026-118395](https://www.cve.org/CVERecord?id=CVE-2026-118395) | 4.3 | The deprecated `POST /api/v1/org/{org}/repos` route lets a public-only token create a private repository in an organization. |
| [CVE-2026-117677](https://www.cve.org/CVERecord?id=CVE-2026-117677) | Medium; no numeric score on the blog | A Helm chart upload inflates the whole archive before the package size quota is checked, so a user with package write access can tie up the server with a small, highly compressed upload. |
| [CVE-2026-117649](https://www.cve.org/CVERecord?id=CVE-2026-117649) | Medium; no numeric score on the blog | The issue timeline shows a private issue linked as a dependency to a user who cannot read it. The web page shows the title, and the API returns the issue including its body. |

The numbers are GitHub's CVSS 3.1 scores where the blog states one. CVE-2026-116474, CVE-2026-116289, CVE-2026-117677, and CVE-2026-117649 have no numeric score on the blog. The five rows added on 2026-11-07 come from that blog, reread that day. They do not change the upgrade: 28.3.0 already covers them. The same binaries are built with Go 1.27.3, so outgoing certificate checks no longer trust the eMudhra intermediates ([CVE-2026-111943](https://www.cve.org/CVERecord?id=CVE-2026-111943)). That is the [certificate-authority incident](emudhra.md), not a new Gitea flaw.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07) for any CVE in this release. No exploitation report was found. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Date | Event and evidence |
| --- | --- |
| 2026-11-01 09:42 UTC | GitHub publishes the first three advisories. Each says patched in **28.3.0**. [CVE-2026-118386][a1], [CVE-2026-116296][a2], [CVE-2026-113429][a3] |
| 2026-11-01; time/TZ unknown | The [28.3.0 blog post][blog] lists four more High advisories in the same tag: [CVE-2026-120263](https://github.com/go-gitea/gitea/security/advisories/GHSA-8p3x-w464-4g6v), [CVE-2026-117635](https://github.com/go-gitea/gitea/security/advisories/GHSA-37xv-m4w7-j2fh), [CVE-2026-119441](https://github.com/go-gitea/gitea/security/advisories/GHSA-jh8p-x4ch-389q), and [CVE-2026-117685](https://github.com/go-gitea/gitea/security/advisories/GHSA-8g99-g36h-5p2w). |
| 2026-11-01 09:55 UTC | Gitea tags **v28.3.0**. [Release][rel] |
| Customer action | Upgrade. 28.2.0 is inside every affected range. |

**Evidence limits:** The advisories do not name a reporter date. CVE-2026-118386's range starts at 1.19.0; the other two say `<= 28.2.0` and do not name a first affected release. The XSS advisory says it was tested in Chromium only. NVD had not scored these records when checked.

## Detection

1. Read the running version from `gitea --version` or `/api/v1/version` on every instance, including replicas. **28.2.0 and earlier are affected.** 28.3.0 is the first listed fix.
2. **Actions secret theft** needs read access, a runner for that repository, and one pull request whose head branch is in the repository itself (open or merged). Disabling forks does not remove it: the advisory says a fork pull request or a push to `refs/for/main/<topic>` also needs only read access.
3. **Archived writes** need an archived repository and a collaborator or token with write access. Look for release assets, milestones, or labels that changed after the repository was archived.
4. **XSS** needs one job the attacker could run, then a victim opening `/{owner}/{repo}/actions/runs/{run_id}/artifacts/{name}`. The in-page artifact preview stays sandboxed; the direct URL does not.

## Remediation

1. Upgrade to **Gitea 28.3.0 or later** and restart. Back up first. This is the same upgrade that covers the [built-in SSH bypass](gitea.md#remediation) if you have not installed 28.0.0 yet.
2. There is no configuration workaround in the advisories for the Actions secret theft. Until 28.3.0 is running, do not treat a read-only account as unable to start a trusted workflow.
3. For the archived-repository gap, removing write collaborators is the only reduction the advisory supports, and it does not fix the missing check.
4. For the XSS, do not send users direct artifact links from untrusted runs until the upgrade is in place.

## Verification

- `/api/v1/version` reports 28.3.0 or later on every instance.
- After the upgrade, a review whose `commit_id` is not the pull request's head must not start a workflow with `IsForkPullRequest = false`. The advisory's fix is that check; do not post an exploit payload to confirm it.
- An archived repository must reject release, milestone, and label changes from a write collaborator.

## Compromise response

- **Actions:** If a read-only user could open reviews, treat Actions secrets on repositories that had a same-repository pull request as exposed, and rotate them. Also review commits made with `GITEA_TOKEN` from runs you did not approve.
- **Releases:** If an archived repository had write collaborators, compare release asset hashes with a copy from before the archive. The download URL staying the same is the point of the flaw.
- **XSS:** A user who opened a direct artifact link may have run JavaScript as themselves. For an admin, the advisory says that means control of the instance: review admin actions and rotate session secrets.

## Sources

- [GHSA-32h8-5xqg-h466 / CVE-2026-118386](https://github.com/go-gitea/gitea/security/advisories/GHSA-32h8-5xqg-h466)
- [GHSA-6h2f-c8jm-84hc / CVE-2026-116296](https://github.com/go-gitea/gitea/security/advisories/GHSA-6h2f-c8jm-84hc)
- [GHSA-9v6p-xpcp-7488 / CVE-2026-113429](https://github.com/go-gitea/gitea/security/advisories/GHSA-9v6p-xpcp-7488)
- [Gitea v28.3.0](https://github.com/go-gitea/gitea/releases/tag/v28.3.0)
- [Gitea 28.3.0 blog post](https://blog.gitea.com/release-of-28.3.0), which lists the High flaws the GitHub release notes omit
- [GHSA-8p3x-w464-4g6v / CVE-2026-120263](https://github.com/go-gitea/gitea/security/advisories/GHSA-8p3x-w464-4g6v)
- [GHSA-37xv-m4w7-j2fh / CVE-2026-117635](https://github.com/go-gitea/gitea/security/advisories/GHSA-37xv-m4w7-j2fh)
- [GHSA-jh8p-x4ch-389q / CVE-2026-119441](https://github.com/go-gitea/gitea/security/advisories/GHSA-jh8p-x4ch-389q)
- [GHSA-8g99-g36h-5p2w / CVE-2026-117685](https://github.com/go-gitea/gitea/security/advisories/GHSA-8g99-g36h-5p2w)

[a1]: https://github.com/go-gitea/gitea/security/advisories/GHSA-32h8-5xqg-h466
[a2]: https://github.com/go-gitea/gitea/security/advisories/GHSA-6h2f-c8jm-84hc
[a3]: https://github.com/go-gitea/gitea/security/advisories/GHSA-9v6p-xpcp-7488
[rel]: https://github.com/go-gitea/gitea/releases/tag/v28.3.0
[blog]: https://blog.gitea.com/release-of-28.3.0
