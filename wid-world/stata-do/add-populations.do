use "$work_data/populations.dta", clear

tempfile popul
save "`popul'"

use "$work_data/add-national-accounts-output.dta", clear

generate newobs = 0
append using "`popul'"
replace newobs = 1 if (newobs >= .)

///* SWEDEN - 992i: Bauluz estimates end in 2016, 2017 WID value (WID extrapolated with UN's growth rate) is too low (drop between 2016 and 2017)
* take Bauluz's 2016 value and apply growth rate of WID between 2016 and 2017 
/*
foreach var in "992i" "999i" {
	sum value if (iso == "SE" & year == 2016 & widcode == "npopul`var'" & newobs == 1)
	local wid16 = r(mean)
	sum value if (iso == "SE" & year == 2017 & widcode == "npopul`var'" & newobs == 1)
	local wid17 = r(mean)
	local gwthwidSE = ((`wid17' - `wid16')/`wid16')
	sum value if (iso == "SE" & year == 2016 & widcode == "npopul`var'" & newobs == 0)
	local Bauluz16 = r(mean)
	replace value = (`Bauluz16' * (1 + `gwthwidSE')) if (iso == "SE" & year == 2017 & widcode == "npopul`var'" & newobs == 1)
}
*/

duplicates tag iso widcode p year, generate(duplicate)
drop if duplicate & newobs
drop duplicate newobs

// Harmonize subcategories with 999i and 992i aggregates

preserve 
	drop if substr(widcode,1,6) == "npopul"
	tempfile nopopul
	save "`nopopul'"
restore


keep if substr(widcode,1,6) == "npopul"
drop currency
reshape wide value, i(iso year p) j(widcode) string

*recompute children with right 999i and 992i
replace valuenpopul991i = valuenpopul999i - valuenpopul992i

* compute ratio of the right 999i and 992i to the ones obtained from the subcategories
gen adults = valuenpopul993i + valuenpopul994i + valuenpopul995i 
gen ratio = valuenpopul992i/adults

* For France, there is information on the adult working population (20 - 64 = npopul996i) for several groups of the distribution
* => apply the corresponding French annual ratio 

bys iso year: egen newratio = min(ratio)
replace ratio = newratio

* generate missing i variables based on m and f
forvalues n = 2/9 {
	cap gen valuenpopul`n'01i = valuenpopul`n'01f + valuenpopul`n'01m
	cap gen valuenpopul`n'02i = valuenpopul`n'02f + valuenpopul`n'02m
	cap gen valuenpopul`n'51i = valuenpopul`n'51f + valuenpopul`n'51m
}

* apply ratios to subcategories to make them consistent with new 999i and 992i aggregates

forvalues n = 2/9 {
	foreach sex in "f" "m" "i" {
		replace valuenpopul`n'01`sex' = valuenpopul`n'01`sex' * ratio 
		replace valuenpopul`n'51`sex' = valuenpopul`n'51`sex' * ratio 
		replace valuenpopul`n'02`sex' = valuenpopul`n'02`sex' * ratio 
	}
}

forvalues n = 3/8 {
	foreach sex in "f" "m" "i" {
		replace valuenpopul99`n'`sex' = valuenpopul99`n'`sex' * ratio
	}
}

foreach sex in "f" "m" "i" {
	replace valuenpopul111`sex' = valuenpopul111`sex' * ratio 
}


* do the same for children 

gen children = valuenpopul001i + valuenpopul051i + valuenpopul101i + valuenpopul151i
gen chratio = valuenpopul991i/children

forvalues n = 0/1 {
	foreach sex in "f" "m" "i" {
		replace valuenpopul`n'01`sex' = valuenpopul`n'01`sex' * chratio 
		replace valuenpopul`n'51`sex' = valuenpopul`n'51`sex' * chratio 
	}
}

drop ratio adults newratio children chratio
reshape long value, i(iso year p) j(widcode) string 

drop if missing(value)

append using "`nopopul'"

compress
label data "Generated by add-populations.do"
save "$work_data/add-populations-output.dta", replace