*------------------------------------------------------------------
* MODULE 04 — GEOGRAPHIC DISTRIBUTION OF CCMT INVENTION
*------------------------------------------------------------------

do "00_globals.do"

*------------------------------------------------------------------
* Load final CCMT invention panel (inventor country)
*------------------------------------------------------------------
use "$finalpath/mitigation_inv_inventor_ctry_year.dta", clear

keep if inrange(publn_year, $START_YEAR, $END_YEAR)
keep if technology == "Y02"

*------------------------------------------------------------------
* WORLD TOTAL BY YEAR
*------------------------------------------------------------------
bys publn_year: egen world_hvi = sum(nb_hvi_CCMT)

*------------------------------------------------------------------
* COUNTRY SHARES
*------------------------------------------------------------------
gen share_country = nb_hvi_CCMT / world_hvi
label var share_country "Country share of global CCMT inventions"

*------------------------------------------------------------------
* TOP INVENTOR COUNTRIES (AVERAGE SHARE)
*------------------------------------------------------------------
collapse (mean) share_country (sum) nb_hvi_CCMT, ///
 by(inventor_ctry)

gsort -nb_hvi_CCMT
gen rank = _n
keep if rank <= 15
tempfile top_ctry
save `top_ctry'

*------------------------------------------------------------------
* TIME SERIES FOR TOP COUNTRIES
*------------------------------------------------------------------
use "$finalpath/mitigation_inv_inventor_ctry_year.dta", clear
keep if technology == "Y02"
merge m:1 inventor_ctry using `top_ctry', keep(match) nogen

*------------------------------------------------------------------
* FIGURE 5 — CCMT invention shares of leading countries
*------------------------------------------------------------------
twoway ///
 line share_country publn_year, ///
 by(inventor_ctry, legend(off) note("")) ///
 ytitle("Share of global CCMT inventions") ///
 xtitle("Publication year") ///
 title("Leading inventor countries in CCMT")

graph export "$figpath/Figure_5_CCMT_country_shares.png", replace

*------------------------------------------------------------------
* CONCENTRATION MEASURE: HERFINDAHL INDEX
*------------------------------------------------------------------
bys publn_year inventor_ctry: keep publn_year inventor_ctry share_country
duplicates drop

gen share_sq = share_country^2
bys publn_year: egen hhi = sum(share_sq)
label var hhi "Herfindahl concentration index"

*------------------------------------------------------------------
* FIGURE 6 — Global concentration of CCMT invention
*------------------------------------------------------------------
twoway ///
 line hhi publn_year, ///
 ytitle("HHI") ///
 xtitle("Publication year") ///
 title("Geographic concentration of CCMT invention")

graph export "$figpath/Figure_6_CCMT_concentration.png", replace

*------------------------------------------------------------------
* Save outputs
*------------------------------------------------------------------
save "$outpath/Table_CCMT_geo_distribution.dta", replace
