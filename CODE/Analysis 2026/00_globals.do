*------------------------------------------------------------------
* Global parameters for NACI 2026 analysis modules
*------------------------------------------------------------------

* Years
capture confirm global START_YEAR
if _rc global START_YEAR 1995
capture confirm global END_YEAR
if _rc global END_YEAR 2025
capture confirm global BASE_YEAR
if _rc global BASE_YEAR 1995

* Paths (override in Master_General.do if needed)
local _pwd = c(pwd)

capture confirm global datapath
if _rc global datapath "`_pwd'"

capture confirm global patstpath
if _rc global patstpath "`_pwd'"

capture confirm global droppath
if _rc global droppath "`_pwd'"

capture confirm global finalpath
if _rc global finalpath "$datapath/Final_database"

capture confirm global figpath
if _rc global figpath "$droppath/Analysis_Outputs/Figures"

capture confirm global outpath
if _rc global outpath "$droppath/Analysis_Outputs/Tables"

capture mkdir "$figpath"
capture mkdir "$outpath"

* Country groups
capture confirm global BRICS5
if _rc global BRICS5 "BRA RUS IND CHN ZAF"
