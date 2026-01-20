#!/usr/bin/env python3
"""
Interactive report generator for analysis outputs.

This script scans an output directory for figures/tables and creates a short
markdown report with links and embedded images.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import os
import shutil
import subprocess
import sys
from typing import Iterable, List, Tuple


def _prompt(text: str, default: str) -> str:
    value = input(f"{text} [{default}]: ").strip()
    return value or default


def _parse_keywords(raw: str) -> List[str]:
    return [item.strip().lower() for item in raw.split(",") if item.strip()]


def _match_keywords(name: str, keywords: Iterable[str]) -> bool:
    if not keywords:
        return True
    lower = name.lower()
    return any(keyword in lower for keyword in keywords)


def _collect_outputs(outputs_dir: str, keywords: Iterable[str]) -> Tuple[List[str], List[str], List[str]]:
    figure_images: List[str] = []
    tables: List[str] = []
    data_files: List[str] = []

    for root, _dirs, files in os.walk(outputs_dir):
        for filename in files:
            if not _match_keywords(filename, keywords):
                continue
            lower = filename.lower()
            full_path = os.path.join(root, filename)

            if lower.endswith(".png") and "figure" in lower:
                figure_images.append(full_path)
            elif lower.endswith(".xlsx") and "table" in lower:
                tables.append(full_path)
            elif lower.endswith(".xlsx") and "figure" in lower:
                data_files.append(full_path)
            elif lower.endswith(".xlsx") or lower.endswith(".csv"):
                data_files.append(full_path)

    return sorted(figure_images), sorted(tables), sorted(data_files)


def _relpath(path: str, report_dir: str) -> str:
    return os.path.relpath(path, report_dir)


def _title_from_filename(path: str) -> str:
    name = os.path.splitext(os.path.basename(path))[0]
    return name.replace("_", " ").strip()


def _write_report(
    report_path: str,
    outputs_dir: str,
    title: str,
    figures: List[str],
    tables: List[str],
    data_files: List[str],
) -> str:
    report_dir = os.path.dirname(report_path)
    timestamp = _dt.datetime.now().strftime("%Y-%m-%d %H:%M")

    lines: List[str] = []
    lines.append(f"# {title}")
    lines.append("")
    lines.append(f"Generated: {timestamp}")
    lines.append(f"Outputs scanned: `{outputs_dir}`")
    lines.append("")
    lines.append("## Summary")
    lines.append(f"- Figures found: {len(figures)}")
    lines.append(f"- Tables found: {len(tables)}")
    lines.append(f"- Data files found: {len(data_files)}")
    lines.append("")

    if figures:
        lines.append("## Figures")
        for path in figures:
            caption = _title_from_filename(path)
            rel = _relpath(path, report_dir)
            lines.append(f"### {caption}")
            lines.append(f"![{caption}]({rel})")
            lines.append("")

    if tables:
        lines.append("## Tables")
        for path in tables:
            caption = _title_from_filename(path)
            rel = _relpath(path, report_dir)
            lines.append(f"- {caption}: `{rel}`")
        lines.append("")

    if data_files:
        lines.append("## Data Exports")
        for path in data_files:
            caption = _title_from_filename(path)
            rel = _relpath(path, report_dir)
            lines.append(f"- {caption}: `{rel}`")
        lines.append("")

    content = "\n".join(lines)
    with open(report_path, "w", encoding="utf-8") as handle:
        handle.write(content)
    return content


def _write_html(html_path: str, title: str, markdown_content: str) -> None:
    html = f"""<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>{title}</title>
  <style>
    body {{ font-family: Arial, sans-serif; max-width: 960px; margin: 32px auto; padding: 0 16px; }}
    img {{ max-width: 100%; height: auto; }}
    code {{ background: #f5f5f5; padding: 2px 4px; border-radius: 4px; }}
    pre {{ background: #f5f5f5; padding: 8px; overflow: auto; }}
  </style>
</head>
<body>
<pre>{markdown_content}</pre>
</body>
</html>
"""
    with open(html_path, "w", encoding="utf-8") as handle:
        handle.write(html)


def _write_pdf(pdf_path: str, markdown_path: str) -> bool:
    pandoc = shutil.which("pandoc")
    if not pandoc:
        return False
    try:
        subprocess.run(
            [pandoc, markdown_path, "-o", pdf_path],
            check=True,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
    except subprocess.SubprocessError:
        return False
    return True


def main() -> int:
    parser = argparse.ArgumentParser(description="Generate a short markdown report from analysis outputs.")
    parser.add_argument("--outputs-dir", default="", help="Directory containing exported figures/tables.")
    parser.add_argument("--report-dir", default="", help="Directory to write the report (default: outputs dir).")
    parser.add_argument("--title", default="", help="Report title.")
    parser.add_argument("--keywords", default="", help="Comma-separated filename keywords to include.")
    parser.add_argument("--report-name", default="report.md", help="Report filename.")
    parser.add_argument("--html", action="store_true", help="Also write a report.html file.")
    parser.add_argument("--pdf", action="store_true", help="Also write a report.pdf file (requires pandoc).")
    args = parser.parse_args()

    cwd = os.getcwd()
    outputs_dir = args.outputs_dir or _prompt("Outputs directory", cwd)
    outputs_dir = os.path.abspath(outputs_dir)
    if not os.path.isdir(outputs_dir):
        print(f"Outputs directory not found: {outputs_dir}", file=sys.stderr)
        return 2

    report_dir = args.report_dir or _prompt("Report directory", outputs_dir)
    report_dir = os.path.abspath(report_dir)
    os.makedirs(report_dir, exist_ok=True)

    title_default = "Climate Change Mitigation Technology Patent Analysis"
    title = args.title or _prompt("Report title", title_default)
    keywords = _parse_keywords(args.keywords or _prompt("Filter filenames by keywords (comma-separated, blank for all)", ""))

    figures, tables, data_files = _collect_outputs(outputs_dir, keywords)

    report_path = os.path.join(report_dir, args.report_name)
    content = _write_report(report_path, outputs_dir, title, figures, tables, data_files)

    if args.html:
        html_path = os.path.splitext(report_path)[0] + ".html"
        _write_html(html_path, title, content)

    if args.pdf:
        pdf_path = os.path.splitext(report_path)[0] + ".pdf"
        if not _write_pdf(pdf_path, report_path):
            print("PDF not generated (pandoc not found or failed).", file=sys.stderr)
    print(f"Report written to {report_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
