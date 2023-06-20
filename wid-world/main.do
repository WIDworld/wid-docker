// -------------------------------------------------------------------------- //
// This Stata do file combines data from many sources, including data from
// researchers, national statistical institutes and international
// organisations to generate the data present on <wid.world>.
//
// See README.md file for more information.
// -------------------------------------------------------------------------- //


// -------------------------------------------------------------------------- //
// Setup project (e.g. global variables) using absolute path.
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME beginning main.do run..."
etime, start

quietly do "/wid-world/stata-do/setup.do"


// -------------------------------------------------------------------------- //
// Import country codes and regions
// TODO: Have necessary file/s in Cloud with timestamp.
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME setting up country codes..."
etime

quietly do "$do_dir/import-country-codes.do"


// -------------------------------------------------------------------------- //
// Import, clean, and convert to the new format the old WTID
//
// ** Must re-run if the following raw files have changed **
//		$wtid_data/Database.xls 
// 	  	$wid_dir/Methodology/Codes_Dictionnary_WID.xlsx
//		$wtid_data/correspondance_composition.xlsx
//		$un_data/sna-main/exchange-rate/zimbabwe/zimbabwe-exchange-rate.csv
//		$wtid_data/CFCNFIGDP_WID.xls
// Requires:
//		$wtid_data/Database.xls 
// 	  	$wid_dir/Methodology/Codes_Dictionnary_WID.xlsx
// 		$wtid_data/correspondance_composition.xlsx
//		$un_data/sna-main/exchange-rate/zimbabwe/zimbabwe-exchange-rate.csv
//		$wtid_data/CFCNFIGDP_WID.xls
// Produces:
//		original-wtid-db.dta
//		correspondance_table.dta
//		add-new-wid-codes-output-data.dta
//		add-new-wid-codes-output-metadata.dta
//		correct-wtid-metadata-output.dta
//		harmonize-units-output.dta
//		convert-to-nominal-output.dta
//		calculate-averages-output.dta
//		add-macro-data-output.dta
//
// TODO: Have necessary file/s in Cloud with timestamp.
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME importing old WTID..."
etime

// Import original Excel file to Stata (if not done already)
// $wtid_data/Database.xls 
//		-> original-wtid-db.dta
if !fileexists("$work_data/original-wtid-db.dta") {
	quietly do "$do_dir/import-wtid-from-excel-to-stata.do"
}
assert fileexists("$work_data/original-wtid-db.dta")


// Import the conversion table from old to the new WID codes
// $codes_dictionary (i.e. $wid_dir/Methodology/Codes_Dictionnary_WID.xlsx)
// 		-> correspondance_table.dta
// TODO: have $codes_dictionary in one cloud file
quietly do "$do_dir/import-conversion-table.do"


// Add the new WID variable codes
// original-wtid-db.dta, 
// correspondance-table.dta 
// 		-> add-new-wid-codes-output-data.dta
// 		-> add-new-wid-codes-output-metadata.dta
quietly do "$do_dir/add-new-wid-codes.do"


// Correct the metadata
// $codes_dictionary, 
// add-new-wid-codes-output-metadata.dta
//		-> correct-wtid-metadata-output.dta
quietly do "$do_dir/correct-wtid-metadata.do"


// Identify and harmonize units from the old database
// add-new-wid-codes-output-data.dta,
// $un_data/sna-main/exchange-rate/zimbabwe/zimbabwe-exchange-rate.csv
// 		-> harmonize-units-output.dta
quietly do "$do_dir/harmonize-units.do"


// Convert currency amounts to nominal
// harmonize-units-ouput.dta
//		-> convert-to-nominal-output.dta
quietly do "$do_dir/convert-to-nominal.do"


// Calculate income averages from shares
// convert-to-nominal-output.dta
//		-> calculate-averages-output.dta
quietly do "$do_dir/calculate-averages.do"


// Add some macroeconomic data from Piketty & Zucman (2013)
// $wtid_data/CFCNFIGDP_WID.xls,
// calculate-averages-output.dta
// 		-> add-macro-data-output.dta
quietly do "$do_dir/add-macro-data.do"


// -------------------------------------------------------------------------- //
// Calculate new variables for the new database.
//
// Requires:
// 		add-macro-data-output.dta
// Produces:
//		calculate-income-categories-output.dta
//		calculate-average-over-output.dta
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME calculating new variables..."
etime

