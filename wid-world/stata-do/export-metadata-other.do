// List variables in the database
use "$work_data/calculate-pareto-coef-output.dta", clear
append using "$work_data/add-carbon-series-output.dta"

generate fivelet = substr(widcode, 2, 5)
keep fivelet
gduplicates drop

tempfile fivelet
save "`fivelet'", replace

tempfile variables

local firstiter = 1
foreach sheet in Wealth_Macro_Variables Income_Macro_Variables ///
		Income_Distributed_Variables Other_Macro_Variables Wealth_Distributed_Variables Carbon_Macro Carbon_Distributed {
	
	import excel "$codes_dictionary", sheet("`sheet'") clear allstring
	
	keep  A B C D G J M Q
	rename A onelet
	replace onelet = "" if onelet=="."
	rename B twolet
	rename C threelet
	rename D fivelet
	rename G rank
	rename J shortname
	rename M simpledes
	rename Q technicaldes
	drop in 1/2
	replace fivelet = usubinstr(fivelet,"*","",1)
	drop if fivelet == "see Distributed_Variables_Categories"
	drop if fivelet == "WID CODE"
	drop if fivelet == ""
	replace onelet = "" if onelet == "*"
	if (`firstiter' != 1) {
		append using "`variables'"
	}
	local firstiter = 0
	save "`variables'", replace
}

collapse (firstnm) onelet twolet threelet shortname simpledes technicaldes rank, by(fivelet)

replace fivelet = substr(fivelet, 2, 5) if strlen(fivelet) == 6

// Check if we don't create redundant variables
duplicates tag fivelet, generate(duplicate)
assert duplicate == 0
drop duplicate

// Check we don't miss any variable
merge 1:1 fivelet using "`fivelet'", nogen 
// assert(master match)

sort fivelet
*drop fivelet onelet
compress

duplicates tag twolet threelet, generate(duplicate)
assert duplicate == 0
drop duplicate
keep twolet threelet shortname simpledes technicaldes rank
capture mkdir "$output_dir/$time/metadata"

export delimited using "$output_dir/$time/metadata/var-names-$time.csv", delim(";") replace
label data "Generated by export-metadata-other.do"
save "$work_data/var-names.dta", replace


// Series type

clear
import excel "$codes_dictionary", sheet("Series_Type") clear allstring
keep A B C D E
rename A onetype
rename B shortdes  
rename C longdes
rename D onlinedes
rename E rank
drop if onetype == ""
drop in 1
replace onlinedes = strtrim(onlinedes)
generate onelinedes2 = onlinedes
order onetype shortdes longdes onlinedes onelinedes2 rank
replace rank = "0" if missing(rank)
destring rank, gen(rank2)
gsort rank2
drop rank2
replace onetype = "r" if onetype == "r "

export delimited using "$output_dir/$time/metadata/var-types-$time.csv", delim(";") replace
label data "Generated by export-metadata-other.do"
save "$work_data/var-types.dta", replace

// Population type

clear
import excel "$codes_dictionary", sheet("Population_Categories") clear allstring
keep A B C D
rename A onepop
rename B shortdes
rename C longdes
rename D rank
drop if shortdes==""
drop in 1
replace longdes = strtrim(longdes)
export delimited using "$output_dir/$time/metadata/var-pops-$time.csv", delim(";") replace
label data "Generated by export-metadata-other.do"
save "$work_data/var-pops.dta", replace

// Age groups

clear
import excel "$codes_dictionary", sheet("Age_Categories") clear allstring
keep A B C E
rename A agecode
rename B shortname
rename C fullname
rename E rank
drop in 1
drop if _n > 118
replace fullname = strtrim(fullname)
export delimited using "$output_dir/$time/metadata/var-ages-$time.csv", delim(";") replace
label data "Generated by export-metadata-other.do"
save "$work_data/var-ages.dta", replace

