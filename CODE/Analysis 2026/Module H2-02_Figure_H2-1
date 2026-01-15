use "$datapath/Analysis/Hydrogen/H2_BRICS_RoW_year.dta", clear

gen sh_BRICS_H2 = 100 * H2_BRICS / H2_WORLD

keep publn_year sh_BRICS_H2
sort publn_year

export excel "$droppath/Analysis/Hydrogen/Figure_H21_BRICS_share.xlsx", ///
replace firstrow(variables)
