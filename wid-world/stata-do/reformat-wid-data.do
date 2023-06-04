// -------------------------------------------------------------------------- //
// Import NA data that already exists in the WID
// -------------------------------------------------------------------------- //

use "$work_data/correct-widcodes-output.dta", clear

// Keep relevant macro income variables
generate to_keep = 0
replace to_keep = 1 if inlist(widcode, "mhsavi999i", "mhsgro999i", "mhsdep999i") // Personal sector
replace to_keep = 1 if inlist(widcode, "misavi999i", "misgro999i", "misdep999i") // NPISH
replace to_keep = 1 if inlist(widcode, "mcsavi999i", "mcsgro999i", "mcsdep999i") // Corporate sector
replace to_keep = 1 if inlist(widcode, "mgsavi999i", "mgsgro999i", "mgsdep999i") // Government sector
replace to_keep = 1 if inlist(widcode, "mnsavi999i", "mnsgro999i", "mnsdep999i", "mnvatp999i") // National economy
replace to_keep = 1 if inlist(widcode, "mnninc999i", "mgdpro999i", "mconfc999i", "mnnfin999i") // National income
keep if to_keep
drop to_keep p currency

greshape wide value, i(iso year) j(widcode) string
renvars value*, predrop(5)

ds iso year mgdpro999i, not
foreach v of varlist `r(varlist)' {
	replace `v' = `v'/mgdpro999i
}

// Adapt widcodes
rename mconfc999i confc
rename mcsavi999i secco
rename mcsdep999i cfcco
rename mcsgro999i segco
rename mgsavi999i savgo
rename mgsdep999i cfcgo
rename mgsgro999i saggo
rename mhsavi999i savho
rename mhsdep999i cfcho
rename mhsgro999i sagho
rename misavi999i savnp
capture confirm variable misdep999i
if (_rc == 0) {
   rename misdep999i cfcnp
}
capture confirm variable misgro999i
if (_rc == 0) {
   rename misgro999i sagnp
}
capture confirm variable mnnfin999i
if (_rc == 0) {
   rename mnnfin999i nnfin
}
capture confirm variable mnninc999i
if (_rc == 0) {
   rename mnninc999i nninc
}
capture confirm variable mnsavi999i
if (_rc == 0) {
   rename mnsavi999i savin
}
capture confirm variable mnsgro999i
if (_rc == 0) {
   rename mnsgro999i savig
}
capture confirm variable mnvatp999i
if (_rc == 0) {
   rename mnvatp999i ptxgo
}
drop *999i
dropmiss confc-ptxgo, obs force

// Ensure consistency
generate gdpro = 1
foreach var in "cfchn" "savhn" "saghn" "cfcnp" "sagnp" {
	capture confirm variable `var'
	if (_rc != 0) {
   		generate `var' = .
	}
}

enforce /// National income
        (nninc = gdpro - confc + nnfin) ///
	/// Consumption of fixed capital
        (confc = cfcco + cfchn + cfcgo) ///
	(cfchn = cfcnp + cfcho) ///
	/// National savings
	(savig = savin + confc) ///
	(savin = savhn + savgo + secco) ///
	/// Savings by sector
	(saghn = savhn + cfchn) ///
	(sagho = savho + cfcho) ///
	(sagnp = savnp + cfcnp) ///
	(saggo = savgo + cfcgo) ///
	(segco = secco + cfcco), ///
	fixed(gdpro) replace

generate series = 200000

// Drop main aggregates for now (to be recalculated later)
drop gdpro nninc

save "$work_data/sna-wid.dta", replace

// -------------------------------------------------------------------------- //
// Export metadata
// -------------------------------------------------------------------------- //

use "$work_data/correct-widcodes-metadata.dta", clear

keep if sixlet == "mnninc"

collapse (firstnm) source, by(iso)

save "$work_data/sna-wid-metadata.dta", replace
