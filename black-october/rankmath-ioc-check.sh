#!/bin/sh
# Rank Math PRO 3.0.123 incident (CVE-2026-111862): read-only offline IOC check.
#
# Usage:
#   sh rankmath-ioc-check.sh WP_ROOT [EVIDENCE_FILE ...]
#
#   WP_ROOT        WordPress root directory (contains wp-includes/ and
#                  wp-content/). Prefer a read-only mounted copy or snapshot of
#                  a suspect site, inspected from a clean host.
#   EVIDENCE_FILE  Optional text exports made by the operator, for example an
#                  SQL dump of the site database, saved query output listing
#                  wp_options names and administrator users, or a saved
#                  `crontab -l` listing for the web server user.
#
# Exit status:
#   0  no indicators found by the checks that ran. NOT proof the site is clean.
#   1  at least one indicator found (investigate; see the detailed guide).
#   2  unknown: bad arguments, unreadable input, not a WordPress root, a scan
#      error, or a Rank Math PRO 3.0.123 copy whose download time the files
#      cannot establish. Status 1 takes precedence over 2.
#
# The script only reads files with find, grep, sed and ls. It does not run PHP,
# WordPress, WP-CLI or a database client, contact the network, follow symlinks
# or change anything. It needs no privileges beyond read access to the inputs.
# Indicators come from the Rank Math incident notice:
# https://rankmath.com/kb/pro-3-0-123-security-incident/
set -u

found=0
unknown=0

usage() {
    echo 'Usage: sh rankmath-ioc-check.sh WP_ROOT [EVIDENCE_FILE ...]' >&2
    exit 2
}

indicator() { found=1; printf 'INDICATOR: %s\n' "$*"; }
# shellcheck disable=SC2317 # called indirectly through report_scan
review() { found=1; printf 'INDICATOR (heuristic; review context): %s\n' "$*"; }
unknown() { unknown=1; printf 'UNKNOWN: %s\n' "$*"; }
info() { printf 'INFO: %s\n' "$*"; }

# Run find with the given arguments; print "H path" for matching files and
# "E message" for find/grep errors, so unreadable files become UNKNOWN.
tagged_find() {
    { { find "$@" | sed 's/^/H /'; } 2>&1 1>&3 | sed 's/^/E /' 1>&3; } 3>&1
}

report_scan() { # $1 = label, $2 = indicator|review; stdin = tagged_find output
    label=$1
    kind=$2
    while IFS= read -r line; do
        case "$line" in
            'H '*) "$kind" "$label: ${line#H }" ;;
            'E '*) unknown "scan error ($label): ${line#E }" ;;
        esac
    done
}

[ "$#" -ge 1 ] || usage
case "$1" in -*) usage ;; esac
root=$1
shift

if [ ! -d "$root" ] || [ ! -r "$root" ] || [ ! -x "$root" ]; then
    echo "UNKNOWN: cannot read directory: $root" >&2
    exit 2
fi
if [ ! -d "$root/wp-includes" ] || [ ! -d "$root/wp-content" ]; then
    echo "UNKNOWN: $root does not look like a WordPress root (no wp-includes/ or wp-content/)." >&2
    exit 2
fi
for f in "$@"; do
    if [ ! -f "$f" ] || [ ! -r "$f" ]; then
        echo "UNKNOWN: cannot read evidence file: $f" >&2
        exit 2
    fi
done

echo "Rank Math PRO 3.0.123 incident IOC check (read-only) of: $root"

# 1. Fake core file named by the vendor.
fake="$root/wp-includes/class-wp-cache-util.php"
if [ -e "$fake" ] || [ -L "$fake" ]; then
    indicator "fake WordPress core file present: $fake"
    ls -l "$fake" 2>/dev/null
else
    info "no wp-includes/class-wp-cache-util.php"
fi

