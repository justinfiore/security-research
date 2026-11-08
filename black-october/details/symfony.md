# Symfony: a YAML document holds a PHP worker, and a data URI reads a file

**Last updated:** 2026-11-08 (America/New_York)

[Main Symfony summary](../black-october-2026.md#symfony-a-yaml-document-holds-a-php-worker-and-a-data-uri-reads-a-file) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Symfony published three High advisories on 2026-11-04. Checkmarx published CVE records for two of them on 2026-11-06. The same four releases fix all three.

**GitHub rates [CVE-2026-123792](https://www.cve.org/CVERecord?id=CVE-2026-123792) CVSS 4.0 8.7 High.** NVD has not scored it. The YAML parser repeats work it has already done, so a small document can hold a PHP process for seconds or minutes. On Symfony 7.4 and later, one unauthenticated request with a YAML content type does that through `#[MapRequestPayload]` when the Yaml component is installed and the endpoint does not restrict `acceptFormat`. JSON is valid YAML, so a JSON body sent as YAML is enough for the flow-collection case. On 6.4, that attribute accepts YAML only when the application registers a yaml request format. Any other code that parses untrusted YAML with the default flags is affected too.

**Checkmarx rates [CVE-2026-121623](https://www.cve.org/CVERecord?id=CVE-2026-121623) CVSS 4.0 8.2 High.** NVD has not scored it. `DataUriNormalizer::denormalize()` accepts `DATA:` and then PHP opens that string as a local path, including `..`. Symfony's advisory says a value denormalized to `\SplFileObject` returns the file. A public endpoint that deserializes untrusted input into `File`, `\SplFileInfo`, or `\SplFileObject` needs no login. FrameworkBundle registers this normalizer by default. Symfony's advisory page now names [CVE-2026-121623](https://www.cve.org/CVERecord?id=CVE-2026-121623). The GitHub record was updated 2026-11-06. An earlier reading of the same page said no CVE was known.

The third advisory, [GHSA-6prc-h956-hxjq](https://github.com/symfony/symfony/security/advisories/GHSA-6prc-h956-hxjq), has no CVE. Symfony rates it High. `Path` treats anything before `://` as a root, so a check with `isBasePath()` can say a path is inside a directory when PHP then opens a file outside it. On 6.4 and later, AssetMapper uses the same join when it installs a remote package, and a malicious package can write a file outside `assets/vendor`.

The floors are **5.4.56**, **6.4.50**, **7.4.23**, and **8.1.11**. The path-escape advisory starts at 5.4.0; the other two cover everything before 5.4.56. Symfony does not report exploitation.

**CISA KEV:** Not listed (catalog 2026.11.06, checked 2026-11-07). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement** | **2026-11-04; time/TZ unknown** | GitHub advisories published by fabpot. [YAML][yaml] [Data URI][datauri] [Path][path] |
| CVE records | 2026-11-06; time/TZ unknown | Checkmarx CNA. The data-URI advisory page now names CVE-2026-121623. It was updated 2026-11-06. [CVE-2026-123792][cve792] [CVE-2026-121623][cve623] |
| CISA KEV | Not listed (catalog 2026.11.06, checked 2026-11-07) | [KEV][kev] |

## Detection

This only reads.

From the application root, on a machine you trust:

```sh
composer show symfony/yaml symfony/serializer symfony/filesystem --no-interaction
```

A lockfile line is enough when Composer is not installed: `symfony/yaml`, `symfony/serializer`, and `symfony/filesystem` in `composer.lock`. An application that vendors Symfony without those package names is not answered by this command.

- Below 5.4.56, 6.4.50, 7.4.23, or 8.1.11 is inside the YAML and data-URI ranges.
- `symfony/filesystem` from 5.4.0 below those same floors is inside the path-escape range. A 5.3 or older filesystem package is outside that one advisory and is not cleared for the other two.
- A Symfony application that does not parse YAML, does not deserialize into `File`, and does not call `Path` is still inside the version range. Reachability is a separate question, and this check does not answer it.

Do not send a crafted YAML document or a `DATA:` value to check.

## Remediation

1. Upgrade `symfony/yaml`, `symfony/serializer`, and `symfony/filesystem` together to **5.4.56**, **6.4.50**, **7.4.23**, or **8.1.11** or later on that line. `symfony/symfony` uses the same floors.
2. Redeploy and restart PHP-FPM, workers, and long-running processes. The running code is what matters.
3. Symfony lists no workaround. Restricting `acceptFormat` on `#[MapRequestPayload]` avoids the YAML content type for that one attribute. It does not fix other YAML parsing, the data-URI read, or the path check.
4. The upgrade does not show whether a request already read a file or wrote one through AssetMapper.

## Verification

- `composer show` prints 5.4.56, 6.4.50, 7.4.23, or 8.1.11 or later for each of the three packages you use.
- A request your application already accepts still succeeds. Do not send a nested YAML document or a `DATA:` path.

## Compromise response

Symfony does not publish an indicator. If a public endpoint deserialized into `File` or parsed untrusted YAML while the version was below the floor, treat a file read and a hung worker as possible.

- Preserve the web server and PHP-FPM logs from before the upgrade.
- On 6.4 and later, review files written under and outside `assets/vendor` by `importmap:require` or `importmap:install` from a package you did not pin.
- A file read does not leave a reliable marker. Rotate secrets the PHP process could read if you have another reason to think a request succeeded.

## Sources

- [GHSA-hwfg-qwvh-2wfx][yaml] — Symfony, published 2026-11-04. YAML parse time. CVSS 4.0 8.7 High. Fixed in 5.4.56, 6.4.50, 7.4.23, and 8.1.11.
- [GHSA-pxj9-jh84-vhm5][datauri] — Symfony, published 2026-11-04, updated 2026-11-06. Data URI read as a local file. Rated High. The page now names CVE-2026-121623.
- [GHSA-6prc-h956-hxjq][path] — Symfony, published 2026-11-04. Path prefix escape. Rated High. No CVE.
- [CVE-2026-123792][cve792] — Checkmarx CNA, published 2026-11-06. CVSS 4.0 8.7.
- [CVE-2026-121623][cve623] — Checkmarx CNA, published 2026-11-06. CVSS 4.0 8.2.
- [CISA KEV][kev] — catalog 2026.11.06. Neither CVE is listed.

[yaml]: https://github.com/symfony/symfony/security/advisories/GHSA-hwfg-qwvh-2wfx
[datauri]: https://github.com/symfony/symfony/security/advisories/GHSA-pxj9-jh84-vhm5
[path]: https://github.com/symfony/symfony/security/advisories/GHSA-6prc-h956-hxjq
[cve792]: https://www.cve.org/CVERecord?id=CVE-2026-123792
[cve623]: https://www.cve.org/CVERecord?id=CVE-2026-121623
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
