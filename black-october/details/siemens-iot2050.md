# Siemens SIMATIC IoT2050: unauthenticated Node-RED command execution

**Last updated:** 2026-11-03 (America/New_York)

[Back to Siemens IoT2050 summary](../black-october-2026.md#siemens-simatic-iot2050-unauthenticated-node-red-command-execution) · [Changelog](../../CHANGELOG.md)

**[CVE-2026-58115](https://www.cve.org/CVERecord?id=CVE-2026-58115): Siemens (CNA) CVSS 3.1 10.0 Critical and CVSS 4.0 10.0 Critical.** SIMATIC IoT2050 Advanced (order 6ES7647-0BA00-1YA2) running Industrial OS **before V4.3.4.1 with Node-RED installed** does not require authentication on the Node-RED HTTP interface. Anyone who can reach that interface can deploy a flow that runs a shell command as the server. Siemens published the fix on 2026-08-11. CISA republished the advisory on 2026-08-25 and does not say the flaw is exploited. VulnCheck says its canaries received complete exploit requests on 2026-10-30 and through 2026-11-01. That is a honeypot, not a report of a compromised Siemens device. It is not in CISA KEV. [SSA-834709][ssa] [CISA][cisa] [VulnCheck][vc]

**CISA KEV:** Not listed (catalog 2026.10.30, checked 2026-11-03). VulnCheck recorded honeypot exploit attempts and says the CVE is in VulnCheck's own catalog, not CISA's. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

## Table of contents

- [Timeline](#timeline)
- [Detection](#detection)
- [Remediation](#remediation)
- [Verification](#verification)
- [Compromise response](#compromise-response)
- [Sources](#sources)

## Timeline

| Event | Date and time (timezone) | Notes |
|---|---|---|
| Siemens advisory | 2026-08-11; time/TZ unknown | SSA-834709 V1.0. Fix is Industrial OS V4.3.4.1 or later. [SSA-834709][ssa] |
| CISA republication | 2026-08-25; time/TZ unknown | ICSA-26-237-03. CISA's initial release date for the same advisory is 2026-08-11. [CISA][cisa] |
| VulnCheck detection artifacts | 2026-10-27; time/TZ unknown | Initial Access customers received a proof of concept, scanner, and detection rules. [VulnCheck][vc] |
| Honeypot exploit attempts | 2026-10-30 through 2026-11-01; times not given | One source IP sent 16 `POST /flows` events. VulnCheck did not retrieve the downloaded binary. [VulnCheck][vc] |
| VulnCheck write-up | 2026-11-02; time/TZ unknown | Names the request, the drop paths, and the payload servers. [VulnCheck][vc] |
| **Last updated** | **2026-11-03 (America/New_York)** | New item. The August fix is unchanged. The new fact is the honeypot exploitation. |

## Detection

1. This CVE applies only to **SIMATIC IoT2050 Advanced, order 6ES7647-0BA00-1YA2**, running Industrial OS before V4.3.4.1 **and** with Node-RED installed. A different IoT2050 model, or this model without Node-RED, is outside Siemens' affected line.
2. Read the Industrial OS version from the device's support path (`get system` or the web status Siemens documents for that image). A version string of V4.3.4.1 or later is the fixed line. Anything lower with Node-RED installed is affected.
3. A Node-RED editor that loads with no login, on the device's HTTP port, is the exposed interface. Siemens does not publish a separate port number in SSA-834709. Node-RED's own default is 1880; do not treat a closed 1880 as proof the interface is off if the image binds it elsewhere.
4. VulnCheck's canary saw `POST /flows` from `4.201.105.116` (AS8075). The decoded commands saved a file as `/dev/shm/.b` from `http://85.215.73.250:8080/bot-linux-amd64`, or ran `/tmp/.s` from `wget.sh` on the same host, or saved `/tmp/.kworker` from `http://45.194.90.57:38472/.sys_update`. Later requests left an `http in` node (paths such as `/cmd`) wired to an `exec` node. A match in a proxy log or a flow export is an indicator. Absence is not a clean bill: VulnCheck says the same address used several user agents and payloads, and it did not fetch the binaries.
5. Review deployed flows for an `exec` node you did not add, and for an `http in` node whose path you do not recognize. A flow can remain after the downloaded file is gone. `/dev/shm` is RAM-backed, so a reboot removes `/dev/shm/.b` and does not remove a flow.

## Remediation

1. Update SIMATIC IoT2050 Advanced to **Industrial OS V4.3.4.1 or later** from [Siemens support entry 109741799](https://support.industry.siemens.com/cs/ww/en/view/109741799/). Siemens' advisory was last updated 2026-08-11 and still names that version.
2. If Node-RED is not needed, uninstall it. That removes the interface this CVE uses.
3. If you still need Node-RED before the update, set `adminAuth` as the [Node-RED securing guide](https://nodered.org/docs/user-guide/runtime/securing-node-red) describes, and do not expose the HTTP listener to the internet. Siemens lists both as mitigations. Neither replaces V4.3.4.1.
4. A generic Node-RED install that is not this Siemens image is not covered by SSA-834709's version number. The same missing-authentication default is what the honeypot answered. Set `adminAuth` there too, and keep the editor off untrusted networks.

## Verification

- After the update, read the running Industrial OS version and confirm it is V4.3.4.1 or later. A downloaded image that is not the booted image is not the fix.
- From a network that should not manage the device, confirm the Node-RED editor does not load. Do not send a flow.
- Export the flow list and confirm it contains no `exec` node and no `http in` path you did not deploy.

## Compromise response

- Preserve the flow configuration and any proxy logs before you update. The update does not say it deletes flows an attacker already deployed.
- If a flow contains an unexpected `exec` or `http in` node, or if `/dev/shm/.b`, `/tmp/.s`, or `/tmp/.kworker` is present, take the device off the network, keep the image for review, and redeploy from a known image rather than deleting the node and calling it clean. VulnCheck did not retrieve the binaries, so their behavior after download is unknown.
- Rotate credentials stored on the device. A command run as the Node-RED user can read what that user can read.

## Sources

- [Siemens SSA-834709](https://cert-portal.siemens.com/productcert/html/ssa-834709.html)
- [CISA ICSA-26-237-03](https://www.cisa.gov/news-events/ics-advisories/icsa-26-237-03)
- [CVE-2026-58115](https://www.cve.org/CVERecord?id=CVE-2026-58115)
- [VulnCheck, 2026-11-02: Exploitation Targeting Node-RED](https://www.vulncheck.com/blog/exploitation-targeting-node-red)

[ssa]: https://cert-portal.siemens.com/productcert/html/ssa-834709.html
[cisa]: https://www.cisa.gov/news-events/ics-advisories/icsa-26-237-03
[vc]: https://www.vulncheck.com/blog/exploitation-targeting-node-red