// Calculate income in each category from the composition variables
// add-macro-data-output.dta
// 		-> calculate-income-categories-output.dta
quietly do "$do_dir/calculate-income-categories.do"


// Calculate o- variables
// calculate-income-categories-output.dta
// 		-> calculate-average-over-output.dta
quietly do "$do_dir/calculate-average-over.do"


// -------------------------------------------------------------------------- //
// Add new data, pre-cleaned in respective raw /Country-Updates/* folders
//
// ** Must re-run if the following raw files have changed **
//		/Country-Updates/*
// Requires:
// 		/Country-Updates/*
// 		calculate-average-over-output.dta
// 		correct-wtid-metadata-output.dta
// Produces:
//		add-researchers-data-output.dta
//		add-researchers-data-metadata.dta
//		correct-widcodes-output.dta
//		correct-widcodes-metadata.dta
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME adding new data..."
etime

// Add researchers data
// Country-Updates/***.dta,
// calculate-average-over-output.dta,
// correct-wtid-metadata-output.dta
//		-> add-researchers-data-output.dta
//		-> add-researchers-data-metadata.dta
quietly do "$do_dir/add-researchers-data.do"


// Make some corrections because some widcodes for national wealth had to be
// changed: to be eventually integrated to the above files
// add-researchers-data-output.dta
//		-> correct-widcodes-output.dta
// add-researchers-data-metadata.dta
//		-> correct-widcodes-metadata.dta
quietly do "$do_dir/correct-widcodes.do"


// -------------------------------------------------------------------------- //
// Import external GDP data
//
// Requires:
//		$wb_data/metadata/wb-metadata-2020.xlsx
// 		$un_data/sna-main/gdp/gdp-current-$pastyear.csv,
// 		$un_data/sna-main/gni/gni-current-$pastyear.csv,
// 		$un_data/sna-main/gdp/gdp-usd-current-$pastyear.csv,
// 		$oecd_data/exchange-rates/ils-usd-$pastyear.csv
// 		$wb_data/gdp-current-lcu/API_NY.GDP.MKTP.CN_DS2_en_csv_v2_$pastyear.csv,
// 		$wb_data/gdp-current-usd/API_NY.GDP.MKTP.CD_DS2_en_csv_v2_$pastyear.csv,
// 		$wb_data/nfi/API_NY.GSR.NFCY.CD_DS2_en_csv_v2_$pastyear.csv
//		$wb_data/global-economic-monitor/$pastyear/GDP at market prices, current LCU, millions, seas. adj..xlsx
// 		$imf_data/world-economic-outlook/WEO-${year-2}.csv
//		$maddison_data/china/maddison-wu-na.dta
// 		$east_germany_data/east-germany-maddison-oecd.xlsx
// 		$maddison_data/world/original.xls
// 		$input_data_dir/taxhavens-data/GDP-selected_countries.xlsx
// Produces:
//		wb-metadata.dta
//		un-sna-summary-tables.dta
// 		wb-macro-data.dta
//		wb-gem-gdp.dta
//		imf-weo-gdp.dta
//		maddison-wu-gdp.dta
//		east-germany-gdp.dta
//		maddison-gdp.dta
//		$input_data_dir/taxhavens-data/GDP-selected_countries.dta 
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME importing external GDP data..."
etime

// Import World Bank metadata (for currencies & fiscal year type)
// $wb_data/metadata/wb-metadata-2020.xlsx
//		-> wb-metadata.dta
quietly do "$do_dir/import-wb-metadata.do"


// Import the UN SNA summary tables
// $un_data/sna-main/gdp/gdp-current-$pastyear.csv,
// $un_data/sna-main/gni/gni-current-$pastyear.csv,
// $un_data/sna-main/gdp/gdp-usd-current-$pastyear.csv,
// $oecd_data/exchange-rates/ils-usd-$pastyear.csv
// 		-> un-sna-summary-tables.dta
quietly do "$do_dir/import-un-sna-main-tables.do"


// Import World Bank macro data
// $wb_data/gdp-current-lcu/API_NY.GDP.MKTP.CN_DS2_en_csv_v2_$pastyear.csv,
// $wb_data/gdp-current-usd/API_NY.GDP.MKTP.CD_DS2_en_csv_v2_$pastyear.csv,
// $wb_data/nfi/API_NY.GSR.NFCY.CD_DS2_en_csv_v2_$pastyear.csv,
// wb-metadata.dta
// 		-> wb-macro-data.dta
quietly do "$do_dir/import-wb-macro-data.do"


