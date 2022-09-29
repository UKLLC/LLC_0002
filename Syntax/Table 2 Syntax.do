*TABLE 2
*load data from LATEST File 1 Metrics and DEMOGRAPHICS files (Permission_Status Base from Prerequisite)
clear
use "S:\LLC_0002\Resource Profile Paper\Datasets\Participant Base\Permission_Status_Base.dta"

**Only use participants with UK LLC status = 1
keep if ukllc_status=="1"
**RICH TO EDIT**** 
replace nhs_e_linkage_permission="0" if nhs_e_linkage_permission=="9"

**Do participants link: 
generate participants_link=0 if NHSD_linked==""
replace participants_link=1 if NHSD_linked!=""
tab cohort participants_link
*label define participants_linkl 0 "Participants Not Linked to NHS Digital" 1 "Participants Linked to NHS Digital"
label define participants_linkl 0 "dont" 1 "do"
label values participants_link participants_linkl
tab participants_link

**generating consent type 
generate consent_type=0 if nhs_e_linkage_permission==""|nhs_e_linkage_permission=="0"|nhs_e_linkage_permission=="NULL"
replace consent_type=1 if nhs_e_linkage=="1" & national_opt_out=="1"
replace consent_type=2 if nhs_e_linkage=="1" & national_opt_out=="0"
label define consent_typel 0 "Dissent" 1 "S251" 2 "Consent" 
label values consent_type consent_typel
tab consent_type

**generating any consent
generate any_consent=1 if consent_type==1|consent_type==2
replace any_consent=0 if consent_type==0
tab any_consent

**generating permission link 
generate permission_link=1 if nhs_e_linkage=="1"
replace permission_link=0 if nhs_e_linkage_permission==""|nhs_e_linkage_permission=="0"|nhs_e_linkage_permission=="NULL"
label define permission_linkl 1 "Permission" 0 "No Permission"
label values permission_link permission_linkl
tab permission_link


**generating denominator 
generate denominator=1 if ukllc_status =="1"
label define denominatorl 1 "Total"
label values denominator denominatorl
tab denominator

keep if cohort!="GENSCOT"
keep if cohort!="SABRE"
keep if cohort!="NICOLA"

*de-string cohort
encode cohort, generate(cohort_nn)

***TABLE 2A Totals only 

