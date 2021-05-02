---
layout: page
title: RP- Vulnerability modeling for sub-Saharan Africa
---


**Replication of Vulnerability modeling for sub-Saharan Africa**

Original study *by* Malcomb, D. W., E. A. Weaver, and A. R. Krakowka. 2014. Vulnerability modeling for sub-Saharan Africa: An operationalized approach in Malawi. *Applied Geography* 48:17–30. DOI:[10.1016/j.apgeog.2014.01.004](https://doi.org/10.1016/j.apgeog.2014.01.004)

Replication Authors:
Sanjana Roy, Joseph Holler, Kufre Udoh, Open Source GIScience students of fall 2019 and Spring 2021

Replication Materials Available at: [RP-Malcomb](https://github.com/sanjana-roy/RP-Malcomb)

Created: `29 April 2021`
Revised: `2 May 2021`

## Abstract

The original study is a multi-criteria analysis of vulnerability to Climate Change in Malawi, and is one of the earliest sub-national geographic models of climate change vulnerability for an African country. The study aims to be replicable, and had 40 citations in Google Scholar as of April 8, 2021.

## Original Study Information

The study region is the country of Malawi. The spatial support of input data includes DHS survey points, Traditional Authority boundaries, and raster grids of flood risk (0.833 degree resolution) and drought exposure (0.416 degree resolution).

The original study was published without data or code, but has detailed narrative description of the methodology. The methods used are feasible for undergraduate students to implement following completion of one introductory GIS course. The study states that its data is available for replication in 23 African countries. According to Tate (2013), Malcomb et al. (2014) is a classic example of the development of a social vulnerability index, which involves the "selection of demographic indicators, normalization of indicators to a common scale, and summation to a final value."


### Data Description and Variables

The study by Malcomb et al. (2014) attempts to create a multi-criteria analysis model of vulnerability in Malawi. The authors use three sources of data that investigate four different criteria or "metathemes": adaptive capacity, including access and assets, livelihood sensitivity, and physical exposure. These metathemes were decided upon after a series of interviews that the authors conducted to understand "household social and economic practices in the context of environmental uncertainty." These interviews also informed the weighting of the eighteen evidence-based indicators in order to statistically represent vulnerability, which is a common approach used in many vulnerability studies (Malcomb et al., 2014). This weighting is demonstrated in the table below:

![Table2](assets/results/figures/MalcombTable2)
**Figure 1.** Malcomb et al. (2014) Table 2 showing weighted indicators by metatheme

**ADAPTIVE CAPACITY**
Data from the Demographic Health Survey (DHS) from 2004-2010, conducted by the U.S. agency for International Development (USAID) was used to to model household dynamics and socio-economic data, including the 'access' and 'assets' criteria.

**Assets** are important coping strategies to understand vulnerability, adaptive capacity, and resilience. The following indicators were determined to increase or decrease household resilience in the context of climate-induced disasters or shocks:
1. Number of Livestock units - None/More than 95/Unknown
2. Number of Household members sick in the past 12 months - member very sick for 3+ months No/Yes/Don't Know
3. Arables land (hectares) - 95/95 or more/unknown
4. Wealth index score - Poorest/Poorer/Middle/Richer/Richest
5. Number of Orphans in a household - Number of orphans and vulnerable children

**Access** indicators covered a wide range of areas, including resources, healthcare, education, markets, insurance, infrastructure, water, and sanitation:
6. Time to water source - On premises/Don't know
7. Electricity - Has electricity Yes/No
8. Type of Cooking Fuel - Electricity, LPG/Natural gas, Natural gas, Biogas, Kerosene, Coal/lignite, charcoal, wood, straw/shrubs/grass, agricultural crop, animal dung, no food cooked, other
9. Sex of Head of Household - Male/Female
10. Own a Cell Phone - Yes/No
11. Own a Radio - Yes/No
12. House Setting - Urban/Rural

**LIVELIHOOD SENSITIVITY** data was acquired through the Famine Early Warnings Systems Network (FEWSNET) who conducted interviews in Malawi in collaboration with the Malawi Vulnerability Assessment Committee (MVAC) and the USAID. Livelihood zones were established based on households sharing similar options for obtaining food and income and divided into wealth groups of 'Poor', 'Middle', and 'Better-Off'. Using this data, four variables from livelihood zones were developed to evaluate the sensitivity of livelihoods. Data from the different Livelihood zones were extracted based on these indicators. These were then converted into percentages based on the respective formulas:
13. Percent of food poor households obtained from their own farms = crops as source of food (%)
14. Percent of income that poor households obtain from wage labour = (labor/total) * 100
15. Percent of income from cash crops - percent labor income that is susceptible to market shocks = (crops/total) * 100
16. Disaster Coping Strategy - Ecological destruction associated with livelihood coping strategies during times of crisis in each zone. Function of baseline access, possible hazards, and response strategies. Response strategies broken down into expanding existing strategies and distress strategies. Hazards broken down into periodic and chronic. = % income from practices that would lead to ecological destruction. Determining these practices was vague and there was much uncertainty in which practices were considered in the Malcomb et al. (2014) study.

For the above three metathemes (Assets, Access, and Livelihood Sensitivity), indicators were converted to a 1-5 scale to match the Malcomb et al. (2014) study. There scores were then used to calculate capacity scores based on table 2 in the paper by weighting them with percentages outlined in the model. These percentages were then converted to a 0-20 scale, by multiplying by 20, to resemble the range of the original study. Livelihood sensitivity and adaptive capacity were then rasterized to calculate vulnerability along with physical exposure.

**PHYSICAL EXPOSURE** data was acquired through the United Nations Environmental Program (UNEP) Global Disaster Risk Platform, which provides easily interpretable data on the risk of flood and drought exposure, two variables used under this metatheme. UNEP's Global Resource Information Database (GRID)- Europe designed this information for the global interpretation of these two variables in terms of risk evaluation, vulnerability, and information and early-warning.
17. Estimated Risk for Flood Hazard - Modeled using global data using estimated index 1 - 5 (extreme)
18. Estimated Risk to Drought Events - based on Standardized Precipitation Index. Unit as expected average annual population exposed
Bilinear sampling was used for the drought layer to average continuous population exposure values and this layer was also reclassified into the quintile classification (1-5). Near sampling was used for the flood layer to preserve integer values.  

### Analytical Specification

The original study was conducted using ArcGIS and STATA, but does not state which versions of these software were used.
The replication study will use R.

## Materials and Procedure

1. Data Preprocessing:
    - Download traditional authorities: MWI_adm2.shp
2. Adding Traditional Authorities (TA) and Livelihood Zone (LZ) ids to DHS clusters
3. Removing Household (HH) entries with invalid or unknown values
4. Aggregating HH data to DHA clusters, and then joining to traditional authorities to get: ta_capacity_2010
5. Removing index and livestock values that were NA
6. Sum of Livestock by HH
7. Scale adaptive capacity fields (from DHS data) on scale of 1 - 5 to match Malcomb et al.
8. Weight capacity based on table 2 in Malcomb et al.
    - Calculate capacity by summing all weighted capacity fields
9. Summarize capacity from households to traditional authorities
10. Joining mean capacities to TA polygon layer
11. Making capacity score resemble Malcomb et al s work (scores on range of 0-20) by multiplying capacity score by 20
12. Categorizing capacities using natural jenks methods
13. Creating blank raster and setting extent of Malawi - CRS: 4326
14. Reproject, clip and resampling flood risk and drought exposure rasters to new extent and cell size
    - Uses bilinear resampling for drought to average continuous population exposure values
    - Uses nearest neighbor resampling for flood risk to preserve integer values
    - Removing factors from flood layer and recasting them as integers
    - Clipping TAs with LZs to remove lake
    - Rasterizing final TA capacity layer
15. Masking flood and drought layers
16. Reclassify drought raster into quantiles
17. Add all RASTERs together to calculate final output:  final = (40 - geo) * 0.40 + drought * 0.20 + flood * 0.20 + LHZ * 0.20
18. Using zonal statistics to aggregate raster to TA geometry for final calculation of vulnerability in each traditional authority

## Replication Results

### Mapping Adaptive Capacity

![Figure4](assets/results/maps/ac_2010.png)
**Figure 2.** Digitized map of Figure 4 in Malcomb et al. (2014). Digitization was conducted using the Georeferencer in QGIS

![DiffFigure4](assets/results/maps/diffmap2010.png)
**Figure 3.** Difference in results of adaptive capacity from the Malcomb et al. (2014) original study and this replication study

![CompTable](assets/results/figures/CompTable.png)
**Table 1.** Matrix of comparison between Malcomb et al. (2014) original study and this replication study based on the Jenk's classification used in the original study

With a Spearman's Rho coefficient of 0.764, the Malcomb et. al (2014) adaptive capacity scores in Malawi were mostly supported by and aligned with the replication. This coefficient, which indicates how well two sets of ranked data correlate with each other, is 0 at no correlation, 1 at a positive correlation, and -1 at an inverse correlation. Therefore, our replication study demonstrates a relatively strong positive correlation with the original study. However, according to the difference map (Figure 3), the replication does appear to have a greater number of higher scores than the original. There seems to be only a few cases in which the original study adaptive capacity scores were greater. Having used the same data, it is possible that certain indicators were calculated differently than what was done in the original study. There may also be issues with the rescaling of variables through our multiplication by 20 in order to match the Malcomb et al. (2014) range, which may have pushed certain indicators higher than the original study.


### Mapping Vulnerability

![Figure5](assets/esults/maps/vulnerability.png)
**Figure 4.** Digitized map of Figure 5 in Malcomb et al. (2014). Digitization was conducted using the Georeferencer in QGIS

![DiffFigure5](assets/results/maps/diffmapvuln.png)
**Figure 5.** Difference in results of vulnerability from the Malcomb et al. (2014) original study and this replication study

![Scatterplot](assets/results/figures/scatterplot.png)
**Figure 6.** Scatterplot demonstrating correlation between raster values of the original and replicated study

A Spearman's Rho result of 0.273 as well as the scatterplot in Figure 6 both demonstrate a weak correlation between the vulnerability mapping of the original and replicated studies. There was much uncertainty in calculating livelihood sensitivity indicators, which could be a major source of error in this replication.


## Unplanned Deviations from the Protocol

Replication and reproduction of scientific methods required a sound description of methodology. These are some of the changes we made from our original interpretation of the workflow in the Malcomb et al. (2014) study to our final workflow based on the data we accessed and the R code script created by Kufre Udoh and Joseph Holler:

1. The Malcomb et al. study classified indicators on a 0 to 5 scale, with 0 representing the worst condition for a household and 5 representing the best. Their use of the term "quintile" was confusing in this case as 0 to 5 would represent six different categories and not five. We made the decision to normalize our indicators on a scale of 1 to 5 instead, by multiplying indicator percent ranks by 4 and adding 1.
2. The numbers that we ended up with through our calculation of the capacity scores based on the percentage allocation were not in the same range as those in Malcomb et al.'s (2014) study. We had to adjust our workflow and multiply the adaptive capacity scores by 20 to resemble the original study scale.
3. Malcomb et al. (2014) did not detail any of the protocols or methods they used to clean and preprocess the original data. Our workflow included steps to remove NA values from the data as well as code that included joining certain variables in the data for a more logical workflow.
4. We found that the Malcomb et al. (2014) study did not elaborate on the methodology they used to calculate livelihood zone indicators, particularly for the "Disaster Coping Strategy" indicator, which is determined through "ecological destruction associated with livelihood coping strategies during time of crisis in each zone" and "access to alternative forms of income." We altered our workflow to calculate this by assessing the percent income from practices that would lead to ecological destruction. However, we had to make arbitrary decisions on what these practices could be and included practices such as selling firewood or grasses.


## Discussion

The replication of the Malcomb et al. (2014) study proved to be more of a success when replicating results for adaptive capacity scores with a Spearman's correlation of 0.764, but less so for the mapping of vulnerability, with a Spearman's correlation of 0.273. While the former denotes a strong positive correlation between the original and replicated study, it is still a low correlation given that we used the same data. Issues were seen to stem from lack of details in the original analysis as to how they conducted their methodology. The weak correlation in the latter replication speaks more to uncertainties that derived from the manner in which data was used and vulnerability indicators were calculated. In general, the Malcomb et al. (2014) study failed to provide necessary specifications in order to replicate or reproduce their vulnerability model. Models are meant to be tested, retested, and applied to different contexts. This replication of the Malcomb et al. (2014) study speaks to larger issues in the design and communication of social vulnerability models.  

While conducting our replication study, we found that uncertainty arose in many ways. Primarily, this uncertainty was found in the explanation and lack of detailedness of the methodology. The narrative format of the methodology section led to arbitrary interpretations in how certain processes took place in the original study. Details on preprocessing and how certain variables or indicators were calculated were oftentimes unclear or left out from the narrative. Their explanation of ranking vulnerability indicators on a quintile scale from 0-5 was confusing (as this would imply six different categories rather than five). We decided to rank these indicators on a scale of 1-5 instead, which may have led to differences in the our replicated output. Furthermore, it was also unclear as to where in the methodology aggregation took place from the household level to traditional authorities: before or after the weighting of variables. The lack of a clear and precise workflow led to many uncertainties in comprehending the methodology narrative.

We also noticed that uncertainty arose in the translation of real world phenomenon and processes into data to use for modeling. It was unclear as to how certain vulnerability indicators, such as 'sex of head of household',  were ranked on a quintile scale. From the DHS data itself, classifications for indicators, such as 'hectares of agricultural land' - 95 hectares, more than 95 hectares, or unknown -  were left unexplained and seemed arbitrary. However, the largest uncertainty in our replication study was the calculation of livelihood sensitivity indicators, which would have likely led to the large discrepancies between vulnerability mapping of our study and the original. This dilemma is termed by Tate (2013) as "epistemic uncertainty," which stems from an "incomplete or imprecise understanding of parameters that are modeled with fixed but poorly known values" or a "misrepresentation of processes." Although the methods in calculating indicators was somewhat defined by Malcomb et al. (2014), calculating certain indicators required the use of subjective decision-making from our understanding of the study and data they used. Therefore, uncertainty arises form both the error in measurement of input data as well as the transformation of data into variables.

According to Tate (2013) this study would be a classic example of the development of a vulnerability index, which involves the "selection of demographic indicators, normalization of indicators to a common scale, and summation to a final value." As the author points out, there is little consensus on how indexes are developed and how different variables are interpreted, which is the the case of this replication study. These uncertainties in the inputs of the model have significant consequences for the derived output. Longely et al. (2008) defines a method for understanding how these uncertainties can manifest and develop in spatial research from the real world referents to problem conceptualization, measurement and representation, analysis, to interpretation and validation. Each one of these steps introduces a new form of uncertainty that each amounts to a result further from the real world phenomenon. With "improved knowledge, data, and modeling processes, epistemic uncertainty can be reduced" and uncertainty analyses can help improve upon the robustness of the model structure as well as its potential to be replicated and reproduced (Tate, 2013).

## Conclusion

This replication of the Malcomb et al.(2014) study proves that there is much to consider when developing a social vulnerability model. Models are meant to be applied to different contexts and therefore, their capacity for reproducibility and replicability must be tested for. The provision of a more detailed methodology from the measurement of variables and real-world translation to aggregation is of utmost importance in these kinds of studies. Transparency in methodology can be improved through providing the code and processing details behind the model. However, epistemic uncertainty is ultimately inevitably associated with social vulnerability models. Its prevalence can be reduced through the use of uncertainty analyses, as suggested by Tate (2013), as a method to improve the quality and applicability of such a model.


## Acknowledgement

Major thanks to the group members I worked with - Maddie Tango, Jackson Mumper, Evan Killion, Arielle Landau, and Steven Montilla Morantes - in replicating this study. Thank you to Joe Holler and Kufre Udoh for providing the code for this replication as well as guidance on the technical matters.


## References

Longley, P. A., M. F. Goodchild, D. J. Maguire, and D. W. Rhind. 2008. Geographical information systems and science 2nd ed. Chichester: Wiley. Chapter 6: Uncertainty, pages 127-153.

Malcomb, D. W., E. A. Weaver, and A. R. Krakowka. 2014. Vulnerability modeling for sub-Saharan Africa: An operationalized approach in Malawi. Applied Geography 48:17–30. DOI:10.1016/j.apgeog.2014.01.004

Tate, E. 2013. Uncertainty Analysis for a Social Vulnerability Index. Annals of the Association of American Geographers 103 (3):526–543. doi:10.1080/00045608.2012.700616.


####  Report Template References & License

This template was developed by Peter Kedron and Joseph Holler with funding support from HEGS-2049837. This template is an adaptation of the ReScience Article Template Developed by N.P Rougier, released under a GPL version 3 license and available here: https://github.com/ReScience/template. Copyright © Nicolas Rougier and coauthors. It also draws inspiration from the pre-registration protocol of the Open Science Framework and the replication studies of Camerer et al. (2016, 2018). See https://osf.io/pfdyw/ and https://osf.io/bzm54/

Camerer, C. F., A. Dreber, E. Forsell, T.-H. Ho, J. Huber, M. Johannesson, M. Kirchler, J. Almenberg, A. Altmejd, T. Chan, E. Heikensten, F. Holzmeister, T. Imai, S. Isaksson, G. Nave, T. Pfeiffer, M. Razen, and H. Wu. 2016. Evaluating replicability of laboratory experiments in economics. Science 351 (6280):1433–1436. https://www.sciencemag.org/lookup/doi/10.1126/science.aaf0918.

Camerer, C. F., A. Dreber, F. Holzmeister, T.-H. Ho, J. Huber, M. Johannesson, M. Kirchler, G. Nave, B. A. Nosek, T. Pfeiffer, A. Altmejd, N. Buttrick, T. Chan, Y. Chen, E. Forsell, A. Gampa, E. Heikensten, L. Hummer, T. Imai, S. Isaksson, D. Manfredi, J. Rose, E.-J. Wagenmakers, and H. Wu. 2018. Evaluating the replicability of social science experiments in Nature and Science between 2010 and 2015. Nature Human Behaviour 2 (9):637–644. http://www.nature.com/articles/s41562-018-0399-z.
