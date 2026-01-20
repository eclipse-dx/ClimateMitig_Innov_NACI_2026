# climate change mitigation patent data analysis for a NACI 2026 Report

## Interactive report generator

To create a short markdown report from exported figures and tables, run:

```
python3 "CODE/Analysis 2026/report_generate.py"
```

The script will prompt for the outputs directory (where figures/tables were exported),
optional filename filters, and the report title. The report is saved as `report.md`
in the selected report directory.

You can also run it non-interactively and generate HTML/PDF:

```
python3 "CODE/Analysis 2026/report_generate.py" \
  --outputs-dir "/path/to/Analysis_Outputs" \
  --report-dir "/path/to/Analysis_Outputs" \
  --title "Climate Change Mitigation Technology Patent Analysis" \
  --html --pdf
```

Note: PDF requires `pandoc` to be installed.
