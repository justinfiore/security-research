#!/usr/bin/env python3
"""Read package metadata without importing inspected packages.

Use a trusted Python 3.8+ interpreter:
    python3 -I -S python-package-inventory.py /absolute/path/to/site-packages [...]
On suspected compromised systems, inspect a snapshot from a clean host instead.
"""

import argparse
import os
from importlib.metadata import distributions
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("directories", nargs="+", type=Path)
args = parser.parse_args()

wanted = {"brotli", "brotlicffi", "pillow", "olefile", "litellm", "sap-cloud-sdk"}
for path in args.directories:
    if not path.is_dir():
        parser.error(f"UNKNOWN: not a package directory: {path}")
    # Fail explicitly for inaccessible directories, rather than reporting absence.
    try:
        with os.scandir(path) as entries:
            next(entries, None)
    except OSError as error:
        parser.error(f"UNKNOWN: cannot inspect {path}: {error}")
    found = set()
    print(f"Directory: {path}")
    for dist in distributions(path=[str(path)]):
        name = dist.metadata.get("Name", "")
        key = name.lower().replace("_", "-")
        if key in wanted:
            found.add(key)
            print(f"  {name}=={dist.version}")
    for name in sorted(wanted - found):
        print(f"  {name}: no distribution metadata found here")

print("Inventory only: compare versions with the report and verify vendor backports.")
print("Missing metadata does not exclude vendored copies or other environments.")
print("Metadata is not proof of binary integrity or absence of past compromise.")