// Import GDP from World Bank Global Economic Monitor
// $wb_data/global-economic-monitor/$pastyear/GDP at market prices, current LCU, millions, seas. adj..xlsx
//		-> wb-gem-gdp.dta
quietly do "$do_dir/import-wb-gem-gdp.do"


// Import GDP from the IMF World Economic Outlook data
// $imf_data/world-economic-outlook/WEO-${year-2}.csv
//		-> imf-weo-gdp.dta
quietly do "$do_dir/import-imf-weo-gdp.do"


// Import GDP from Maddison & Wu for China
// $maddison_data/china/maddison-wu-na.dta
//		-> maddison-wu-gdp.dta
quietly do "$do_dir/import-maddison-wu-china-gdp.do"


// Import GDP from Maddison for East Germany
// $east_germany_data/east-germany-maddison-oecd.xlsx
//		-> east-germany-gdp.dta
quietly do "$do_dir/import-maddison-east-germany-gdp.do"


// Import the GDP data from Maddison
// $maddison_data/world/original.xls
// 		-> maddison-gdp.dta
quietly do "$do_dir/import-maddison-gdp.do"


// Import the selected GDP from LaneMilesiFerreti and from CBS Netherlands
// $input_data_dir/taxhavens-data/GDP-selected_countries.xlsx
// 		-> $input_data_dir/taxhavens-data/GDP-selected_countries.dta 
quietly do "$do_dir/import-lmfcbs-gdp.do"


// -------------------------------------------------------------------------- //
// Import external price data
//
// Requires:
//		$wb_data/cpi/API_FP.CPI.TOTL_DS2_en_csv_v2_$pastyear.csv
//		$wb_data/deflator/API_NY.GDP.DEFL.ZS_DS2_en_csv_v2_$pastyear.csv
//		wb-metadata.dta
//		$wb_data/global-economic-monitor/GDP Deflator at Market Prices, LCU.xlsx
//		$un_data/sna-main/deflator/deflator-$pastyear.csv
//		$oecd_data/exchange-rates/ils-usd.csv
//		$imf_data/world-economic-outlook/WEO-$pastpastyear.csv
//		$gfd_data/price-index/*.csv
//		$fw_data/*-wages-prices-welfare-ratio.xls*
//		$maddison_data/china/maddison-wu-deflator.dta
//		$argentina_data/arklems-deflator.xlsx
//		$eastern_bloc_data/Ex_socialist.xlsx
//		$input_data_dir/taxhavens-data/cpi-cbs.xlsx
// Produces:
//		wb-cpi.dta
//		wb-deflator.dta
//		wb-gem-deflator.dta
//		un-deflator.dta
//		imf-deflator-weo.dta
//		gfd-cpi.dta
//		fw-cpi.dta
//		mw-deflator.dta
//		arklems-deflator.dta
//		eastern-bloc-deflator.dta
//		cbs-cpi.dta
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME importing external price data..."
etime

// Import CPI from the World Bank
// $wb_data/cpi/API_FP.CPI.TOTL_DS2_en_csv_v2_$pastyear.csv
// wb-metadata.dta
//		-> wb-cpi.dta
quietly do "$do_dir/import-wb-cpi.do"


// Import GDP deflator from the World Bank
// $wb_data/deflator/API_NY.GDP.DEFL.ZS_DS2_en_csv_v2_$pastyear.csv,
// wb-metadata.dta
// 		-> wb-deflator.dta
quietly do "$do_dir/import-wb-deflator.do"


// Import GDP deflator from the World Bank Global Economic Monitor
// $wb_data/global-economic-monitor/GDP Deflator at Market Prices, LCU.xlsx
//		-> wb-gem-deflator.dta
quietly do "$do_dir/import-wb-gem-deflator.do"


// Import GDP deflator from the UN
// $un_data/sna-main/deflator/deflator-$pastyear.csv
// $oecd_data/exchange-rates/ils-usd.csv
//		-> un-deflator.dta
quietly do "$do_dir/import-un-deflator.do"


// Import GDP deflator from the IMF World Economic Outlook
// $imf_data/world-economic-outlook/WEO-$pastpastyear.csv
// 		-> imf-deflator-weo.dta
quietly do "$do_dir/import-imf-weo-deflator.do"


