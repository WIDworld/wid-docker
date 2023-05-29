// ------------------------------------------------------- //
*	Retropolate backwards gdo for countries that were part 
*	of other countries before independance
*
// ------------------------------------------------------- //


clear all
tempfile combined
save `combined', emptyok

use "$work_data/gdp.dta", clear

// Extrapolate backwards for countries without gdp before independance
*keep iso year gdp currency level_src level_year

greshape wide gdp currency level_src level_year growth_src, i(year) j(iso) string

foreach var in gdp {
	
	// Eriteria 1993 with Ethiopia
	gen ratioET_ER = `var'ER/`var'ET if year == 1993
	egen x2 = mode(ratioET_ER) 
	replace `var'ER = `var'ET*x2 if missing(`var'ER)
	drop ratioET_ER x2
	
	// Kosovo 1990  with Serbia
	gen ratioKS_RS = `var'KS/`var'RS if year == 1990
	egen x2 = mode(ratioKS_RS) 
	replace `var'KS = `var'RS*x2 if missing(`var'KS)
	drop ratioKS_RS x2
	
	// Timor Leste with Indonesia
	gen ratioTL_ID = `var'TL/`var'ID if year == 1990
	egen x2 = mode(ratioTL_ID) 
	replace `var'TL = `var'ID*x2 if missing(`var'TL)
	drop ratioTL_ID x2
	
	// South Sudan and Sudan
	gen ratioSS_SD = `var'SS/`var'SD if year == 2012
	egen x2 = mode(ratioSS_SD) 
	replace `var'SS = `var'SD*x2 if missing(`var'SS)
	drop ratioSS_SD x2
	
	// Zanzibar and Tanzania
	gen ratioZZ_TZ = `var'ZZ/`var'TZ if year == 1990
	egen x2 = mode(ratioZZ_TZ) 
	replace `var'ZZ = `var'TZ*x2 if missing(`var'ZZ)
	drop ratioZZ_TZ x2

tempfile `var'
append using `combined'
save `combined', replace
}
use `combined', clear
duplicates drop year, force
		
	// Ex-soviet countriees , there is a year of GDP in 1973 we interpolate up to that year
foreach iso in AM AZ BY KG KZ TJ TM UZ EE LT LV MD {
	ipolate gdp`iso' year , gen(x)
	replace gdp`iso' = x if missing(gdp`iso') 
	drop x
}


greshape long gdp currency level_src level_year growth_src, i(year) j(iso) string


foreach var in currency level_src level_year growth_src{
	egen `var'2 = mode(`var'), by(iso)
	drop `var'
	rename `var'2 `var'

}

duplicates tag year iso gdp currency, gen(dup)
assert dup == 0
drop dup 

drop if missing(gdp)
save "$work_data/retropolate-gdp.dta", replace 

