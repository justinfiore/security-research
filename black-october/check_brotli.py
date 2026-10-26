#!/usr/bin/env python3
"""Inventory HTTP response Brotli advertising; NOT a vulnerability scanner.

Python 3.9+, standard library only. No Brotli library is loaded, and response
bodies are never read or decompressed. Uses GET because HEAD can behave
differently. Each URL gets two Accept-Encoding probes, sent sequentially.

Usage:
  python3 check_brotli.py https://example.com/ https://example.com/app.js
  python3 check_brotli.py --file endpoints.txt > results.jsonl
  python3 check_brotli.py --file endpoints.txt --follow-redirects

Input file: one full http:// or https:// URL per line; blank lines and lines
starting with # are ignored. Use --file - to read stdin.
Output: one JSON object per response/hop/probe on stdout; summary on stderr.
Exit codes: 0 = probes completed (NOT a security pass), 1 = probe errors,
2 = invalid CLI arguments or unreadable input file.

BR_ADVERTISED means a Content-Encoding token is br, not that its bytes were
validated. NOT_OBSERVED means a 2xx response did not advertise br for this
request only. INCONCLUSIVE covers other statuses; ERROR covers failed probes.
None of these results establishes whether vulnerable decoding is reachable.

Test representative HTML, JS, CSS, JSON, and sufficiently large responses;
small pages, redirects, auth failures, caches, CDN rules, and content types
can hide compression. HTTP/1.1 only; HTTP/2/3 and browser behavior may differ.
Connections are direct (environment proxy settings are not used). TLS
certificates are verified. No credentials or cookies are sent or retained.
Redirects are off by default; --follow-redirects may contact other hosts,
including private addresses. HTTPS-to-HTTP redirects are refused. Run only
against authorized, safe-to-GET URLs. Output includes URLs: avoid secrets in
query strings and handle output accordingly. Timeout is per socket operation,
not a total wall-clock deadline. No retries are performed.
"""

import argparse
import http.client
import json
import math
import ssl
import sys
from collections import Counter
from urllib.parse import urljoin, urlsplit


PROBES = (
    ("prefer_br", "br, identity;q=0, *;q=0"),
    ("common", "gzip, deflate, br"),
)
REDIRECTS = {301, 302, 303, 307, 308}


def parse_url(url):
    if any(character.isspace() or ord(character) < 32 or ord(character) == 127
           for character in url):
        raise ValueError("URL must not contain whitespace or control characters")
    parts = urlsplit(url)
    if parts.scheme not in {"http", "https"} or not parts.hostname:
        raise ValueError("Provide a full http:// or https:// URL")
    if parts.username is not None or parts.password is not None:
        raise ValueError("Credentials in URLs are not supported")
    if parts.port is not None and parts.port == 0:
        raise ValueError("Port must be between 1 and 65535")
    return parts


def get_headers(url, accept_encoding, timeout, context):
    parts = parse_url(url)
    if parts.scheme == "https":
        connection = http.client.HTTPSConnection(
            parts.hostname, parts.port, timeout=timeout, context=context
        )
    else:
        connection = http.client.HTTPConnection(
            parts.hostname, parts.port, timeout=timeout
        )
    try:
        target = parts.path or "/"
        if parts.query:
            target += "?" + parts.query
        connection.request("GET", target, headers={
            "Accept-Encoding": accept_encoding,
            "Accept": "*/*",
            "User-Agent": "brotli-header-check/1.0",
            "Connection": "close",
        })
        # http.client does not decode Content-Encoding. Do not call read().
        with connection.getresponse() as response:
            return response.status, {
                name: response.getheader(name, "")
                for name in ("Content-Encoding", "Content-Type", "Vary", "Location")
            }
    finally:
        connection.close()


def probe(url, profile, accept_encoding, timeout, max_redirects, context):
    current = url
    seen = set()
    for hop in range(max_redirects + 1):
        row = {
            "input_url": url, "url": current, "profile": profile,
            "accept_encoding": accept_encoding, "hop": hop,
            "status": None, "content_encoding": "", "content_type": "",
            "vary": "", "location": "", "result": "ERROR", "error": "",
        }
        next_url = None
        try:
            seen.add(current)
            status, headers = get_headers(current, accept_encoding, timeout, context)
            encodings = {token.strip().lower()
                         for token in headers["Content-Encoding"].split(",")}
            row.update(
                status=status, content_encoding=headers["Content-Encoding"],
                content_type=headers["Content-Type"], vary=headers["Vary"],
                location=headers["Location"],
                result=("BR_ADVERTISED" if "br" in encodings else
                        "NOT_OBSERVED" if 200 <= status < 300 else "INCONCLUSIVE"),
            )
            if status in REDIRECTS and headers["Location"] and max_redirects:
                next_url = urljoin(current, headers["Location"])
                destination = parse_url(next_url)
                if urlsplit(current).scheme == "https" and destination.scheme == "http":
                    raise ValueError("Refusing HTTPS-to-HTTP redirect")
                if next_url in seen:
                    raise ValueError("Redirect loop")
                if hop == max_redirects:
                    raise ValueError("Redirect limit reached")
        except (OSError, ValueError, http.client.HTTPException) as error:
            row["error"] = f"{type(error).__name__}: {error}"
            # Preserve a successfully observed header even if redirect handling fails.
            yield row
            return
        yield row
        if next_url is None:
            return
        current = next_url


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("urls", nargs="*", help="Full HTTP(S) URLs")
    parser.add_argument("-f", "--file", help="URL list file, or - for stdin")
    parser.add_argument("--timeout", type=float, default=10.0,
                        help="Socket timeout in seconds (default: 10)")
    parser.add_argument("--follow-redirects", action="store_true",
                        help="Follow up to 5 redirects; may contact other hosts")
    args = parser.parse_args(argv)
    if not math.isfinite(args.timeout) or args.timeout <= 0:
        parser.error("--timeout must be a finite positive number")
    urls = list(args.urls)
    if args.file:
        try:
            if args.file == "-":
                lines = sys.stdin.read().splitlines()
            else:
                with open(args.file, encoding="utf-8-sig") as source:
                    lines = source.read().splitlines()
            urls.extend(line.strip() for line in lines
                        if line.strip() and not line.lstrip().startswith("#"))
        except (OSError, UnicodeError) as error:
            parser.error(str(error))
    urls = list(dict.fromkeys(urls))
    if not urls:
        parser.error("Provide at least one URL or a nonempty --file")

    context = ssl.create_default_context()
    counts = Counter()
    errors = 0
    for url in urls:
        for profile, accept_encoding in PROBES:
            for row in probe(url, profile, accept_encoding, args.timeout,
                             5 if args.follow_redirects else 0, context):
                print(json.dumps(row), flush=True)
                counts[row["result"]] += 1
                errors += bool(row["error"])
    print(f"Response/probe counts: {dict(counts)}; errors: {errors}. "
          "This is not a vulnerability assessment.", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