// Import CPI from Global Financial Data
// $gfd_data/price-index/*.csv
//		-> gfd-cpi.dta
quietly do "$do_dir/import-gfd-cpi.do"


// Import CPI from Frankema and Waijenburg (2012) (historical African data)
// $fw_data/*-wages-prices-welfare-ratio.xls*
//		-> fw-cpi.dta
quietly do "$do_dir/import-fw-cpi.do"


// Import deflator for China from Maddison & Wu
// $maddison_data/china/maddison-wu-deflator.dta
//		-> mw-deflator.dta
quietly do "$do_dir/import-maddison-wu-china-deflator.do"


// Import deflator for Argentina from ARKLEMS
// $argentina_data/arklems-deflator.xlsx
//		-> arklems-deflator.dta
quietly do "$do_dir/import-arklems-deflator.do"


// Import deflator for former socialist economies
// $eastern_bloc_data/Ex_socialist.xlsx
// 		-> eastern-bloc-deflator.dta
quietly do "$do_dir/import-eastern-bloc-deflator.do"


// Import CPI for Caribbean Netherlands
// $input_data_dir/taxhavens-data/cpi-cbs.xlsx
//		-> cbs-cpi.dta
quietly do "$do_dir/import-cbs-cpi.do"


// -------------------------------------------------------------------------- //
// Import external population data
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME importing external population data..."
etime

// Import the UN population data from the World Population Prospects
quietly do "$do_dir/import-un-populations.do"


// Import the UN population data from the UN SNA (entire populations only,
// but has data for some countries that is missing from the World Population
// Prospects)
// $un_data/populations/wpp/WPP${pastpastpastyear}_totalpopulation_bothsexes.xlsx
// $un_data/populations/wpp/WPP${pastpastpastyear}_POP_F15_1_ANNUAL_POPULATION_BY_AGE_BOTH_SEXES.xlsx
// $un_data/populations/wpp/WPP${pastpastpastyear}_POP_F15_2_ANNUAL_POPULATION_BY_AGE_MALE.xlsx
// $un_data/populations/wpp/WPP${pastpastpastyear}_POP_F15_3_ANNUAL_POPULATION_BY_AGE_FEMALE.xlsx
//		-> un-population.dta
quietly do "$do_dir/import-un-sna-populations.do"


// Calculate the population series
// un-population.dta
// un-sna-population.dta
// correct-widcodes-output.dta
//		-> population-metadata.dta
//		-> populations.dta
quietly do "$do_dir/calculate-populations.do"


// -------------------------------------------------------------------------- //
// Generate harmonized series for GDP and deflators
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME harmonizing series..."
etime

// Price index
// correct-widcodes-output.dta
// correct-widcodes-metadata.dta
// wb-cpi.dta
// wb-deflator.dta
// wb-gem-deflator.dta
// un-deflator.dta
// imf-deflator-weo.dta
// gfd-cpi.dta
// fw-cpi.dta
// mw-deflator.dta
// eastern-bloc-deflator.dta
// arklems-deflator.dta
// 		-> price-index-metadata.dta
//		-> price-index-with-metadata.dta
// 		-> price-index.dta
quietly do "$do_dir/calculate-price-index.do"


// GDP
// correct-widcodes-output.dta
// un-sna-summary-tables.dta
// wb-macro-data.dta
// wb-gem-gdp.dta
// imf-weo-gdp.dta
// maddison-wu-gdp.dta
// east-germany-gdp.dta
// price-index.dta
// maddison-gdp.dta
// $wid_dir/Country-Updates/Europe/2019_03/europe-bcg2019-macro.dta
//		-> gdp.dta
quietly do "$do_dir/calculate-gdp.do"


// Retropolate
// gdp.dta
// 		-> retropolate-gdp.dta
quietly do "$do_dir/retropolate-gdp.do"


// -------------------------------------------------------------------------- //
// Calculate PPPs & exchange rates
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME calculating PPPs..."
etime

// Import exchange rates from Open Exchange rates
// price-index.dta
// $input_data_dir/currency-rates/currencies-rates-$pastyear.csv
// $un_data/sna-main/exchange-rate/somalia/tableExPop.xlsx
// $wb_data/exchange-rates/API_PA.NUS.FCRF_DS2_en_csv_v2_$pastyear.csv
// wb-metadata.dta
// 		-> exchange-rates.dta
quietly do "$do_dir/import-exchange-rate.do"


