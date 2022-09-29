*Update UK LLC File 1 Documentation Table 1
*define latest version: 
*local core_denom "denominator_file1_20220914"
*local demographics "DEMOGRAPHICS_20220716"
*local nhsd_sociodemo "derived_indicator_v0002_20220915"
*local self-report_sociodemo "sociodemo_harmonised_selfreport_v0002_20220908"


*Permission_Status_Base Table 2
clear
odbc load, exec("select A.llc_0002_stud_id, A.ukllc_status, A.nhs_e_linkage_permission, A.national_opt_out, A.cohort, A.llc_join_date, B.llc_0002_stud_id as NHSD_linked FROM [UKSERPUKLLC].[LLC_0002].[CORE_denominator_file1_20220914] A left join LLC_0002.nhsd_DEMOGRAPHICS_20220716 B on A.llc_0002_stud_id=B.llc_0002_stud_id") dsn (LLC_DB)

***needs to come out when duplicates gone**
rename llc_0002_stud_id LLC_0002_stud_id
duplicates tag LLC_0002_stud_id, gen(dup)
duplicates drop LLC_0002_stud_id, force 

save "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Permission_Status_Base.dta", replace 

**Linked_Participant_Base Table 3 & 4 
keep NHSD_linked
keep if NHSD_linked!=""
rename NHSD_linked LLC_0002_stud_id

save "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Linked_Participant Base.dta", replace 

**Participant_Base Table 3 & 4
clear
odbc load, exec("select llc_0002_stud_id, cohort FROM [UKSERPUKLLC].[LLC_0002].[CORE_denominator_file1_20220914] where ukllc_status = '1' order by llc_0002_stud_id") dsn (LLC_DB)
***destring LPS**
encode cohort, generate(LPS)
drop cohort 
rename llc_0002_stud_id LLC_0002_stud_id
save "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_base.dta", replace

***NHSD Harmonisation File****(Sociodemographics from NHS Digital for only those participants who link to NHS Digital)**** 
clear
odbc load, exec("select * FROM [UKSERPUKLLC].[LLC_0002].[CORE_nhsd_derived_indicator_v0002_20220915]") dsn (LLC_DB) 
save "S:\LLC_0002\Resource Profile Paper\Datasets\NHSD_Harmonisation\NHSD_Harmonisation_raw.dta", replace

**Self-Report Harmonsiation File***(Project llc_0001) Table 3 & 4 
clear
odbc load, exec("select * FROM [UKSERPUKLLC].[LLC_0002].[RETURNED_sociodemo_harmonised_selfreport_v0004_20220927]") dsn (LLC_DB) 
drop avail_from_dt
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta", replace
**Add in missing participants****
keep if object=="llc_gender"
merge 1:1 LLC_0002_stud_id using "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_Base.dta"
replace object="llc_gender" if object==""
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_gender_+base.dta", replace
clear 
use "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta"
keep if object=="llc_sex"
merge 1:1 LLC_0002_stud_id using "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_Base.dta"
replace object="llc_sex" if object==""
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_sex_+base.dta", replace
clear 
use "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta"
keep if object=="llc_ethnic3"
merge 1:1 LLC_0002_stud_id using "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_Base.dta"
replace object="llc_ethnic3" if object==""
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_ethnic3_+base.dta", replace
clear 
use "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta"
keep if object=="llc_ethnic6"
merge 1:1 LLC_0002_stud_id using "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_Base.dta"
replace object="llc_ethnic6" if object==""
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_ethnic6_+base.dta", replace
clear 
use "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta"
keep if object=="llc_ethnic7"
merge 1:1 LLC_0002_stud_id using "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_Base.dta"
replace object="llc_ethnic7" if object==""
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_ethnic7_+base.dta", replace
clear 
use "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta"
keep if object=="llc_age"
merge 1:1 LLC_0002_stud_id using "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Participant_Base.dta"
replace object="llc_age" if object==""
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_age_+base.dta", replace

clear 
use "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_age_+base.dta"
append using "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_gender_+base.dta"
append using "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_sex_+base.dta"
append using "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_ethnic3_+base.dta"
append using "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_ethnic6_+base.dta"
append using "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_ethnic7_+base.dta"
drop _merge
save "S:\LLC_0002\Resource Profile Paper\Datasets\Self-Report_Harmonisation\SelfReport_Harmonisation_raw.dta", replace
