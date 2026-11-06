# Rails: Active Storage file write and read

**Last updated:** 2026-11-05 (America/New_York)

[Main Rails summary](../black-october-2026.md#rails-active-storage-file-write-and-read) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

**MITRE assigned [CVE-2026-122006](https://www.cve.org/CVERecord?id=CVE-2026-122006) on 2026-11-04 and rates it CVSS 3.1 9.8 Critical** (`CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`). Rails rates the same issue, [GHSA-f3w6-w445-fwh9][ghsa-image], CVSS 3.0 9.8 Critical. The GitHub advisory still says no CVE is known. A Rails application that processes attachments with ImageMagick may let an unauthenticated attacker write arbitrary files, and, when attachments use the Disk service, read files the application process can read. Those files typically include `secret_key_base`. Rails says that can become remote code execution. The record's range is activestorage before 8.0.5.2, and 8.1 before 8.1.4.1. The same releases fix four more High issues that still have no CVE. [Rails blog][blog] [GHSA][ghsa-image] [Record][cve]

**CISA KEV:** Not listed (catalog 2026.11.04, checked 2026-11-05). The four High issues that still have no CVE cannot be listed. Rails does not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [The other High fixes in the same release](#the-other-high-fixes-in-the-same-release)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | Rails credits HackerOne researcher ryotak for the Critical issue. [GHSA][ghsa-image] |
| Public announcement | 2026-11-04 02:58:37 UTC | Mike Dalessio posted the release to oss-security at 2026-11-03 21:58:37 −0500. The blog post is dated November 4 and lists 21 issues. [oss-security][oss] [Rails blog][blog] |
| Fixed gems | 2026-11-04; time/TZ unknown | `activestorage` 8.0.5.2 and 8.1.4.1. Rails 7 and older are unsupported. Security support for 8.0 ends 2026-11-07. [Rails blog][blog] |
| CVE record | 2026-11-04; time/TZ unknown | MITRE published CVE-2026-122006, CVSS 3.1 9.8. The GitHub advisory still says no CVE is known. [Record][cve] |

## The other High fixes in the same release

The blog lists 21 issues. These four are also High, and none has a CVE. The rest of the list is Medium or Low and is not repeated here.

| Advisory | Score | What it is |
|---|---|---|
| [GHSA-v924-7rp8-4mxh](https://github.com/rails/rails/security/advisories/GHSA-v924-7rp8-4mxh) | CVSS 3.1 8.8 High | Active Storage names a tempfile with the uploaded extension. FFmpeg and ImageMagick can then pick a decoder from that extension. An FFmpeg built with AviSynth can treat an `.avs` upload as a script. Common Linux packages do not enable AviSynth; the GPL builds from ffmpeg.org do. |
| [GHSA-wm3x-v3qw-4jh3](https://github.com/rails/rails/security/advisories/GHSA-wm3x-v3qw-4jh3) | CVSS 3.0 7.5 High | `Parameters#each_key` returns the inner hash, so mass assignment accepts it. Rails says the application has to pass that return value to mass assignment. This is an incomplete fix of CVE-2020-8164. |
| [GHSA-8474-xrp6-wh69](https://github.com/rails/rails/security/advisories/GHSA-8474-xrp6-wh69) | CVSS 3.0 7.5 High | `safe_constantize` compiles the requested constant name as a regular expression. Action Cable passes the subscribe channel name to it before authentication, so an unauthenticated client of `/cable` can crash the process. |
| [GHSA-2gff-2mmg-m73p](https://github.com/rails/rails/security/advisories/GHSA-2gff-2mmg-m73p) | CVSS 3.0 7.4 High | Rails 8.1 only. A client-supplied `Forwarded` header can replace `request.remote_ip` when the proxy sets `X-Forwarded-For` and leaves `Forwarded` alone. Rails 8.0 is outside this one. |

## Detection

Read the resolved gem versions. Do not upload a file to test the flaw.

```sh
bundle exec ruby -e 'puts Gem.loaded_specs["activestorage"]&.version'
bundle exec ruby -e 'puts Gem.loaded_specs["actionpack"]&.version'
bundle exec ruby -e 'puts Gem.loaded_specs["activesupport"]&.version'
bundle exec ruby -e 'puts Gem.loaded_specs["rails"]&.version'
```

| Line | Vulnerable | Fixed |
|---|---|---|
| 8.0 | below 8.0.5.2 | 8.0.5.2 |
| 8.1 | 8.1.0 through 8.1.4 | 8.1.4.1 |
| 7.2 and older | unsupported | no backport; move to 8.0.5.2 or 8.1.4.1 |

A version the table does not name is **unknown**, not safe. The Critical issue also needs all three of these: `config.active_storage.variant_processor` is `:mini_magick` (the default on `load_defaults 6.1` or earlier), the host ImageMagick policy does not already deny the coders Rails names, and untrusted users can upload files. An application that meets none of those is outside that one issue and still needs the other High fixes if it is on a vulnerable gem.

Debian and Ubuntu's packaged ImageMagick policies do not deny the coders, Rails says.

## Remediation

1. Upgrade every Rails gem to **8.0.5.2 or later** on the 8.0 line, or **8.1.4.1 or later** on the 8.1 line, then restart every process:

   ```sh
   bundle update rails activestorage actionpack activesupport actionview activejob activemodel activerecord actioncable actionmailer actionmailbox actiontext railties
   ```

   An application whose variant processor is `:mini_magick` must also use **mini_magick 5.1 or later**. An older mini_magick raises during boot after this upgrade. Rails 7 and older get no fix. Security support for 8.0 ends on 2026-11-07.

2. If you cannot upgrade yet, copy the rules from `activestorage/lib/active_storage/image_magick/policy.xml` in a fixed gem into the host policy, for example `/etc/ImageMagick-7/policy.xml`. At a minimum, deny the `MSL` coder, the Ghostscript coders, and the `gs` delegate:

   ```xml
   <policy domain="coder" rights="none" pattern="MSL" />
   <policy domain="delegate" rights="none" pattern="gs" />
   <policy domain="coder" rights="none" pattern="{PS,PS2,PS3,EPS,EPS2,EPS3,EPI,EPSF,EPSI,EPT,EPT2,EPT3,PDF,AI,EPDF,PDFA,POCKETMOD,XPS,PCL}" />
   ```

   That workaround covers the Critical ImageMagick issue only. It does not cover the FFmpeg filename issue, `each_key`, `safe_constantize`, or `Forwarded`. An application that replaces `MiniMagick.cli_env` after boot does not receive the policy the gem ships. GraphicsMagick does not read ImageMagick policies.

3. An application that renders PostScript or PDF through ImageMagick must re-allow the `gs` delegate and the coders it uses after the upgrade, or those conversions stop.

4. If attachments use the Disk service, or if the host FFmpeg was built with AviSynth, change `secret_key_base` and every secret the process could read. Do not keep an exposed secret as a fallback. Changing `secret_key_base` expires sessions and signed URLs.

## Verification

- The four gem versions from Detection are 8.0.5.2 or later, or 8.1.4.1 or later. A lockfile that still resolves an older `activestorage` is not upgraded.
- The running process was restarted after the deploy. A lockfile change does not replace a process that already loaded the old gems.
- On an application that uses `:mini_magick`, boot succeeds. Failure at boot with an older mini_magick means the policy is not applied.
- A normal image upload still stores and displays. That check does not prove the policy is loaded.

## Compromise response

Rails describes what an upload can do. It does not describe a log line that shows an upload already did it.

- If the Disk service was in use on a vulnerable version, treat `secret_key_base`, the master key, `config/credentials.yml.enc`, database credentials, and third-party tokens as exposed. Rotate them, then look for files the application did not write.
- Review upload records and web logs for attachments whose names end in an unexpected extension, such as `.avs`, `.msl`, or `.mvg`. A matching name is a lead, not proof.
- Upgrading does not delete a file an attacker already wrote, and it does not expire a secret that already left.

## Sources

- [Rails 8.0.5.2 and 8.1.4.1][blog] — November 4, 2026. Twenty-one issues. 8.0 security support ends November 7, 2026. Older lines are unsupported.
- [oss-security announcement][oss] — 2026-11-03 21:58:37 −0500 (2026-11-04 02:58:37 UTC).
- [GHSA-f3w6-w445-fwh9][ghsa-image] — Rails CVSS 3.0 9.8 Critical. The advisory text still says no CVE is known. ImageMagick coder policy. Disk-service file read.
- [CVE-2026-122006][cve] — MITRE, published 2026-11-04. CVSS 3.1 9.8. activestorage before 8.0.5.2, and 8.1 before 8.1.4.1.
- [GHSA-v924-7rp8-4mxh](https://github.com/rails/rails/security/advisories/GHSA-v924-7rp8-4mxh) — CVSS 3.1 8.8 High. Filename selects the decoder.
- [GHSA-wm3x-v3qw-4jh3](https://github.com/rails/rails/security/advisories/GHSA-wm3x-v3qw-4jh3) — CVSS 3.0 7.5 High. `each_key` bypasses strong parameters.
- [GHSA-8474-xrp6-wh69](https://github.com/rails/rails/security/advisories/GHSA-8474-xrp6-wh69) — CVSS 3.0 7.5 High. `safe_constantize` compiles untrusted input.
- [GHSA-2gff-2mmg-m73p](https://github.com/rails/rails/security/advisories/GHSA-2gff-2mmg-m73p) — CVSS 3.0 7.4 High. Rails 8.1 `Forwarded` spoofing.
- [CISA KEV JSON feed][kev] — CVE-2026-122006 is not listed (catalog 2026.11.04, checked 2026-11-05). The other four High issues have no CVE.

[blog]: https://rubyonrails.org/2026/11/4/Rails-8.0.5.2-and-8.1.4.1-have-been-released
[oss]: https://www.openwall.com/lists/oss-security/2026/11/04/2
[ghsa-image]: https://github.com/rails/rails/security/advisories/GHSA-f3w6-w445-fwh9
[cve]: https://www.cve.org/CVERecord?id=CVE-2026-122006
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