// Import Purchasing Power Parities from the OECD
// $oecd_data/ppp/SNA_TABLE4_05032020140215471.csv
// $oecd_data/ppp/PPP2017_05032020140258689.csv
//		-> ppp-oecd.dta
quietly do "$do_dir/import-ppp-oecd.do"


// Import Purchasing Power Parities from the World Bank
// $wb_data/ppp/API_PA.NUS.PPP_DS2_en_csv_v2_$pastyear.csv
// wb-metadata.dta
// 		-> ppp-wb.dta
quietly do "$do_dir/import-ppp-wb.do"


// Combine and extrapolate PPPs
// ppp-oecd.dta
// ppp-wb.dta
// gdp.dta
// price-index.dta
// $eurostat_data/deflator/namq_10_gdp_1_Data-$pastyear.csv
//		-> ppp-metadata.dta
//		-> ppp.dta
quietly do "$do_dir/calculate-ppp.do"


// Retropolate again now that have PPPs
// retropolate-gdp.dta
// ppp.dta
// exchange-rates.dta
//		-> retropolate-gdp.dta
quietly do "$do_dir/retropolate-gdp-again.do"


// -------------------------------------------------------------------------- //
// Generate data on the decomposition of income
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME generating income decomposition..."
etime

// Import data from UN SNA 1968 archives
quietly do "$do_dir/import-un-sna68.do"
quietly do "$do_dir/import-un-sna68-foreign-income.do"
quietly do "$do_dir/import-un-sna68-government.do"
quietly do "$do_dir/import-un-sna68-households-npish.do"
quietly do "$do_dir/import-un-sna68-corporations.do"
quietly do "$do_dir/combine-un-sna68.do"


// Import data from UN SNA online (SLOW!)
quietly do "$do_dir/import-un-sna-gdp.do"
quietly do "$do_dir/import-un-sna-national-income.do"
quietly do "$do_dir/import-un-sna-corporations.do"
quietly do "$do_dir/import-un-sna-households-npish.do"
quietly do "$do_dir/import-un-sna-government.do"
quietly do "$do_dir/combine-un-sna-online.do"


// Import data from OECD
quietly do "$do_dir/import-oecd-data.do"


// Import data from other sources
quietly do "$do_dir/import-imf-bop.do"
quietly do "$do_dir/import-income-researchers.do"
quietly do "$do_dir/reformat-wid-data.do"


// Retropolate, combine, impute and calibrate series (SLOW!)
quietly do "$do_dir/retropolate-combine-series.do"
quietly do "$do_dir/impute-confc.do"
quietly do "$do_dir/finalize-series.do"


// Perform corrections for tax havens and reinvested earnings on portfolio investment
quietly do "$do_dir/estimate-tax-haven-income.do"
quietly do "$do_dir/estimate-reinvested-earnings-portfolio.do"
// do "$do_dir/estimate-missing-profits.do"
quietly do "$do_dir/adjust-series.do"


// Combine decomposition with totals
quietly do "$do_dir/calculate-national-accounts.do"


// -------------------------------------------------------------------------- //
// Add PPP/exchange rates to the database
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME adding PPPs/exchange rates..."
etime

// Add to the database
// ppp.dta
// correct-widcodes-output.dta
// 		-> add-ppp-output.dta
quietly do "$do_dir/add-ppp.do"


// Add market exchange rates in 2018
// exchange-rates.dta
// add-ppp-output.dta
// 		-> add-exchange-rates-output.dta
quietly do "$do_dir/add-exchange-rates.do"


// -------------------------------------------------------------------------- //
// Incorporate the external info to the WID
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME incorporating external info..."
etime

// Convert WID series to real values
// add-exchange-rates-output.dta
// price-index.dta
// import-region-codes-output.dta
// 		-> convert-to-real-output.dta
quietly do "$do_dir/convert-to-real.do"


// Add the price index
// price-index.dta
// convert-to-real-output.dta
// 		-> add-price-index-output.dta
quietly do "$do_dir/add-price-index.do"


// Add the national accounts
// national-accounts.dta
// add-price-index-output.dta
// national-accounts.dta
// correct-widcodes-metadata.dta
// na-metadata.dta
// 		-> add-national-accounts-output.dta
// 		-> metadata-no-duplicates.dta
quietly do "$do_dir/add-national-accounts.do"


