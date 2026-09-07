library(tidyverse)
library(dplyr)
library(readxl)


#Bring in Outcome Variable and Main Predictors
out_data <- read_excel("data/Boston_Crosswalk_ZIP_.xlsx")
pre_data <- read_excel("data/Open_Space_prop.xlsx")

colnames(out_data)
odt <- out_data %>%
  select(c("zip","Case_Rate"))


#For Now Join Outcome Variable and Main Predictors
out_pre <- merge(pre_data, odt, by.x = "ZIP5", by.y = "zip")
out_pre

str(out_pre)

view(out_pre)

#Bring in Age Dataset
age_data <- read_excel("data/acs2021_5yr_B01001_86000US02127.xlsx")

colnames(age_data)

#Transpose Age Dataset to Have Zip Codes as Columns
#Website Reference: https://statisticsglobe.com/select-odd-even-rows-columns-from-data-frame-r#example-2-extract-even-rows-from-data-frame
library(data.table)
adt <- transpose(age_data)

rownames(adt) <- colnames(age_data)
colnames(adt) <- rownames(age_data)

colnames(adt) <- adt[1, ]
adt <- adt[-1, ]

colnames(adt)
row_odd <- seq_len(nrow(adt)) %% 2
row_odd

adt <- adt[row_odd == 1, ]
#Follow syntax: df[rows,columns]
#Link: https://sparkbyexamples.com/r-programming/remove-column-in-r/#:~:text=2.1%20Remove%20Column%20by%20Index,the%20%E2%80%93%20(negative)%20operator.
adt <- adt[,c(-1,-2)]
adt <- adt[-1, ]
adt <- setDT(adt, keep.rownames = TRUE)[]
view(adt)

#write.csv(adt, "data/oold_man.csv", row.names=TRUE)
#Make Row Headers into Zip Code Column

#Do the Same Process with the Education Dataset 

edu_data <- read_excel("data/acs2021_5yr_B15002_86000US02127.xlsx")

edt <- transpose(edu_data)
rownames(edt) <- colnames(edu_data)
colnames(edt) <- rownames(edu_data)

colnames(edt) <- edt[1, ]
edt <- edt[-1, ]

colnames(edt)
row_odd <- seq_len(nrow(edt)) %% 2
row_odd

edt <- edt[row_odd == 1, ]

edt <- edt[,c(-2,-3)]
edt <- edt[-1, ]
view(edt)

#----Add name for 1st Column, right now NA----#

#Geographical Mobility

mob_data <- read_excel("data/acs2021_5yr_B07003_86000US02127.xlsx")
mdt <- transpose(mob_data)
rownames(mdt) <- colnames(mob_data)
colnames(mdt) <- rownames(mob_data)

colnames(mdt) <- mdt[1, ]
mdt <- mdt[-1, ]

colnames(mdt)
row_odd <- seq_len(nrow(mdt)) %% 2
row_odd

mdt <- mdt[row_odd == 1, ]
mdt <- mdt[,c(-1,-2)]
mdt <- mdt[-1, ]
mdt <- setDT(mdt, keep.rownames = TRUE)[]

view(mdt)
#Do the Same Process with the Hispanic

his_data <- read_excel("data/Hispanic or Latino Origin by Race.xlsx")

hdt <- transpose(his_data)
rownames(hdt) <- colnames(his_data)
colnames(hdt) <- rownames(his_data)

colnames(hdt) <- hdt[1, ]
hdt <- hdt[-1, ]

colnames(hdt)
row_odd <- seq_len(nrow(hdt)) %% 2
row_odd

hdt <- hdt[row_odd == 1, ]

hdt <- hdt[,c(-1,-2)]
hdt <- hdt[-1, ]
hdt <- setDT(hdt, keep.rownames = TRUE)[]

view(hdt)

#Wranging the Means of Transportation Dataset

trans_data <- read_excel("data/acs2021_5yr_B08006_86000US02127.xlsx")

trdt <- transpose(trans_data)
rownames(trdt) <- colnames(trans_data)
colnames(trdt) <- rownames(trans_data)

colnames(trdt) <- trdt[1, ]
trdt <- trdt[-1, ]

colnames(trdt)
row_odd <- seq_len(nrow(trdt)) %% 2
row_odd

trdt <- trdt[row_odd == 1, ]
trdt <- trdt[,c(-1,-2)]
trdt <- trdt[-1, ]
trdt <- setDT(trdt, keep.rownames = TRUE)[]
view(trdt)


#Population Data

pop_data <- read_excel("data/acs2021_5yr_B01003_86000US02127.xlsx")

pdt <- transpose(pop_data)
rownames(pdt) <- colnames(pop_data)
colnames(pdt) <- rownames(pop_data)

pdt <- pdt[-1:-3, ]
row_odd <- seq_len(nrow(pdt)) %% 2
row_odd

pdt <- pdt[row_odd == 1, ]

#Remove Second Column and Rename Columns for Zip Code and Population
pdt <- pdt[,-2]

colnames(pdt)
pdt <- rename(pdt, "Population" = "3")

view(pdt)


#Bind all 6 Datasets together to become one

data <- bind_cols(adt, edt, mdt, hdt, trdt, pdt) 
colnames(data)

#Create Dataset of only the Covariates that will be used for the Analysis

covars <- subset(data, select = c("rn...1", "65_both", "Total_HS", "Hispanic or Latino:", "Same house 1 year ago:", "Public transportation (excluding taxicab):", "Population"))
covars <- rename(covars, "zip_code" = "rn...1")
covars

#Merge Out_pre and Covars

data <- merge(out_pre, covars, by.x = "ZIP5", by.y = "zip_code")
view(data)
data <- data %>%
  #convert to numeric e.g. from 2nd column to 10th column
  mutate_at(c(4:9), as.numeric)
#Export as xlsx file
str(data) #Everthing except for the zip_code column is numeric

library(writexl)

write_xlsx(data, "data/dataset.xlsx")
