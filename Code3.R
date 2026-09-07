# Prepare workspace
rm(list = ls()) # Clear environment
gc()            # Clear unused memory
cat("\f")       # Clear the console

library.list <- c("ppcor","Hmisc","ggplot2","knitr",
                  "data.table","tidyverse","olsrr",
                  "car","sandwich","msm", "msm") # this is a list of libraries we will be using

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


library(corrtable) 
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
summary(pd_a <- lm(Spring_Rate ~ pop_density + hh_size + high_school + service_employed + Hispanic + public_transit, data=analysis))
summary(pd_f <- lm(Fall_Rate ~ pop_density + hh_size + high_school + service_employed + Hispanic + public_transit, data=analysis))

#Predictor 2: Open Space
cor.test(analysis$hh_size, analysis$pop_density)

summary(os.spring <- lm(Spring_Rate ~ open_space + hh_size + high_school + 
                          service_employed + Hispanic + public_transit, data=analysis))  
summary(os.fall <- lm(Fall_Rate ~ open_space +  hh_size + high_school + 
                        service_employed + Hispanic + public_transit, data = analysis)) 

summary(os.spring <- lm(Spring_Rate ~ open_space + hh_size, data=analysis)) #Significant, 

#Note: The variable for Household Size remains significant from Spring to Fall

#Confidence Intervals
confint(os.spring)
confint(os.fall)

#Predictor 3: Hospital Density
summary(hos.spring <- lm(Spring_Rate ~ hos_density + service_employed, data=analysis)) 

summary(hos.fall <- lm(Fall_Rate ~ hos_density + hh_size, data=analysis))

#Predictor 4: Community Center Density
summary(com.spring <- lm(Spring_Rate ~ comm_cen_dens +
                           high_school, data=analysis)) #Significant Model 
broom::glance(hos.spring)

summary(com.fall <- lm(Fall_Rate ~ comm_cen_dens + high_school + 
                         public_transit, data=analysis)) #Same AIC when I with and without public transit 

broom::glance(com.fall)

#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#+Re Analysis of OLS Models with Smaller Dataset#

a2 <- analysis[c(-4,-9), ] #Remove Mattpan and Dorchester from dataset, down from n = 15 to n = 13 observations

correlation_matrix(a2,
                   type = "pearson", 
                   digits = 2, 
                   show_significance = TRUE,
)

summary(pda <- lm(Spring_Rate ~ pop_density + hh_size + high_school + 
                     service_employed + Hispanic + public_transit, data=a2))
summary(pdf <- lm(Fall_Rate ~ pop_density + hh_size + high_school + 
                     service_employed + Hispanic + public_transit, data=a2))

#Diagnostics from OLS Model
opar <- par(mfrow = c(2,2), oma = c(0, 0, 1.1, 0))
plot(pda, las = 1) #Dorchester, Mattapan and Roxbury appear to have either high leverage or residual in the data. 

ols_vif_tol(pda)
ols_vif_tol(pdf)

#The indicator variable, population density(Tolerance = 0.26, VIF = 3.82) 
#has 26% of variance completely independent from other variables
#The covariate, the proportion of people who commute to work via public transit (Tolerance = 0.29, VIF ~ 3.43) has 
#29% of the variance completely independent from the other variables
#Covariates HH Size, High_scool, service_employed, and Hispanic have low tolerance and VIF > 5
#(i.e.,  low variance independent from other variables)

summary(pts <- lm(Spring_Rate ~ pop_density + Hispanic + public_transit, data=a2)) 
summary(ptf <- lm(Fall_Rate ~ pop_density + Hispanic + public_transit, data=a2)) #Trust this model above more, adj. R-adjusted value is 65.45% variance between each other

ols_vif_tol(pts)
ols_vif_tol(ptf)

#Partial Correlations
spcor(as.matrix(analysis))

##Hospital Density
summary(hs <- lm(Spring_Rate ~ hos_density +  hh_size + high_school + 
                           service_employed + Hispanic + public_transit, data = a2))

ols_vif_tol(hs)

#Removed Hispanic due to low variance based on part correlation between Hispanic and Spring Rate (Spring COVID-19 incidence)
summary(hs3 <- lm(Spring_Rate ~ hos_density + hh_size + public_transit, data = a2)) 
#Put back in Hispanic, remove high school

ols_vif_tol(hs3)

#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#Quasi-Poisson Regression
#QuasiPoisson model may be better since the dataset has a small sample size
#This analysis will be using both Spring and Fall Case Counts

#library(ggplot2)
#library(sandwich)
#library(msm)
#library(car)

#Correlation Tests

cor_matrix <- cor(analysis, use = "complete.obs")
print(cor_matrix)

#Partial Correlation for Data set
spcor(as.matrix(analysis))

#Model 
m3 <- glm(Spring_Case_Count ~ pop_density + 
            hh_size + public_transit, family = quasipoisson, data = analysis)

summary(m3)

vif(m3)

summary(p.fall.count <- glm(formula = Fall_Case_Count ~ pop_density
                            + hh_size + public_transit, family = quasipoisson, data = analysis))

#Open Space
summary(open.spr.count <- glm(formula = Spring_Case_Count ~ open_space + pop_density + 
                                public_transit + hh_size, family = quasipoisson, data = analysis))

vif(open.spr.count)

summary(open.fall.count <- glm(formula = Fall_Case_Count ~ open_space + pop_density + 
                                 public_transit + hh_size, family = quasipoisson, data = analysis))

vif(open.fall.count)

#Model Diagnostics

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
