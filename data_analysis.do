/*
CTAW Portfolio Data Analysis
    * Author: ZHANG Yifan, z.yf@pku.edu.cn
    * Latest Update: 2020/12/14
    * Data Source: 
        (1) “cases”, “deaths”: WHO Coronavirus Disease (COVID-19) Dashboard, https://covid19.who.int/table, Data last updated: 2020/11/10, 9:26am CET. All data collected on 2020/11/9.
        (2) “V196”, “V192”: World Values Survey Wave 6, https://www.worldvaluessurvey.org/WVSDocumentationWV6.jsp. Here we use WVS Wave 6, as Wave 7 doesn't provide data of perceptions about science and technology.
        (3) “pop”: World Bank: Population, total, https://data.worldbank.org/indicator/SP.POP.TOTL.
        (4) “old_pr”: World Bank: Population ages 65 and above (% of total population) https://data.worldbank.org/indicator/SP.POP.65UP.TO.ZS.
        (5) “GDP_C”, “CHE_C”, “CHE_GDP”: WHO: Global Health Observatory data repository, https://www.who.int/data/gho.
    * GitHub: https://github.com/PKU-Zyf/CTAW-portfolio.
*/

* 0. Preparation
clear
global PATH = "C:/Users/PKU-Z/Desktop/data" // My own working directory

* 1. WVS Wave 6 Country Data Analysis
use "$PATH\WVS\WV6_Data_Stata_v20180912.dta"
tab V2, contents(mean V196) format(%9.7f) center row col
tab V2, contents(mean V192) format(%9.7f) center row col

* 2. Comprehensive Data Analysis
import excel "$PATH/main_data.xlsx", sheet("Data") firstrow clear

** 2.1. Constructing variables
*** 2.1.1. New variables
gen death_pr = 10000 * deaths / pop
gen case_pr = 100 * cases / pop
gen CHE_C_k = CHE_C / 1000
gen death_possibility = deaths / cases
gen case_prxV196 = case_pr * V196

*** 2.1.2. Variable labels
label variable country "Country"
label variable cases "Case number"
label variable deaths "Death number"
label variable pop "Population"
label variable old_pr "Elderly population"
label variable GDP_C "GDP per capita"
label variable CHE_C "CHE per capita"
label variable CHE_GDP "CHE as % GDP"
label variable V196 "Science knowledge acquisition"
label variable V192 "Evaluation on science"
label variable death_pr "Death rate"
label variable case_pr "Infection rate"
label variable CHE_C_k "CHE per capita"
label variable death_possibility "Death possibility"
label variable case_prxV196 "Inf. rate * Att. to sci."

** 2.2. Correlation analysis
global Y death_pr
global Ctrl case_pr CHE_C CHE_GDP GDP_C old_pr
global X V196 V192
global Mod case_prxV192 case_prxV196
twoway (scatter death_pr V196) (lfit death_pr V196)
pwcorr $Y $X $Ctrl, sig

** 2.3. OLS regression
eststo clear
eststo A: quietly regress death_pr case_pr
eststo B: quietly regress death_pr case_pr old_pr CHE_C_k
eststo C: quietly regress death_pr case_pr old_pr CHE_C_k V196 V192
eststo D: quietly regress death_pr case_pr old_pr CHE_C_k case_prxV196 V192
outreg2 [A B C D] using "$PATH/OLS_regression.doc", replace nose label e(r2_a) ctitle(Death rate)

** 2.4. Supplementary explanation
twoway (scatter V192 V196) (lfit V192 V196) , name(my_graph, replace) // The two explantory variables are not significantly correlative.
graph export "$PATH/my_graph.png", name(my_graph) as(png) replace
