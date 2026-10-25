#!/bin/sh
# Read-only inventory, not an exploit or an automatic vulnerability verdict.
# Use on trusted systems; application CLIs may load application/startup code.
set -eu

usage() {
    echo 'Usage: sh stack-inventory.sh php|node|bun|ruby|gitlab' >&2
    echo '       sh stack-inventory.sh nextcloud /absolute/path/to/occ' >&2
    echo '       sh stack-inventory.sh go /absolute/path/to/deployed-binary' >&2
    exit 2
}

[ "$#" -ge 1 ] || usage
mode=$1
shift
case "$mode" in
    php|node|bun|ruby) tool=$mode; [ "$#" -eq 0 ] || usage ;;
    gitlab) tool=gitlab-rake; [ "$#" -eq 0 ] || usage ;;
    nextcloud) tool=php; [ "$#" -eq 1 ] || usage ;;
    go) tool=go; [ "$#" -eq 1 ] || usage ;;
    *) usage ;;
esac

if ! command -v "$tool" >/dev/null 2>&1; then
    echo "UNKNOWN: $tool is not on this user's PATH; check the deployment/container." >&2
    exit 2
fi
if [ "$#" -eq 1 ]; then
    case "$1" in /*) ;; *) usage ;; esac
    if [ ! -f "$1" ] || [ ! -r "$1" ]; then
        echo "UNKNOWN: cannot read file: $1" >&2
        exit 2
    fi
fi

echo "Inventory only: $mode (compare with the report and vendor backports)."
printf 'Tool on PATH: '
command -v "$tool"
case "$mode" in
    php)
        php -v
        php --ini
        php -r 'foreach (["session.serialize_handler", "session.upload_progress.enabled"] as $k) { echo $k, "=", ini_get($k), PHP_EOL; }'
        echo 'CLI PHP only: verify the web runtime and its effective settings separately.'
        ;;
    node)
        node -p 'JSON.stringify({node: process.versions.node, brotli: process.versions.brotli})'
        ;;
    bun) bun --version ;;
    ruby) ruby -v ;;
    gitlab) gitlab-rake gitlab:env:info ;;
    nextcloud) php "$1" app:list ;;
    go) go version -m "$1" ;;
esac
echo 'Successful inventory is not a clean bill of health or evidence of no past compromise.'
