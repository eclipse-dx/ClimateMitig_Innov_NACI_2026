*------------------------------------------------------------------
* MODULE 08 — ADAPTATION: TECHNOLOGY STRUCTURE (Y02A)
*------------------------------------------------------------------

do "00_globals.do"

local outdir "$outpath/Adaptation"
capture mkdir "`outdir'"

use "$finalpath/adaptation_inv_tech_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)

* Determine if multiple adaptation technologies exist
levelsof technology, local(techs)
local ntech : word count `techs'

if `ntech' > 1 {
    drop if technology == "Y02A"
}

* WORLD AGGREGATES BY TECHNOLOGY
bys publn_year technology: egen world_hvi_tech = sum(nb_hvi_CCMT)
keep publn_year technology world_hvi_tech
duplicates drop

* TOTAL ADAPTATION INVENTIONS PER YEAR
bys publn_year: egen world_hvi_CCMT = sum(world_hvi_tech)

* TECHNOLOGY SHARES
gen share_tech = world_hvi_tech / world_hvi_CCMT
label var share_tech "Share of adaptation inventions"

* COLLAPSE FOR STRUCTURAL FIGURES
collapse (sum) world_hvi_tech (mean) share_tech, ///
    by(publn_year technology)

* FIGURE A3 — Adaptation technology composition
twoway ///
 area share_tech publn_year, ///
 by(technology, legend(off) note("")) ///
 ytitle("Share of adaptation inventions") ///
 xtitle("Publication year") ///
 title("Technology structure of adaptation invention activity")

graph export "$figpath/Figure_A3_Adaptation_tech_structure.png", replace

* STRUCTURAL CHANGE: BASE-YEAR INDEX BY TECHNOLOGY
bys technology: gen base_tech = world_hvi_tech if publn_year == $BASE_YEAR
bys technology: egen base_tech_year = max(base_tech)

gen index_tech = world_hvi_tech / base_tech_year
label var index_tech "Invention index ($BASE_YEAR = 1)"

* FIGURE A4 — Indexed growth by adaptation technology
twoway ///
 line index_tech publn_year, ///
 by(technology, legend(off) note("")) ///
 ytitle("Index ($BASE_YEAR = 1)") ///
 xtitle("Publication year") ///
 title("Growth trajectories of adaptation technologies")

graph export "$figpath/Figure_A4_Adaptation_tech_growth.png", replace

* Save structural table for reporting
save "`outdir'/Table_Adaptation_tech_structure.dta", replace
