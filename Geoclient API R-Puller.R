# Title - Geoclient API R-Puller
# Author - Ahmad Shaibani
# Created - 04/05/2022
# Purpose - to 'Geocode' and pull data on addresses from .csv using NYC Geoclient which uses PLUTO, PAD, and other data.

#install.packages(c("httr", "jsonlite", "dplyr"))
library(httr)
library(jsonlite)
library(dplyr)

###################
###User Settings###
###################

#Set working directory
setwd("C:/Users/nycem/Desktop/Geoclient Geocoder")

###Master Tracker
#Create list object to populate at the end of the loop
datalist = list()
#Load 'Master Tracker' to geocode
mydata <- read.csv('sample_data.csv', fileEncoding="UTF-8-BOM")
###

#Begin loop
for(i in 1:nrow(mydata)){
  
  #Define API query
  query <- paste0("https://api.nyc.gov/geo/geoclient/v1/search.json?exactMatchMaxLevel=1&input=",as.character(mydata$address[i]))
  
  #Test API query, run outside loop
  #query <- paste0("https://api.nyc.gov/geo/geoclient/v1/search.json?exactMatchMaxLevel=1&input= 285 Court St")
  
  #GET function and security headers, make sure to encode to uTF-8 due to spaces in query
  getdata <- GET(url=query, add_headers('Ocp-Apim-Subscription-Key'="0b04cf9e99d54875ac40af3da09b2b9c"), encoding = "UTF-8")
  
  tryCatch({ 
    
  #Parse JSON
  results_1 <- fromJSON(content(getdata,type="text"))
 
  #Convert JSON to Dataframe
  results_2 <- as.data.frame(do.call(c, unlist(results_1, recursive=FALSE)))

  #Filter for wanted columns. See below for all columns.
  results_3 = results_2[c("input",
                          "results.response.bbl",
                          "results.response.buildingIdentificationNumber",
                          "results.response.latitude",
                          "results.response.longitude",
                          "results.response.firstBoroughName",
                          "results.response.communityDistrict",
                          "results.response.nta",
                          "results.response.ntaName",
                          "results.response.censusBlock2010")]
  
  #Load results onto the list object
  datalist[[i]] <- results_3

  remove(list=c("results_1", "results_2"))
  
  }, error=function(e){})
  
  
}
#End loop

#Load results list onto dataframe
big_data = do.call(rbind, datalist)

#Rename columns to make things a bit cleaner
big_data <- big_data %>% 
  rename(
    bbl = results.response.bbl, 
    buildingIdentificationNumber = results.response.buildingIdentificationNumber,
    latitude = results.response.latitude,
    longitude = results.response.longitude,
    firstBoroughName = results.response.firstBoroughName,
    communityDistrict = results.response.communityDistrict,
    nta = results.response.nta,
    ntaName = results.response.ntaName,
    censusBlock2010 = results.response.censusBlock2010
  )

#Remove duplicates
big_data <- big_data[!duplicated(big_data$input), ]

#Merge results dataframe with the 'Master Tracker'
mydata <- merge(x = mydata, y = big_data, by.x = "address", by.y = "input", all.x = TRUE)

#View final data
head(mydata)

#Export .csv
### need help with this, bblbin changes when exported, does not a/effect building_composite output because it uses the original dataframe "mydata" see building_composite script for note.
write.csv(mydata,"sample_data_output.csv", row.names = FALSE)












###List of columns returned from Geoclient
#id
#status
#input
#results.level
#results.status
#results.request
#results.response.assemblyDistrict
#results.response.bbl
#results.response.bblBoroughCode
#results.response.bblTaxBlock
#results.response.bblTaxLot
#results.response.blockfaceId
#results.response.boardOfElectionsPreferredLgc
#results.response.boePreferredStreetName
#results.response.boePreferredstreetCode
#results.response.boroughCode1In
#results.response.buildingIdentificationNumber
#results.response.censusBlock2000
#results.response.censusBlock2010
#results.response.censusTract1990
#results.response.censusTract2000
#results.response.censusTract2010
#results.response.cityCouncilDistrict
#results.response.civilCourtDistrict
#results.response.coincidentSegmentCount
#results.response.communityDistrict
#results.response.communityDistrictBoroughCode
#results.response.communityDistrictNumber
#results.response.communitySchoolDistrict
#results.response.condominiumBillingBbl
#results.response.congressionalDistrict
#results.response.cooperativeIdNumber
#results.response.cornerCode
#results.response.crossStreetNamesFlagIn
#results.response.dcpCommercialStudyArea
#results.response.dcpPreferredLgc
#results.response.dcpZoningMap
#results.response.dotStreetLightContractorArea
#results.response.dynamicBlock
#results.response.electionDistrict
#results.response.fireBattalion
#results.response.fireCompanyNumber
#results.response.fireCompanyType
#results.response.fireDivision
#results.response.firstBoroughName
#results.response.firstStreetCode
#results.response.firstStreetNameNormalized
#results.response.fromActualSegmentNodeId
#results.response.fromLionNodeId
#results.response.fromPreferredLgcsFirstSetOf5