collect clear  
table any_consent consent_type var, statistic(fvfrequency permission_link#permission_link denominator) statistic(fvpercent permission_link#permission_link) statistic (fvfrequency participants_link) statistic(fvpercent participants_link) sformat("%s%%" fvpercent) style(table-1)
collect recode result fvfrequency=column1 fvpercent=column2 
collect layout (cohort_nn) (any_consent[.m]#consent_type[.m]#denominator#result[column1] any_consent[.m]#consent_type[.m]#permission_link[1]#result[column1 column2] any_consent[.m]#consent_type[1]#participants_link[1]#result[column1] any_consent[.m]#consent_type[1]#permission_link[1]#result[column1] any_consent[.m]#consent_type[1]#participants_link[1]#result[column2]  any_consent[.m]#consent_type[2]#participants_link[1]#result[column1] any_consent[.m]#consent_type[2]#permission_link[1]#result[column1] any_consent[.m]#consent_type[2]#participants_link[1]#result[column2] any_consent[1]#consent_type[.m]#participants_link[1]#result[column1 column2])
collect style cell result[column1], nformat(%6.0fc) 
collect style cell result[column2], nformat(%6.1f) sformat("(%s%%)")
collect style cell consent_type[1]#permission_link[1]#result[column1], warn sformat(/%s) halign(left)
collect style cell consent_type[2]#permission_link[1]#result[column1], warn sformat(/%s) halign(left)
collect style cell consent_type[1]#participants_link[1]#result[column2], halign(left)
collect style cell consent_type[2]#participants_link[1]#result[column2], halign(left)
collect style cell consent_type[.m]#participants_link[1]#result[column2], halign(left)
collect style cell consent_type[1]#participants_link[1]#result[column1], warn border( left, width(1) pattern(thickThinLargeGap) color(black))
collect style header any_consent, title(hide) level(hide)
collect style header consent_type, title(hide) level(hide)
collect style header participants_link[1], level(hide) title(hide)
collect style header permission_link, level(hide) title(hide)
collect style header denominator, level(hide) title(hide)
collect style header cohort_nn, title(hide)
putexcel set "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Table2A_output.xlsx", replace
putexcel A1="Denominator"
putexcel B1="Permission to Link"
putexcel B1:C1, merge
putexcel D1="S251"
putexcel D1:F1, merge
putexcel G1="Consent"
putexcel G1:G1, merge
putexcel J1="Total"
putexcel J1:K1, merge
putexcel A2=collect



**TABLE 2B By Cohort
table (cohort_nn any_consent consent_type) var, statistic(fvfrequency permission_link#permission_link denominator) statistic(fvpercent permission_link#permission_link) statistic (fvfrequency participants_link) statistic(fvpercent participants_link) sformat("%s%%" fvpercent) style(table-1)
collect recode result fvfrequency=column1 fvpercent=column2
collect layout (cohort_nn) (any_consent[.m]#consent_type[.m]#denominator#result[column1] any_consent[.m]#consent_type[.m]#permission_link[1]#result[column2] any_consent[.m]#consent_type[1]#participants_link[1]#result[column2] any_consent[.m]#consent_type[2]#participants_link[1]#result[column2] any_consent[1]#consent_type[.m]#participants_link[1]#result[column2])
collect style cell result[column1], nformat(%6.0fc) 
collect style cell result[column2], nformat(%6.1f)
collect style header any_consent, title(hide) level(hide)
collect style header consent_type, title(hide) level(hide)
collect style header participants_link[1], level(hide) title(hide)
collect style header permission_link, level(hide) title(hide)
collect style header denominator, level(hide) title(hide)
collect style header cohort_nn, title(hide)
putexcel set "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Table2B_output.xlsx", replace
putexcel A1="LPS"
putexcel B1="Denominator"
putexcel C1="Permission to Link"
putexcel D1="S251"
putexcel E1="Consent"
putexcel F1="Total"
putexcel A2=collect

**Import dataset to categorise variables**
clear 
import excel "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Table2B_output.xlsx", sheet("Sheet1") firstrow
**getting rid of the total row (not needed in table 2b)
drop if LPS=="Total"
****Categorising****
generate Permission_cat="≥95%" if PermissiontoLink>=95
replace Permission_cat="90-94.9%" if PermissiontoLink<95 & PermissiontoLink>=90
replace Permission_cat="85-89.9%" if PermissiontoLink<90 & PermissiontoLink>=85
replace Permission_cat="80-84.9%" if PermissiontoLink<85 & PermissiontoLink>=80
replace Permission_cat="75-79.9%" if PermissiontoLink<80 & PermissiontoLink>=75
replace Permission_cat="70-74.9%" if PermissiontoLink<75 & PermissiontoLink>=70
replace Permission_cat="65-69.9%" if PermissiontoLink<70 & PermissiontoLink>=65
replace Permission_cat="60-64.9%" if PermissiontoLink<65 & PermissiontoLink>=60
replace Permission_cat="55-59.9%" if PermissiontoLink<60 & PermissiontoLink>=55
replace Permission_cat="50-54.9%" if PermissiontoLink<55 & PermissiontoLink>=50
replace Permission_cat="45-49.9%" if PermissiontoLink<50 & PermissiontoLink>=45
replace Permission_cat="40-44.9%" if PermissiontoLink<45 & PermissiontoLink>=40
replace Permission_cat="35-39.9%" if PermissiontoLink<40 & PermissiontoLink>=35
replace Permission_cat="30-34.9%" if PermissiontoLink<35 & PermissiontoLink>=30
replace Permission_cat="25-29.9%" if PermissiontoLink<30 & PermissiontoLink>=25
replace Permission_cat="20-24.9%" if PermissiontoLink<25 & PermissiontoLink>=20
replace Permission_cat="15-19.9%" if PermissiontoLink<20 & PermissiontoLink>=15
replace Permission_cat="10-14.9%" if PermissiontoLink<15 & PermissiontoLink>=10
replace Permission_cat="5-9.9%" if PermissiontoLink<10 & PermissiontoLink>=5
replace Permission_cat="<5%" if PermissiontoLink<5
replace Permission_cat="" if PermissiontoLink==.
drop PermissiontoLink
generate S251_cat="≥95%" if S251>=95
replace S251_cat="90-94.9%" if S251<95 & S251>=90
replace S251_cat="85-89.9%" if S251<90 & S251>=85
replace S251_cat="80-84.9%" if S251<85 & S251>=80
replace S251_cat="75-79.9%" if S251<80 & S251>=75
replace S251_cat="70-74.9%" if S251<75 & S251>=70
replace S251_cat="65-69.9%" if S251<70 & S251>=65
replace S251_cat="60-64.9%" if S251<65 & S251>=60
replace S251_cat="55-59.9%" if S251<60 & S251>=55
replace S251_cat="50-54.9%" if S251<55 & S251>=50
replace S251_cat="45-49.9%" if S251<50 & S251>=45
replace S251_cat="40-44.9%" if S251<45 & S251>=40
replace S251_cat="35-39.9%" if S251<40 & S251>=35
replace S251_cat="30-34.9%" if S251<35 & S251>=30
replace S251_cat="25-29.9%" if S251<30 & S251>=25
replace S251_cat="20-24.9%" if S251<25 & S251>=20
replace S251_cat="15-19.9%" if S251<20 & S251>=15
replace S251_cat="10-14.9%" if S251<15 & S251>=10
replace S251_cat="5-9.9%" if S251<10 & S251>=5
replace S251_cat="<5%" if S251<5
replace S251_cat="" if S251==.
drop S251
generate Consent_cat="≥95%" if Consent>=95
replace Consent_cat="90-94.9%" if Consent<95 & Consent>=90
replace Consent_cat="85-89.9%" if Consent<90 & Consent>=85
replace Consent_cat="80-84.9%" if Consent<85 & Consent>=80
replace Consent_cat="75-79.9%" if Consent<80 & Consent>=75
replace Consent_cat="70-74.9%" if Consent<75 & Consent>=70
replace Consent_cat="65-69.9%" if Consent<70 & Consent>=65
replace Consent_cat="60-64.9%" if Consent<65 & Consent>=60
replace Consent_cat="55-59.9%" if Consent<60 & Consent>=55
replace Consent_cat="50-54.9%" if Consent<55 & Consent>=50
replace Consent_cat="45-49.9%" if Consent<50 & Consent>=45
replace Consent_cat="40-44.9%" if Consent<45 & Consent>=40
replace Consent_cat="35-39.9%" if Consent<40 & Consent>=35
replace Consent_cat="30-34.9%" if Consent<35 & Consent>=30
replace Consent_cat="25-29.9%" if Consent<30 & Consent>=25
replace Consent_cat="20-24.9%" if Consent<25 & Consent>=20
replace Consent_cat="15-19.9%" if Consent<20 & Consent>=15
replace Consent_cat="10-14.9%" if Consent<15 & Consent>=10
replace Consent_cat="5-9.9%" if Consent<10 & Consent>=5
replace Consent_cat="<5%" if Consent<5
replace Consent_cat="" if Consent==.
drop Consent
generate Total_cat="≥95%" if Total>=95
replace Total_cat="90-94.9%" if Total<95 & Total>=90
replace Total_cat="85-89.9%" if Total<90 & Total>=85
replace Total_cat="80-84.9%" if Total<85 & Total>=80
replace Total_cat="75-79.9%" if Total<80 & Total>=75
replace Total_cat="70-74.9%" if Total<75 & Total>=70
replace Total_cat="65-69.9%" if Total<70 & Total>=65
replace Total_cat="60-64.9%" if Total<65 & Total>=60
replace Total_cat="55-59.9%" if Total<60 & Total>=55
replace Total_cat="50-54.9%" if Total<55 & Total>=50
replace Total_cat="45-49.9%" if Total<50 & Total>=45
replace Total_cat="40-44.9%" if Total<45 & Total>=40
replace Total_cat="35-39.9%" if Total<40 & Total>=35
replace Total_cat="30-34.9%" if Total<35 & Total>=30
replace Total_cat="25-29.9%" if Total<30 & Total>=25
replace Total_cat="20-24.9%" if Total<25 & Total>=20
replace Total_cat="15-19.9%" if Total<20 & Total>=15
replace Total_cat="10-14.9%" if Total<15 & Total>=10
replace Total_cat="5-9.9%" if Total<10 & Total>=5
replace Total_cat="<5%" if Total<5
replace Total_cat="" if Total==.
drop Total
rename S251_cat S251
rename Consent_cat Consent 
rename Total_cat Total 
rename Permission_cat Permission 
export excel using "S:\LLC_0002\Resource Profile Paper\Excel Outputs\Table2B_output.xlsx", firstrow(variables) replace
