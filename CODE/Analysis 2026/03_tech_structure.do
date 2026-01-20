*------------------------------------------------------------------
* MODULE 03 — TECHNOLOGY STRUCTURE OF CCMT
*------------------------------------------------------------------

do "00_globals.do"

*------------------------------------------------------------------
* Load final invention panel
*------------------------------------------------------------------
use "$finalpath/mitigation_inv_tech_year.dta", clear

keep if inrange(publn_year, $START_YEAR, $END_YEAR)

*------------------------------------------------------------------
* Exclude CCMT aggregate to focus on sub-technologies
*------------------------------------------------------------------
drop if technology == "Y02"

*------------------------------------------------------------------
* WORLD AGGREGATES BY TECHNOLOGY
*------------------------------------------------------------------
bys publn_year technology: egen world_hvi_tech = sum(nb_hvi_CCMT)

keep publn_year technology world_hvi_tech
duplicates drop

*------------------------------------------------------------------
* TOTAL CCMT INVENTIONS PER YEAR
*------------------------------------------------------------------
bys publn_year: egen world_hvi_CCMT = sum(world_hvi_tech)

*------------------------------------------------------------------
* TECHNOLOGY SHARES
*------------------------------------------------------------------
gen share_tech = world_hvi_tech / world_hvi_CCMT
label var share_tech "Share of CCMT inventions"

*------------------------------------------------------------------
* COLLAPSE FOR STRUCTURAL FIGURES
*------------------------------------------------------------------
collapse (sum) world_hvi_tech (mean) share_tech, ///
 by(publn_year technology)

*------------------------------------------------------------------
* FIGURE 3 — CCMT technology composition (stacked area)
*------------------------------------------------------------------
twoway ///
 area share_tech publn_year, ///
 by(technology, legend(off) note("")) ///
 ytitle("Share of CCMT inventions") ///
 xtitle("Publication year") ///
 title("Technology structure of CCMT invention activity")

graph export "$figpath/Figure_3_CCMT_tech_structure.png", replace

*------------------------------------------------------------------
* STRUCTURAL CHANGE: BASE-YEAR INDEX BY TECHNOLOGY
*------------------------------------------------------------------
bys technology: gen base_tech = world_hvi_tech if publn_year == $BASE_YEAR
bys technology: egen base_tech_year = max(base_tech)

gen index_tech = world_hvi_tech / base_tech_year
label var index_tech "Invention index ($BASE_YEAR = 1)"

*------------------------------------------------------------------
* FIGURE 4 — Indexed growth by CCMT technology
*------------------------------------------------------------------
twoway ///
 line index_tech publn_year, ///
 by(technology, legend(off) note("")) ///
 ytitle("Index ($BASE_YEAR = 1)") ///
 xtitle("Publication year") ///
 title("Growth trajectories of CCMT technologies")

graph export "$figpath/Figure_4_CCMT_tech_growth.png", replace

*------------------------------------------------------------------
* Save structural table for reporting
*------------------------------------------------------------------
save "$outpath/Table_CCMT_tech_structure.dta", replace
