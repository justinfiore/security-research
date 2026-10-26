"""CLI integration tests using a disposable local HTTP server."""

import json
import subprocess
import sys
import tempfile
import threading
import time
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


SCRIPT = Path(__file__).with_name("check_brotli.py")


class Handler(BaseHTTPRequestHandler):
    def log_message(self, *args):
        pass

    def do_GET(self):
        if self.path == "/slow":
            time.sleep(0.3)
            return
        status = 200
        headers = []
        if self.path == "/br":
            headers = [("Content-Encoding", "br")]
        elif self.path == "/stacked":
            headers = [("Content-Encoding", "gzip"), ("Content-Encoding", "BR")]
        elif self.path == "/substring":
            headers = [("Content-Encoding", "not-br")]
        elif self.path == "/negotiated?asset=1":
            encoding = "gzip" if "gzip" in self.headers["Accept-Encoding"] else "br"
            headers = [("Content-Encoding", encoding)]
        elif self.path == "/redirect":
            status, headers = 302, [("Location", "/br")]
        elif self.path == "/loop":
            status, headers = 302, [("Location", "/loop")]
        elif self.path.startswith("/chain/"):
            index = int(self.path.rsplit("/", 1)[1])
            status, headers = 302, [("Location", f"/chain/{index + 1}")]
        elif self.path == "/denied":
            status = 403
        elif self.path == "/denied-br":
            status, headers = 403, [("Content-Encoding", "br")]
        self.send_response(status)
        for name, value in headers:
            self.send_header(name, value)
        self.send_header("Content-Type", "text/plain")
        self.send_header("Vary", "Accept-Encoding")
        # Deliberately omit the promised body. Reading it would fail, and
        # decoding it cannot validate Brotli. A header-only probe still works.
        self.send_header("Content-Length", "1000000")
        self.end_headers()


class CheckerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        cls.thread = threading.Thread(target=cls.server.serve_forever)
        cls.thread.start()
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def run_cli(self, *arguments, stdin=None, code=0):
        completed = subprocess.run(
            [sys.executable, str(SCRIPT), *arguments], input=stdin,
            capture_output=True, text=True, timeout=10,
        )
        self.assertEqual(completed.returncode, code, completed.stderr)
        return [json.loads(line) for line in completed.stdout.splitlines()]

    def test_encoding_tokens_and_header_only_get(self):
        for path, expected in (("/br", "BR_ADVERTISED"),
                               ("/stacked", "BR_ADVERTISED"),
                               ("/substring", "NOT_OBSERVED"),
                               ("/plain", "NOT_OBSERVED")):
            with self.subTest(path=path):
                rows = self.run_cli(self.base + path)
                self.assertEqual([row["result"] for row in rows], [expected] * 2)
                self.assertTrue(all(row["status"] == 200 for row in rows))
                self.assertTrue(all(row["vary"] == "Accept-Encoding" for row in rows))

    def test_negotiation_and_query_string(self):
        rows = self.run_cli(self.base + "/negotiated?asset=1")
        self.assertEqual([row["content_encoding"] for row in rows], ["br", "gzip"])
        self.assertEqual([row["result"] for row in rows],
                         ["BR_ADVERTISED", "NOT_OBSERVED"])

    def test_http_errors_are_not_negative_findings(self):
        rows = self.run_cli(self.base + "/denied", self.base + "/denied-br")
        self.assertEqual([row["result"] for row in rows],
                         ["INCONCLUSIVE"] * 2 + ["BR_ADVERTISED"] * 2)
        self.assertTrue(all(row["status"] == 403 for row in rows))

    def test_redirects_opt_in_and_preserve_each_hop(self):
        url = self.base + "/redirect"
        rows = self.run_cli(url)
        self.assertEqual([row["status"] for row in rows], [302, 302])
        rows = self.run_cli(url, "--follow-redirects")
        self.assertEqual([row["status"] for row in rows], [302, 200, 302, 200])
        self.assertEqual([row["result"] for row in rows],
                         ["INCONCLUSIVE", "BR_ADVERTISED"] * 2)
        self.assertTrue(all(row["input_url"] == url for row in rows))

    def test_redirect_loop_and_limit(self):
        for path, count, message in (("/loop", 2, "Redirect loop"),
                                     ("/chain/0", 12, "Redirect limit reached")):
            with self.subTest(path=path):
                rows = self.run_cli(self.base + path, "--follow-redirects", code=1)
                self.assertEqual(len(rows), count)
                self.assertIn(message, rows[-1]["error"])

    def test_invalid_url_does_not_stop_remaining_endpoints(self):
        rows = self.run_cli("file:///etc/passwd", self.base + "/br", code=1)
        self.assertEqual([row["result"] for row in rows],
                         ["ERROR"] * 2 + ["BR_ADVERTISED"] * 2)

    def test_timeout_is_an_error(self):
        rows = self.run_cli(self.base + "/slow", "--timeout", "0.05", code=1)
        self.assertEqual([row["result"] for row in rows], ["ERROR", "ERROR"])
        self.assertTrue(all("timed out" in row["error"] for row in rows))

    def test_list_file_stdin_and_deduplication(self):
        text = f"# endpoints\n\n{self.base}/br\n {self.base}/plain \n{self.base}/br\n"
        rows = self.run_cli("--file", "-", stdin=text)
        self.assertEqual([row["result"] for row in rows],
                         ["BR_ADVERTISED"] * 2 + ["NOT_OBSERVED"] * 2)
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "endpoints.txt"
            path.write_text(text, encoding="utf-8-sig")
            self.assertEqual(self.run_cli("--file", str(path)), rows)

    def test_invalid_arguments(self):
        self.run_cli(code=2)
        for timeout in ("0", "-1", "nan", "inf"):
            with self.subTest(timeout=timeout):
                self.run_cli(self.base, "--timeout", timeout, code=2)


if __name__ == "__main__":
    unittest.main()
