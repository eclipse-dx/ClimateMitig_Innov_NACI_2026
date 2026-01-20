*------------------------------------------------------------------
* MODULE 09 — ADAPTATION: GEOGRAPHIC DISTRIBUTION (Y02A)
*------------------------------------------------------------------

do "00_globals.do"

local outdir "$outpath/Adaptation"
capture mkdir "`outdir'"

* Load final adaptation invention panel (inventor country)
use "$finalpath/adaptation_inv_tech_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)

capture confirm variable technology
if !_rc {
    keep if technology == "Y02A" | technology == ""
}

* WORLD TOTAL BY YEAR
bys publn_year: egen world_hvi = sum(nb_hvi_CCMT)

* COUNTRY SHARES
gen share_country = nb_hvi_CCMT / world_hvi
label var share_country "Country share of global adaptation inventions"

* TOP INVENTOR COUNTRIES (AVERAGE SHARE)
collapse (mean) share_country (sum) nb_hvi_CCMT, ///
    by(invt_iso invt_name)

gsort -nb_hvi_CCMT
gen rank = _n
keep if rank <= 15
tempfile top_ctry
save `top_ctry'

* TIME SERIES FOR TOP COUNTRIES
use "$finalpath/adaptation_inv_tech_inventor_ctry_year", clear
keep if inrange(publn_year, $START_YEAR, $END_YEAR)
capture confirm variable technology
if !_rc {
    keep if technology == "Y02A" | technology == ""
}
merge m:1 invt_iso using `top_ctry', keep(match) nogen

bys publn_year: egen world_hvi = sum(nb_hvi_CCMT)
gen share_country = nb_hvi_CCMT / world_hvi

* FIGURE A5 — Adaptation invention shares of leading countries
twoway ///
 line share_country publn_year, ///
 by(invt_name, legend(off) note("")) ///
 ytitle("Share of global adaptation inventions") ///
 xtitle("Publication year") ///
 title("Leading inventor countries in adaptation")

graph export "$figpath/Figure_A5_Adaptation_country_shares.png", replace

* CONCENTRATION MEASURE: HERFINDAHL INDEX
keep publn_year invt_iso share_country
duplicates drop

gen share_sq = share_country^2
bys publn_year: egen hhi = sum(share_sq)
label var hhi "Herfindahl concentration index"

* FIGURE A6 — Global concentration of adaptation invention
twoway ///
 line hhi publn_year, ///
 ytitle("HHI") ///
 xtitle("Publication year") ///
 title("Geographic concentration of adaptation invention")

graph export "$figpath/Figure_A6_Adaptation_concentration.png", replace

* Save outputs
save "`outdir'/Table_Adaptation_geo_distribution.dta", replace
