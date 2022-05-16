

clear
import delimited "C:\Users\rasha\OneDrive\Desktop\TS_Pollution\Data\stata_file.csv", clear 
bysort month: egen mean = mean(deaths)
sort year month
gen t = _n
tsset t
line deaths t
graph export deaths.jpg,replace
reg deaths i.month
predict r_deaths, xb
predict res_deaths, resid
line res_deaths t
graph export res_deaths.jpg,replace
gen d_deaths = deaths - mean
line d_deaths t
graph export d_deaths.jpg,replace
	gen f_Y_10_24_12 = .
		gen stdf_Y_10_24_12 = .
		gen sqdiff_10_24_12 = .	
forvalues n = 100/133 {
			qui regress d_deaths L(1/10).d_deaths L(1/24).o3mean L(1/24).so2mean L(1/24).comean L(1/12).pm25 if t < `n'
			predict Temp_Y_hat, xb
			predict Temp_Y_rmsfe, stdf
			replace f_Y_10_24_12 = Temp_Y_hat if t == `n'+1
			replace stdf_Y_10_24_12 = Temp_Y_rmsfe if t==`n'+1
			replace sqdiff_10_24_12 = (d_deaths - Temp_Y_hat)^2 if t==`n'+1
			drop Temp_Y_hat Temp_Y_rmsfe
}
scalar BIC_10_24_12 = el(IC, 1, 6) 
scalar AIC_10_24_12 = el(IC, 1, 5) 
		gen f_Y_3_1_12 = .
		gen stdf_3_1_12 = .
		gen sqdiff_3_1_12 = .	
forvalues n = 100/133 {
			qui regress d_deaths L(1/3).d_deaths L(1).o3mean L(1).so2mean L(1).comean L(1/12).pm25 if t < `n'
			predict Temp_Y_hat, xb
			predict Temp_Y_rmsfe, stdf
			replace f_Y_3_1_12 = Temp_Y_hat if t == `n'+1
			replace f_Y_3_1_12 = Temp_Y_rmsfe if t==`n'+1
			replace sqdiff_3_1_12 = (d_deaths - Temp_Y_hat)^2 if t==`n'+1
			drop Temp_Y_hat Temp_Y_rmsfe
}
scalar BIC_3_1_12 = el(IC, 1, 6) 
scalar AIC_3_1_12 = el(IC, 1, 5) 

 
pca comean no2mean so2mean pm25
** Test for Stationarity
dfuller d_deaths
predict pc1 pc2 pc3, score

forvalues i = 1/3{
	forvalues j = 1/3{
		forvalues k = 1/3{
			forvalues l = 1/3{
		gen f_Y_P`i'_`j'_`k'_`l' = .
		gen stdf_Y_P`i'_`j'_`k'_`l' = .
		gen sqdiff_P`i'_`j'_`k'_`l' = .	
		forvalues n = 100/133 {
			qui regress d_deaths L(1/`i').d_deaths L(1/`j').pc1 L(1/`k').pc2  L(1/`l').pc3 if t < `n'
			predict Temp_Y_Phat, xb
			predict Temp_Y_Prmsfe, stdf
			replace f_Y_P`i'_`j'_`k'_`l' = Temp_Y_Phat if t == `n'+1
			replace stdf_Y_P`i'_`j'_`k'_`l'= Temp_Y_Prmsfe if t==`n'+1
			replace sqdiff_P`i'_`j'_`k'_`l' = (d_deaths - Temp_Y_Phat)^2 if t==`n'+1
			drop Temp_Y_Phat Temp_Y_Prmsfe
		}
			
		estat ic 
		mat IC = r(S) //save results
		scalar BIC_P`i'_`j'_`k'_`l' = el(IC, 1, 6) 
		scalar AIC_P`i'_`j'_`k'_`l' = el(IC, 1, 5)  
		egen meansqdiff_P`i'_`j'_`k'_`l' = mean(sqdiff_P`i'_`j'_`k'_`l')
		scalar RMSFE_P`i'_`j'_`k'_`l'  = sqrt(meansqdiff_P`i'_`j'_`k'_`l')
		drop meansqdiff_P`i'_`j'_`k'_`l'
			}
			}
	}
}


scalar minBIC_P = . 
scalar minAIC_P = .
scalar minRMSFE_P = .

// find the minimum values of the criteria
forvalues i = 1/3 {
forvalues j =1/3 {
	forvalues k = 1/3{
		forvalues l = 1/3{
if BIC_P`i'_`j'_`k'_`l' < minBIC_P {
scalar minBIC_P = BIC_P`i'_`j'_`k'_`l'
local minBIC_Pijkl ",`i' , `j' , `k' , `l'"
}
if AIC_P`i'_`j'_`k'_`l' < minAIC_P {
scalar minAIC_P = AIC_P`i'_`j'_`k'_`l' 
local minAIC_Pijkl ",`i' , `j' , `k' , `l'"
}
if RMSFE_P`i'_`j'_`k'_`l' < minRMSFE_P {
scalar minRMSFE_P = RMSFE_P`i'_`j'_`k'_`l'
local minRMSFE_Pijkl ",`i' , `j' , `k' , `l'"
}
}
}
}
}

