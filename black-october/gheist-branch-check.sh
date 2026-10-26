#!/bin/sh
# Gheist campaign (stolen GitHub tokens planting secret-dumping workflows):
# read-only check for planted ci-sync-* branches through the GitHub API.
#
# Usage:
#   sh gheist-branch-check.sh [--no-runs] TARGET [TARGET ...]
#
#   TARGET     An organization or user login (every repository that
#              `gh repo list TARGET` returns to your token is checked), or a
#              single repository written OWNER/REPO.
#   --no-runs  Skip listing the workflow runs that remain on each matching
#              branch (saves one API request per matching branch).
#
# Requirements: GitHub CLI `gh`, already authenticated (`gh auth login`, or
# GH_TOKEN / GH_ENTERPRISE_TOKEN in the environment). Set GH_HOST for GitHub
# Enterprise Server. The token needs read access to repository contents,
# metadata and Actions (classic: `repo`; fine-grained: Contents, Metadata and
# Actions read-only) for private repositories.
#
# Output (one line per result):
#   INDICATOR: ...  a branch named ci-sync- plus six [0-9a-z] characters. The
#                   line says whether its head commit matches the published
#                   pattern (message "ci: sync config", only
#                   .github/workflows/sync-check.yml) and whether the workflow
#                   file is one of the four blob SHAs Wiz published.
#   REVIEW: ...     a branch that starts with ci-sync- but does not match the
#                   six-character pattern (could be legitimate).
#   RUN: ...        a workflow run still listed on a matching branch.
#   UNKNOWN: ...    a repository, branch or commit that could not be read.
#   INFO: ...       progress and summary.
#
# Exit status:
#   0  no ci-sync-* branches found in any repository checked. NOT proof that
#      Gheist never touched them: branches can be deleted or renamed away.
#   1  at least one INDICATOR or REVIEW line (investigate; see the guide).
#   2  unknown: bad arguments, gh missing, a target that could not be listed,
#      or at least one repository/branch that could not be read.
#      Status 1 takes precedence over 2.
#
# The script only sends GET requests (`gh repo list` and `gh api` without
# fields). It does not create, approve, re-run, delete or modify anything,
# check out code, or run workflows. It prints no token values.
# Indicators come from Wiz Research, 2026-10-25:
# https://www.wiz.io/blog/gheist-attempted-scaled-abuse-of-stolen-github-tokens-stumbles
set -u

found=0
unknown=0
runs=1
checked=0
us=$(printf '\037') # field separator for gh --jq output (allows empty fields)

# Workflow blob SHAs published by Wiz (environment-matrix variants differ).
known_blob() {
    case "$1" in
        f3da2b8b357dcda02fd455d314be2a95007516a6) echo 'Wiz blob "plain"' ;;
        d09535857a741bbb976bdc084a9a021713133291) echo 'Wiz blob "timeout"' ;;
        1dc5af9cce950aad1eb1546ecce8565b117540c4) echo 'Wiz blob "separator"' ;;
        c665b778b2d822453293003e7ca0bbb2cb08e39d) echo 'Wiz blob "self-hosted job"' ;;
        *) echo '' ;;
    esac
}

usage() {
    echo 'Usage: sh gheist-branch-check.sh [--no-runs] TARGET [TARGET ...]' >&2
    echo '  TARGET is an org/user login or OWNER/REPO.' >&2
    exit 2
}

unknown() { unknown=1; printf 'UNKNOWN: %s\n' "$*"; }
info() { printf 'INFO: %s\n' "$*"; }

while [ "$#" -gt 0 ]; do
    case "$1" in
        --no-runs) runs=0; shift ;;
        --) shift; break ;;
        -*) usage ;;
        *) break ;;
    esac
done
[ "$#" -ge 1 ] || usage
for t in "$@"; do
    case "$t" in
        */*/*|/*|*/|'') usage ;;
        *[!A-Za-z0-9._/-]*) usage ;;
    esac
done

if ! command -v gh >/dev/null 2>&1; then
    echo 'UNKNOWN: GitHub CLI (gh) not found on PATH.' >&2
    exit 2
fi

tmp=$(mktemp -d 2>/dev/null) || { echo 'UNKNOWN: cannot create a temporary directory.' >&2; exit 2; }
trap 'rm -rf "$tmp"' EXIT HUP INT TERM

