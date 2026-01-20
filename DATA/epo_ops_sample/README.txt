This folder holds small EPO OPS XML samples for local testing.

Usage:
  export EPO_OPS_KEY="your_key"
  export EPO_OPS_SECRET="your_secret"
  python3 CODE/Data/scripts/epo_ops_fetch_sample.py

You can also pass specific DOCDB publication numbers:
  python3 CODE/Data/scripts/epo_ops_fetch_sample.py EP1000000.A1 EP1000001.A1

Output files are saved as <publication>.xml in this folder.
