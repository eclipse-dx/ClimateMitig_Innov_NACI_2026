*------------------------------------------------------------------
* RUNNER — ALL ANALYSIS MODULES (MITIGATION + ADAPTATION)
*------------------------------------------------------------------

clear all
set more off

local start_dir = c(pwd)

* If launched from repo root, switch to this folder.
capture confirm file "CODE/Analysis 2026/00_globals.do"
if !_rc {
    cd "CODE/Analysis 2026"
}

* Mitigation (Y02)
do "00_globals.do"
do "module 02_global_trends.do"
do "03_tech_structure.do"
do "04_geo_distribution.do"
do "05_deepdive_transport_ev.do"
do "06_deepdive_renewables_hydrogen.do"

* Adaptation (Y02A)
do "07_adapt_global_trends.do"
do "08_adapt_tech_structure.do"
do "09_adapt_geo_distribution.do"
do "10_adapt_brics.do"

* Return to original directory
capture cd "`start_dir'"

* --------------------------------------------------------------
* Optional: generate a short markdown + HTML summary report
* --------------------------------------------------------------
local report_outputs = "$droppath/Analysis_Outputs"
local report_title = "Climate Change Mitigation Technology Patent Analysis"
capture shell python3 "report_generate.py" ///
    --outputs-dir "`report_outputs'" ///
    --report-dir "`report_outputs'" ///
    --title "`report_title'" ///
    --html