// Add the population data
// populations.dta
// add-national-accounts-output.dta
// 		-> add-populations-output.dta
quietly do "$do_dir/add-populations.do"


// -------------------------------------------------------------------------- //
// Perform some additional computations
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME performing additional computations..."
etime

// Add researchers data which are in real value
// $updates/France/2022-ggp/france-ggp2017.dta
// $updates/Germany/2018/May/bartels2018.dta
// $updates/Korea/2018_10/korea-kim2018-constant.dta
// $updates/Europe/2022_10/Europe2022.dta
// $updates/Latin_America/2022/September/LatinAmercia2022.dta
// $updates/Europe/2022_10/Europe2022-metadata.dta
// $updates/Latin_America/2022/September/LatinAmercia2022-metadata.dta
// add-populations-output.dta
// metadata-no-duplicates.dta
// 		-> add-researchers-data-real-output.dta
//		-> add-researchers-data-real-metadata.dta
quietly do "$do_dir/add-researchers-data-real.do"


// Import forbes data
// $forbes_data/forbes-1988-2010.dta
// $forbes_data/forbes-1997-2018.csv
// $forbes_data/forbes-2015-$forbes_year.csv
// $forbes_data/WID_Country_Codes.xls
// $forbes_data/wealth-distributions-$forbes_upd_year.dta
//		-> wealth-distributions-matched-forbes.dta
quietly do "$do_dir/import-forbes.do"


// Correct forbes data
// wealth-distributions-matched-forbes.dta
//		-> wealth-distributions-billionaires.dta
//		-> wealth-distributions-corrected.dta
quietly do "$do_dir/correct-top-forbes.do"


// Add wealth macro aggregates
// add-researchers-data-real-output.dta
// $updates/Wealth/2022_September/wealth-aggregates.dta
// $updates/Netherlands/2022_11/NL_WealthAggregates_WID_tomerge
// add-researchers-data-real-metadata.dta
//		-> add-wealth-aggregates-metadata.dta
//		-> add-wealth-aggregates-output.dta
quietly do "$do_dir/add-wealth-aggregates.do"


// Add Wealth distribution 
// add-wealth-aggregates-output.dta
// $updates/Wealth/2022_May/wealth-gperc-all.dta
// wealth-distributions-corrected.dta
// $updates/Asia/2022/September/cn-wealth.dta
// $updates/Asia/2022/September/hk-wealth.dta
// $updates/Netherlands/2022_12/NL-wealth-ts-rm.dta
// $updates/Poland/2022_February/poland_hweal_1923.dta
// add-wealth-aggregates-metadata.dta
// 		-> add-wealth-distribution-metadata.dta
// 		-> add-wealth-distribution-output.dta
quietly do "$do_dir/add-wealth-distribution.do"


// Aggregate by regions
// import-country-codes-output.dta
// import-region-codes-output.dta
// add-wealth-distribution-output.dta
// 		-> $input_data_dir/wid-regions-list.xlsx
//		-> aggregate-regions-output.dta
//		-> aggregate-regions-metadata-output.dta
quietly do "$do_dir/aggregate-macro-regions.do"


// Complete some missing variables for which we only have subcomponents
// aggregate-regions-output.dta
// aggregate-regions-metadata-output.dta
// 		-> complete-variables-metadata.dta
//		-> complete-variables-output.dta
quietly do "$do_dir/complete-variables.do"


// Wealth/income ratios (+ labor/capital shares)
// complete-variables-output.dta
// complete-variables-metadata.dta
// 		-> calculate-wealth-income-ratio-output.dta
//		-> calculate-wealth-income-ratio-metadata.dta
quietly do "$do_dir/calculate-wealth-income-ratios.do"


// Per capita/per adults series
// calculate-wealth-income-ratio-output.dta
// 		-> calculate-per-capita-series-output.dta
quietly do "$do_dir/calculate-per-capita-series.do"


// Distribute national income by rescaling fiscal income
// calculate-per-capita-series-output.dta
// calculate-wealth-income-ratio-metadata.dta
//		-> distribute-national-income-output.dta
//		-> distribute-national-income-metadata.dta
quietly do "$do_dir/distribute-national-income.do"


