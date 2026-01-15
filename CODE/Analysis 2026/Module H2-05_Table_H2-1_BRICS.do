use "$patstpath/mitigation/Hydrogen_ZOOM_inventor_ctry_year", clear
keep if publn_year >=2013 & publn_year <=2025
keep if inlist(invt_iso,"BRA","RUS","IND","CHN","ZAF")

egen H2_country = sum(world_hvi_H2), by(invt_iso)
egen H2_BRICS_total = sum(world_hvi_H2)

gen sh_BRICS_H2 = 100 * H2_country / H2_BRICS_total

keep invt_iso invt_name H2_country sh_BRICS_H2
duplicates drop
gsort -H2_country

export excel "$droppath/Analysis/Hydrogen/Table_H21_structure.xlsx", ///
replace firstrow(variables)
