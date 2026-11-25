# Hex.pm: an Erlang request body ran commands on the registry

**Last updated:** 2026-11-25 (America/New_York)

[Main summary](../black-october-2026.md#hexpm-an-erlang-request-body-ran-commands-on-the-registry) · [Main TOC](../black-october-2026.md#table-of-contents) · [Changelog](../../CHANGELOG.md)

Hex.pm is the package registry Elixir and Erlang projects fetch dependencies from. On November 23 an unauthenticated request ran operating-system commands on six of its web servers. The same week the maintainers found the same class of flaw in Ash's keyset pagination.

**The Erlang Ecosystem Foundation rates [CVE-2026-129514](https://www.cve.org/CVERecord?id=CVE-2026-129514) CVSS 4.0 10.0 Critical.** The vector is `CVSS:4.0/AV:N/AC:L/AT:N/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H/E:A`. The `E:A` is the foundation marking the attack as exploited. Hex.pm decoded `application/vnd.hex+erlang` bodies with `Plug.Crypto.non_executable_binary_to_term/2` before routing and before any login check. That decoder refuses functions and new atoms. It accepts a map with a `__struct__` key, which Elixir treats as a struct. Error reporting then calls `inspect` on the request, and the attacker chooses which `Inspect` and `Enumerable` implementations run. A chain through `Ecto.Query.DynamicExpr` and `DBConnection.Stream` reaches `apply/3` on a `{module, function, args}` tuple taken from the body. The call runs as the BEAM user, which can read the database URL, the storage credentials, and the registry signing key. The safety check that would have rejected this was removed on 2016-02-23. The fix, commit `379b0a29bcc95164249f38ad7d772a37a8ff9533`, rejects any map that has a `__struct__` key and returns 400.

**The same foundation rates [CVE-2026-124283](https://www.cve.org/CVERecord?id=CVE-2026-124283) CVSS 4.0 8.9 High**, `CVSS:4.0/AV:L/AC:L/AT:P/PR:N/UI:N/VC:H/VI:H/VA:H/SC:H/SI:H/SA:H`. Ash 3.31.3 before **3.38.0** decodes a client-supplied keyset cursor from Erlang term format. The check added for an earlier flaw does not look inside a struct. A cursor value for a `:ci_string`, `:map`, `:struct`, or `:term` sort field can reach AshPostgres, run a function the cursor names, or write an `Ash.Query.Function.Fragment` into the SQL as raw text. The foundation scored the attack vector local. The cursor arrives as a query parameter on any API that accepts it. **3.38.0** encodes unsigned keysets as JSON. A `keyset_signing_secret`, available from 3.37.0, also closes the path and invalidates cursors issued before the change. [CVE-2026-133555](https://www.cve.org/CVERecord?id=CVE-2026-133555) is the DBConnection hop, the same 8.9 vector, in `db_connection` 1.1.0 before **2.10.3**. The foundation says that library is not exploitable by itself: some other component has to decode an untrusted term into the struct.

**CISA KEV:** Not listed (catalog 2026.11.24, checked 2026-11-25) for CVE-2026-129514, CVE-2026-124283, or CVE-2026-133555. Hex reported the registry incident to CISA on November 23 at 23:05 UTC, and CISA confirmed receipt at 23:43 UTC. That report is not a KEV listing. Absence from KEV is not evidence that exploitation has not occurred. [What KEV means](../black-october-2026.md#what-cisa-kev-means).

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
| Decoder check removed | 2016-02-23; time/TZ unknown | Hex's git history. The vulnerable decoder dates from that day. [Hex][hex] |
| Attack on hex.pm | 2026-11-23 18:16:00–18:29:33 UTC | 69 requests. Six web servers ran commands. Firewall rule at 18:27, full effect 18:30–18:33. [Hex][hex] |
| Patched build | 2026-11-23 18:30–18:31 UTC | Every web, worker, and job server replaced. [Hex][hex] |
| CVE published | 2026-11-24 13:48 UTC | CVE-2026-129514. The OSV record's published time. [OSV][osv] |
| **Public incident post** | **2026-11-24; time/TZ unknown** | Hex dates the post November 24 and prints no clock time. [Hex][hex] |
| Ash 3.38.0 | 2026-11-24 02:57 UTC | CVE-2026-124283 published 02:34 UTC. Advisory at 02:29 UTC. [CVE][ashcve] |
| DBConnection record | 2026-11-24 14:12:48 UTC | CVE-2026-133555. Fixed in 2.10.3. |
| **Last updated** | **2026-11-25 (America/New_York)** | New item. Change the Hex password. |

## Detection

1. A Hex account needs the password change whether or not you can see anything wrong. Hex says database reads are not logged.
2. For a self-hosted hexpm checkout, the vulnerable decoder is `HexpmWeb.ErlangFormat.decode/1` before commit `379b0a2`. The public hex.pm service was patched by 18:31 UTC on November 23; a fork was not.
3. For Ash, read the resolved version. 3.31.3 through 3.37.x is inside CVE-2026-124283 when a read action uses keyset pagination, accepts a client `page[:after]` or `page[:before]`, sorts on a `:ci_string`, `:map`, `:struct`, or `:term` field, and `config :ash, :keyset_signing_secret` is unset. Offset pagination, or a sort that is only integers, dates, UUIDs, or strings, is outside the cast the advisory describes.
4. `mix deps.tree` or `mix.lock` shows `ash` and `db_connection`. A lockfile that is not what the running release was built from is unknown, not safe.

Do not send a crafted Erlang term to test either flaw.

## Remediation

1. On hex.pm, change the password. Reset two-factor authentication at the dashboard security page so the authenticator secret and the recovery codes are new. Hex says API key hashes are HMAC-SHA256 of 128-bit values and does not ask you to rotate API keys for the hashes alone.
2. Until Hex ships the client with the new registry signing system, fetch packages only from `repo.hex.pm`. Do not use a third-party mirror. Hex says that client is "in the coming days" and names no version yet. `mix local.hex --force` is how Hex says to pick it up once it exists.
3. A self-hosted hexpm application needs commit `379b0a2` or later and a restart. The public service is already on that build. Rotating a self-hosted deployment's own secrets is a separate decision: Hex rotated the public service's storage, CDN, email, and database credentials because the BEAM user could read them.
4. Upgrade `ash` to **3.38.0 or later** and redeploy. On 3.37.0 or later, setting `keyset_signing_secret` also closes CVE-2026-124283 and invalidates every cursor issued before the change. Upgrade `db_connection` to **2.10.3 or later**. That upgrade does not fix a decoder you wrote yourself.

Changing the Hex password does not show whether the database was read, and it does not replace the registry signing key. Hex says that key was not rotated.

## Verification

The Hex dashboard accepts the new password and a code from the new authenticator entry. `mix hex.info` still resolves packages from `repo.hex.pm`. A self-hosted checkout's `HexpmWeb.ErlangFormat` rejects a map that has a `__struct__` key. `mix deps.tree` shows `ash` 3.38.0 or later and `db_connection` 2.10.3 or later. Do not send an exploit term.

## Compromise response

Hex's own investigation is the record for the public registry: no modified packages in the checks it describes, no unexplained database writes, and a read of the database that cannot be ruled out. Treat the password as exposed to offline guessing. Forward a suspicious Hex email to `security@hex.pm`, and confirm any link is `hex.pm`.

For an Ash application that accepted keyset cursors on an affected version, treat the database role and the BEAM process's secrets as exposed if a forged cursor cannot be excluded. Rotate those credentials and review rows the application role could write. The upgrade does not undo a query that already ran.

## Sources

- [Hex, Security incident on hex.pm][hex] — November 24, 2026. Attack window 18:16–18:29 UTC. Six servers. No modified packages found. Database reads not ruled out. Registry signing key not rotated.
- [GHSA-9pmm-hf4r-27pg][ghsa] — Critical, CVSS 4.0 10.0, vector with `E:A`. Affected from 2016-02-23 before 2026-11-23. Fix commit `379b0a2`.
- [CVE-2026-129514](https://www.cve.org/CVERecord?id=CVE-2026-129514) — Erlang Ecosystem Foundation. Published 2026-11-24.
- [CVE-2026-124283][ashcve] — Ash 3.31.3 before 3.38.0. CVSS 4.0 8.9. The vector is local.
- [GHSA-m5v6-3qwf-6w9r](https://github.com/ash-project/ash/security/advisories/GHSA-m5v6-3qwf-6w9r) — published 2026-11-24 02:29 UTC. Ash 3.38.0 at 02:57 UTC.
- [CVE-2026-133555](https://www.cve.org/CVERecord?id=CVE-2026-133555) — `db_connection` 1.1.0 before 2.10.3. The foundation says it is not exploitable alone.
- [CISA KEV JSON][kev] — catalog 2026.11.24, checked 2026-11-25. None of the three is listed.

[hex]: https://hex.pm/blog/security-incident-on-hexpm
[ghsa]: https://github.com/hexpm/hexpm/security/advisories/GHSA-9pmm-hf4r-27pg
[osv]: https://osv.dev/vulnerability/EEF-CVE-2026-129514
[ashcve]: https://www.cve.org/CVERecord?id=CVE-2026-124283
[kev]: https://www.cisa.gov/sites/default/files/feeds/known_exploited_vulnerabilities.json
