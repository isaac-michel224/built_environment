# Prepare workspace
rm(list = ls()) # Clear environment
gc()            # Clear unused memory
cat("\f")       # Clear the console


library.list <- c("ppcor","Hmisc","ggplot2","knitr","data.table","tidyverse") # this is a list of libraries we will be using
# foreign is a package that allows us to read spss data in r
# The rcorr( ) function in the Hmisc package produces correlations/covariances and significance levels for pearson  correlations.
# ppcor provides functions that Calculate parital and semi-partial (part) correlations along with p value.
# ggplot2 is a package that allows us to creat elegant data visualisations using the grammar of graphics.
# tidyverse will make it easy to install and load multiple "tidyverse" packages in a single step.
# knitr is a general-purpose package for dynamic report generation in R.

for (i in 1:length(library.list)) {
  if (!library.list[i] %in% rownames(installed.packages())) {
    install.packages(library.list[i])
  }
  library(library.list[i], character.only = TRUE)
}
rm(library.list)


spring <- read.csv("data/COVID-19 Cases and Rates by Neighborhood. 04-26-2020 to 05-09-2020.csv")
fall <- read.csv("data/COVID-19 Cases and Rates by Neighborhood. 10-04-2020 to 10-17-2020.csv")

#Clean Datasets

outcome_1 <- spring %>%
  mutate(Category1=strsplit(Category1, "/")) %>%
  unnest(Category1) 

#Remove Rows Contain Boston and Dorchester(),
outcome_1 <- outcome_1[c(-6,-9,-10), ]

outcome_2 <- fall %>%
  mutate(Category1=strsplit(Category1, "/")) %>%
  unnest(Category1) 

outcome_2 <- outcome_2[c(-6,-9,-10), ]

#Merge 2 variables

covid <- merge(outcome_1, outcome_2,
            by = "Category1")

covid[covid == "Backbay"] <- "Back Bay"

#Write excel Data output
library(readxl)
neigh_cov <- read_excel("data/neigh_cov.xlsx")

data <- merge(covid, neigh_cov,
              by.x = "Category1",
              by.y = "Neighborhood")

datx <- data[c(-3,-6), ]


#--Descriptive Statistics--#
library(vtable)
summ <- datx %>%
  select("Category1", "public_transit", "Hispanic", "hh_size",
         "high_school", "service_employed", "open_space",
          "pop_density", "hos_density", "comm_cen_dens")

st(summ, add.median = TRUE)



#----Correlation---#
#https://www.geeksforgeeks.org/correlation-matrix-in-r-programming/

analysis <- datx %>%
  select("Spring_Rate", "Spring_Case_Count", "Fall_Rate", 
         "Fall_Case_Count", "public_transit", "Hispanic", "hh_size",
         "high_school", "service_employed", "open_space",
         "pop_density", "hos_density", "comm_cen_dens")

matrix <- data %>%
  select("Spring_Rate", "Spring_Case_Count", "Fall_Rate", 
         "Fall_Case_Count", "public_transit", "Hispanic", "hh_size",
         "high_school", "service_employed", "open_space",
         "pop_density", "hos_density", "comm_cen_dens")


library(corrtable) #Documentation: https://paulvanderlaken.com/2020/07/28/publication-ready-correlation-matrix-significance-r/#save_correlation_matrix
save_correlation_matrix(analysis[,c(-2,-4)],
                   filename = 'be_boston_matrix.csv',
                   type = "pearson", 
                   digits = 2, 
                   show_significance = TRUE,
                   )


correlation_matrix(data,
                   type = "pearson", 
                   digits = 2, 
                   show_significance = TRUE,
)

#---OLS Model ---#
#This analysis will be using both Spring and Fall Rates

#Predictor 1: Population Density
#summary(pdx <- lm(Spring_Rate ~ pop_density + hh_size + high_school + service_employed, data=analysis)) #Significance
#confint(pdx)
#summary(pdz <- lm(Fall_Rate ~ pop_density + hh_size + high_school + service_employed, data=analysis))#Significance Model, p < .05


summary(pd_a <- lm(Spring_Rate ~ pop_density + hh_size + high_school + service_employed + Hispanic + public_transit, data=analysis))
summary(pd_f <- lm(Fall_Rate ~ pop_density + hh_size + high_school + service_employed + Hispanic + public_transit, data=analysis))

#Predictor 2: Open Space


cor.test(analysis$hh_size, analysis$pop_density)

summary(os.spring <- lm(Spring_Rate ~ open_space + hh_size + high_school + 
                          service_employed + Hispanic + public_transit, data=analysis))  
summary(os.fall <- lm(Fall_Rate ~ open_space +  hh_size + high_school + 
                        service_employed + Hispanic + public_transit, data = analysis)) 

summary(os.spring <- lm(Spring_Rate ~ open_space + hh_size, data=analysis)) #Significant, 

#hh_size remains significant from Spring to Fall

