*------------------------------------------------------------------
* MODULE 05 — DEEP DIVE: TRANSPORT (ELECTRIC VEHICLES)
*------------------------------------------------------------------

do "00_globals.do"

local outdir "$outpath/DeepDives/EV"
capture mkdir "$outpath/DeepDives"
capture mkdir "`outdir'"

*------------------------------------------------------------------
* Load EV inventions (country-year)
*------------------------------------------------------------------
use "$patstpath/mitigation/ElecVehicles_ZOOM_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)

capture confirm variable invt_iso
if _rc rename invt_country invt_iso

gen byte brics = inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")
label var brics "BRICS-5 inventor country"

*------------------------------------------------------------------
* FIGURE EV-1 — BRICS share in global EV inventions
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_EVall, by(brics publn_year)
reshape wide nb_hvi_EVall, i(publn_year) j(brics)
gen world = nb_hvi_EVall0 + nb_hvi_EVall1
gen sh_BRICS_EV = 100 * nb_hvi_EVall1 / world
keep publn_year sh_BRICS_EV
export excel "`outdir'/Figure_EV1_BRICS_share.xlsx", replace firstrow(variables)
save "`outdir'/Figure_EV1_BRICS_share.dta", replace
restore

*------------------------------------------------------------------
* FIGURE EV-2 — Growth performance: BRICS vs Rest of World
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_EVall, by(brics publn_year)
sort brics publn_year
by brics: gen growth = 100 * ///
    (nb_hvi_EVall - nb_hvi_EVall[_n-1]) / nb_hvi_EVall[_n-1]
drop if missing(growth)
gen period = .
replace period = 1 if inrange(publn_year, 1996, 2012)
replace period = 2 if inrange(publn_year, 2013, $END_YEAR)
collapse (mean) growth, by(brics period)
reshape wide growth, i(brics) j(period)
rename growth1 avg_growth_9512
rename growth2 avg_growth_1325
export excel "`outdir'/Figure_EV2_Growth_BRICS_vs_RoW.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Figure_EV2_Growth_BRICS_vs_RoW.dta", replace
restore

*------------------------------------------------------------------
* FIGURE EV-3 — EV specialisation (RTA) for BRICS countries
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_EVall, by(invt_iso publn_year)
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
gen spe_EV = nb_hvi_EVall / nb_hvi_CCMT
egen world_EV = total(nb_hvi_EVall)
egen world_CCMT = total(nb_hvi_CCMT)
gen spe_world = world_EV / world_CCMT
gen RTA_EV = spe_EV / spe_world
keep if brics == 1
collapse (mean) RTA_EV, by(invt_iso)
export excel "`outdir'/Figure_EV3_RTA_BRICS.xlsx", replace firstrow(variables)
save "`outdir'/Figure_EV3_RTA_BRICS.dta", replace
restore

*------------------------------------------------------------------
* TABLE EV-1 — BRICS internal structure (2013–2025)
*------------------------------------------------------------------
preserve
keep if inrange(publn_year, 2013, $END_YEAR)
collapse (sum) nb_hvi_EVall, by(invt_iso)
gen byte brics = inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")
keep if brics == 1
egen brics_total = total(nb_hvi_EVall)
gen sh_BRICS_EV = 100 * nb_hvi_EVall / brics_total
gsort -nb_hvi_EVall
export excel "`outdir'/Table_EV1_BRICS_structure.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Table_EV1_BRICS_structure.dta", replace
restore