check_branch() { # $1 = owner/repo, $2 = branch, $3 = head sha
    repo=$1
    branch=$2
    sha=$3
    if ! gh api "repos/$repo/commits/$sha" --jq '[
            .commit.message,
            (.files | length | tostring),
            ([.files[].filename] | join(",")),
            ([.files[] | select(.filename == ".github/workflows/sync-check.yml") | .sha] | first // ""),
            (.commit.verification.verified | tostring),
            .commit.author.date,
            (.author.login // .commit.author.name // "")
        ] | map(tostring | gsub("[\n\r\u001f]"; " ")) | join("\u001f")' \
        </dev/null >"$tmp/commit" 2>"$tmp/err"; then
        found=1
        printf 'INDICATOR: %s branch %s (head %s): pattern-named branch; head commit unreadable\n' "$repo" "$branch" "$sha"
        unknown "$repo commit $sha: $(head -n 1 "$tmp/err")"
        return
    fi
    IFS=$us read -r msg nfiles files blob verified date author <"$tmp/commit"
    if [ "$msg" = 'ci: sync config' ] && [ "$nfiles" = 1 ] && [ "$files" = '.github/workflows/sync-check.yml' ]; then
        match='head commit matches the published pattern'
    else
        match='head commit differs from the published pattern; review the branch history'
    fi
    label=$(known_blob "$blob")
    [ -n "$label" ] && match="$match; workflow file is $label"
    found=1
    printf 'INDICATOR: %s branch %s (head %s): %s [message=%s; files=%s; signed=%s; author=%s; authored=%s]\n' \
        "$repo" "$branch" "$sha" "$match" "$msg" "$files" "$verified" "$author" "$date"

    [ "$runs" -eq 1 ] || return
    if ! gh api "repos/$repo/actions/runs?branch=$branch&per_page=100" \
            --jq '.workflow_runs[] | [.id, .name, .status, (.conclusion // ""), .created_at, .event]
                  | map(tostring | gsub("[\n\r\u001f]"; " ")) | join("\u001f")' \
            </dev/null >"$tmp/runs" 2>"$tmp/err"; then
        unknown "$repo branch $branch: cannot list workflow runs: $(head -n 1 "$tmp/err")"
        return
    fi
    if [ -s "$tmp/runs" ]; then
        while IFS=$us read -r id name status conclusion created event; do
            printf 'RUN: %s branch %s run %s "%s" status=%s conclusion=%s event=%s created=%s\n' \
                "$repo" "$branch" "$id" "$name" "$status" "$conclusion" "$event" "$created"
        done <"$tmp/runs"
    else
        info "$repo branch $branch: no workflow runs listed (runs may have been deleted; check the audit log)"
    fi
}

check_repo() { # $1 = owner/repo
    repo=$1
    if ! gh api "repos/$repo/git/matching-refs/heads/ci-sync-" \
            --jq '.[] | [(.ref | sub("^refs/heads/"; "")), .object.sha]
                  | map(tostring | gsub("[\n\r\u001f]"; " ")) | join("\u001f")' \
            </dev/null >"$tmp/refs-$checked" 2>"$tmp/err"; then
        if grep -q 'Git Repository is empty' "$tmp/err"; then
            info "$repo: empty repository (no branches)"
            return
        fi
        unknown "$repo: cannot list branches: $(head -n 1 "$tmp/err")"
        return
    fi
    while IFS=$us read -r branch sha; do
        [ -n "$branch" ] || continue
        if printf '%s\n' "$branch" | grep -Eq '^ci-sync-[0-9a-z]{6}$'; then
            check_branch "$repo" "$branch" "$sha"
        else
            found=1
            printf 'REVIEW: %s branch %s (head %s): starts with ci-sync- but does not match ^ci-sync-[0-9a-z]{6}$\n' \
                "$repo" "$branch" "$sha"
        fi
    done <"$tmp/refs-$checked"
}

for target in "$@"; do
    case "$target" in
        */*)
            checked=$((checked + 1))
            check_repo "$target"
            ;;
        *)
            if ! gh repo list "$target" --limit 100000 --json nameWithOwner \
                    --jq '.[].nameWithOwner' </dev/null >"$tmp/repos" 2>"$tmp/err"; then
                unknown "$target: cannot list repositories: $(head -n 1 "$tmp/err")"
                continue
            fi
            n=$(grep -c . "$tmp/repos")
            info "$target: $n repositories visible to this token"
            while IFS= read -r repo; do
                [ -n "$repo" ] || continue
                checked=$((checked + 1))
                check_repo "$repo"
            done <"$tmp/repos"
            ;;
    esac
done

info "repositories checked: $checked"
if [ "$found" -eq 1 ]; then
    info 'result: candidate Gheist branches found; see the detailed guide before deleting anything'
    exit 1
fi
if [ "$unknown" -eq 1 ]; then
    info 'result: UNKNOWN for at least one repository; no candidate branches in the rest'
    exit 2
fi
info 'result: no ci-sync-* branches found (not proof of no compromise: branches can be deleted)'
exit 0
