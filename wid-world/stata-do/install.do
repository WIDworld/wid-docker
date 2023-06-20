// -------------------------------------------------------------------------- //
// Installation requirements. 
// -------------------------------------------------------------------------- //

clear all
set more off, perm

program main

	// Add required packages from SSC to this list
	local ssc_packages 	"kountry" "coefplot" "sxpose" "egenmore" "carryforward" "quandl" "gtools" "etime" "swapval" "grstyle"
	if !missing("`ssc_packages'") {
		foreach pkg in "`ssc_packages'" {
		// install using ssc, but avoid re-installing if already present
			capture which `pkg'
			if _rc == 111 {
				dis "Installing `pkg'"
				quietly ssc install `pkg', replace
			}
		}
	}
	
	// Install required packages from net
	capture which "dm89_2"
	if _rc == 111 {
		quietly net from "http://www.stata-journal.com/software/sj15-4"
		dis "Installing dm89_2"
		quietly net install dm89_2, replace
	}
	capture which "dm88_1"
	if _rc == 111 {
		quietly net from "http://www.stata-journal.com/software/sj5-4"
		dis "Installing dm88_1"
		quietly net install dm88_1, replace
	}
	capture which "xfill"
	if _rc == 111 {
		quietly net from "https://www.sealedenvelope.com/"
		dis "Installing xfill"
		quietly net install xfill, replace
	}
	capture which "rsource"
	if _rc == 111 {
		quietly net from "http://fmwww.bc.edu/RePEc/bocode/r/"
		dis "Installing rsource"
		quietly net install rsource, replace
	}
	capture which "winsor2"
	if _rc == 111 {
		quietly net from "http://fmwww.bc.edu/RePEc/bocode/w"
		dis "Installing winsor2"
		quietly net install winsor2, replace
	}
	capture which "_gwtmean"
	if _rc == 111 {
		quietly net from "http://fmwww.bc.edu/RePEc/bocode/_"
		dis "Installing _gwtmean"
		quietly net install _gwtmean, replace
	}	

end

main

