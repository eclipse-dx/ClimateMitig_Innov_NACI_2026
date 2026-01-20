*------------------------------------------------------------------
* MODULE 10 — ADAPTATION: BRICS-5 VS REST OF WORLD (Y02A)
*------------------------------------------------------------------

do "00_globals.do"

local outdir "$outpath/Adaptation"
capture mkdir "`outdir'"

use "$finalpath/adaptation_inv_tech_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)

capture confirm variable technology
if !_rc {
    keep if technology == "Y02A" | technology == ""
}

gen byte brics = inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")

*------------------------------------------------------------------
* FIGURE A7 — BRICS share in global adaptation inventions
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_CCMT, by(brics publn_year)
reshape wide nb_hvi_CCMT, i(publn_year) j(brics)
gen world = nb_hvi_CCMT0 + nb_hvi_CCMT1
gen sh_BRICS_ADAPT = 100 * nb_hvi_CCMT1 / world
keep publn_year sh_BRICS_ADAPT
export excel "`outdir'/Figure_A7_BRICS_share_Adaptation.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Figure_A7_BRICS_share_Adaptation.dta", replace
restore

*------------------------------------------------------------------
* FIGURE A8 — Growth performance: BRICS vs Rest of World
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_CCMT, by(brics publn_year)
sort brics publn_year
by brics: gen growth = 100 * ///
    (nb_hvi_CCMT - nb_hvi_CCMT[_n-1]) / nb_hvi_CCMT[_n-1]
drop if missing(growth)
gen period = .
replace period = 1 if inrange(publn_year, 1996, 2012)
replace period = 2 if inrange(publn_year, 2013, $END_YEAR)
collapse (mean) growth, by(brics period)
reshape wide growth, i(brics) j(period)
rename growth1 avg_growth_9512
rename growth2 avg_growth_1325
export excel "`outdir'/Figure_A8_Growth_BRICS_vs_RoW_Adaptation.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Figure_A8_Growth_BRICS_vs_RoW_Adaptation.dta", replace
restore

*------------------------------------------------------------------
* FIGURE A9 — Adaptation specialisation (RTA) for BRICS countries
*------------------------------------------------------------------
preserve
collapse (sum) nb_hvi_CCMT nb_hvi_all, by(invt_iso publn_year)
keep if inrange(publn_year, 2013, $END_YEAR)
gen spe_adapt = nb_hvi_CCMT / nb_hvi_all
egen world_adapt = total(nb_hvi_CCMT)
egen world_all = total(nb_hvi_all)
gen spe_world = world_adapt / world_all
gen RTA_adapt = spe_adapt / spe_world
keep if inlist(invt_iso, "BRA", "RUS", "IND", "CHN", "ZAF")
collapse (mean) RTA_adapt, by(invt_iso)
export excel "`outdir'/Figure_A9_RTA_BRICS_Adaptation.xlsx", ///
    replace firstrow(variables)
save "`outdir'/Figure_A9_RTA_BRICS_Adaptation.dta", replace
restore
