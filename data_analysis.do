/*
CTAW Portfolio Data Analysis
    * Author: ZHANG Yifan, z.yf@pku.edu.cn
    * Latest Update: 2021/1/2
    * Data Source: 
        (1) “cases”, “deaths”: WHO Coronavirus Disease (COVID-19) Dashboard, https://covid19.who.int/table; https://covid19.who.int/WHO-COVID-19-global-data.csv, Data last updated: 2020/11/10, 9:26am CET. All data collected on 2020/11/9.
        (2) “V196”, “V192”: World Values Survey Wave 6, https://www.worldvaluessurvey.org/WVSDocumentationWV6.jsp. Here we use WVS Wave 6, as Wave 7 doesn't provide data of perceptions about science and technology.
        (3) “pop”: World Bank: Population, total, https://data.worldbank.org/indicator/SP.POP.TOTL.
        (4) “old_pr”: World Bank: Population ages 65 and above (% of total population), https://data.worldbank.org/indicator/SP.POP.65UP.TO.ZS.
        (5) “GDP_C”, “CHE_C”, “CHE_GDP”: WHO: Global Health Observatory data repository, https://www.who.int/data/gho.
    * GitHub: https://github.com/PKU-Zyf/CTAW-portfolio.
*/

* 0. Preparation
clear
global PATH = "C:\Users\PKU-Z\Desktop\data" // My own working directory

* 1. WVS Wave 6 Country Data Analysis
use "$PATH/WVS/WV6_Data_Stata_v20180912.dta"
table V2, contents(mean V196) format(%9.7f) center row col
table V2, contents(mean V192) format(%9.7f) center row col

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
label variable V196 "Scientific knowledge acquisition"
label variable V192 "Evaluation on science"
label variable death_pr "Death rate"
label variable case_pr "Infection rate"
label variable CHE_C_k "CHE per capita"
label variable death_possibility "Death possibility"
label variable case_prxV196 "Inf. rate * Kno. acq."

** 2.2. Correlation analysis
global Y death_pr
global Ctrl case_pr CHE_C CHE_GDP GDP_C old_pr
global X V196 V192
global Mod case_prxV192 case_prxV196
twoway (scatter death_pr V196) (lfit death_pr V196)
pwcorr $Y $X $Ctrl, sig

** 2.3. OLS regression
eststo clear
eststo A0: quietly regress case_pr old_pr CHE_C_k
eststo A1: quietly regress case_pr old_pr CHE_C_k V196 V192
eststo A2: quietly regress case_pr V196 V192
eststo B0: quietly regress death_pr old_pr CHE_C_k
eststo B1: quietly regress death_pr old_pr CHE_C_k V196 V192
eststo B2: quietly regress death_pr old_pr CHE_C_k case_prxV196 V192
local Group_A A0 A1 A2
local Group_B B0 B1 B2
outreg2 [`Group_B'] using "$PATH/OLS_regression.doc", replace nose label e(all) ctitle(Death rate)

** 2.4. Supplementary explanation
twoway (scatter V192 V196) (lfit V192 V196) , name(my_graph, replace) // The two explantory variables are not significantly correlative.
graph export "$PATH/my_graph1.png", name(my_graph) as(png) replace
