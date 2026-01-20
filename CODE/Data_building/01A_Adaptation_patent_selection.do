*=== NACI Report: 2026
*=== Chapter title:
*				Sustainability and climate Change
*				Climate Change Adaptation Technologies
*=== Objective:
* - Selection of patents (CPC id) for climate change adaptation technologies (Y02A)

**************************************************************************************************************************
*** 			SELECTION OF TECHNOLOGY CODES (CPC CODES) TO BUILD DATABASES
**************************************************************************************************************************

**************************************************************************************************************************
*** 		1A -	Selection of adaptation patents (Y02A)
**************************************************************************************************************************

* Select adaptation patents (CPC codes begin with Y02A)
use "$patstpath/general/CPC_codes.dta", clear
keep if regexm(cpc_code,"Y02A")
assert regexm(cpc_code,"Y02A")
gen technology = substr(cpc_code,1,4)
save "$datapath/Y02A_PatstatCAT_adaptation.dta", replace

* Create sub-technology identifiers using 6 first digits of CPC codes
use "$datapath/Y02A_PatstatCAT_adaptation.dta", clear
gen sub_tech = substr(cpc_code,1,6)
save "$datapath/Y02A_SubtechCAT_adaptation.dta", replace

* Create core adaptation list (technology = Y02A)
use "$datapath/Y02A_PatstatCAT_adaptation.dta", clear
keep technology appln_id cpc_code
duplicates drop
save "$datapath/Patstat_adaptation2026.dta", replace

*=============================================
*=============================================
*=============================================
*=============================================
*=============================================

