*------------------------------------------------------------------
* MODULE 06 — DEEP DIVE: RENEWABLE ENERGY (HYDROGEN)
*------------------------------------------------------------------

do "00_globals.do"

local outdir "$outpath/DeepDives/Hydrogen"
capture mkdir "$outpath/DeepDives"
capture mkdir "`outdir'"

*------------------------------------------------------------------
* Load hydrogen inventions (country-year)
*------------------------------------------------------------------
use "$patstpath/mitigation/HydrogenTech_ZOOM_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)

capture confirm variable invt_iso
if _rc rename invt_country invt_iso

gen byte brics = inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")
label var brics "BRICS-5 inventor country"

*------------------------------------------------------------------
* FIGURE H2-1 — BRICS share in global hydrogen inventions
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_HAll, by(brics publn_year)
reshape wide nb_hvi_HAll, i(publn_year) j(brics)
gen world = nb_hvi_HAll0 + nb_hvi_HAll1
gen sh_BRICS_H2 = 100 * nb_hvi_HAll1 / world
keep publn_year sh_BRICS_H2
export excel "`outdir'/Figure_H21_BRICS_share.xlsx", replace firstrow(variables)
save "`outdir'/Figure_H21_BRICS_share.dta", replace
restore

*------------------------------------------------------------------
* FIGURE H2-2 — Growth performance: BRICS vs Rest of World
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_HAll, by(brics publn_year)
sort brics publn_year
by brics: gen growth = 100 * ///
    (nb_hvi_HAll - nb_hvi_HAll[_n-1]) / nb_hvi_HAll[_n-1]
drop if missing(growth)
gen period = .
replace period = 1 if inrange(publn_year, 1996, 2012)
replace period = 2 if inrange(publn_year, 2013, $END_YEAR)
collapse (mean) growth, by(brics period)
reshape wide growth, i(brics) j(period)
rename growth1 avg_growth_9512
rename growth2 avg_growth_1325
export excel "`outdir'/Figure_H22_Growth_BRICS_vs_RoW.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Figure_H22_Growth_BRICS_vs_RoW.dta", replace
restore

*------------------------------------------------------------------
* FIGURE H2-3 — Hydrogen specialisation (RTA) for BRICS countries
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_HAll, by(invt_iso publn_year)
tempfile ccmt_total
preserve
use "$finalpath/mitigation_inv_tech_inventor_ctry_year.dta", clear
local techvar ""
capture confirm variable techno
if !_rc local techvar "techno"
else {
    capture confirm variable technology
    if !_rc local techvar "technology"
}
if "`techvar'" != "" {
    keep if `techvar' == "Y02"
}
keep invt_iso publn_year nb_hvi_CCMT
collapse (sum) nb_hvi_CCMT, by(invt_iso publn_year)
save `ccmt_total'
restore
merge m:1 invt_iso publn_year using `ccmt_total', keep(match) nogen

keep if inrange(publn_year, 2013, $END_YEAR)
gen byte brics = inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")
gen spe_H2 = nb_hvi_HAll / nb_hvi_CCMT
egen world_H2 = total(nb_hvi_HAll)
egen world_CCMT = total(nb_hvi_CCMT)
gen spe_world = world_H2 / world_CCMT
gen RTA_H2 = spe_H2 / spe_world
keep if brics == 1
collapse (mean) RTA_H2, by(invt_iso)
export excel "`outdir'/Figure_H23_RTA_BRICS.xlsx", replace firstrow(variables)
save "`outdir'/Figure_H23_RTA_BRICS.dta", replace
restore

*------------------------------------------------------------------
* TABLE H2-1 — BRICS internal structure (2013–2025)
*------------------------------------------------------------------
preserve
keep if inrange(publn_year, 2013, $END_YEAR)
collapse (sum) nb_hvi_HAll, by(invt_iso)
gen byte brics = inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")
keep if brics == 1
egen brics_total = total(nb_hvi_HAll)
gen sh_BRICS_H2 = 100 * nb_hvi_HAll / brics_total
gsort -nb_hvi_HAll
export excel "`outdir'/Table_H21_BRICS_structure.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Table_H21_BRICS_structure.dta", replace
restore