confint(os.spring)
confint(os.fall)
#Predictor 3: Hospital Density
summary(hos.spring <- lm(Spring_Rate ~ hos_density + service_employed, data=analysis)) 
#broom::glance(hos.spring)

summary(hos.fall <- lm(Fall_Rate ~ hos_density + hh_size, data=analysis))

#Predictor 4: Community Center Density
summary(com.spring <- lm(Spring_Rate ~ comm_cen_dens +
                           high_school, data=analysis)) #Significant Model 
broom::glance(hos.spring)
summary(com.fall <- lm(Fall_Rate ~ comm_cen_dens + high_school + 
                         public_transit, data=analysis)) #Same AIC when I with and without public transit 
broom::glance(com.fall)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+
#+Re Analysis of OLS Models#

library(MASS)
a2 <- analysis[c(-4,-9), ] #Remove Mattpan and Dorchester from dataset, down from n = 15 to n = 13 observations

summary(pd_a <- lm(Spring_Rate ~ pop_density + hh_size + high_school + 
                     service_employed + Hispanic + public_transit, data=a2))
summary(pd_f <- lm(Fall_Rate ~ pop_density + hh_size + high_school + 
                     service_employed + Hispanic + public_transit, data=a2))


###VIF
library(ppcor)
library(olsrr)

ols_vif_tol(pd_a)
#The indicator variable, population density(Tolerance = 0.26, VIF = 3.82) 
#has 26% of variance completely independent from other variables
#The covariate, the proportion of people who commute to work via public transit (Tolerance = 0.29, VIF ~ 3.43) has 
#29% of the variance completely independent from the other variables
#+Covariates HH Size, High_scool, service_employed, and Hispanic have low tolerance and VIF > 5
#+(i.e.,  low variance independent from other variables)
#Partial Correlations
spcor(as.matrix(analysis))

ols_vif_tol(pd_a)

anova(pd_a, pd_b)

#Is Hispanic a suppressor variable since it accounts for a lot of R-2 changed? 
#When I drop it, the variance decreases significantly

summary(pops_transit <- lm(Spring_Rate ~ pop_density + Hispanic + public_transit, data=a2)) 
#Trust this model above more, adj. R-adjusted value is 65.45% variance between each other

ols_vif_tol(pops_transit)


#Part Correlations
spcor(as.matrix(analysis))

##Hospital Density
summary(hos.spring <- lm(Spring_Rate ~ hos_density +  hh_size + high_school + 
                           service_employed + Hispanic + public_transit, data = a2))

ols_vif_tol(hos.spring)
anova(hos.spring, hos.sp.2)

summary(hos.sp.2 <- lm(Spring_Rate ~ hos_density +  hh_size + high_school + public_transit, data = a2)) 
#Removed Hispanic due to low variance based on part correlation between Hispanic and Spring Rate (Spring COVID-19 incidence)

summary(hos.sp.3 <- lm(Spring_Rate ~ hos_density + hh_size + public_transit, data = a2)) 
#Put back in Hispanic, remove high school
anova(hos.sp.2, hos.sp.3)

ols_vif_tol(hos.sp.2)

#Partial Correlation for 'a2' Data set
spcor(as.matrix(analysis))

correlation_matrix(a2,
                   type = "pearson", 
                   digits = 2, 
                   show_significance = TRUE,
)

#Diagnostics from OLS Model

opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(pd_a, las = 1)

#Dorchester, Mattapan and Roxbury appear to have either high leverage or residual in the data. 
 

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#
#This analysis will be using both Spring and Fall Case Counts
library(ggplot2)
library(sandwich)
library(msm)
library(car)


#QuasiPoisson model may be better since the dataset has a small sample size
m3 <- glm(Spring_Case_Count ~ pop_density + 
            hh_size + public_transit, family = quasipoisson, data = analysis)

summary(m3)

#Correlation Tests

cor_matrix <- cor(analysis, use = "complete.obs")
print(cor_matrix)


vif(m3)

colnames(analysis)

#--------

summary(p.fall.count <- glm(formula = Fall_Case_Count ~ pop_density
                            + hh_size + public_transit, family = quasipoisson, data = analysis))

#Open Space
summary(open.spr.count <- glm(formula = Spring_Case_Count ~ open_space + pop_density + 
                                public_transit + hh_size, family = quasipoisson, data = analysis))

vif(open.spr.count)

summary(open.fall.count <- glm(formula = Fall_Case_Count ~ open_space + pop_density + 
                                 public_transit + hh_size, family = quasipoisson, data = analysis))

vif(open.fall.count)

#Model Diagnostic


#DFBETA Plots
dfbetaPlots(open.spr.count)
dfbetaPlots(open.fall.count)

#Cook's Distance Plots

plot(open.spr.count, which = 4)
plot(open.fall.count, which = 4)

#Leverage
plot(open.spr.count, which = 5)
plot(open.fall.count, which = 5)

#Residuals

ols_plot_resid_stud(open.spr.count)
ols_plot_resid_stud(open.fall.count)