// Extrapolate pre-tax national income shares with fiscal income when possible
// distribute-national-income-metadata.dta
// distribute-national-income-output.dta
//		-> extrapolate-pretax-income-output.dta
//		-> extrapolate-pretax-income-metadata.dta
quietly do "$do_dir/extrapolate-pretax-income.do"


// Calibrate distributed data on national accounts totals
// distribute-national-income-output.dta
// 		-> calibrate-dina-revised-output.dta
quietly do "$do_dir/calibrate-dina-revised.do"


// Correct Bottom 20% of the distribution
// calibrate-dina-revised-output.dta
// 		-> correct-bottom20-output.dta
quietly do "$do_dir/correct-bottom20.do"


// Extrapolate backwards income distribution up to 1980 for ALL countries
// correct-bottom20-output.dta
// 		-> extrapolate-wid-1980-output.dta
quietly do "$do_dir/extrapolate-wid-1980.do"


// Extrapolate forward to $year/$pastyear
// extrapolate-wid-1980-output.dta
// 		-> extrapolate-wid-forward-output.dta
quietly do "$do_dir/extrapolate-wid-forward.do"


// Clean up percentiles, etc.
// extrapolate-wid-forward-output.dta
// 		-> clean-up-output.dta
quietly do "$do_dir/clean-up.do"


// Compute World and Regional Aggregates
// clean-up-output.dta
// distribute-national-income-metadata.dta
// 		-> regions_temp.dta
//		-> regions_temp2.dta
//		-> World-and-regional-aggregates-metadata.dta
//		-> World-and-regional-aggregates-output.dta
quietly do "$do_dir/aggregate-distribution-regions.do"


// Compute Top10/Bottom50 ratio 
// World-and-regional-aggregates-output.dta
// 		-> calculate-top10bot50-ratio.dta
quietly do "$do_dir/calculate-top10bot50-ratio.do"


// Compute Pareto coefficients
// calculate-top10bot50-ratio.dta
//		-> calculate-pareto-coef-output.dta
quietly do "$do_dir/calculate-pareto-coef.do"


// calculate gini coefficients
// calculate-pareto-coef-output.dta
// 		-> calculate-gini-coef-output.dta
quietly do "$do_dir/calculate-gini-coef.do"


// Merge longrun series with main data, update metadata
// $historical/gpinterize/merge-gpinterized
// $historical/regions-percapita
// $historical/regions-peradults
// $historical/WO
// calculate-gini-coef-output.dta
// $historical/merge-longrun-all-output.dta
// World-and-regional-aggregates-metadata.dta
// 		-> merge-historical-main.dta
//		-> merge-historical-main-metadata.dta
quietly do "$do_dir/merge-historical-main.do"


// Import carbon series (independent) - to be activated when updated!
// merge-historical-main.dta
// merge-historical-main-metadata.dta
// $updates/Carbon/macro/April_2021/carbon.dta
// $updates/Carbon/distribution/September_2022/carbon-distribution-2022.dta
// $updates/Carbon/distribution/September_2022/carbon-distribution-2022-metadata.dta
// $updates/Carbon/macro/April_2021/carbon-metadata.dta
// 		-> add-carbon-series-output.dta
//		-> add-carbon-series-metadata.dta
quietly do "$do_dir/add-carbon-series.do"


// -------------------------------------------------------------------------- //
// Export the database
// -------------------------------------------------------------------------- //

di "At $S_DATE $S_TIME exporting the database..."
etime

// Create a folder for the timestamp
cap mkdir "$output_dir/$datetime"
cap mkdir "$output_dir/$datetime/metadata"


// Export the metadata
// World-and-regional-aggregates-metadata.dta
// $input_data_dir/data-quality/data-quality.csv
// $input_data_dir/data-quality/wid-africa-construction.dta"
// population-metadata.dta
// price-index-metadata.dta
// ppp-metadata.dta
// $quality_file
// 		-> metadata-final.dta
//		-> $output_dir/$datetime/metadata/var-notes.csv
quietly do "$do_dir/export-metadata-source-method.do"

// calculate-pareto-coef-output.dta
// add-carbon-series-output.dta
// $codes_dictionary
//		-> $output_dir/$datetime/metadata/var-names.csv
//		-> var-names.dta
//		-> $output_dir/$datetime/metadata/var-types.csv
//		-> var-types.dta
//		-> $output_dir/$datetime/metadata/var-pops.csv
//		-> var-pops.dta
//		-> $output_dir/$datetime/metadata/var-ages.csv
//		-> var-ages.dta
quietly do "$do_dir/export-metadata-other.do"


