#!/usr/bin/env python3
"""
Fetch a small EPO OPS sample (DOCDB XML) for local testing.

Requires either:
- EPO_OPS_TOKEN (bearer token), OR
- EPO_OPS_KEY + EPO_OPS_SECRET (client credentials).

Outputs XML files to DATA/epo_ops_sample by default.
"""
from __future__ import annotations

import base64
import json
import os
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import Request, urlopen


OPS_TOKEN_URL = "https://ops.epo.org/3.2/auth/accesstoken"
OPS_BIBLIO_URL = (
    "https://ops.epo.org/rest-services/published-data/publication/docdb/{pub}/biblio"
)

DEFAULT_PUBS = [
    "EP1000000.A1",
    "EP1000001.A1",
    "EP1000002.A1",
    "EP1000003.A1",
    "EP1000004.A1",
]


def get_token_from_env() -> str:
    token = os.getenv("EPO_OPS_TOKEN", "").strip()
    if token:
        return token

    key = os.getenv("EPO_OPS_KEY", "").strip()
    secret = os.getenv("EPO_OPS_SECRET", "").strip()
    if not key or not secret:
        raise RuntimeError(
            "Missing credentials. Set EPO_OPS_TOKEN or EPO_OPS_KEY/EPO_OPS_SECRET."
        )

    auth = base64.b64encode(f"{key}:{secret}".encode("utf-8")).decode("ascii")
    payload = urlencode({"grant_type": "client_credentials"}).encode("utf-8")
    req = Request(
        OPS_TOKEN_URL,
        data=payload,
        headers={
            "Authorization": f"Basic {auth}",
            "Content-Type": "application/x-www-form-urlencoded",
        },
        method="POST",
    )
    with urlopen(req, timeout=30) as resp:
        data = json.loads(resp.read().decode("utf-8"))
    token = data.get("access_token", "")
    if not token:
        raise RuntimeError("Could not obtain access token from OPS.")
    return token


def fetch_pub(token: str, pub: str, out_dir: Path) -> Path:
    url = OPS_BIBLIO_URL.format(pub=pub)
    req = Request(
        url,
        headers={"Authorization": f"Bearer {token}", "Accept": "application/xml"},
        method="GET",
    )
    with urlopen(req, timeout=30) as resp:
        content = resp.read()
    out_path = out_dir / f"{pub}.xml"
    out_path.write_bytes(content)
    return out_path


def main() -> int:
    out_dir = Path("DATA/epo_ops_sample")
    out_dir.mkdir(parents=True, exist_ok=True)

    pubs = sys.argv[1:] if len(sys.argv) > 1 else DEFAULT_PUBS
    token = get_token_from_env()

    for pub in pubs:
        try:
            path = fetch_pub(token, pub, out_dir)
            print(f"Saved {pub} -> {path}")
            time.sleep(0.2)
        except HTTPError as exc:
            print(f"HTTP error for {pub}: {exc.code} {exc.reason}")
        except URLError as exc:
            print(f"URL error for {pub}: {exc.reason}")
        except Exception as exc:
            print(f"Error for {pub}: {exc}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