// display your results
di "min BIC lag"`minBIC_Pijkl' " : " minBIC_P
di "min AIC lag"`minAIC_Pijkl' " : " minAIC_P
di "min RMSFE lag"`minRMSFE_Pijkl' " : " minRMSFE_P

twoway line d_deaths f_Y_3_1_12 f_Y_P3_1_1_1 t if t >100
graph export error1.jpg, replace
twoway line d_deaths f_Y_3_1_12 f_Y_P3_1_1_1 t if t >100
graph export pcaforecast.jpg, replace

clear
import delimited "C:\Users\rasha\OneDrive\Desktop\TS_Pollution\Data\stata_file.csv", clear 
bysort month: egen mean = mean(deaths)
sort year month
gen t = _n
tsset t
line deaths t
graph export deaths.jpg,replace
reg deaths i.month
predict r_deaths, xb
predict res_deaths, resid
gen d_deaths = deaths - mean

scalar minBIC_P = . 
scalar minAIC_P = .
scalar minRMSFE_P = .
pca comean no2mean so2mean pm25
** Test for Stationarity
dfuller d_deaths
predict pc1 pc2 pc3, score

forvalues i = 1/3{
	forvalues j = 0/3{
		forvalues k = 0/3{
			forvalues l = 0/3{
		gen f_Y_P_`i'_`j'_`k'_`l' = .
		gen stdf_Y_P`i'_`j'_`k'_`l' = .
		gen sqdiff_P`i'_`j'_`k'_`l' = .	
		forvalues n = 100/133 {
			qui regress d_deaths L(1/`i').d_deaths L(1/`j').pc1 L(1/`k').pc2  L(1/`l').pc3 if t < `n'
			predict Temp_Y_Phat, xb
			predict Temp_Y_Prmsfe, stdf
			replace f_Y_P_`i'_`j'_`k'_`l' = Temp_Y_Phat if t == `n'+1
			replace stdf_Y_P`i'_`j'_`k'_`l'= Temp_Y_Prmsfe if t==`n'+1
			replace sqdiff_P`i'_`j'_`k'_`l' = (d_deaths - Temp_Y_Phat)^2 if t==`n'+1
			drop Temp_Y_Phat Temp_Y_Prmsfe
		}
			
		estat ic 
		mat IC = r(S) //save results
		scalar BIC_P`i'_`j'_`k'_`l' = el(IC, 1, 6) 
		scalar AIC_P`i'_`j'_`k'_`l' = el(IC, 1, 5)  
		egen meansqdiff_P`i'_`j'_`k'_`l' = mean(sqdiff_P`i'_`j'_`k'_`l')
		scalar RMSFE_P`i'_`j'_`k'_`l'  = sqrt(meansqdiff_P`i'_`j'_`k'_`l')
		drop meansqdiff_P`i'_`j'_`k'_`l'
			}
			}
	}
}



// find the minimum values of the criteria
forvalues i = 1/3 {
forvalues j =0/3 {
	forvalues k = 0/3{
		forvalues l = 0/3{
if BIC_P`i'_`j'_`k'_`l' < minBIC_P {
scalar minBIC_P = BIC_P`i'_`j'_`k'_`l'
local minBIC_Pijkl ",`i' , `j' , `k' , `l'"
}
if AIC_P`i'_`j'_`k'_`l' < minAIC_P {
scalar minAIC_P = AIC_P`i'_`j'_`k'_`l' 
local minAIC_Pijkl ",`i' , `j' , `k' , `l'"
}
if RMSFE_P`i'_`j'_`k'_`l' < minRMSFE_P {
scalar minRMSFE_P = RMSFE_P`i'_`j'_`k'_`l'
local minRMSFE_Pijkl ",`i' , `j' , `k' , `l'"
}
}
}
}
}
di "min BIC lag"`minBIC_Pijkl' " : " minBIC_P
di "min AIC lag"`minAIC_Pijkl' " : " minAIC_P
di "min RMSFE lag"`minRMSFE_Pijkl' " : " minRMSFE_P

twotway line d_deaths f_Y_P_3_1_1_1 f_Y_P3_1_1 f_Y_3_1_12
