## Background: 

Built environment is described by as “all manufactured structures, including buildings, transportation systems and other physical surroundings constructed by humans”.1,2 This encompasses the roads, greenspaces, sidewalks, housing and overall land people use daily. Since we spend most of our time in the built environment2,3, it is important to recognize the risks associated with it.
Previous research has shown how the built environment impacts our health. Greenspace promotes physical activity, which in has positive effects on combatting mental health and boosting immunity.4    
Living in close proximity to recreational open space was associated with lower BMI.5 Areas categorized as rural areas were found to have worse health outcomes in chronic illnesses and self-rated health.6 
The presence of highways were related to better health outcomes since they provide ease of access to travel to obtain resources.6 Characteristics of the built environment influence infectious disease outcomes as well, especially COVID-19. A previous study in New York found an association between percentage of sidewalks in a given area and COVID-19 incidence7. 
Another study in Washington found that overcrowding correlated with increased incidence rates and increased open space was correlated with lowering COVID-19 incidence rates.8 
COVID-19 has been shown the necessity of researchers and policymakers to pay attention to the built environment has a factor that either mitigate or exacerbate health outcomes. It allows for targeted public health interventions that are tailed to each community rather than general policies that may leave out certain vulnerable populations. In Boston, prior work has focused examining body mass index based on Boston’s built environment9, but not associating with infectious disease outcomes.  
This study assesses how built environment measures impact COVID-19 outcomes in Boston. We want to assess differences in COVID-19 outcomes vary spatially and what structural issues around the built environment around the city that can affect COVID-19 outcomes.

## Methods: 

# Data

COVID-19 data was extracted from the Boston Public Health Commission’s COVID-19 Dashboard. Demographic Data was extracted at the neighborhood level from the 5-year American Community Survey 5-year (2015-2019). 

# Outcome

There are two main outcome variables were COVID-19 incidence rate (number of cases per 100,000 residents) and COVID-19 case count. We examined the COVID-19 incidence rates during the spring and the fall of 2020 during the following two-week periods: April 26th, 2020 – May 9th, 2020 and October 4th, 2020 – October 17th, 2020. 

# Predictors

Four exposure variables were examined in this study: The proportion of open space per zip code was calculated using square kilometers. There are main predictors, which include hospital density (number of hospitals per square kilometer), population density (number of people per square kilometer) and community center density (community centers per square kilometer).    

# Covariates

Covariates included the percentage of people: who were 65 years and older, who were Hispanic, walk to commute, who had a high school education, and who had geographical mobility within the past year. 

# Analysis

COVID-19 Incidence was cross walked from the county level to zip code level. Correlation tests were performed between the outcome variable, predictors, and the covariates at the zip code level. 

Ordinary least squares (OLS) regression was used to assess the global relationships between built environment variables and COVID-19 incidence. Poisson regression models analyzed the case count data. 

## Findings: 

# Summary Statistics

In Boston, the population density per zip code is approximately 8,305 residents per square kilometer (SD: 10,938.92) (Table 1). About 23% (SD: 0.12) of residents per zip code commute to work using public transportation. 

# Correlation

The proportion of people that commute to work using public transportation (p < .001) was positively associated with COVID-19 incidence (Table 2).

# Ordinary Least Squares

Population density (p < .05) was positively associated with COVID-19 incidence after controlling for the proportion of people who commute 
to work using public transportation. The model explains about 48% of the overall data.  

## References

1.	Martin LJ, Adams RI, Bateman A, et al. Evolution of the indoor biome. Trends Ecol Evol. 2015;30(4):223-232. doi:10.1016/j.tree.2015.02.001
2.	Gilbert JA, Stephens B. Microbiology of the built environment. Nat Rev Microbiol. 2018;16(11):661-670. doi:10.1038/s41579-018-0065-5
3.	Klepeis NE, Nelson WC, Ott WR, et al. The National Human Activity Pattern Survey (NHAPS): a resource for assessing exposure to environmental pollutants. J Expo Sci Environ Epidemiol. 2001;11(3):231-252. doi:10.1038/sj.jea.7500165
4.	Kuthunur S. COVID-19 pandemic exposes Boston green space disparity issues. The Scope. https://thescopeboston.org/4704/features/covid-19-pandemic-exposes-boston-green-space-disparity-issues/. Published September 18, 2020. Accessed February 17, 2023.
5.	Duncan DT, Sharifi M, Melly SJ, et al. Characteristics of Walkable Built Environments and BMI z-Scores in Children: Evidence from a Large Electronic Health Record Database. Environ Health Perspect. 2014;122(12):1359-1365. doi:10.1289/ehp.1307704
6.	Nguyen QC, Khanna S, Dwivedi P, et al. Using Google Street View to examine associations between built environment characteristics and U.S. health outcomes. Prev Med Rep. 2019;14:100859. doi:10.1016/j.pmedr.2019.100859
7.	Tribby CP, Hartmann C. COVID-19 Cases and the Built Environment: Initial Evidence from New York City. Prof Geogr. 2021;73(3):365-376. doi:10.1080/00330124.2021.1895851
8.	Liu C, Liu Z, Guan C. The impacts of the built environment on the incidence rate of COVID-19: A case study of King County, Washington. Sustain Cities Soc. 2021;74:103144. doi:10.1016/j.scs.2021.103144
9.	Duncan DT, Castro MC, Gortmaker SL, Aldstadt J, Melly SJ, Bennett GG. Racial differences in the built environment—body mass index relationship? A geospatial analysis of adolescents in urban neighborhoods. Int J Health Geogr. 2012;11(1):11. doi:10.1186/1476-072X-11-11
10. JHU COVID-19 Dashboard Infographic US v5.2. Accessed February 18, 2023. https://bao.arcgis.com/covid-19/jhu/county/25025.html
11. Hazarie S, Soriano-Paños D, Arenas A, Gómez-Gardeñes J, Ghoshal G. Interplay between population density and mobility in determining the spread of epidemics in cities. Commun Phys. 2021;4(1):1-10. doi:10.1038/s42005-021-00679-0

Table 1: Summary Statistics across Boston Neighborhoods
Variable	Mean	Std. Dev.	Min	Pctl. 25	Median	Pctl. 75	Max
Open Space	0.18	0.12	0.03	0.11	0.14	0.25	0.48
65 years and older	0.13	0.06	0.00	0.09	0.13	0.15	0.37
Population Density	8305.43	10938.92	0.00	3573.31	5656.67	8190.58	60736.00
Hispanic/Latino	0.16	0.12	0.02	0.09	0.13	0.20	0.56
Same house 1 year ago	0.78	0.11	0.51	0.69	0.80	0.87	0.93
Public_transportation	0.23	0.10	0.07	0.17	0.23	0.31	0.46
High School Education	0.16	0.10	0.01	0.07	0.14	0.26	0.38

