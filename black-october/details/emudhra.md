# eMudhra / emSign: compromised intermediate CA keys

**Last updated:** 2026-10-26 (America/New_York)

[Back to eMudhra summary](../black-october-2026.md#emudhra--emsign) · [Changelog](../../Changelog.md)

Eight P-384 intermediate CA keys were trivially recoverable: **six TLS and two code-signing keys**, with additional cross-signed certificates carrying the same keys. This is defective CA key generation, not a general break of TLS or proof that every eMudhra product was breached. Clients trusting these keys could accept fraudulent certificates even when their own servers use another CA.

## Timeline

Times below are UTC where specified; release dates without times follow the publishing vendor. Revocation publication, browser protection, and installed-client remediation are different events.

| Date | Event and evidence |
| --- | --- |
| 2025-04-30 | Affected intermediates created in a key ceremony, according to Mozilla and eMudhra in the incident record. Earlier malicious key recovery, if any, is **unknown**. |
| 2026-10-17 16:27; 18:05 | Researcher's private discovery; private report emailed to eMudhra and root programs, respectively (Bugzilla comment 2). Mozilla received the forwarded report at 20:06 and independently recovered keys at 21:48. |
| 2026-10-17 22:59 | Mozilla completed OneCRL distribution for Firefox with standard configurations. This was not an update to every application using Mozilla-derived CA data. |
| 2026-10-18 09:24:32–09:38:46 | eMudhra revoked the eight original intermediates with `cACompromise` (comment 10). |
| 2026-10-18 12:06 | Public Bugzilla incident opened, according to the researcher's timeline. This predates the vendor's public statement. |
| 2026-10-19 14:55 | Sectigo reported completion of cross-certificate revocation; new CRL/OCSP data was propagating to CDN edges (comment 13). |
| 2026-10-19 | Go release history dates **1.27.3 / 1.26.10** to this day: `crypto/x509` blocking, **CVE-2026-111943**. The linked Google Groups announcement displays October 20; use release history for the release date. |
| 2026-10-20 | Mozilla public security post and Firefox **158.0.1**, ESR **115.43.1 / 153.5.1** releases; NSS **3.131.1** trust-list update announced. eMudhra's statement was first published this day. |
| 2026-10-21 08:29 | Firefox Android **158.0.2** released to fix some clients not immediately applying bundled OneCRL changes after startup. Do not stop Android remediation at 158.0.1. |
| 2026-10-22 | eMudhra announced withdrawal from global TLS issuance and offered Sectigo replacement certificates. This is a transition announcement, not universal root removal. |
| 2026-10-26 | eMudhra leadership acknowledged a script error and promised full root-cause analysis and independent review. Completion dates for that review and universal client protection remain **unknown**. |

**Corrections and limits:** The current eMudhra statement now says notification October 17 and revocation October 18; older October 18/19 dates were challenged in Bugzilla comment 35. The precise correction time is not published. Its shorthand “eight TLS” must not replace Mozilla's six-TLS/two-code-signing inventory. The wrap/unwrap explanation remains preliminary, not proof of an HSM hardware defect.

## Detection

1. Inventory **relying clients**, not only hosted certificates: browsers, OS stores, Java truststores, Python/application bundles, containers, Go executables, CI downloaders, mobile apps, and appliances. Record the effective trust source and update owner for each.
2. Compare stored/presented intermediate certificates with the SHA-256 fingerprints and issuer/serial pairs in the [incident description and comment 2](https://bugzilla.mozilla.org/show_bug.cgi?id=2083449#c2). Include Sectigo cross-signs; the original and cross-signed certificates have different fingerprints despite sharing compromised keys.
3. Names such as `EM DV TLS CA - G3B` are search clues, not identity checks. Cover DV/OV/EV TLS G3B/G3C and OV CS G3B/G3C; inspect alternate chain paths rather than just the first chain a server sends.
4. Read a saved public certificate on a clean analysis host without executing the source application:

   ```sh
   openssl x509 -in /mnt/snapshot/certificates/issuer.pem -noout -subject -issuer -serial -fingerprint -sha256
   ```

5. Inspect Go executable build metadata using the separate `stack-inventory.sh go /path/to/binary` companion script from a trusted environment. A patched compiler on the build machine does not establish the build version of a deployed executable.
6. Review historical TLS/proxy telemetry, certificate-transparency alerts for your domains, code-signing verification records, and downloaded artifact hashes. Unexpected issuers, certificate changes, or signatures warrant investigation; CT cannot prove that an unlogged certificate never existed.

**Impact assessment:** eMudhra says it issued no end-entity certificates from the affected intermediates. That does not prevent other holders of recovered keys from issuing them. Bugzilla comment 44 reports post-disclosure proof-of-concept certificates in CT; those counts were not independently reproduced here and do not establish real victim interception. Missing TLS/certificate telemetry leaves historical impersonation **unknown**.

## Remediation

1. Update OS/browser/application trust data using each distributor's supported channel. Confirm intermediate blocking or the relevant root removal is actually enforced; a generic CA-bundle update may not incorporate OneCRL or cover cross-sign paths.
2. Deploy the Firefox/ESR fixes above or later supported releases, including the Android 158.0.2 follow-up. Update NSS consumers separately; Firefox's remotely delivered OneCRL is not a global operating-system revocation list.
3. Rebuild and redeploy Go programs with **1.27.3 / 1.26.10 or a later supported fixed toolchain**. Obtain an explicit backport statement for vendor builds; refresh images and replace old running processes as well as build caches.
4. For opaque appliances, pinned CA bundles, Java stores, and custom TLS libraries, require vendor confirmation covering affected keys and alternate chains. If protection cannot be established, restrict sensitive outbound operations or apply an approved targeted distrust policy pending an update. Never disable TLS verification to restore service.
5. Replace any deployed certificate whose chain is affected by compromise or resulting distrust, using a verified unaffected hierarchy. eMudhra's October 22 update offers Sectigo replacements through CertiNext or support. Inspect the **actual replacement chain**; a CA brand alone is not evidence of safety.
6. Preserve public certificates and relevant logs before changes. Do not import a compromised intermediate as a trust anchor to make an application work. Do not assume cached CRLs, leaf-only OCSP checks, or successful HTTPS requests establish protection.

## Verification

- Record each deployed trust-store package/build, update time, effective bundle path, running application version, and verification owner. Include embedded/offline copies and custom settings that disable updates.
- In an isolated test environment, use approved known affected certificate-chain fixtures with the **same verifier and policy as production**. Require rejection of affected original and cross-signed paths; a random expired certificate failing is not a meaningful test of the new block.
- Run an unaffected valid-chain control and confirm hostname verification remains enabled. For code-signing consumers, test their signing-policy trust separately from TLS; timestamp and signature policy may differ.
- Verify rebuilt Go artifact metadata on the deployment itself, restart/redeploy, and confirm traffic comes from the new instances. Updating `go` alone is insufficient.
- Check that replacement server chains work for supported clients without restoring distrusted anchors. Record vendor evidence or an explicit **unknown** for clients you cannot test.
- Revocation at the CA is not proof that every client fetched or enforced it. The source record also raises CRL availability and caching concerns; this guide does not certify current CRL/OCSP reachability or universal trust-store coverage.

## Compromise response

- CA-key compromise alone does **not** demonstrate theft of your leaf private key, stored passwords, or past TLS session keys. Avoid claiming passive decryption of all recorded traffic; assess actual interception and endpoint exposure.
- If fraudulent certificates or interception are suspected, preserve certificate chains, timestamps, destination/DNS/proxy logs, downloaded binaries, and relevant authentication records. Investigate the network path and affected endpoints before returning them to service.
- From a clean client with verified trust, revoke tokens, API keys, passwords, and sessions that may have traversed impersonated services. Replace local private keys if endpoint compromise exposed them; rotate application signing/session secrets where downstream takeover is plausible.
- For suspicious signed software, quarantine the artifact, compare with independently authenticated publisher hashes/provenance, and rebuild compromised hosts. A valid signature under an affected chain is not sufficient publisher authentication.
- Review identity-provider and service audit logs for misuse after the suspected interception, invalidate attacker-created sessions/keys, and assess notification obligations. Trust-store remediation prevents future acceptance; it does not undo actions taken with already stolen credentials.

## Sources

- [Mozilla incident record, including eMudhra and Sectigo responses](https://bugzilla.mozilla.org/show_bug.cgi?id=2083449): exact identities, discovery, revocations, open questions, and separately attributed community findings.
- [Mozilla security post, including Android correction](https://blog.mozilla.org/security/2026/10/20/protecting-firefox-users-following-the-compromise-of-emudhra-intermediate-certificates/).
- [Go security announcement](https://groups.google.com/g/golang-announce/c/66pojueaQek) and [Go release history](https://go.dev/doc/devel/release): mitigation scope and release dates.
- [eMudhra statement, updated October 26](https://emudhra.com/en/post/certificate-security-incident) and [October 22 TLS-business exit announcement](https://emudhra.com/en/press-release/emudhra-to-exit-global-ssl-tls-certificate-business).

Sources freshly read on the update date. These are published findings and response procedures, not a forensic assessment of your systems; final root-cause evidence and per-client enforcement evidence were unavailable.
