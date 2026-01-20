*------------------------------------------------------------------
* MODULE 07 — ADAPTATION: GLOBAL TRENDS (Y02A)
*------------------------------------------------------------------

do "00_globals.do"

local outdir "$outpath/Adaptation"
capture mkdir "`outdir'"

use "$finalpath/adaptation_inv_tech_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)

capture confirm variable technology
if !_rc {
    preserve
    keep if technology == "Y02A"
    count
    if r(N) > 0 {
        restore
        keep if technology == "Y02A"
    }
    else restore
}

* WORLD AGGREGATES (Adaptation vs all technologies)
bys publn_year: egen world_hvi_CCMT = sum(nb_hvi_CCMT)
bys publn_year: egen world_hvi_all  = sum(nb_hvi_all)

keep publn_year world_hvi_CCMT world_hvi_all
duplicates drop

* INDEX CONSTRUCTION (base year = $BASE_YEAR)
gen base_CCMT = world_hvi_CCMT if publn_year == $BASE_YEAR
egen base_CCMT_year = max(base_CCMT)

gen base_all = world_hvi_all if publn_year == $BASE_YEAR
egen base_all_year = max(base_all)

gen index_CCMT = world_hvi_CCMT / base_CCMT_year
gen index_all  = world_hvi_all  / base_all_year

label var index_CCMT "Adaptation inventions (index, $BASE_YEAR=1)"
label var index_all  "All inventions (index, $BASE_YEAR=1)"

* FIGURE A1 — Long-run evolution of adaptation vs all inventions
twoway ///
 (line index_CCMT publn_year, lwidth(medthick)) ///
 (line index_all  publn_year, lpattern(dash)), ///
 legend(order(1 "Adaptation" 2 "All technologies")) ///
 ytitle("Index ($BASE_YEAR = 1)") ///
 xtitle("Publication year") ///
 title("Global trends in adaptation invention activity")

graph export "$figpath/Figure_A1_Global_trends_Adaptation.png", replace
export excel "`outdir'/Figure_A1_Global_trends_Adaptation.xlsx", ///
    replace firstrow(variables)

* GROWTH RATES
bys (publn_year): gen growth_CCMT = ///
    100 * (world_hvi_CCMT - world_hvi_CCMT[_n-1]) / world_hvi_CCMT[_n-1]

bys (publn_year): gen growth_all = ///
    100 * (world_hvi_all - world_hvi_all[_n-1]) / world_hvi_all[_n-1]

* PERIOD AVERAGES (policy-relevant windows)
gen period = .
replace period = 1 if inrange(publn_year, 1995, 2005)
replace period = 2 if inrange(publn_year, 2006, 2012)
replace period = 3 if inrange(publn_year, 2013, $END_YEAR)

label define period 1 "1995–2005" 2 "2006–2012" 3 "2013–$END_YEAR"
label values period period

collapse (mean) growth_CCMT growth_all, by(period)

* FIGURE A2 — Average annual growth rates by period
graph bar growth_CCMT growth_all, ///
 over(period, label(angle(0))) ///
 legend(order(1 "Adaptation" 2 "All technologies")) ///
 ytitle("Average annual growth rate (%)") ///
 title("Growth dynamics of adaptation invention activity")

graph export "$figpath/Figure_A2_Growth_rates_Adaptation.png", replace
save "`outdir'/Table_Adaptation_growth_rates.dta", replace
