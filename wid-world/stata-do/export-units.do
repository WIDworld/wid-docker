// Import currency symbols
import delimited "$currency_codes/symbols.csv", ///
	delimiter("\t") clear encoding("utf8") varnames(1)

drop if currency == "(none)"
drop if isocode  == "(none)"
	
keep currency symbol isocode
	
replace symbol = "" if symbol == "(none)"
replace symbol = "" if ustrregexm(symbol, "\.svg$")

// Add Yugoslav dinar
local nobs = _N + 1
set obs `nobs'
replace currency = "1990 Yugoslav dinar" in l
replace symbol = "дин." in l
replace isocode = "YUN" in l

// Add the new cuurency code for Mauritania
replace isocode = "MRU" if isocode == "MRO"

split symbol, parse(" or ")
drop symbol symbol2
rename symbol1 symbol
	
duplicates drop isocode, force

rename currency name
rename isocode currency

replace currency = "STN" if currency == "STD"

tempfile currencies
save "`currencies'"

use "$work_data/extrapolate-pretax-income-output.dta", clear
append using "$work_data/add-carbon-series-output.dta"

// Add Euro for German subregions
replace currency = "EUR" if strpos(iso, "DE-")

// Add the new cuurency code for Mauritania
replace currency = "MRU" if currency == "MRO"

keep iso currency
drop if currency == ""
duplicates drop

sort iso currency

// Here: make sure that no new (unknown) currency has been introduced
merge n:1 currency using "`currencies'", keep(master match) assert(match using) nogenerate
rename currency currency_iso
rename symbol currency_symbol
rename name currency_name

// Expand for all types (variable first letter)
expand 19
sort iso
generate nobs = _n
generate type = ""
local i 0
foreach c in a b c f g h i n s t m o p w x e k l r {
	replace type = "`c'" if mod(nobs, 18) == `i'
	local i = `i' + 1
}
drop nobs

// Metadata
generate metadata = `""'
replace metadata = `"{"unit":""' + currency_iso + `"","unit_name":""' + currency_name + ///
	`"","unit_symbol":""' + currency_symbol + `""}"' if inlist(type, "a", "t", "m", "o")

// Yugoslavia: remove the year for the nominal serie
replace metadata = `"{"unit":""' + currency_iso + `"","unit_name":""' + currency_name + ///
	`"","unit_symbol":""' + currency_symbol + `"","nominal_unit_name":{"-1990":"Yugoslav dinars"}}"' ///
	if inlist(type, "a", "t", "m", "o") & (iso == "QY")

replace metadata = `"{"unit":""}"' if inlist(type, "b", "i","g")
replace metadata = `"{"unit":"% of national income"}"' if (type == "w")
replace metadata = `"{"unit":"% of population"}"' if (type == "p")
replace metadata = `"{"unit":"population"}"' if inlist(type, "n", "h", "f")
replace metadata = `"{"unit":"share"}"' if inlist(type, "c", "s")
replace metadata = `"{"unit":"local currency per foreign currency"}"' if (type == "x")
replace metadata = `"{"unit":"CO2 emissions or CO2 equivalent"}"' if (inlist(type, "e", "k"))
replace metadata = `"{"unit":"tCO2 equivalent/cap"}"' if (type == "l")
replace metadata = `"{"unit":"Ratio of Top 10% average income to Bottom 50% average income"}"' if (type == "r")

keep iso type metadata

// Export results
sort iso type
rename iso country
rename type var_type

*replace country = "KV" if country == "KS"

export delimited "$output_dir/$datetime/metadata/var-units.csv", replace delimiter(";")

label data "Generated by export-units.do"
save "$work_data/var-units.dta", replace