# 2. Installed Rank Math PRO version (default folder name only).
plugdir="$root/wp-content/plugins/rank-math-pro"
if [ -d "$plugdir" ]; then
    ver=
    for p in "$plugdir"/*.php; do
        [ -f "$p" ] || continue
        if grep -q 'Plugin Name:' "$p" 2>/dev/null; then
            ver=$(sed -n 's/^[[:space:]*#@]*Version:[[:space:]]*\([^[:space:]]*\).*/\1/p' "$p" | head -n 1)
            if [ -n "$ver" ]; then
                info "Rank Math PRO header in $p: Version $ver"
                ls -l "$p"
                break
            fi
        fi
    done
    case "$ver" in
        '') unknown "could not read the Rank Math PRO version header in $plugdir" ;;
        3.0.123) unknown "Rank Math PRO 3.0.123 is installed. The version alone does not show whether this copy was downloaded in the affected window (2026-10-15 20:02 UTC to 2026-10-16 07:12 UTC); file times are not reliable download times. Establish when it was obtained and activated, or treat it as affected." ;;
        *) info "installed version is not 3.0.123; this says nothing about earlier activation of an affected copy" ;;
    esac
else
    info "no wp-content/plugins/rank-math-pro folder (it may have been removed, renamed, or never installed)"
fi

# 3. Vendor-named strings in PHP, .cache and .htaccess files anywhere under the root.
out=$(tagged_find "$root" -type f \( -name '*.php' -o -name '*.cache' -o -name '.htaccess' -o -name '*.inc' -o -name '*.phtml' \) \
    -exec grep -l -F -e 'xmmqhn' -e 'rank1cdn' {} +)
report_scan "file contains vendor-named key 'xmmqhn' or domain 'rank1cdn'" indicator <<EOF
$out
EOF

# 4. .cache files containing PHP code, and .htaccess rules that make .cache run as PHP.
out=$(tagged_find "$root" -type f -name '*.cache' -exec grep -l -F '<?php' {} +)
report_scan ".cache file containing PHP code" review <<EOF
$out
EOF
# Same-line match only; a multi-line <FilesMatch> block needs manual review.
out=$(tagged_find "$root" -type f -name '.htaccess' \
    -exec grep -l -i -E '\.cache.*(php|handler)|(php|handler).*\.cache' {} +)
report_scan ".htaccess line pairing .cache with PHP/handler (check whether it makes .cache files execute)" review <<EOF
$out
EOF

# 5. Operator-supplied database/cron exports.
if [ "$#" -eq 0 ]; then
    info "NOT CHECKED: wp_options names, administrator accounts and cron entries (supply an SQL dump or saved query/crontab output)."
else
    for f in "$@"; do
        for pat in _uf6qdn2hmm t8krdk990phb _np5pvf754c; do
            if grep -F -e "$pat" "$f" >/dev/null 2>&1; then
                indicator "$f: malicious wp_options name $pat"
            fi
        done
        if grep -F -e 'wpsupport_' "$f" >/dev/null 2>&1; then
            indicator "$f: 'wpsupport_' (vendor-named admin username prefix); confirm the account and its role"
        fi
        if grep -i -F -e '@wp-mail.net' "$f" >/dev/null 2>&1; then
            indicator "$f: '@wp-mail.net' account email"
        fi
        if grep -i -F -e 'rank1cdn' "$f" >/dev/null 2>&1; then
            indicator "$f: 'rank1cdn' domain"
        fi
        if grep -F -e '#ms6v46' "$f" >/dev/null 2>&1; then
            indicator "$f: cron marker '#ms6v46'"
        fi
    done
fi

echo 'Not checked here: PHP files without the named strings (uploads, mu-plugins, themes, other plugins), SSH keys, processes, other system users, logs and network traffic.'
if [ "$found" -eq 1 ]; then
    echo 'RESULT: indicator(s) found. Treat the site as compromised and follow the incident guide.'
    exit 1
elif [ "$unknown" -eq 1 ]; then
    echo 'RESULT: unknown. Resolve the UNKNOWN lines above.'
    exit 2
fi
echo 'RESULT: no indicators found by these checks. This is not proof that the site is clean.'
exit 0
