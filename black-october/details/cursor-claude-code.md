# Cursor: malicious Claude Code extension installed an SSH backdoor

**Last updated:** 2026-10-31 (America/New_York)

[Back to Cursor summary](../black-october-2026.md#cursor-malicious-claude-code-extension-installed-an-ssh-backdoor) · [Changelog](../../CHANGELOG.md)

On October 29, 2026, Cursor served two modified builds of the Claude Code VS Code extension from its own marketplace. The builds were not Anthropic's. When the extension loaded, injected code tried to plant an SSH key, open a reverse SSH tunnel, and keep that tunnel across restarts. Cursor says at most 5,000 users installed them. Microsoft confirmed the same packages were never on the Visual Studio Marketplace or on npm, and Anthropic told Microsoft its systems were not compromised.

**This is a marketplace supply-chain incident, not a flaw in Claude Code itself.** No CVE is assigned. There is no CVSS score. Updating or uninstalling the extension does not remove the key or the startup scripts the payload already wrote.

**CISA KEV:** Not applicable — no CVE is assigned, and KEV lists only CVEs. Cursor and Microsoft describe a completed distribution of malware, not a software vulnerability. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| 2026-10-29, about 02:27–13:35 PT (PDT, UTC−07:00) | Malicious `Anthropic.claude-code` **2.1.312** and **2.1.313** for Windows and macOS were available in the Cursor VS Code Extension Marketplace. The notice's "today" is October 29. [Cursor][cursor] |
| 2026-10-29, by 13:35 PT | Cursor removed the builds, shut the marketplace, audited other extensions, rotated its keys, rebuilt the marketplace, and had the attacker server taken offline. [Cursor][cursor] |
| 2026-10-30 | Cursor posted on X that at most 5,000 users were affected and asked customers to move to Claude Code for VS Code **2.1.314**. [Cursor on X][cursor-x] |
| 2026-10-30 11:30 PT | Cursor updated the notice: clarified that both 2.1.312 and 2.1.313 are affected, and expanded the indicators. [Cursor][cursor] |
| 2026-10-30 | Microsoft Threat Intelligence published an analysis of the injected loader. It says the packages were never on the Visual Studio Marketplace or npm `@anthropic-ai/claude-code`, and that Anthropic confirmed its systems were not compromised. [Microsoft][msft] |

**Evidence limits:** Cursor says errors in the payload, plus missing administrator rights, stopped the reverse tunnel from letting the attacker log in on most macOS and Windows hosts. The same hosts could still have the SSH key, the persistence files, and a beacon of host details. A missing `svc-telemetry` line does not prove the extension never loaded. Cursor does not publish a per-customer install list in the notice.

## Detection

Check a machine only if it ran Cursor on macOS or Windows and could have installed or auto-updated `Anthropic.claude-code` during 02:27–13:35 PT on October 29, 2026. Linux is not in Cursor's affected-package list. Microsoft's analysis describes Linux persistence the loader *attempts*; Cursor's notice names Windows and macOS packages only.

1. **SSH key.** The reliable marker Cursor names is the comment `svc-telemetry` on an Ed25519 key. On macOS or Linux, as the user who ran Cursor:

   ```sh
   grep -qs svc-telemetry ~/.ssh/authorized_keys && echo "svc-telemetry key found" || echo "No key found; machine not impacted"
   ```

   On Windows, in PowerShell:

   ```powershell
   $files = "$HOME\.ssh\authorized_keys", "C:\ProgramData\ssh\administrators_authorized_keys" | Where-Object { Test-Path $_ }
   if ($files -and (Select-String -Pattern svc-telemetry -Path $files)) { "svc-telemetry key found" } else { "No key found; machine not impacted" }
   ```

   Cursor publishes the key and fingerprint: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDdvylCEJ/k2TpezcTfedrkHyFSK9IZ3vmP6vhY4Ss0P svc-telemetry`, fingerprint `SHA256:0Z6R+DF64Do2nwQic8a7kkfDLNNk4IiK+2U2Rci4htk`. Match the fingerprint before deleting a line. Another key that happens to use the same comment is not this incident.

2. **Files the loader writes outside the extension.** macOS: `~/Library/LaunchAgents/com.apple.sysmond.plist`, `~/.config/.smt`, `~/.config/.smtk`. Windows: `%USERPROFILE%\.config\smt.cmd`, `%USERPROFILE%\.config\smtk`, scheduled task `SysMon`, and `%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\sysmon.cmd`. A name match is a lead; read the file or the task action before treating it as this payload. `com.apple.sysmond` is not an Apple system service.

3. **Extension copy.** In the Cursor extensions folder, `extension.js` from 2.1.312 or 2.1.313 contains `134.209.82.225` and `svc-telemetry`. Cursor's payload SHA-256 is `ecb58cb29078d9646ad1dcdbe51526f2d9cfea06be5fb2ab183e8ecc3ab6bf15`. Package hashes are in the notice; do not treat a hash miss as clean if the key or the startup file is present.

4. **Network, if you have logs from October 29 onward.** Outbound SSH to `134.209.82.225` as user `tunnel` on TCP 22, or HTTP POST to port 8099 path `/beacon`. Cursor says that server no longer answers. A connection is evidence the payload ran. No connection is not evidence it did not.

Absence of the key is what Cursor's own check calls "not impacted." It does not cover a host whose authorized-keys file was cleaned, or a host you cannot log into as the Cursor user.

## Remediation

1. If the key, a startup file, or the malicious `extension.js` is present, isolate the host before cleanup. Collect the extension directory, `authorized_keys`, and the startup files first if you need them for an investigation.
2. Remove the malicious extension. That alone is not enough: Cursor says the payload drops standalone scripts that keep running.
3. On an impacted Mac, download [Cursor's macOS script](https://cursor.com/static/security/claude-code-extension/remediate-macos.sh) and run `bash remediate-macos.sh` **as the affected user, not as root**. On an impacted Windows host, download [Cursor's Windows script](https://cursor.com/static/security/claude-code-extension/remediate-windows.ps1) and run it from an **Administrator** PowerShell: `powershell -ExecutionPolicy Bypass -File .\remediate-windows.ps1`. Read the script before running it. Both exit non-zero if anything they look for remains.
4. If you clean up by hand, delete only the `svc-telemetry` line whose fingerprint matches, unload the LaunchAgent or scheduled task after confirming its action points at the `.smt` / `smt.cmd` script, and stop `ssh` / `autossh` processes whose command line contains `-R` to `localhost:22` with identity files named `.stk_` plus ten hex characters.
5. Install Claude Code for VS Code **2.1.314 or later** from the reinstated marketplace only after the host is clean. 2.1.314 is Cursor's current ask; it is not a patch for files already written.
6. From a **different, trusted** machine, rotate credentials and revoke sessions that the affected host could use: Git, cloud CLIs, SSH keys that lived on that host, and editor tokens. Cursor's beacon sent environment-variable **names**, not values. That does not rule out later use of the planted key.

## Verification

- Re-run the `svc-telemetry` search. It should print that no key was found.
- Confirm the LaunchAgent, scheduled task, Startup script, `.smt` / `.smtk`, and `smt.cmd` are gone, and that no `ssh -N -R` tunnel to `134.209.82.225` is running.
- Confirm the installed Claude Code extension is 2.1.314 or later and that its `extension.js` does not contain `134.209.82.225`.
- Cursor's scripts exit non-zero when something remains. A zero exit is the script's result, not a full forensic clearance.

## Compromise response

- Treat a host with the key or the startup files as exposed for the whole window after the extension loaded, not only while the tunnel was up. Review SSH logins, new authorized keys, and cloud-token use from that host.
- Rebuild when you cannot account for activity after the extension loaded, or when the host had administrator rights (the case Cursor says is required for the tunnel to have worked).
- The Visual Studio Marketplace and the official npm Claude Code package are not part of this incident, per Microsoft. Do not rotate those installs on that basis.
- Report a confirmed install to Cursor at security@cursor.com. Cursor said it would contact affected users; not receiving that mail is not a clean result.

## Sources

- [Cursor security notice, published 2026-10-29, updated 2026-10-30 11:30 PT](https://cursor.com/blog/claude-code-extension-security-notice)
- [Cursor on X, 2026-10-30, at most 5,000 users, update to 2.1.314](https://x.com/cursor_ai/status/2116074289053175808)
- [Microsoft Threat Intelligence, 2026-10-30](https://www.microsoft.com/en-us/security/blog/2026/10/30/inside-malicious-claude-code-branded-cursor-extension-persistent-ssh-backdoor/)

[cursor]: https://cursor.com/blog/claude-code-extension-security-notice
[cursor-x]: https://x.com/cursor_ai/status/2116074289053175808
[msft]: https://www.microsoft.com/en-us/security/blog/2026/10/30/inside-malicious-claude-code-branded-cursor-extension-persistent-ssh-backdoor/
