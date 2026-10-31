# Security updates

[Main guide](black-october/black-october-2026.md#table-of-contents)

New findings, corrected impact assessments, patch releases, and detection or remediation guidance, newest first. Follow each link to the affected issue. Timestamps show when information was added to the guides, not when the vulnerability was discovered.

## 2026-10-31 08:30 EDT (UTC−04:00) — Northflank secrets; LiteLLM signing key; Drupal lab chain

- **Northflank:** If you stored secrets there, [revoke them at each issuer and redeploy](black-october/details/northflank.md#remediation). Northflank says to assume every environment variable was decrypted after a Wiz alert on October 30, and users report their AI API keys were used. The incident is still open. There is no CVE and no software update to install. Audit logs turned on October 31 do not cover earlier activity.
- **LiteLLM:** The vendor now says the [previous image-signing key's private half was exposed](black-october/details/litellm.md#verification). Verify 1.106.3 and later with the new key. Trust an old-key signature only on an image published before the 1.107.0 release, and still match the digest: the compromised images were signed with that key too.
- **Drupal:** A public lab reconstruction of the Field UI flaw now exists. It uses a synthetic module, fails on 11.4.10, and is not a report of attacks. The fix is unchanged: [11.4.10, 11.3.19 or 10.6.19](black-october/details/drupal.md#remediation). Drupal's own rating is still Theoretical.
- **Ivanti Connect Secure:** The stack decision row now matches the item. Install [25.1.1.3 or 22.8R2.6](black-october/details/ivanti-connect-secure.md#remediation). The older 25.1.1.2 and 22.8R2.5 builds fix only the original authentication bypass.

## 2026-10-31 04:15 EDT (UTC−04:00) — LiteLLM Enterprise file read; WordPress CVE; Debian TCP kernels

- **LiteLLM Enterprise:** Upgrade a proxy that loads an Enterprise license to [1.106.5, or 1.105.6 / 1.104.8 / 1.103.10](black-october/details/litellm-enterprise-file-read.md#remediation). LiteLLM rates an unauthenticated file read 10.0 Critical: one request can send `/proc/self/environ`, including the master key, to an attacker URL. Open-source installs without a license are not affected. This is not the 1.107.0 malware release. No CVE is assigned.
- **WordPress:** The upgrade-window flaw is now [CVE-2026-119977](black-october/details/wordpress-upgrade-window.md#timeline). Wordfence rates it 8.1 High; WordPress's own advisory still says Low and "No known CVE." The fix is unchanged: 7.1.4 or the fixed release for your branch. Confirm the update finished. Wordfence's counts are probes, not confirmed compromises, and the CVE is not in KEV.
- **Linux kernel (CVE-2026-98432):** Debian already shipped fixed kernels. Install [trixie `linux` 6.12.113-1 or bookworm `linux` 6.1.190-1](black-october/details/linux-tcp-options.md#remediation) and reboot. Ubuntu and Red Hat still have no kernel fix; Red Hat's nftables filter is not a substitute.
- **PAN-OS / Brotli:** Do not stop at [11.2.10-h16](black-october/details/brotli.md#pan-os). That build fixes only PHP. Brotli needs 11.2.10-h17 or the other branch hotfix. Prisma Cloud and Strata Cloud Manager are on the SaaS list Palo Alto is fixing itself.

## 2026-10-31 01:15 EDT (UTC−04:00) — Ubuntu Brotli packages

- **Brotli on Ubuntu:** Install [USN-8956-1](black-october/details/brotli.md#remediation) and restart every process that loaded `libbrotli`. 26.10 gets `libbrotli1` 1.2.0-4ubuntu0.1, 26.04 gets 1.2.0-3ubuntu0.1, 24.04 gets 1.1.0-2ubuntu0.1, and 22.04 gets 1.0.9-2ubuntu0.1. Those version numbers are backports, not upstream 1.2.1. Ubuntu Pro covers 20.04, 18.04 and 16.04. The Arrow source fix is merged, but no fixed Arrow release exists yet.

## 2026-10-31 00:45 EDT (UTC−04:00) — SAP SDK second range; OpenShift and RHEL 6 kernels

- **SAP Cloud SDK for Python:** Upgrade to [0.55.1 or later](black-october/details/sap-cloud-sdk-python.md#remediation), not only 0.45.2. SAP's CVE record now lists a second affected range, 0.53.0 through 0.55.0, for the same Critical OAuth credential leak. Restage every instance.
- **Linux kernel (PwnEscape):** Red Hat shipped fixes on October 27 for [RHEL 6 ELS and OpenShift RHCOS 4.12 through 4.22](black-october/details/pwnescape.md#fixed-versions-and-backports) (not 4.13, 4.15 or 4.17). Update those clusters and reboot the nodes. OpenShift Container Platform 5 and general RHEL 9 `kernel-rt` are still unfixed.

## 2026-10-31 00:15 EDT (UTC−04:00) — Gravity Forms object injection

- **Gravity Forms:** Update to [3.1.3 or later](black-october/details/gravity-forms.md#remediation). Wordfence rates CVE-2026-103039 9.8 Critical: an unauthenticated visitor can store a PHP object in post meta when a form creates posts from a List field with a content template. The plugin has no gadget chain. Wordfence says WordPress supplies one if that field maps to `_wp_page_template`, and that this becomes code execution only on hosts with a readable PEAR install and `register_argc_argv` enabled. It is not in KEV, and neither Wordfence nor Patchstack reports exploitation.

## 2026-10-30 20:15 EDT (UTC−04:00) — Chrome 156 follow-up; WS_FTP Web Admin flaw; Red Hat TCP filter

- **Chrome:** Update desktop Chrome to [156.0.8078.79 or later](black-october/details/chrome-156.md#remediation) (Windows and Mac also list .80). The October 27 builds do not include Critical CVE-2026-76024, memory corruption in MediaStream. Google does not report exploitation. The CVE record has no CNA score; CISA's enrichment is 6.5 Medium, which is not Google's rating.
- **Progress WS_FTP Server:** Stay on [2024.0.7 or 2025.0.4](black-october/details/progress-wsftp.md#remediation). Progress also rates CVE-2026-90867 8.1 High: improper access control in the Web Admin console, fixed in those same builds. 2024.0.6 and 2025.0.3 fix only the earlier authentication flaw. The vendor article is login-gated; the score and range are from Progress's CVE record.
- **Linux kernel (CVE-2026-98432):** Red Hat published a temporary [nftables filter](black-october/details/linux-tcp-options.md#remediation) that drops incoming IPv4 TCP packets containing IP options. It reduces exposure and is not a kernel fix. Install a vendor kernel that names the CVE when one exists, then reboot and remove the filter.

## 2026-10-30 16:15 EDT (UTC−04:00) — Synology DSM ransomware wave; Ivanti chained flaws added to KEV

- **Synology DSM:** Upgrade to [7.4-90075, 7.3.2-86009-4, 7.2.2-72806-9, or 7.2.1-69057-12 or later](black-october/details/synology-dsm.md#remediation) and keep DSM and SSH off the internet until that build is running. Synology rates two unauthenticated flaws Critical (CVSS 3.1 9.8) and lists no workaround. 360 reports October ransomware through those flaws; Synology's same-day statement instead points to a vulnerability patched in December 2024. A current build covers both, and files renamed `.L0CK3D` are the reported ransomware marker.
- **Ivanti Connect Secure:** CISA added the chained flaws to KEV on October 30. [CVE-2026-111357](black-october/details/ivanti-connect-secure.md#remediation) is due November 2 and requires forensic triage; CVE-2026-118527 is due November 13. Install **25.1.1.3** or **22.8R2.6**. The earlier 25.1.1.2 and 22.8R2.5 builds fix only the original authentication bypass.
- **Linux local root (skb_zerocopy):** CloudLinux 7 hybrid and 8 production kernels are out: [4.18.0-553.177.1.lve.1.el7h and 4.18.0-553.177.1.lve.1.el8](black-october/details/skb-zerocopy-lpe.md#fixed-kernels-and-live-patches). They were beta yesterday. Reboot into them. CloudLinux 8 ELS and 9 ELS are still pending.
- **PAN-OS / Brotli:** Palo Alto's advisory also covers Prisma Cloud Application Security Transporter Client before 0.2.9. Upgrade that client to [0.2.9 or later](black-october/details/brotli.md#pan-os); the firewall hotfix does not update it.

## 2026-10-30 12:05 EDT (UTC−04:00) — WordPress core upgrade race; PAN-OS hotfixes; Linux TCP lab exploit and Go stopgap

- **WordPress:** Update core to [7.1.4 or the fixed release for your branch](black-october/details/wordpress-upgrade-window.md#remediation). Wordfence rates an unauthenticated race during a full-package upgrade 8.1 High: attackers are already polling the predictable staging path, though the window lasts seconds and no compromise is confirmed. WordPress 4.6 and older get no fix. Confirm the update finished; a firewall plugin does not see the request.
- **PAN-OS / Panorama:** Palo Alto has now released a PHP2Shell hotfix for [every supported branch](black-october/details/php2shell.md#timeline), including the builds that were still ETAs on October 27. Install the one for your train and keep management access restricted until it is on. The same day's Brotli advisory releases the remaining 11.2 and 12.1 hotfixes; install those where Brotli inspection is enabled.
- **Linux kernel (CVE-2026-98432):** Red Hat's public score is now 9.8, matching kernel.org. Anthropic demonstrated remote root in a lab against a multipath TCP listener and did not publish the exploit. Go 1.24+ turns that listener on by default; `GODEBUG=multipathtcp=0` blocks that shape and [is not a kernel fix](black-october/details/linux-tcp-options.md#sources). Install a vendor kernel that names the CVE, then reboot.
- **GitLab:** The October 29 releases (19.5.3 and the matching older branches) [drop the compromised eMudhra intermediates](black-october/details/gitlab-ruby.md#remediation). They do not replace the regex remote-code-execution fixes. Also update self-hosted Runner to 19.5.1 and AI Gateway to its fixed release; a GitLab upgrade updates neither.
- **Linux local root (skb_zerocopy):** CloudLinux 9 and 10 now have [production kernels](black-october/details/skb-zerocopy-lpe.md#fixed-kernels-and-live-patches), the same builds as AlmaLinux. Reboot into the fixed kernel. CloudLinux 7 hybrid and 8 moved to production later the same day; see the newer entry above.
- **headscale:** Upgrade to [0.29.7](black-october/details/tailworm.md#remediation) and keep Tailscale nodes on v1.104.4 or later. The headscale release does not apply the node SSH and Serve fixes.
- **NGINX on Ubuntu:** Install the [USN-8955-1 packages](black-october/details/nginx.md#distribution-packages) (22.04, 24.04, 26.04 and 26.10) and reload nginx. Upstream version numbers alone do not show the backport.
- **Drupal Commerce:** The affected 3.x range is everything before 3.3.13, [including 3.2.x and 3.3.0–3.3.12](black-october/details/drupal-commerce.md#detection), not only through 3.1.x. The advisory page is dated October 28.

## 2026-10-30 11:05 EDT (UTC−04:00) — Telegram, Edge and Mitsubishi ICONICS added; PHP2Shell, Node2Shell, PAN-OS GlobalProtect and Oracle EBS exploitation updates

- **Telegram:** Update Desktop to [7.2.9+](black-october/details/telegram-clients.md#remediation), which fixes the one-click session-file theft CVE-2026-107181 (8.6 High). Also update Android to 12.10.4+, where the source no longer uses the rlottie sticker renderer behind ZDI's unpatched CVE-2026-111105 (7.0 High) and NebuSec's unscored call flaw is fixed. iOS status is unconfirmed, and old Desktop installs that may have been targeted should terminate other sessions.
- **Microsoft Edge:** Confirm every install is on [148.0.3967.70 or later](black-october/details/edge-pwn2own.md#remediation). Orange Tsai's newly published Pwn2Own chain goes from a web page to code execution on Windows using logic bugs only; Microsoft rates the RCE link CVE-2026-45495 8.8 Important (NVD 9.8) and reports no exploitation.
- **Mitsubishi Electric ICONICS SCADA:** Update ICONICS Suite to 10.98+, GENESIS to 11.04+ and IoTWorX to 10.98+ for the [shared unlock response and DCOM permission flaws](black-october/details/mitsubishi-iconics-genesis.md#remediation) (Mitsubishi CVSS 4.0 up to 9.4). MC Works64, GENESIS32 and BizViz will not be fixed; apply the challenge-file workaround and network restrictions.
- **PHP2Shell:** Dream's [PHP2Shell + Fragnesia chain](black-october/details/php2shell.md#exploitation-status) rooted 24 PAN-OS firewalls and a management server, then attacked Active Directory; Morphisec reports post-exploitation on a Windows IIS / PHP-CGI server. Patch PHP and the kernel, and hunt with the [PAN-OS and IIS indicators](black-october/details/php2shell.md#look-for-suspicious-execution).
- **PAN-OS GlobalProtect:** Ransomware operators (Qilin, Inc) and the k0t campaign are exploiting the unauthenticated GlobalProtect bypass CVE-2026-0257 to open VPN sessions; it has been in KEV since May. Upgrade every portal and gateway that uses authentication-override cookies to the [fixed builds](black-october/details/pan-os.md#related-globalprotect-cve-2026-0257-exploited-by-ransomware-operators-and-k0t), or disable override until then, and search GlobalProtect logs for Unit 42's indicators.
- **Node.js / Brotli (Node2Shell):** ELLIO reproduced RCE on the official Node.js 24.22.0 x86-64 build and recorded an [in-the-wild exploit attempt against it](black-october/details/brotli.md#operational-signals-and-evidence-limits) on 2026-10-26. Upgrade to 24.22.1 or another fixed release, and investigate Node worker crashes after large `br` request bodies.
- **Oracle E-Business Suite:** Attackers began probing [CVE-2026-101767](black-october/details/oracle-cpu-october.md#log-and-host-review) on 2026-10-27, according to Defused's honeypots; no successful compromise has been reported and it is not in KEV. Apply the October CPU to internet-facing EBS now, and review web tiers that were unpatched on or after that date.
- **Fortinet FortiGate / FortiWeb:** The k0t campaign brute-forces FortiGate logins, exploits the older FortiWeb CVE-2025-64446 and decrypts downloaded configurations with the default key. Patch FortiWeb, enable `private-data-encryption` and [rotate credentials stored in exposed configurations](black-october/details/fortinet-october.md#compromise-response).
- **eMudhra / emSign:** On Macs, built-in curl, git and python3 [still trust the affected chains through /etc/ssl/cert.pem](black-october/details/emudhra.md#containers-os-stores-and-alternate-copies) until Apple ships a macOS update; Cisco customers should check each product in [Cisco's interim advisory](black-october/details/emudhra.md#remediation), where several fixes are only scheduled.
- **Laravel:** CISA's [SSVC enrichment](black-october/details/laravel.md#timeline) rates the TokenGuard bypass Technical Impact total, not automatable, with no exploitation recorded; a public PoC still exists, so keep upgrading to 12.68.0+ / 13.29.0+.
- **ImageMagick:** The newer 7.1.2-34 and 6.9.13-59 releases do not change the [bzip2 overflow fixed versions](black-october/details/imagemagick.md#remediation); stay on 7.1.2-33 / 6.9.13-58 or later.

## 2026-10-30 08:04 EDT (UTC−04:00) — WS_FTP, Linux TCP and Jenkins Critical/High disclosures

- **Progress WS_FTP Server:** Upgrade Windows servers to [2024.0.7 or 2025.0.4](black-october/details/progress-wsftp.md#remediation). Progress rates the disclosed authentication and command-injection flaws Critical (10.0 and 9.9); the newer release covers both.
- **Linux kernel:** Track a vendor-fixed kernel for [CVE-2026-98432](black-october/details/linux-tcp-options.md#remediation) and reboot when available. kernel.org rates the IPv4 TCP race 9.8 Critical; Red Hat and Ubuntu list affected products without a released fix at this review.
- **Jenkins:** Upgrade core controllers to [weekly 2.588 or LTS 2.580.2](black-october/details/jenkins-october.md#remediation) for the October High-severity bundle, then validate trusted job and agent workflows.
- **Ivanti Connect Secure:** The chained local escalation now has [Ivanti-supported fixed versions](black-october/details/ivanti-connect-secure.md#remediation): 25.1.1.3 and 22.8R2.6. Earlier CVE-2026-104935 fixes alone do not cover it.
- **Wasmtime:** Microsoft now identifies [Azure Linux 3.0 Rust packages](black-october/details/wasmtime.md#remediation) as known affected by CVE-2026-115889 with no fix; isolate untrusted Wasm compilation until a fixed package is available.

## 2026-10-30 04:05 EDT (UTC−04:00) — Five High/Critical guides added

- **Drupal Commerce Core:** Update to [3.3.13 or 8.x-2.41](black-october/details/drupal-commerce.md#remediation) and audit orders for inconsistencies; Drupal reports active exploitation of the highly critical access bypass CVE-2026-118539.
- **n8n:** Shared-workflow deployments should update to [the fixed branch release](black-october/details/n8n-credential-guard.md#remediation) for CVE-2026-118675 and review editor access to restricted credentials.
- **Wing FTP Server and Juniper Session Smart Router:** Upgrade to [Wing FTP 8.2.6+](black-october/details/wing-ftp.md#remediation) and the [applicable Juniper fixed release](black-october/details/juniper-session-smart.md#remediation); restrict privileged administration and provisioning interfaces during rollout.
- **Linux kernel:** Install a vendor-fixed kernel for [CVE-2026-98432](black-october/details/linux-tcp-rcu.md#remediation) and reboot. Do not infer distribution patch status from upstream version strings alone.

## 2026-10-30 04:05 EDT (UTC−04:00) — KEV confirmations and PHP2Shell exploitation update

- **Cisco Secure Firewall ASA / FTD:** CISA has added [CVE-2026-76418 to KEV](black-october/details/cisco-secure-firewall-vpn.md#timeline); apply Cisco’s fixed release and prioritize the federal due-date urgency signal.
- **GitLab:** CISA has added [CVE-2026-97229 to KEV](black-october/details/gitlab-ruby.md#timeline). Update self-managed instances to a supported patched release and review GitLab’s threat detections for historic attempts.
- **PHP2Shell / PAN-OS:** Palo Alto now confirms exploitation against internet-exposed PAN-OS management interfaces and a chained root campaign. Apply the [branch-specific hotfixes and restrict management access](black-october/details/php2shell.md#remediation), then investigate exposed appliances.

## 2026-10-29 08:03 EDT (UTC−04:00) — Cisco exploitation updates and Ultralytics model-file code injection

- **Cisco Secure Firewall ASA / FTD:** Upgrade Remote Access SSL VPN deployments to [Cisco's first fixed release for their train](black-october/details/cisco-secure-firewall-vpn.md#remediation). Cisco reports active exploitation of CVE-2026-76418, which can reload an appliance when secondary authentication is configured; use Cisco's temporary mitigation only after evaluating its VPN and security impact.
- **Cisco Catalyst SD-WAN:** Upgrade Controller, Manager and Validator components to the [listed fixed release](black-october/details/cisco-sdwan-keydrift.md#remediation), restrict ports 22 and 830 to known peers, and investigate unexplained `vmanage-admin` authentication or peering events. Cisco linked limited exploitation to Talos's KeyDrift investigation, which includes persistence and key-material theft evidence.
- **Ultralytics:** Do not open untrusted model files in affected workflows. [CVE-2026-118618](black-october/details/ultralytics-parse-model.md#remediation) lets an opened malicious model execute Python code as the current user; no vendor fixed-version statement is established.
- **Supermicro BMC:** Apply the higher applicable firmware version in both [October 26 advisory tables](black-october/details/supermicro-bmc.md#remediation). The separate High CVE-2026-16521 syslog command injection can execute an administrator-supplied payload after the related service restarts; keep BMCs isolated and restrict privileged access.

## 2026-10-29 04:03 EDT (UTC−04:00) — Tabularis MCP SQL injection and AlmaLinux kernel fixes

- **Tabularis:** Upgrade to [0.28.0 or later](black-october/details/tabularis.md#remediation). CVE-2026-118378 can let attacker-influenced MCP tool calls modify or delete SQLite data despite Tabularis read-only mode and write approval.
- **Linux skb_zerocopy:** AlmaLinux 9 and 10 now have [production fixed kernels](black-october/details/skb-zerocopy-lpe.md#fixed-kernels-and-live-patches): `5.14.0-687.60.1.el9_8` and `6.12.0-211.69.1.el10_2`. Install the appropriate vendor kernel and reboot; the Dirty Frag fix alone does not cover this local root path.
- **Railway:** [Recovery remains in monitoring](black-october/details/railway.md#timeline) and new signups remain paused. Continue issuer-side secret rotation and verify platform recovery before placing replacement secrets there.

## 2026-10-29 00:03 EDT (UTC−04:00) — Adobe Critical updates and eMudhra Windows response

- **Adobe Campaign Classic:** Update fully on-premise and hybrid components to [7.4.4 build 9403](black-october/details/adobe-campaign-classic.md#remediation), then restart `nlserver`. Adobe fixed eight Critical CVEs in build 9402 and earlier; Adobe-hosted instances were remediated by Adobe.
- **Adobe Connect:** Update Desktop to [the platform-specific fixed release and Android Mobile to 4.5](black-october/details/adobe-connect.md#remediation) for the Critical code-injection CVE-2026-48360, then relaunch the desktop client.
- **eMudhra / emSign:** Apply the [Microsoft Windows and Edge trust updates](black-october/details/emudhra.md#net--c) where applicable, but continue to inventory Linux, custom and bundled stores separately. eMudhra says Sectigo replacements are available; do not infer universal protection from a platform update.

## 2026-10-28 16:00 EDT (UTC−04:00) — Chrome and EDK II Critical disclosures

- **Chrome 156:** Update desktop Chrome to [Google's fixed builds](black-october/details/chrome-156.md#remediation) and relaunch. Google lists four Critical vulnerabilities: CVE-2026-118306, CVE-2026-118331, CVE-2026-118344 and CVE-2026-118348.
- **TianoCore EDK II:** Isolate PXE provisioning networks and [obtain an OEM firmware update](black-october/details/edk2-pxe.md#remediation) for CVE-2026-97631. The upstream advisory lists a source fix but no patched EDK II release.

## 2026-10-28 20:04 EDT (UTC−04:00) — Bandit HTTP/2 request-body fix

- **Linux Fragnesia:** CISA added [CVE-2026-46300 to KEV](black-october/details/linux-fragnesia.md#timeline), reporting active exploitation and a PHP2Shell chain to root. Install a vendor-fixed kernel, reboot into it, and investigate suspected compromise.
- **Bandit:** Upgrade [Elixir/Phoenix HTTP servers to 1.14.1](black-october/details/elixir-bandit.md#remediation), not 1.14.0. CVE-2026-116078 lets an unauthenticated HTTP/2 client exhaust memory with many tiny request-body frames on routes that read bodies; disable HTTP/2 as the vendor workaround while the update is deployed.
- **Windows Shell:** Microsoft’s revision 2.0 adds [supported Edge software](black-october/details/windows-shell.md#remediation) to the update table for the exploited MOTW bypass. Apply both the Windows cumulative update and the indicated Edge update.
- **Linux skb_zerocopy:** [Linux 7.3 includes the upstream fix](black-october/details/skb-zerocopy-lpe.md#timeline), but distribution backports remain a separate verification step; use only vendor builds that explicitly include the fix.

## 2026-10-28 16:00 EDT (UTC−04:00) — Electrum CVE assignment and Railway recovery status

- **Electrum:** [CVE-2026-117601](black-october/details/electrum.md#timeline) now assigns CVSS 4.0 9.3 to the already tracked exploited malicious-server transaction-swap issue. Upgrade to [4.8.3](black-october/details/electrum.md#remediation) and verify every fee-bump recipient and amount.
- **Railway:** [Recovery remains in monitoring](black-october/details/railway.md#timeline); new signups remain paused. Continue issuer-side secret rotation and confirm service recovery before storing replacement credentials.

## 2026-10-28 12:00 EDT (UTC−04:00) — Veeam Backup & Replication Critical update

- **Veeam Backup & Replication / Veeam Software Appliance:** Update affected deployments to [13.1.2 or 13.0.3](black-october/details/veeam-backup.md#remediation) to correct CVE-2026-108142, a Critical unauthenticated authorization bypass in the CDP Coordinator Service. Restrict management access to trusted administration networks during rollout.
- **Veeam Agent for Linux:** Update [managed 13.1 agents to 13.1.2](black-october/details/veeam-backup.md#remediation) for the separate High local privilege escalation CVE-2026-105477.

## 2026-10-28 08:01 EDT (UTC−04:00) — TeamViewer client and EPICS Base Critical fixes

- **TeamViewer:** Update clients to [15.83 or the vendor's supported fixed legacy build](black-october/details/teamviewer.md#remediation). Crafted screen images or recordings can execute code only after the documented user interaction; TeamViewer reported no known active exploitation when it published the bulletin.
- **EPICS Base:** Update [7.0.10 and earlier to 7.0.11](black-october/details/epics-base.md#remediation) through validated OT change management. Keep control-network segmentation while the update is staged; CISA reports no known public exploitation of the tracked Critical CVE at publication.
- **Supermicro BMC:** The eight CVE records are now published; retain the [existing board-specific BMC firmware update and management-network isolation plan](black-october/details/supermicro-bmc.md#remediation).
- **LiteLLM:** Later releases [1.106.5 and matching backports](black-october/details/litellm.md#remediation) are available, but they are not designated malware-cleanup releases. Preserve the incident-recovery process and verify clean artifacts.

## 2026-10-28 04:03 EDT (UTC−04:00) — Tailscale Tailworm fixes

- **Tailscale / Tailworm:** Update Tailscale deployments to [v1.104.4 or later](black-october/details/tailworm.md#remediation). Tailscale says it addresses confirmed SSH vulnerabilities and three Serve/Funnel bugs; retain SSH/Serve mitigations and treat headscale and any unmapped Tailworm findings as unresolved until their respective vendors publish complete fix status.

## 2026-10-28 00:03 EDT (UTC−04:00) — Brotli KEV update

- **Brotli / HTTP2Shell:** CISA added [CVE-2026-111497 to KEV](black-october/details/brotli.md#timeline) based on evidence of active exploitation, with a federal civilian due date of 2026-11-10. Prioritize the [component-specific updates and temporary decoder controls](black-october/details/brotli.md#remediation); the related Node.js CVEs are not listed.

## 2026-10-27 20:04 EDT (UTC−04:00) — Adobe Commerce / Magento KEV update

- **Adobe Commerce / Magento Open Source:** CISA added [CVE-2026-48356 to KEV](black-october/details/adobe-commerce-upload.md#timeline), with a federal civilian due date of 2026-11-10. Install Adobe's [July 2026 update for your supported product line](black-october/details/adobe-commerce-upload.md#remediation), then retain the separate October BlockStrap patch sequence.

## 2026-10-27 16:01 EDT (UTC−04:00) — GoAhead TLS backend fixes and DuckDB source-fix status

- **GoAhead:** Add the [backend-specific TLS guidance](black-october/details/goahead-tls.md#remediation). Embedded device-management servers using affected OpenSSL-compatible or Mbed TLS builds should move to **6.1.1+**; on legacy LibreSSL builds, enable issuer verification or migrate to a supported TLS backend. A configured CRL is not enforced by affected OpenSSL-compatible builds.
- **Brotli / DuckDB:** DuckDB's [upstream decoder fix is merged](black-october/details/brotli.md#inventory-by-language-and-deployment), but no fixed DuckDB release is established. Keep deployed DuckDB builds in the unknown state until the supplier identifies a released or backported artifact with the fix.

## 2026-10-27 09:27 EDT (UTC−04:00) — PHP2Shell hotfixes and incident recovery updates

- **PHP2Shell / PAN-OS:** Palo Alto released additional [PAN-OS and Panorama hotfixes](black-october/details/php2shell.md#timeline), including 12.2.4-h1, 12.1.7-h11, 10.2.13-h27 and 10.2.16-h12. Install the hotfix listed for your branch; do not use an earlier ETA as a patch decision.
- **Railway:** [Recovery remains in progress](black-october/details/railway.md#timeline). Replace provider-revoked replacement OpenAI/Anthropic keys and redeploy, but do not rotate working replacements solely because of the October 24 batch-processing notice.
- **Langflow:** Third-party honeypot telemetry now reports [4,924 attempts](black-october/details/langflow.md#timeline) from 34 IPs; that remains attempt telemetry from one sensor, not proof of compromise.
- **Oracle CPU:** Oracle [Revision 2](black-october/details/oracle-cpu-october.md#timeline) updates Siebel CRM version information and credits; the reviewed CPU counts, impact, patch availability and KEV status are unchanged.

## 2026-10-27 08:04 EDT (UTC−04:00) — Tailscale confirms serious SSH privilege escalation

- **Tailworm:** Tailscale now confirms [serious privilege-escalation issues](black-october/details/tailworm.md#timeline) affecting authorization- and configuration-dependent Tailscale SSH scenarios. [Disable unneeded SSH forwarding, tighten SSH access policies and prepare to update](black-october/details/tailworm.md#remediation); the vendor targets a patched client release by the end of October 27 subject to testing, but has not published a fixed version or complete affected-configuration matrix.

## 2026-10-27 04:02 EDT (UTC−04:00) — PAN-OS Brotli inspection update

- **PAN-OS / Brotli:** [CVE-2026-111497 affects only firewalls that both decrypt TLS/SSL and inspect Brotli on the dataplane](black-october/details/brotli.md#pan-os); the management interface, PAN-OS 11.1 and 10.2 are not affected. [Install the branch-specific hotfix when available, or disable Brotli inspection and verify it is off](black-october/details/brotli.md#pan-os) while preserving approved traffic-inspection controls.

## 2026-10-27 07:01 EDT (UTC−04:00) — PHP2Shell KEV, Tailworm and PwnEscape fixes

- **PHP2Shell:** CISA added [CVE-2026-109618 and CVE-2026-109619 to KEV](black-october/details/php2shell.md#timeline) on 2026-10-26, requires forensic triage, and sets a federal civilian due date of 2026-10-29. [Patch the PHP runtime immediately and investigate exposed systems from at least 2026-10-17](black-october/details/php2shell.md#remediation); CVE-2026-115560 remains outside KEV.
- **Tailworm:** More [Tailscale source fixes](black-october/details/tailworm.md#timeline) have merged for privileged Unix forwarding and Serve paths, but no numbered Tailscale or headscale release includes them yet. Keep the forwarding and exposure mitigations in place rather than deploying an arbitrary development build.
- **PwnEscape:** Red Hat has published fixed real-time kernel builds for RHEL 7 ELS, RHEL 9.2 SAP Solutions and RHEL 8; [install the exact supported build and reboot](black-october/details/pwnescape.md#remediation). General RHEL 9 `kernel-rt` remains affected.
- **eMudhra / CPython:** The PSF corrected [CVE-2026-115557 affected ranges](black-october/details/emudhra.md#runtime-and-application-trust-store-inventory) to end before the released Python fixes. Continue updating bundled certificate stores and tools separately.

## 2026-10-26 17:27 EDT (UTC−04:00) — GitHub Actions privileged-workflow audit guidance

- **GitHub Actions Gheist:** [Audit privileged workflows](black-october/details/github-gheist.md#remediation) for untrusted-event checkouts, artifact execution, direct event-data shell interpolation and persistent self-hosted runner state. These are separate paths from the stolen-token Gheist campaign, but can expose the same repository secrets. Restrict privileged workflows to authorized actors, use a reviewed head SHA, keep untrusted event data out of shell source, and do not execute artifacts from lower-trust runs.

## 2026-10-26 16:01 EDT (UTC−04:00) — PHP Windows Brotli rebuild identifiers

- **PHP on Windows:** PHP's official Windows packages **8.2.35-1, 8.3.36-1, 8.4.27-1 and 8.5.12-1** bundle Brotli 1.2.1 for CVE-2026-111497. The `-1` suffix is essential: `php -v` still reports the same PHP runtime release. [Install the rebuilt package, verify its filename/hash and restart each SAPI or worker](black-october/details/brotli.md#remediation); separately assess extensions, libcurl and other bundled decoders.

## 2026-10-26 12:30 EDT (UTC−04:00) — Supermicro BMC, Avocent and WolfVision devices, Oracle October CPU and five more; Brotli reaches Visual Studio and PowerShell

None of the new items is in CISA KEV (catalog 2026.10.23) and none has reported in-the-wild exploitation, except the Gheist token-abuse campaign.

- **New: infrastructure and devices:**
  - **Supermicro BMC firmware:** eight runZero-reported IPMI/RMCP+ flaws, led by CVE-2026-18450 (Supermicro 9.8 Critical; runZero 8.1 High) and a low-privilege-to-Administrator escalation (8.8). [Find your board's fixed BMC firmware](black-october/details/supermicro-bmc.md#fixed-firmware-by-board-family) and update it; X12DGU, X13SEW-TF-OS1 and X9/X10 have no listed fix, so [isolate BMCs and disable IPMI over LAN (UDP 623) where unused](black-october/details/supermicro-bmc.md#remediation).
  - **Vertiv Avocent ACS8000 / ACS800:** CVE-2026-65184 (runZero 9.8) lets an unauthenticated attacker run commands as root through the `/termviewer` WebSocket; not in KEV, not yet validated on a live device. No fixed version is confirmed (2.32.6 is unconfirmed), so [restrict web access to a management network](black-october/details/vertiv-avocent-acs.md#remediation) and [check firmware and exposure](black-october/details/vertiv-avocent-acs.md#detection).
  - **WolfVision Cynap:** CVE-2026-59106 (CVSS 4.0 9.3) lets unauthenticated attackers run commands through the WolfProt control interface on nearly every Cynap model; CVE-2026-59107 (9.2) is a shared SSH root key on vSolution Matrix master stations. Not in KEV. [Update to v2.00c/v2.00d, v1.78a or v1.72e](black-october/details/wolfvision-cynap.md#remediation); Cynap, Cynap Core and Cynap Pure SDM get no fix, so [isolate or retire them](black-october/details/wolfvision-cynap.md#remediation) and [check exposure of the WolfProt ports](black-october/details/wolfvision-cynap.md#exposure).
- **New: enterprise and application software:**
  - **Oracle October 2026 CPU:** [unauthenticated 10.0 and 9.8 flaws](black-october/black-october-2026.md#oracle-fusion-middleware-e-business-suite-database-and-mysql-october-2026-critical-patch-update) in Access Manager, SOA Suite, WebLogic, E-Business Suite, the JD Edwards Orchestrator, Database, MySQL and PeopleTools. No exploitation of the new CVEs has been reported, and none is in CISA KEV. [Apply the CPU patches and restrict T3/IIOP and the EBS TCF servlet](black-october/details/oracle-cpu-october.md#remediation). ShinyHunters is still exploiting the June PeopleSoft flaw CVE-2026-35273 (in KEV) on servers with only WAF mitigations, so [confirm that patch too](black-october/details/oracle-cpu-october.md#peoplesoft-the-actively-exploited-june-flaw).
  - **Google MCP Toolbox for Databases:** CVE-2026-93328 (Google Cloud CVSS 4.0 9.3) lets callers of the Cloud Storage upload/download tools in 1.2.0–1.4.0 exfiltrate host files and overwrite local files. The 1.5.0 fix is opt-in, and 1.5.0–1.9.x remain bypassable through symlinks (CVE-2026-102242, 8.6). [Upgrade to 1.10.0+ and set `allowedBuckets` and `allowedLocalRoots`](black-october/details/google-mcp-toolbox.md#remediation).
  - **Bandit (Elixir/Phoenix web server):** ten High advisories (nine CVEs at EEF CVSS 4.0 8.7 or 8.2, plus GHSA-fmr8-qrvr-4ww5 with no CVE) and two Medium ones let unauthenticated clients exhaust BEAM memory or CPU over HTTP/2, HTTP/1.1 chunked bodies, header parsing or WebSocket. [Upgrade to Bandit 1.14.0](black-october/details/elixir-bandit.md#remediation) and redeploy; until then [disable HTTP/2 and tighten WebSocket limits](black-october/details/elixir-bandit.md#workarounds-until-you-can-upgrade).
  - **Apache Camel camel-saxon:** CVE-2026-90885 (Apache 7.5 High) is an XXE in XQuery evaluation that lets an external sender read files the Camel process can read and trigger SSRF, when the body reaching XQuery is already a `Source`. [Upgrade to 4.23.0, 4.22.2 or 4.18.5](black-october/details/apache-camel-saxon.md#remediation) (4.22.1 is still affected), and [check whether your routes reach the vulnerable path](black-october/details/apache-camel-saxon.md#reachability-is-the-vulnerable-path-used).
  - **ImageMagick:** CVE-2026-116149 (8.1 High from the maintainers and VulnCheck; Red Hat Important 7.8) is a stack buffer overflow triggered by a crafted bzip2-compressed image. [Upgrade to 7.1.2-33 or 6.9.13-58](black-october/details/imagemagick.md#remediation) wherever untrusted images are processed, including bundled copies. [Check distribution packages](black-october/details/imagemagick.md#distribution-package-status): Debian stable and RHEL 6/7 were not yet fixed.
- **New related incident:**
  - **GitHub Actions Gheist (related incident, no CVE):** stolen GitHub tokens plant `ci-sync-` branches whose `sync-check.yml` workflow dumps every secret into the run log; GitHub's approval hold protects public repositories only. [Hunt with the audit-log queries and the new read-only branch check script](black-october/details/github-gheist.md#detection), then [rotate exposed secrets and revoke the pushing tokens](black-october/details/github-gheist.md#remediation).
- **Brotli:** Microsoft's [MSRC entry](black-october/details/brotli.md#inventory-by-language-and-deployment) rates CVE-2026-111497 Critical (CVSS 8.1) and lists fixed **Visual Studio** (2019 16.11.61, 2022 17.14.43, 2026 18.11.2) and **PowerShell** (7.4.22, 7.5.13, 7.6.9) builds; update those too. Alpine's `brotli` packages are fixed. DuckDB bundles its own copy and has no fixed release yet.
- **Linux skb_zerocopy local root:** AlmaLinux 8 now has a [production kernel with the fix](black-october/details/skb-zerocopy-lpe.md#remediation) (`4.18.0-553.178.1.el8_10`); AlmaLinux 9 and 10 still have testing kernels only.
- **Tailworm:** Tailscale merged a [source fix](black-october/details/tailworm.md#timeline) that closes SSH connections, including forwarding, when policy grants are revoked or narrowed. It is not in a release yet (latest v1.104.2).

## 2026-10-26 11:45 EDT (UTC−04:00) — Electrum theft, Fortinet hardening release and six more High/Critical items

- **Exploited outside KEV:** [Electrum Bitcoin wallet](black-october/black-october-2026.md#electrum-bitcoin-wallet-malicious-server-swaps-broadcast-transactions-so-a-fee-bump-pays-the-attacker). Rogue servers swap broadcast transactions so a fee bump pays the attacker, with one confirmed theft. Upgrade to 4.8.3, and [check outputs before any fee bump](black-october/details/electrum.md#remediation).
- **Fortinet:** the [October 2026 hardening release](black-october/details/fortinet-october.md#remediation) carries critical and high fixes for FortiOS, FortiManager, FortiAnalyzer, FortiMail and FortiAuthenticator, with advisories withheld until 2026-11-10. The guide also covers two High SQL injection advisories. On FortiManager/FortiAnalyzer 7.2, move to 7.4.12+: the hardening release and FG-IR-26-178 disagree on whether 7.2 is fixed.
- **Signal calling:** a call peer can keep your microphone live after hang-up (MITRE 9.3). Update to [Android 8.27.0, iOS 8.30.0 or Desktop 8.29.0](black-october/details/signal.md#remediation) or later.
- **OVHcloud CLI:** release binaries v0.11.0–v0.15.0 were swapped for a secret stealer on 2026-10-19 (vendor High). [Check hashes and rotate secrets](black-october/details/ovhcloud-cli.md#detection), then install v0.16.0.
- **Microsoft .NET Framework:** CVE-2026-108398 (8.8, publicly disclosed) bypasses App Control through an untrusted assembly search path. [Install the October .NET update](black-october/details/dotnet-framework.md#remediation); MSRC and the CVE record list different builds for Windows 11 26H2.
- **SAP NetWeaver Visual Composer:** CVE-2026-89110 (9.9) gives low-privileged users backend operations on connected systems. [Apply Note 3797111 or enable Secure Mode](black-october/details/sap-netweaver-visual-composer.md#remediation).
- **Docker Hub GhostPat:** CVE-2026-105445 (9.4) was fixed service-side. If Docker emailed you, [revoke unknown tokens and verify images](black-october/details/docker-hub-ghostpat.md#remediation).
- **Progress MarkLogic Server:** 31 CVEs, five Critical, with low-privilege paths to administrator. [Upgrade to 11.3.7 or 12.1.0](black-october/details/marklogic.md#remediation).

## 2026-10-26 11:30 EDT (UTC−04:00) — Seven new High/Critical items; PHP2Shell reaches PAN-OS; PwnEscape fixes ship

- **New: seven High/Critical issues, none yet in CISA KEV:**
  - [HPE Aruba AOS-8/AOS-10](black-october/black-october-2026.md#hpe-aruba-networking-aos-unauthenticated-rce-and-authentication-bypass-in-wireless-infrastructure): 72 CVEs, eight CVSS 10.0. Upgrade controllers, gateways and APs and [confine management and PAPI](black-october/details/aruba-aos.md#remediation).
  - [FortiSIEM 7.5.0](black-october/details/fortisiem.md#remediation): unauthenticated RCE with a public exploit. Canada's Cyber Centre reports in-the-wild exploitation; Fortinet does not. Upgrade to 7.5.1, restrict TCP 27918 and [check the files the exploit overwrites](black-october/details/fortisiem.md#detection).
  - [FortiSandbox](black-october/details/fortisandbox.md#remediation): unauthenticated GUI bypass. Use 5.0.7 / 4.4.10; treat 4.2 as affected.
  - [Magento / Adobe Commerce BlockStrap](black-october/details/magento-blockstrap.md#remediation): CVSS 10.0 RCE. Apply the October isolated patch, keeping the StyleSmuggler hotfix; a plain Composer update does not fix it.
  - [SAP Cloud SDK for Python](black-october/details/sap-cloud-sdk-python.md#remediation): use 0.45.2+. Multi-tenant BTP apps could leak OAuth client credentials; [the Python inventory script](black-october/details/sap-cloud-sdk-python.md#read-only-inventory) now reports `sap-cloud-sdk`.
  - [Rank Math PRO 3.0.123](black-october/details/rankmath-pro.md#detection) shipped malware through official updates on 2026-10-15/16. Treat activated copies as compromised, rotate credentials and use the new offline indicator script.
  - [Linux skb_zerocopy local root (ZDI-CAN-33367)](black-october/details/skb-zerocopy-lpe.md#remediation): public exploit, bypasses the Dirty Frag fix, no CVE. Few vendor kernels are fixed yet; restrict user namespaces or ESP modules on hosts running untrusted code.
- **PHP2Shell:** PAN-OS and Panorama management interfaces embed affected PHP. [Install Palo Alto's per-branch hotfix or restrict management access](black-october/details/php2shell.md#remediation). NVD now scores the CVEs 9.8 and 8.1, and a [complete public exploit](black-october/details/php2shell.md#exploitation-status) exists.
- **PwnEscape:** [Red Hat has shipped fixed kernels](black-october/details/pwnescape.md#detection) for RHEL 10, 9, 8 and 7 ELS. AlmaLinux, Debian and Oracle are also fixed. Ubuntu and RHEL `kernel-rt` are still pending.
- **Brotli:** Debian and Amazon Linux system `libbrotli` packages are fixed and Red Hat rates the CVE Important (8.1). ClickHouse backports are merged but not yet released. [Restart processes that load the system library](black-october/details/brotli.md#remediation).
- **eMudhra:** [Bun 1.4.4](black-october/details/emudhra.md#runtime-and-application-trust-store-inventory) blocks the keys; rebuild compiled Bun executables. CERT-In reports no confirmed malicious use. Python's CVE-2026-115557 record has a wrong affected range; follow the release versions.
- **Other updates:**
  - [AhsayCBS](black-october/details/ahsaycbs.md#detection): the CVE records now show the correct affected range, up to 10.3.4.44 / 9.15.2.69.
  - [KSMBD](black-october/details/ksmbd.md#distinguish-ksmbd-from-unrelated-smb-services): Red Hat says supported RHEL is not affected.
  - [LiteLLM](black-october/details/litellm.md#detection): Microsoft has published Defender detections and hunting queries.
  - [WPSplinter](black-october/details/wpsplinter.md#durable-repair-or-replacement): firmware with only Broadcom's 2018 patch may still be exploitable.
  - [Tailworm](black-october/details/tailworm.md#timeline): more SSH fixes are merged and a headscale fix is proposed, but there is still no stable release.

## 2026-10-26 10:18 EDT (UTC−04:00) — Ten High/Critical flaws in widely deployed developer and self-hosted software

- **Exploitation attempts outside KEV:**
  - [Bricksforge WordPress plugin](black-october/black-october-2026.md#bricksforge-exploited-unauthenticated-file-upload-to-rce-cve-2026-85097): unauthenticated upload to RCE, attempts since 2026-10-07. Update to 3.1.8.10+ (prefer 4.0.x) and [hunt for uploaded PHP files](black-october/details/bricksforge.md#detection).
  - [Langflow](black-october/black-october-2026.md#langflow-authenticated-rce-via-mcp-stdio-server-configuration-cve-2026-105740-and-cve-2026-105697): honeypot attempts using common credentials. **1.9.0 is incomplete; upgrade to 1.10.3+** and [disable auto-login](black-october/details/langflow.md#remediation).
- **Unauthenticated RCE in web stacks:**
  - [Next.js](black-october/black-october-2026.md#nextjs-unauthenticated-rce-in-use-cache-and-image-optimization-ghsa-673q-mjm6-r5xr-and-cve-2026-96889): upgrade to 16.4.1 or 15.5.28, with `sharp` 0.35.5+. One RCE has no CVE, so CVE-only scanners can miss it.
  - [Drupal core Field UI](black-october/details/drupal.md#remediation): 11.4.10 / 11.3.19 / 10.6.19, plus Entity List 3.0.10.
- **Configuration-dependent infrastructure fixes:**
  - [NGINX](black-october/details/nginx.md#detection): 1.30.6 / 1.31.7. F5 rates it Critical, nginx.org medium.
  - [curl/libcurl](black-october/details/curl.md#detection): 8.23.0; rebuild bundled copies.
  - [Gitea built-in SSH server](black-october/details/gitea.md#detection): 28.0.0, the release after 1.27.3.
- **Isolation and auth bypasses:**
  - [PwnEscape guest-to-host kernel flaw and Vghost](black-october/details/pwnescape.md#remediation): VM and sandbox hosts need patched kernels; RHEL fixes were still pending.
  - [Wasmtime sandbox escapes](black-october/details/wasmtime.md#remediation): CVE-2026-115889 affects all architectures. Lines 37–47 get no fixed release, so move to 36.0.19, 48.0.7, 49.0.4 or 50.x.
  - [Laravel TokenGuard](black-october/details/laravel.md#detection): affects only `token`-driver guards on MySQL/MariaDB.

## 2026-10-26 10:00 EDT (UTC−04:00) — Brotli media and analytics exposure

- **Brotli2Shell is another alias for CVE-2026-111497.** JFrog demonstrates FFmpeg/libjxl pointer corruption and a cleanup crash, ClickHouse server DoS, an Arrow/pyarrow CPU loop and a .NET native crash—not complete RCE exploits for those products. [Review the demonstrated outcomes and investigation limits](black-october/details/brotli.md#operational-signals-and-evidence-limits).
- **Inventory media and analytics decoders separately.** JPEG XL metadata, `.br` files and Parquet can reach copies untouched by a Node or Python binding update. libjxl and ClickHouse source fixes are merged, but published fixed artifacts remain unconfirmed; Arrow's dependency-update PR remains open. [Verify supplier builds or pause affected untrusted processing](black-october/details/brotli.md#inventory-by-language-and-deployment).
- **Detection guidance:** Added [JFrog's contextual scanner and Trail of Bits Brotli Checker](black-october/details/brotli.md#official-researcher-detection-tools), including prerequisites, coverage gaps and why matches or empty results do not establish exposure or safety.

## 2026-10-26 09:28 EDT (UTC−04:00) — Twelve KEV-listed flaws, PHP2Shell exploitation and KEV updates

- **New: 12 actively exploited flaws (CISA KEV).** Patch and run the forensic checks for [VeloCloud Orchestrator](black-october/black-october-2026.md#velocloud-orchestrator-authenticated-sql-injection-to-superuser-operator-cve-2026-114625) (KEV due today), [Siemens Software Center](black-october/details/siemens-software-center.md#detection), [PAN-OS / Panorama management interface](black-october/details/pan-os.md#remediation), [Cisco Secure Email Gateway](black-october/details/cisco-seg.md#remediation), [SiteGuard Server Edition](black-october/details/siteguard.md#remediation), [Windows Shell MOTW bypass](black-october/details/windows-shell.md#remediation), [Ivanti Connect Secure](black-october/details/ivanti-connect-secure.md#compromise-response), [Atlassian Data Center](black-october/details/atlassian-dc.md#remediation), [AhsayCBS](black-october/details/ahsaycbs.md#remediation), [NetScaler SAML](black-october/details/netscaler.md#remediation), [FortiMail](black-october/details/fortimail.md#remediation) and [Zammad](black-october/details/zammad.md#remediation). Stack-specific actions are in the [patch table](black-october/black-october-2026.md#what-should-i-patch-a-stack-based-decision-guide).
- **PHP2Shell is exploited.** Amazon saw attempts from 2026-10-17, before disclosure, and a researcher confirmed RCE on PHP 8.4.26 `mod_php` honeypots on 2026-10-24. [Investigate exposed PHP from October 17](black-october/details/php2shell.md#exploitation-status); the upload-progress follow-up still has no fix, so keep the mitigation.
- **Plex2Shell:** Plex confirmed active, widespread exploitation, and CISA added all four CVEs to KEV on 2026-10-20. Treat internet-reachable servers below 1.43.3.10861 as possibly compromised and use the [vendor indicators](black-october/details/plex2shell.md#detection).
- **Nextcloud CODE and BeyondTrust are now in KEV** (added 2026-10-23 and 2026-10-16). See the [CODE KEV status](black-october/details/nextcloud-code.md#cisa-kev-status) and [BeyondTrust KEV status](black-october/details/beyondtrust.md#cisa-kev-status-and-severity-attribution). NVD also scores BeyondTrust 9.8.
- **KSMBD:** Both fixes are now committed upstream, but [no released kernel, distribution or NAS build contains them yet](black-october/details/ksmbd.md#timeline); keep KSMBD disabled or restricted.
- **Header Accordions:** [Bun 1.4.4 fixes the HTTP/3 QPACK issue](black-october/details/header-accordions.md#timeline) under its own advisory; rebuild compiled Bun executables. Rust `h3` and aioquic/mitmproxy remain unfixed.
- **Pillow:** The maintainer now rates CVE-2026-112403 [High rather than Critical](black-october/black-october-2026.md#4-pillow-untrusted-images-reach-native-memory-corruption-and-command-execution); the upgrade target is unchanged.
- **LiteLLM:** From 1.106.3, images are signed with a [new cosign key](black-october/details/litellm.md#verification); update pinned keys, since the old key also signed the malicious build. **Railway:** [timeline](black-october/details/railway.md#timeline) now has exact publication times.

## 2026-10-26 09:23 EDT (UTC−04:00) — Brotli cross-language patches and trust recovery

- **Brotli / HTTP2Shell:** Microsoft now identifies fixed .NET runtimes **8.0.33 / 9.0.22 / 10.0.14**, plus a fixed .NET 11 preview. Update deployed runtimes and [rebuild self-contained/NativeAOT apps](black-october/details/brotli.md#inventory-by-language-and-deployment); automatic request/client decompression is not enabled by default.
- **Brotli bindings:** Added **Brotli4j 1.24.0** (including native artifacts), **PHP extension 0.21.1** and **Ruby gem 0.9.1+**, with [per-language inventory and native-library caveats](black-october/details/brotli.md#inventory-by-language-and-deployment). Bun compiled executables also require [rebuilding with fixed 1.4.4](black-october/details/brotli.md#remediation).
- **Brotli detection and containment:** Added a [safe response-header inventory script and interpretation guide](black-october/details/brotli.md#response-header-inventory-script); its results do **not** establish vulnerability or patch status. Expanded [pre-decoder controls](black-october/details/brotli.md#contain-before-the-first-decoder) for duplicate/stacked encodings, bypass paths, outbound clients and file workers.
- **eMudhra / Java:** Earlier emergency JDK builds are not the final response. Require [CVE-2026-114820 / JDK-8395690 update evidence](black-october/details/emudhra.md#java-and-scala); Debian/Ubuntu also require a Java keystore rebuild. Use the [official offline checker with its root-presence limits](black-october/details/emudhra.md#java-use-the-official-offline-checker-with-its-actual-limits), not a generic failed handshake as proof of protection.
- **eMudhra / Python:** Today's **3.15.2 / 3.14.10 / 3.13.18 / 3.12.16 / 3.11.18** releases add `ssl` key blocking (**CVE-2026-115557**). Check [binary/source availability and independently bundled pip/certifi/tool updates](black-october/details/emudhra.md#python).
- **eMudhra / trust coverage:** Expanded [runtime and hidden-bundle inventory](black-october/details/emudhra.md#runtime-and-application-trust-store-inventory), including precise Rust dependency ranges. [Alternate AAA cross-signs survive emSign-only root removal](black-october/details/emudhra.md#trust-paths-and-what-each-mitigation-changes). Prepare legitimate replacement chains before [Chrome's expected October 27 morning PDT root removal](black-october/details/emudhra.md#timeline); this remains a forecast, not a completed rollout.

## 2026-10-26 08:47 EDT (UTC−04:00) — Tailworm and AuthMask

- **Tailworm — new tracking:** Several researcher-rated High findings require prior Tailscale SSH authorization and applicable forwarding; the report also covers non-SSH features. [Source fixes have merged, but a complete fixed stable-release matrix was not established](black-october/details/tailworm.md#timeline). Apply the vendor's [unnecessary-forwarding mitigation](black-october/details/tailworm.md#disable-unnecessary-forwarding-using-the-vendors-mitigation) and review [per-finding prerequisites](black-october/details/tailworm.md#interpret-the-eleven-findings-separately). No blanket “disable Tailscale” recommendation.
- **AuthMask / CVE-2026-80097 — new tracking:** Microsoft rates this **8.6 High** and identifies **6.2606.4246** as the corrected fixed Android build. A malicious local app can obtain signed-in work-account tokens. Review [affected-device detection](black-october/details/authmask.md#detection), [remediation](black-october/details/authmask.md#remediation), and the [Microsoft/researcher interaction disagreement](black-october/details/authmask.md#preserve-the-interaction-disagreement). September disclosure is distinct from October research; the exact July patch rollout date remains unestablished.

## 2026-10-26 08:22 EDT (UTC−04:00) — Updated exposure and remediation guidance

- **PHP:** The October 23 upload-progress issue needs a [separate mitigation after installing the October 21 emergency releases](black-october/details/php2shell.md#timeline). Added [CISA-backed detection guidance](black-october/details/php2shell.md#look-for-suspicious-execution).
- **Brotli / HTTP2Shell / Node2Shell:** [Cross-stack remediation](black-october/details/brotli.md#remediation) covers outbound-client exposure, downstream encoded-byte forwarding, and unsupported Envoy/Istio branches. [Patch dates differ by library, runtime, Python package and proxy](black-october/details/brotli.md#timeline).
- **GitLab/Ruby:** Added [vendor threat-detection guidance](black-october/details/gitlab-ruby.md#use-gitlabs-threat-detections) and clarified shared-cache/OIDC exposure. [Ruby 4.0.8 is incomplete; later releases contain the complete fixes](black-october/details/gitlab-ruby.md#timeline).
- **Pillow:** [Affected ranges and processing prerequisites differ by issue](black-october/details/pillow.md#map-each-issue-to-an-actual-operation); a format-specific check does not clear every vulnerability. The [package release preceded individual advisory publication](black-october/details/pillow.md#timeline).
- **Plex:** Fixed PMS was [beta on August 3 and generally available August 4](black-october/details/plex2shell.md#timeline). [Recovery must account for persistent codec volumes and stolen owner tokens](black-october/details/plex2shell.md#compromise-response).
- **Nextcloud CODE:** [“Latest compatible” can remain vulnerable on EOL Nextcloud](black-october/details/nextcloud-code.md#patch-or-migrate); upgrade Nextcloud or remove the app. September fix dates are distinguished from later warnings and formal disclosure in the [timeline](black-october/details/nextcloud-code.md#timeline).
- **KSMBD:** An [SMB Direct patch was posted and reviewed October 23](black-october/details/ksmbd.md#timeline); this does not establish a released distribution/NAS fix. [Exposure checks include software RDMA](black-october/details/ksmbd.md#evaluate-the-two-prerequisites-independently). Public demonstrations establish disclosure/crashes, not successful RCE.
- **WPSplinter:** Incorporated the [October 20 ISP-specific findings](black-october/details/wpsplinter.md#timeline). A coordinated ISP mitigation is not evidence that an ordinary [WPS-disable toggle removes the attack path](black-october/details/wpsplinter.md#temporary-mitigation-must-remove-the-radio-attack-path); no universal firmware fix matrix is established.
- **Header Accordions:** [Scope includes quic-go clients and Wireshark capture decryption](black-october/details/header-accordions.md#component-specific-interpretation). Several [component fixes predate October](black-october/details/header-accordions.md#timeline); the research matrix labeled “as of October 20” does not establish later patch availability for the remaining stacks.
- **BeyondTrust:** [Exploitation dates to August; patches were released October 8 before October 15 disclosure](black-october/details/beyondtrust.md#timeline). [Recovery includes rebuilding, replacing enrollments/sessions and rotating brokered credentials](black-october/details/beyondtrust.md#compromise-response). Full KB0024066 requires customer access.
- **eMudhra:** Corrected dates to [October 17 discovery, October 18 revocations and October 19 Go releases](black-october/details/emudhra.md#timeline), with the Firefox Android follow-up. [CA revocation alone does not prove client enforcement](black-october/details/emudhra.md#verification).
- **LiteLLM:** [Corrected the entry point and registry containment windows](black-october/details/litellm.md#timeline). [Cached artifacts remain dangerous; the private-release exception does not cover every enterprise deployment](black-october/details/litellm.md#detection). [Official signing alone did not establish trustworthy content](black-october/details/litellm.md#verification).
- **Railway:** [Detection dates to October 20; incident scope remains preliminary](black-october/details/railway.md#timeline). [Recovery covers issuer-side revocation, existing sessions, private registries and commits not queued during the deployment pause](black-october/details/railway.md#remediation).
