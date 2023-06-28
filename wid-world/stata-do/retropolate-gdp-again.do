// ------------------------------------------------------- //
*	Retropolate backwards gdo for countries that were part 
*	of other countries before independance
*
// ------------------------------------------------------- //

use "$work_data/retropolate-gdp.dta", clear

// Substrat the amount of GDP from country of origin
preserve
	use "$work_data/ppp.dta", clear
	keep if inlist(iso, "SD", "SS") 
	keep if year == $year - 1
	
	drop currency refyear
	reshape wide ppp, i(year) j(iso) string
	gen valueSD_SS = pppSS/pppSD

	reshape long
	drop year iso ppp
	ren valueSD_SS value
	gen exchange = "SD_SS"
	gen iso = "SS"
	duplicates drop
		
	tempfile pppSS_SD
	save `pppSS_SD'
restore

preserve
	use "$work_data/exchange-rates.dta", clear
	keep if widcode == "xlcusx999i"
	keep if inlist(iso, "ER", "ET", "TL", "ID") ///
		  | inlist(iso, "KS", "RS") 
	keep if year == $year - 1
	drop p currency
*	drop if year<1990
	reshape wide value, i(year widcode) j(iso) string
*	reshape wide value*, i(widcode) j(year)

*	keep widcode valueKS1999 valueRS1999 valueTL1990 valueID1990 valueER1993 valueET1993
*	reshape long

	gen valueET_ER = valueER/valueET
	gen valueRS_KS = valueKS/valueRS
	gen valueID_TL = valueTL/valueID
*	drop valueKS-valueTL
	drop valueER-valueTL
		
	reshape long
*	reshape long value, i(year widcode) j(exchange) string
	drop if missing(value)
	replace iso = substr(iso, 4, 2)
	drop year widcode
	
	tempfile exchange
	save `exchange'
restore

merge m:1 iso using `exchange', nogenerate
merge m:1 iso using `pppSS_SD', update replace nogen
//
generate value_origin = gdp/value if inlist(iso, "SS", "ER", "TL", "KS") 
gsort iso year
// br if inlist(iso, "SD", "SS", "ER", "ET", "TL", "ID") ///
// 	| inlist(iso, "KS", "RS", "TZ", "ZZ")

preserve 
	keep year iso gdp value_origin
	reshape wide value_origin gdp, i(year) j(iso) string
	replace value_originRS = value_originKS
	replace value_originET = value_originER
	replace value_originID = value_originTL
	replace value_originSD = value_originSS
	replace value_originTZ = value_originZZ
	reshape long
	
	tempfile double
	save `double'
restore 

merge 1:1 iso year using `double', update replace nogen

replace gdp = gdp-value_origin if iso == "SD" & year < 2012
replace gdp = gdp-value_origin if iso == "ET" & year < 1993
replace gdp = gdp-value_origin if iso == "RS" & year < 1990
replace gdp = gdp-value_origin if iso == "ID" & year < 1990
*replace gdp = gdp-value_origin if iso == "TZ" & year < 1990

drop value* exchange 
drop if missing(gdp)

duplicates tag year iso gdp currency, gen(dup)
assert dup == 0
drop dup 

save "$work_data/retropolate-gdp.dta", replace

