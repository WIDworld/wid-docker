use "$work_data/wid-long.dta", clear

*keep if substr(iso, 1, 2) == "US"

rename iso Alpha2
rename p perc

sort Alpha2 perc year
/*
keep if Alpha2 == "XM"
foreach v of varlist * {
	quietly count if !missing(`v')
	if (r(N) == 0) {
		drop `v'
	}
}
egen tokeep = rownonmiss(agdpro992i-xlcyux999i)
keep if tokeep
drop tokeep
export delimited "$output_dir/$datetime/middle-east.csv", delimiter(";") replace
*/
/*
keep if strpos(Alpha2, "US-")
foreach v of varlist * {
	quietly count if !missing(`v')
	if (r(N) == 0) {
		drop `v'
	}
}
egen tokeep = rownonmiss(afiinc992t-xlcyux999i)
keep if tokeep
drop tokeep
export delimited "$output_dir/$datetime/us-states.csv", delimiter(";") replace
*/
/*
keep Alpha2 perc year ?nw*
egen tokeep = rownonmiss(anwagr992i-mnwodk999i)
keep if tokeep
drop tokeep
export delimited "$output_dir/$datetime/national-wealth.csv", delimiter(";") replace
*/

ds Alpha2 year perc currency, not
local vars = r(varlist)
egen tokeep = rownonmiss(`vars')
keep if tokeep
drop tokeep

// Export by regiosns

preserve
keep if inlist(Alpha2, "WO", "WO-MER", "XL", "XL-MER")
export delimited "$output_dir/$datetime/wid-db1.csv", delimiter(";") replace
restore

preserve
keep if inlist(Alpha2,"QE", "QE-MER", "QF", "QF-MER")
export delimited "$output_dir/$datetime/wid-db2.csv", delimiter(";") replace
restore

preserve
keep if inlist(Alpha2,"XN", "XN-MER", "XA", "XA-MER", "XF", "XF-MER")
export delimited "$output_dir/$datetime/wid-db3.csv", delimiter(";") replace
restore

preserve
keep if inlist(Alpha2,"QP", "QP-MER", "XR", "XR-MER")
export delimited "$output_dir/$datetime/wid-db4.csv", delimiter(";") replace
restore

preserve
keep if inlist(Alpha2,"XM-MER", "XM", "QD", "QD-MER")
export delimited "$output_dir/$datetime/wid-db5.csv", delimiter(";") replace
restore

*Middle East
preserve
keep if inlist(Alpha2,"AE", "BH", "EG", "IQ", "IR")
export delimited "$output_dir/$datetime/wid-ME1.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2,"JO", "KW", "LB", "OM", "PS")
export delimited "$output_dir/$datetime/wid-ME2.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2,"QA", "SA", "SY", "TR", "YE")
export delimited "$output_dir/$datetime/wid-ME3.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "VN", "IL")
export delimited "$output_dir/$datetime/wid-ME4.csv", delimiter(";") replace
restore

*Asia - Povcal
preserve
keep if inlist(Alpha2,"BD", "BT", "JP", "KG")
export delimited "$output_dir/$datetime/wid-AS1.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2,"MN", "MV", "NP", "PH")
export delimited "$output_dir/$datetime/wid-AS2.csv", delimiter(";") replace
restore

preserve
keep if inlist(Alpha2,"KR", "KZ", "LA", "LK", "MM")
export delimited "$output_dir/$datetime/wid-AS3.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2,"PK", "TJ", "TL", "TM", "UZ")
export delimited "$output_dir/$datetime/wid-AS4.csv", delimiter(";") replace
restore
*Asia - the rest
preserve
keep if inlist(Alpha2, "CN", "IN", "ID", "PG")
export delimited "$output_dir/$datetime/wid-AS5.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "TH", "TW", "SG", "MY")
export delimited "$output_dir/$datetime/wid-AS6.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "AF", "BN", "KH", "KP", "MO")
export delimited "$output_dir/$datetime/wid-AS7.csv", delimiter(";") replace
restore
*/
* Europe (East & West) + Russia
preserve 
keep if inlist(Alpha2, "AL", "AT", "BA")
	export delimited "$output_dir/$datetime/wid-eur1.csv", delimiter(";") replace
restore
preserve 
keep if inlist(Alpha2, "BE", "BG", "CH")
	export delimited "$output_dir/$datetime/wid-eur2.csv", delimiter(";") replace
restore
preserve 
keep if inlist(Alpha2, "CY", "CZ", "DD")
	export delimited "$output_dir/$datetime/wid-eur3.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "DE", "DK", "EE")
	export delimited "$output_dir/$datetime/wid-eur4.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "ES", "FI", "GB")
	export delimited "$output_dir/$datetime/wid-eur5.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "GR", "HR", "HU")
	export delimited "$output_dir/$datetime/wid-eur6.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "IE", "IS", "IT")
	export delimited "$output_dir/$datetime/wid-eur7.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "LT", "LU", "LV")
	export delimited "$output_dir/$datetime/wid-eur8.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "MD", "ME", "MK")
	export delimited "$output_dir/$datetime/wid-eur9.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "MT", "NL", "NO")
	export delimited "$output_dir/$datetime/wid-eur10.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "PL", "PT", "QE")
	export delimited "$output_dir/$datetime/wid-eur11.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "QE-MER", "QM", "QY")
	export delimited "$output_dir/$datetime/wid-eur12.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "RO", "RS", "SE")
	export delimited "$output_dir/$datetime/wid-eur13.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "SI", "SK", "RU")
	export delimited "$output_dir/$datetime/wid-eur14.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "KV", "QM-MER", "QX", "QX-MER", "QY-MER")
	export delimited "$output_dir/$datetime/wid-eur15.csv", delimiter(";") replace
restore

preserve
keep if Alpha2 == "FR"
export delimited "$output_dir/$datetime/wid-FR.csv", delimiter(";") replace
restore

preserve 
keep if inlist(Alpha2, "AM", "AZ", "BY")
	export delimited "$output_dir/$datetime/wid-eur16.csv", delimiter(";") replace
restore
preserve 
keep if inlist(Alpha2, "GE", "UA", "KS")
	export delimited "$output_dir/$datetime/wid-eur17.csv", delimiter(";") replace
restore


* Export Latin America
preserve
keep if inlist(Alpha2, "BR", "CL", "CO")
	export delimited "$output_dir/$datetime/wid-latam1.csv", delimiter(";") replace
restore

preserve
keep if inlist(Alpha2, "CR", "EC", "MX")
	export delimited "$output_dir/$datetime/wid-latam2.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "AR", "PE", "SV", "UY")
	export delimited "$output_dir/$datetime/wid-latam3.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "BO", "BS", "BZ")
	export delimited "$output_dir/$datetime/wid-latam4.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "CU", "DO", "GT")
	export delimited "$output_dir/$datetime/wid-latam5.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "GY", "HN", "HT")
	export delimited "$output_dir/$datetime/wid-latam6.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "JM", "NI", "PA")
	export delimited "$output_dir/$datetime/wid-latam7.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "PY", "SR", "TT")
	export delimited "$output_dir/$datetime/wid-latam8.csv", delimiter(";") replace

restore
preserve
keep if inlist(Alpha2, "VE", "XL", "XL-MER")
	export delimited "$output_dir/$datetime/wid-latam9.csv", delimiter(";") replace

restore

*Export Africa
preserve
keep if inlist(Alpha2, "AO", "BF", "BI", "BJ", "BW" )
	export delimited "$output_dir/$datetime/wid-africa1.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "CD", "CF", "CG", "CI", "CM")
	export delimited "$output_dir/$datetime/wid-africa2.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "CV", "DJ", "DZ", "ER", "ET")
	export delimited "$output_dir/$datetime/wid-africa3.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "GA", "GH", "GM", "GN", "GQ")
	export delimited "$output_dir/$datetime/wid-africa4.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "GW", "KE", "KM", "LR", "LS")
	export delimited "$output_dir/$datetime/wid-africa5.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "LY", "MA", "MG", "ML", "MR")
	export delimited "$output_dir/$datetime/wid-africa6.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "MU", "MW", "MZ", "NA", "NE")
	export delimited "$output_dir/$datetime/wid-africa7.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "NG", "QB", "QF", "QK", "QN")
	export delimited "$output_dir/$datetime/wid-africa8.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "QO", "QT", "QV", "RW", "SC")
	export delimited "$output_dir/$datetime/wid-africa9.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "SD", "SL", "SN", "SO", "SS")
	export delimited "$output_dir/$datetime/wid-africa10.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "ST", "SZ", "TD", "TG", "TN")
	export delimited "$output_dir/$datetime/wid-africa11.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "TZ", "UG", "ZM", "ZW", "ZZ" )
	export delimited "$output_dir/$datetime/wid-africa12.csv", delimiter(";") replace
restore
preserve
keep if inlist(Alpha2, "ZA")
	export delimited "$output_dir/$datetime/wid-ZA.csv", delimiter(";") replace
restore

* Export AU NZ CA
preserve
keep if inlist(Alpha2, "AU", "NZ", "CA")
	export delimited "$output_dir/$datetime/wid-AUNZCA.csv", delimiter(";") replace
restore
preserve
keep if Alpha2 == "US"
export delimited "$output_dir/$datetime/wid-US.csv", delimiter(";") replace
restore


/*
*/

// Export South Africa
/*
preserve
keep if Alpha2 == "ZA"
export delimited "$output_dir/$datetime/wid-ZA.csv", delimiter(";") replace
restore
*/
// Export all 
export delimited "$output_dir/$datetime/wid-db.csv", delimiter(";") replace

// -------------------------------------------------------------------------- //
if ($export_with_labels) {
	use "$work_data/wid-final-with-label.dta", clear

	rename iso Alpha2
	rename p perc

	sort Alpha2 perc year
	export delimited "$output_dir/$datetime/wid-db-with-labels.csv", delimiter(";") replace

	// By country
	use "$work_data/wid-final-with-label.dta", clear

	rename iso Alpha2
	rename p perc

	capture mkdir "$output_dir/$datetime/by_country"
	
	// List the variables
	ds Alpha2 perc year, not
	local vars = r(varlist)

	generate iso = substr(Alpha2, 1, 2) if Alpha2 != "ISO-2 country code"
	quietly levelsof iso, local(iso_list)
	foreach iso of local iso_list {
		local usevars
		foreach v of local vars {
			quietly count if (`v' != "") & (iso == "`iso'") & (Alpha2 != "ISO-2 country code")
			if (r(N) > 0) {
				local usevars `usevars' `v'
			}
		}
		export delimited Alpha2 perc year `usevars' using "$output_dir/$datetime/by_country/`iso'.csv" ///
			if iso == "`iso'" | Alpha2 == "ISO-2 country code", delimiter(";") replace
	}
}
