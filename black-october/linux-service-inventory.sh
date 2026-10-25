#!/bin/sh
# Local Linux inventory for KSMBD and Plex. No network probes or service changes.
set -eu

if [ "$(uname -s)" != Linux ]; then
    echo 'UNKNOWN: this script requires Linux; use the appliance/vendor interface.' >&2
    exit 2
fi
echo 'Running kernel:'
uname -r
if [ -d /sys/module/ksmbd ]; then
    echo 'KSMBD sysfs entry present: investigate configuration and vendor fix status.'
else
    echo 'No KSMBD sysfs entry: confirm kernel build and service configuration.'
fi

if command -v ss >/dev/null 2>&1; then
    echo 'TCP 445 listeners (KSMBD or Samba; the port alone cannot distinguish them):'
    ss -ltn 'sport = :445'
    echo 'TCP 32400 listeners (usual Plex port):'
    ss -ltn 'sport = :32400'
else
    echo 'UNKNOWN: ss is unavailable; listener inventory is incomplete.'
fi

echo 'RDMA devices visible through sysfs:'
if [ -d /sys/class/infiniband ]; then
    ls /sys/class/infiniband
else
    echo 'No RDMA device directory visible; confirm host configuration.'
fi
echo 'Local namespace only: absence here does not rule out services elsewhere.'
echo 'Listeners do not prove external reachability, affected versions, or compromise.'
