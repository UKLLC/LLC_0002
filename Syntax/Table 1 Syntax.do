************************************************************************************************
* AUTHOR: SB, RT
* DATE: 12/05/2022
* Updated 09/08/2022
* PURPOSE: TAKE FILE1 INFO FROM STUDIES AND BUILD RESOURCE PROFILE PAPER STUDY NUMBERS TABLES
* Save File 1 Documenation in the 'Resource Paper' Folder
***********************************************************************************************
**TABLE 1

* STEP1: IMPORT GOOGLE DOC and clean data
clear 
import excel "S:\LLC_0002\Resource Profile Paper\File 1 Documentation\UK LLC File 1 Documentation.xlsx", firstrow clear
* strip down vars
keep ID Completiontime LPS File1Update Date Pleaseenterthetotalnumberof-S
* rename vars
rename Pleaseenterthetotalnumberof enrolled
rename Pleaseenterthenumberofparti died_on_before_20191231
rename M died_on_after_20200101
rename N withdrawn_from_lps
rename O dissented_from_llc
rename P dissented_to_linkage
rename Q gov_not_estab
rename R excl_other_reasons
rename S num_in_file1

* STEP2: remove alphas/chars, and commas first
foreach var of varlist enrolled - num_in_file1 {
	replace `var' = subinstr(`var',",","",.)
	replace `var' = subinstr(`var'," ","",.)
	destring `var', replace force
}

* STEP3: sort and keep latest
* most recent entree from cohort where no. in f1 not empty
drop if num_in_file1 ==.
* give max in cohort group
bysort LPS: g t1 = _N
* create counter in cohort group 
bysort LPS (Completiontime): g t2 = _n
* keep latest 
keep if t1==t2
* drop temp vars
drop t1 t2

* STEP 4: merge in numbers form SeRP
rename LPS cohort
*merge 1:1 cohort using "S:\UKLLC - UKLLC Databank\misc\Sammy notes\Resource Paper\ukllc_status_1.dta"


*creating Table 1 

*create percentages **Note: total percentages will be wrong because it will add up all percentages. This needs to be corrected in excel (see bleow)
generate percent= (num_in_file1/enrolled)*100
egen totalenrolled= total( enrolled)
egen totalfile1= total(num_in_file1)
generate percenttotal= (totalfile1/totalenrolled)*100
replace percenttotal=. if _n!=1


****Table 1 TOTALS SDC****
collect clear
table cohort[.m] var, statistic(total enrolled num_in_file1 percenttotal died_on_before_20191231 died_on_after_20200101 withdrawn_from_lps dissented_from_llc dissented_to_linkage gov_not_estab excl_other_reasons)
collect style header cohort, title(hide) level(label)
collect style cell var[percenttotal], warn sformat((%s%%))
collect style cell var[percenttotal], warn nformat(%9.2f)
collect label levels var enrolled "# enrolled", modify
collect label levels var percent "(%)", modify
collect label levels var died_on_before_20191231 "# died <2020", modify
collect label levels var died_on_after_20200101 "# died >=2020", modify
collect label levels var withdrawn_from_lps "# withdrawn from LPS", modify
collect label levels var dissented_from_llc "# dissented from LLC", modify
collect label levels var dissented_to_linkage "# dissented from record linkage", modify
collect label levels var gov_not_estab "# governance not established", modify
collect label levels var excl_other_reasons "# other", modify
collect label levels var num_in_file1 "# sent to UK LLC ", modify
collect style header cohort, title(hide)
putexcel set "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Table1A_output.xlsx", replace 
putexcel E1:K1, merge
putexcel E1="Reasons for Exclusion"
putexcel B1:D1, merge 
putexcel B1="Denominator" 
putexcel A2=collect



***TABLE 1 Supplement by cohort*****

***Adding all exclusion reasons together****
generate exclusions=(died_on_before_20191231+died_on_after_20200101+withdrawn_from_lps+dissented_from_llc+dissented_to_linkage+gov_not_estab+excl_other_reasons)

collect clear 
table cohort var, nototals statistic(total enrolled num_in_file1 percent exclusions)
collect style cell var[percent], warn sformat((%s%%))
collect style cell var[percent], warn nformat(%9.2f)
collect label levels var enrolled "# enrolled", modify
collect label levels var percent "(%)", modify
collect label levels var exclusions "# Excluded", modify
collect label levels var num_in_file1 "# sent to UK LLC ", modify
collect style header cohort, title(hide)

*creating excel file 
putexcel set "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Table1B_output.xlsx", replace 
putexcel B1:D1, merge 
putexcel B1="Denominator" 
putexcel A2=collect

*****For ingest into Database*******

collect clear 
table cohort var, nototals statistic(total enrolled num_in_file1 percent died_on_before_20191231 died_on_after_20200101 withdrawn_from_lps dissented_from_llc dissented_to_linkage gov_not_estab excl_other_reasons)
collect style cell var[percent], warn sformat((%s%%))
collect style cell var[percent], warn nformat(%9.2f)
collect label levels var enrolled "# enrolled", modify
collect label levels var percent "(%)", modify
collect label levels var died_on_before_20191231 "# died <2020", modify
collect label levels var died_on_after_20200101 "# died >=2020", modify
collect label levels var withdrawn_from_lps "# withdrawn from LPS", modify
collect label levels var dissented_from_llc "# dissented from LLC", modify
collect label levels var dissented_to_linkage "# dissented from record linkage", modify
collect label levels var gov_not_estab "# governance not established", modify
collect label levels var excl_other_reasons "# other", modify
collect label levels var num_in_file1 "# sent to UK LLC ", modify
collect style header cohort, title(hide)
putexcel set "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Exclusions_Table.xlsx", replace 
putexcel E1:K1, merge
putexcel E1="Reasons for Exclusion"
putexcel B1:D1, merge 
putexcel B1="Denominator" 
putexcel A2=collect


