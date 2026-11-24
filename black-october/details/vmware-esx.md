# VMware ESX: a network request runs code on the host

**Last updated:** 2026-11-24 (America/New_York)

[Main summary](../black-october-2026.md#vmware-esx-a-network-request-runs-code-on-the-host) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

On 2026-11-24 Broadcom published [VMSA-2026-0011][vmsa]. It covers 23 flaws in ESX, vCenter, Workstation, Fusion, VMware Tools, and Avi Load Balancer. Broadcom rates the advisory Critical, CVSS 3.1 range 3.4–9.8. Broadcom is the CNA. The three that need no login are each 9.8.

This is not [VMSA-2026-0009](vcenter.md). That advisory's authentication bypass, [CVE-2026-123890](https://www.cve.org/CVERecord?id=CVE-2026-123890), is already fixed on vCenter 8.0 U3m, and Broadcom's FAQ for this one says a vCenter already on 8.0 U3m does not need another vCenter update. vCenter 9.1 and 9.0 do. ESX was outside the November 19 advisory and is inside this one.

**[CVE-2026-123910](https://www.cve.org/CVERecord?id=CVE-2026-123910) and [CVE-2026-123911](https://www.cve.org/CVERecord?id=CVE-2026-123911) are each CVSS 3.1 9.8 Critical.** The vector is `CVSS:3.1/AV:N/AC:L/PR:N/UI:N/S:U/C:H/I:H/A:H`. Both are in the ESX I/O filter service. The first is a heap out-of-bounds write and the second is a use-after-free. Broadcom says a malicious actor with network access to ESX may execute code on the host. Neither needs a virtual machine. On ESXi 8.x the service is `IOFilterVP` and listens on TCP 9080.

**[CVE-2026-123903](https://www.cve.org/CVERecord?id=CVE-2026-123903) is CVSS 3.1 9.8 Critical**, the same vector. It is a second authentication bypass in the VMware Directory Service, five days after CVE-2026-123890. Broadcom says a malicious actor with network access to vCenter may bypass authentication and gain unauthorized access. Three teams reported it independently. Broadcom does not say it was used before the advisory.

**[CVE-2026-123912](https://www.cve.org/CVERecord?id=CVE-2026-123912) is CVSS 3.1 9.3 Critical on Workstation and Fusion**, `CVSS:3.1/AV:L/AC:L/PR:N/UI:N/S:C/C:H/I:H/A:H`, and **8.4 Important on ESX**. A local administrator inside a virtual machine runs code as that virtual machine's VMX process. On ESX, Broadcom says that stays inside the VMX sandbox. On Workstation and Fusion, it can run on the machine where the product is installed.

The other High row is [CVE-2026-123913](https://www.cve.org/CVERecord?id=CVE-2026-123913), CVSS 3.1 8.2: a stack-based buffer overflow in the VMkernel. It needs privileges the attacker already has inside the VMX process. The rest of the advisory is Important or lower and needs a login, a backup repository, or root. Broadcom lists no exploitation of any of the 23.

**CISA KEV:** Not listed (catalog 2026.11.23, checked 2026-11-24) for any CVE in VMSA-2026-0011. CVE-2026-123890 is a different flaw and is listed under [the November 19 guide](vcenter.md). Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| **Public announcement and fixes** | **2026-11-24; time/TZ unknown** | VMSA-2026-0011, initial advisory. Issue date 2026-11-24. [VMSA][vmsa] |
| ESXi 8 workaround | 2026-11-24; time/TZ unknown | KB463535. Restrict TCP 9080 to the vCenter address. Not a fix. [KB][kb535] |
| **Last updated** | **2026-11-24 (America/New_York)** | New item. Patch ESX and vCenter 9. The 8.0 vCenter build from November 19 already covers the new vCenter flaws. |

## Detection

Read the build from the host and from vCenter, not from a plan. Cloud Foundation 9 and vSphere Foundation 9 call the hypervisor ESX. Older lines still say ESXi. The patch names keep the ESXi prefix.

- ESX 9.1 below **ESXi-9.1.2.0-25946735** is inside both 9.8 host flaws.
- ESX 9.0 below **ESXi-9.0.2.0200-25953133** is inside both 9.8 host flaws. That build does not fix CVE-2026-123914 or CVE-2026-123915. The matrix says **Patch Pending** for those two on 9.0, and both are Moderate: they need root on a host that already has Secure Boot.
- ESX 8.0 below **ESXi80U3m-25926933** is inside both. vSphere 8 has to be on Update 3 before that build applies.
- ESX 7.0 has no public build. An extended-support contract is the path Broadcom names.
- vCenter 9.1 below **9.1.2**, and vCenter 9.0 below **9.0.2.0300**, are inside CVE-2026-123903. vCenter **8.0 U3m** is the 8.0 floor, and it is the same build as VMSA-2026-0009. A vCenter already on 8.0 U3m does not move again for this advisory.
- Workstation and Fusion 25H2 below **26H1u1** are inside CVE-2026-123912.
- VMware Tools 13.x below **13.1.10.0**, and 12.x or 11.x below **12.5.6.0**, are inside CVE-2026-123918, a denial of service. 12.4.11, inside 12.5.6, covers Windows 32-bit. open-vm-tools comes from the Linux vendor, and Broadcom says that package is still to be distributed.

On ESXi 8.x, `IOFilterVP` listening on TCP 9080 is the service the two 9.8 flaws use. A closed port today does not show whether it was reachable before the update.

## Remediation

1. Update ESX 9.1 to **ESXi-9.1.2.0-25946735**, ESX 9.0 to **ESXi-9.0.2.0200-25953133**, and ESX 8.0 to **ESXi80U3m-25926933**. Cloud Foundation 5.x applies the 8.0 build through **5.2.5** and [KB 88287][kb882]. Telco Cloud follows [KB463501][kb501]. The updates are not eligible for ESX Live Patch. Each host restarts. Update the vSAN Witness Appliance to the same ESX build, and update the host that runs that appliance.
2. ESX 9.0 stays inside CVE-2026-123914 and CVE-2026-123915 after 9.0.2.0200. Broadcom marks both Patch Pending. Both need root on the host. There is no second build to wait for before installing 9.0.2.0200.
3. Update vCenter 9.1 to **9.1.2** and vCenter 9.0 to **9.0.2.0300**. Leave a vCenter that is already on **8.0 U3m** where it is. vCenter 7.0 and ESX 7.0 have no public build. Check the interoperability matrix before moving vCenter ahead of ESX. Updating vCenter does not update ESX, and updating SDDC Manager for the November 19 advisory does not update ESX either.
4. Update Workstation and Fusion 25H2 to **26H1u1**. Update VMware Tools to **13.1.10.0** or **12.5.6.0**. A Linux guest that uses open-vm-tools waits on the distribution package. Broadcom says that package is not out yet.
5. On ESXi 8.x, until the host restarts onto the build, [KB463535][kb535] restricts TCP 9080 to the vCenter Server address. Broadcom's FAQ says that is not a substitute for the update, and that it can affect the cluster. It does nothing for the vCenter bypass or for ESX 9.

## Verification

- Each host reports ESXi-9.1.2.0-25946735, ESXi-9.0.2.0200-25953133, or ESXi80U3m-25926933, and has restarted onto it.
- vCenter 9.1 reports 9.1.2, or vCenter 9.0 reports 9.0.2.0300. A vCenter on 8.0 U3m is current for both advisories.
- Workstation or Fusion reports 26H1u1. Guests report Tools 13.1.10.0 or 12.5.6.0, except a Linux guest still waiting on open-vm-tools.
- Do not send a request to port 9080 or to the Directory Service to test either flaw.

## Compromise response

Broadcom reports no exploitation. A host that was reachable on TCP 9080 before the restart, or a vCenter 9 that was reachable before 9.1.2 or 9.0.2.0300, has no vendor indicator to look for. The update does not show whether code already ran on the host. Review ESX for a VIB or a configuration change you did not make, and review vCenter for an SSO account you did not create. The November 19 indicator list belongs to CVE-2026-123890 and is not evidence about these three.

## Sources

- [VMSA-2026-0011][vmsa] — initial advisory, issue date 2026-11-24. Critical, CVSS 3.1 range 3.4–9.8. The three 9.8 flaws and the fixed builds are in this advisory.
- [VMSA-2026-0011 questions and answers][faq] — vCenter 8.0 U3m from VMSA-2026-0009 does not need another vCenter update. ESX updates are not eligible for Live Patch. ESX 9.0's fixed build for the critical flaws is the 9.0.2 express patch.
- [KB463535][kb535] — updated 2026-11-24. ESXi 8.x only. Restrict `IOFilterVP` on TCP 9080 to the vCenter address. Not a fix.
- [CVE-2026-123910](https://www.cve.org/CVERecord?id=CVE-2026-123910), [CVE-2026-123911](https://www.cve.org/CVERecord?id=CVE-2026-123911), and [CVE-2026-123903](https://www.cve.org/CVERecord?id=CVE-2026-123903) — the CVE.org pages were still reserved when checked on 2026-11-24. The scores and descriptions above are Broadcom's.
- [CISA KEV JSON][kev] — catalog 2026.11.23, checked 2026-11-24. None of this advisory is listed.

[vmsa]: https://support.broadcom.com/web/ecx/support-content-notification/-/external/content/SecurityAdvisories/0/39626
[faq]: https://brcm.tech/vmsa-2026-0011-qna
[kb535]: https://knowledge.broadcom.com/external/article/463535
[kb882]: https://knowledge.broadcom.com/external/article?legacyId=88287
[kb501]: https://knowledge.broadcom.com/external/article/463501
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
