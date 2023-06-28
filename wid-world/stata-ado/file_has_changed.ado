// How to use as Stata ADO program (more efficient)

program file_has_changed

	local temp 		= `1'
	local raw 		= `2'

	quietly ashell date -r `temp' +%s
	local temp_mod = r(o1)

	quietly ashell date -r `raw' +%s
	local raw_mod = r(o1)

	if `raw_mod' > `temp_mod' {
		di "Raw file `raw' has changed, update needed!"
		return scaler a = 1
	} else {
		di "Raw file `raw' has not changed, no re-run needed."
		return scaler a = 0
	}

end