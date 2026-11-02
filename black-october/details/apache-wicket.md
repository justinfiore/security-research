# Apache Wicket: November 2026 upload and script-injection fixes

**Last updated:** 2026-11-01 (America/New_York)

[Main Wicket summary](../black-october-2026.md#apache-wicket-upload-limits-and-script-injection) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Apache rates eight flaws in the November 1, 2026 release **CVSS 4.0 High**, from 7.2 to 8.3. NVD has not published its own scores. The fixes are **8.20.0, 9.25.0, and 10.12.0**. The affected range is not the same for every CVE. Two upload flaws exist only on 9.14.0+ and 10.x. One script-injection flaw is 8.x only.

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-02). The advisories do not report exploitation. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [What each CVE covers](#what-each-cve-covers)
- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## What each CVE covers

| CVE | Apache CVSS 4.0 | Affected | What it takes |
|---|---|---|---|
| [CVE-2026-84170](https://www.cve.org/CVERecord?id=CVE-2026-84170) | 8.3 High | `wicket-core` 9.14.0–9.24.0 and 10.0.0–10.9.1 | `FileUploadToResourceField` ignores the upload limit the application set. One unauthenticated request can fill disk or heap. Not in 8.x. Ordinary `FileUploadField` and `AjaxFileDropBehavior` are not this bug. |
| [CVE-2026-83594](https://www.cve.org/CVERecord?id=CVE-2026-83594) | 8.3 High | `wicket-core` 9.14.0–9.24.0 and 10.0.0–10.11.0 | The same upload field trusts a client-supplied file size and allocates it. The application must call `UploadInfo()` rather than only reading it. Not in 8.x. |
| [CVE-2026-95863](https://www.cve.org/CVERecord?id=CVE-2026-95863) | 7.6 High | 8.0.0–8.19.0, 9.0.0–9.24.0, 10.0.0–10.11.0, including `wicket-extensions` | A markup id or component id that contains a quote is written into generated JavaScript. Wicket does not put that character there itself. |
| [CVE-2026-111089](https://www.cve.org/CVERecord?id=CVE-2026-111089) | 7.6 High | 8.0.0–8.19.0, 9.0.0–9.24.0, 10.0.0–10.11.0 | A resource-bundle string is written into generated JavaScript or markup without escaping. |
| [CVE-2026-82956](https://www.cve.org/CVERecord?id=CVE-2026-82956) | 7.6 High | `wicket-core` 8.0.0–8.19.0, 9.0.0–9.24.0, 10.0.0–10.11.0 | Only if the application added `AjaxNewWindowNotifyingBehavior`. The browser-supplied window name is stored and later written out. |
| [CVE-2026-84231](https://www.cve.org/CVERecord?id=CVE-2026-84231) | 7.4 High | `wicket-core` **8.0.0–8.19.0 only** | `ExternalLink` bound to a tag that is not an anchor writes the model URL into an `onclick` handler. Fixed in 8.20.0. 9.x and 10.x are outside this CVE. |
| [CVE-2026-83559](https://www.cve.org/CVERecord?id=CVE-2026-83559) | 7.4 High | `wicket-core` 8.0.0–8.19.0, 9.0.0–9.24.0, 10.0.0–10.11.0 | `JavaScriptUtils.escapeQuotes()` does not escape the backslash, so its output can leave a JavaScript string. Also reachable through `AjaxEditableLabel` when the error text is attacker-controlled. |
| [CVE-2026-83539](https://www.cve.org/CVERecord?id=CVE-2026-83539) | 7.4 High | `wicket-extensions` 8.0.0–8.19.0, 9.0.0–9.24.0, 10.0.0–10.11.0 | `SmartLinkLabel` and `SmartLinkMultiLineLabel` turn a `javascript:` URL in the text into a link. On 9.x and 10.x, Wicket's default Content-Security-Policy stops that script. 8.x has no such policy. |
| [CVE-2026-82840](https://www.cve.org/CVERecord?id=CVE-2026-82840) | 7.2 High | `wicket-auth-roles` 8.18.0–8.19.0, 9.23.0–9.24.0, 10.9.0–10.11.0 | `AuthenticatedWebSession.signIn` renews the session id only the first time a session signs in. A later sign-in on an already signed-in session does not. |

Apache labels [CVE-2026-84170](https://www.cve.org/CVERecord?id=CVE-2026-84170), [CVE-2026-83594](https://www.cve.org/CVERecord?id=CVE-2026-83594), [CVE-2026-82956](https://www.cve.org/CVERecord?id=CVE-2026-82956), and [CVE-2026-84231](https://www.cve.org/CVERecord?id=CVE-2026-84231) important, and [CVE-2026-83559](https://www.cve.org/CVERecord?id=CVE-2026-83559), [CVE-2026-83539](https://www.cve.org/CVERecord?id=CVE-2026-83539), and [CVE-2026-82840](https://www.cve.org/CVERecord?id=CVE-2026-82840) moderate. The numeric scores above are still High. [CVE-2026-95863](https://www.cve.org/CVERecord?id=CVE-2026-95863) and [CVE-2026-111089](https://www.cve.org/CVERecord?id=CVE-2026-111089) are published with the score and no separate word label on the pages reviewed.

## Timeline

| Event | Date and time (timezone) | Notes and source |
|---|---|---|
| Private discovery | Unknown | The advisories credit Emond Papegaaij and Pedro Santos as finders. They do not give a private-report date. |
| Public advisories | 2026-11-01, from 22:05 UTC | Eight messages on announce@wicket.apache.org. [Upload-limit advisory][cve-84170-mail] |
| Fixed releases | 2026-11-01; exact tag time not established on the advisory pages | 8.20.0, 9.25.0, and 10.12.0. |

## Detection

1. Inventory `org.apache.wicket:wicket-core`, `wicket-extensions`, and `wicket-auth-roles` from the build, not from a running page title. A shaded jar can hide the version.
2. Map the running line to the table above. An application on 10.12.0, 9.25.0, or 8.20.0 is on the fixed release. An application on 7.x or older is out of support; Apache's instruction for the script-injection flaws is to move to a supported line.
3. The upload flaws matter only where the application mounts `FileUploadToResourceField`. The window-name flaw matters only where the application adds `AjaxNewWindowNotifyingBehavior`. The 8.x-only link flaw matters only where `ExternalLink` is bound to a non-anchor tag. Absence of those uses is a deployment fact, not something this guide can see.
4. Apache did not publish compromise indicators. A vulnerable jar is exposure.

## Remediation

1. Upgrade every Wicket module on a line together: **10.12.0 or later**, **9.25.0 or later**, or **8.20.0 or later**. Rebuild and redeploy. Do not upgrade `wicket-core` and leave `wicket-extensions` or `wicket-auth-roles` behind.
2. On 7.x or older, move to one of those lines. There is no 7.x fix.
3. Until the new build is running, renew the session id from application code on every successful authentication, at the end of `authenticate(String, String)`. Use the call named in the [advisory][cve-82840-mail]; the public copy of that page drops the method name. The advisories give no workaround for the upload or script-injection flaws.
4. Do not probe a production app with oversized uploads or quote-bearing component ids.

## Verification

- Confirm the deployed artifacts, including shaded copies, are 8.20.0, 9.25.0, or 10.12.0 or later.
- Exercise an ordinary file upload and an ordinary signed-in page after the deploy. Do not send an exploit payload.
- If the application uses `AuthenticatedWebSession`, sign in twice on one session in a test environment and confirm the container session id changes both times.

## Compromise response

If an untrusted client could reach `FileUploadToResourceField` on an affected build, review disk and heap incidents and unexpected files written through that resource. If component ids, resource-bundle strings, or `SmartLink` text included untrusted data, review access logs for the injected requests and rotate session secrets after the upgrade. The upgrade stops the paths. It does not show whether they were used.

## Sources

- [CVE-2026-84170 advisory][cve-84170-mail] — upload limits, 8.3, 9.14.0–9.24.0 and 10.0.0–10.9.1, fix 9.25.0 or 10.12.0.
- [CVE-2026-83594 advisory][cve-83594-mail] — client-asserted upload size, 8.3, through 10.11.0.
- [CVE-2026-95863 advisory][cve-95863-mail] — markup id script injection, 7.6, includes 8.x, fix also 8.20.0.
- [CVE-2026-111089 advisory][cve-111089-mail] — resource-bundle script injection, 7.6.
- [CVE-2026-82956 advisory][cve-82956-mail] — window name, 7.6, behavior must be added by the application.
- [CVE-2026-84231 advisory][cve-84231-mail] — ExternalLink, 7.4, 8.x only.
- [CVE-2026-83559 advisory][cve-83559-mail] — escapeQuotes, 7.4.
- [CVE-2026-83539 advisory][cve-83539-mail] — SmartLinkLabel, 7.4, CSP note for 9.x and 10.x.
- [CVE-2026-82840 advisory][cve-82840-mail] — session id renewed only on first sign-in, 7.2, narrow ranges.
- [CISA KEV JSON feed][kev] — catalog 2026.10.30 status.

[cve-84170-mail]: https://lists.apache.org/thread.html/bw3hn5cch3q7yrsl05m8mvmgyx4m98y7
[cve-83594-mail]: https://lists.apache.org/thread.html/h5lxspxg746pzjd437n3n7mq5t3sfbcb
[cve-95863-mail]: https://lists.apache.org/thread.html/5wg754b873tlnsc268myrwcoy9lt046v
[cve-111089-mail]: https://lists.apache.org/thread.html/xyp4sm5mm7s618fktstb22577qxbmqw8
[cve-82956-mail]: https://lists.apache.org/thread.html/fs3vdddt9bwshdstj952psj49s5w4vqm
[cve-84231-mail]: https://lists.apache.org/thread.html/39kz9838w25797bpkxn1hvfsm8jtc4zv
[cve-83559-mail]: https://lists.apache.org/thread.html/77kc85ztkxdpp7wg7cv61c4539j9s1g3
[cve-83539-mail]: https://lists.apache.org/thread.html/xqdymd8g178sc112lmqbp53zlss53cwz
[cve-82840-mail]: https://lists.apache.org/thread.html/q812kjb74x2pt6956w0pcmkc4wwj95l9
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