// Create flag variables to indicate extrapolation/interpolations
// TODO: Problem with reshape long to wide !
// metadata-final.dta
// 		-> $output_dir/$datetime/wid-flags.csv
quietly do "$do_dir/create-flag-variables.do"


// Export the units
// $currency_codes/symbols.csv
// extrapolate-pretax-income-output.dta
// add-carbon-series-output.dta
//		-> $output_dir/$datetime/metadata/var-units.csv
//		-> var-units.dta
quietly do "$do_dir/export-units.do"


// Create and export the main database
// merge-historical-main.dta
// 		-> wid-long.dta
//		-> $output_dir/Latest_Updated_WID/wid-data.dta
//		-> $output_dir/$datetime/wid-data-$datetime.csv
quietly do "$do_dir/create-main-db.do"

// wid-final.dta
// wid-final-with-label.dta
//		-> $output_dir/$datetime/wid-db.csv
// 		-> $output_dir/$datetime/wid-*.csv
//		-> $output_dir/$datetime/by_country/`iso'.csv
//		-> wid-db-with-labels.csv
// quietly do "$do_dir/export-main-db.do"


// Export the list of countries
// calculate-gini-coef-output.dta
// import-country-codes-output.dta
// import-region-codes-output.dta
// import-region-codes-mer-output.dta
// 		-> $output_dir/$datetime/metadata/country-codes.csv
quietly do "$do_dir/export-countries.do"


// Make the variable tree
// $codes_dictionary
//		-> $output_dir/$datetime/metadata/variable-tree.csv
quietly do "$do_dir/make-variable-tree.do"


// -------------------------------------------------------------------------- //
// Report updated and deleted data
// TODO: Needs total update, not running.
// -------------------------------------------------------------------------- //

// di "At $S_DATE $S_TIME report updated and deleted data..."
// etime

// Export the list of countries
// $oldoutput_dir/wid-db.csv
// wid-final.dta
// 		-> $updates/WID Data updates/$olddate-to-$datetime.xlsx

// quietly do "$do_dir/update-report.do"


// -------------------------------------------------------------------------- //
// Report some of the results
// TODO: Needs total update, not running.
// -------------------------------------------------------------------------- //

// di "At $S_DATE $S_TIME reporting results..."
// etime

// Compare the world distribution of NNI vs. GDP
// wid-final.dta
// import-country-codes-output
// import-region-codes-output
// 		-> $output_dir/world-summary/TableX_GDPNNI_MER_${pastyear}_$pop_summary.xlsx
//		-> $output_dir/world-summary/TableX_GDPNNI_PPP_${pastyear}_$pop_summary.xlsx
// quietly do "$do_dir/gdp-vs-nni.do"


// Evolution of GDP and population in all countries
// wid-final.dta
// 		-> $output_dir/countries-gdp/`l'.pdf
//		-> $output_dir/countries-populations/`l'.pdf
// quietly do "$do_dir/plot-gdp-population.do"


// Evolution of CFC and NFI in selected countries
// wid-final.dta
// import-country-codes-output
// import-region-codes-output
// 		-> $output_dir/cfc-nfi/cfc.pdf
//		-> $output_dir/cfc-nfi/cfc.png
//		-> $output_dir/cfc-nfi/nfi.pdf
//		-> $output_dir/cfc-nfi/nfi.png
// quietly do "$do_dir/plot-cfc-nfi.do"


// -------------------------------------------------------------------------- //
// Sanity checks when updating database to a new year
// TODO: Needs total update, not running.
// -------------------------------------------------------------------------- //

// di "At $S_DATE $S_TIME performing sanity check/s..."
// etime

// quietly do "$do_dir/update-check.do"


// -------------------------------------------------------------------------- //
// Summary table
// TODO: Needs total update, not running.
// -------------------------------------------------------------------------- //

// di "At $S_DATE $S_TIME running final summary tables..."
// etime

// wid-final.dta
// $oldoutput_dir/metadata/var-notes.csv
// $oldoutput_dir/metadata/var-names.csv
// $country_codes/country-codes.xlsx
// $input_data_dir/variable-tree.csv
// 		-> sumtable.dta
//		-> $output_dir/WID_SummaryTable_`date_string'.xlsx
// quietly do "$do_dir/create-summary-table.do"

