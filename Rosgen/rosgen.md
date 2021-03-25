---
layout: page
title: Replication of Rosgen Stream Classification
---

**Replication of**
# A classification of natural rivers

Original study *by* Rosgen, D. L.
*in* *CATENA* 22 (3):169–199. https://linkinghub.elsevier.com/retrieve/pii/0341816294900019.

and Replication by: Kasprak, A., N. Hough-Snee, T. Beechie, N. Bouwes, G. Brierley, R. Camp, K. Fryirs, H. Imaki, M. Jensen, G. O’Brien, D. Rosgen, and J. Wheaton. 2016. The Blurred Line between Form and Process: A Comparison of Stream Channel Classification Frameworks ed. J. A. Jones. *PLOS ONE* 11 (3):e0150293. https://dx.plos.org/10.1371/journal.pone.0150293.

Replication Authors:
Sanjana Roy, Zach Hilgendorf, Joseph Holler, and Peter Kedron.

Replication Materials Available at: [RE-Rosgen](https://github.com/sanjana-roy/RE-rosgen)

Created: `24 March 2021`
Revised: `25 March 2021`

## Introduction

This study attempts to use the Rosgen Stream Classification System (RCS), which is a method classifying streams and rivers based on their form and morphology at a particular moment in time, through replicating findings from the Kasprak et al. (2016) study of the Middle Fork John Day Basin (MFJD), a watershed of high conservation interest within the Columbia River Basin. The Rosgen classification attempts to “provide a consistent and reproducible frame of reference of communication for those working with river systems in a variety of professional disciplines” (Rosgen, 1994). It uses four hierarchical stages of classification under two ‘Levels’. Level 1 utilizes morphological ratios of rivers, such as entrenchment, width/depth, and sinuosity, from variables observed and calculated through site measurements, like bankfull width, bankfull depth, valley width, valley length, channel length, etc. Level 2 utilizes characteristics, such as the slope of the valley and channel material, to further determine classification. There has been an increase in the use of GIS in aiding to classify streams according to their aforementioned characteristics, however, its application has not been standardized. As RCS is “arguably the most commonly used stream classification system in North America and the world,” its replication through GIS modelling would be particularly helpful through applications in river maintenance, flood control, channel and riparian protection and restoration, impact assessment, etc. (Kasprak et al., 2016).

Therefore, this study attempts to create and practice a method of replicability of the Rosgen Classification System using high resolution terrain models to classify sections of streams and rivers, or “reaches.” We attempt to replicate the RCS analysis of Kasprak et al.’s (2016) study, which compared four different classification methods at the MFJD watershed scale.

![Image of Rosgen Classification](Rosgen/assets/Rosgenclass.png)
Figure 1. Level I and II of the Rosgen Classification System

## Data

### CHaMP Data
Kasprak et al. (2016) uses the Columbia Habitat Monitoring Program (CHaMP) data, collected as a result of aquatic-habitat monitoring in the watershed of the Columbia River Basin. This data contains information on reaches, of which details were collected during 2012 and 2013, at wadable, perennial streams selected through random sampling. Each reach includes information on channel bankfull width and depth, gradient, substrate, and sinuosity. Each sampled reach is twenty times as long as the bankfull channel width at each site (120-360 m in length).

We also utilised LiDAR data of the MFJD Watershed collected in 2008, as part of the Camp Creek LIDAR Project.

## Methods

### Kasprak et al. (2016) Analysis
Kasprak et al. (2016) classified 33 CHaMP reaches in the MFJD Basin using Levels I and II of the RCS.
The study used DEMs of grid resolutions 10m and 0.1m, aerial imagery, and ground-based assessments to understand stream morphological characteristics in order to fulfil the Level I classification. Processing was done using the [River Bathymetry Toolkit (RBT)](https://essa.com/explore-essa/tools/river-bathymetry-toolkit-rbt/) and the [CHaMP Topo Toolbar](http://champtools.northarrowresearch.com/), both used with ESRI ArcGIS software. In order to further classify streams at Level II, Kasprak et al. (2016) then used river bed material size identified by the CHaMP survey from the stream reaches.


### Class Analysis
As a class, we were randomly assigned 17 CHaMP points to classify through replication of the Kasprak et al.(2016) methods. I was assigned the Granite Boulder Creek stream (loc_id = 10) to analyse.

![Image of watershed and points](Rosgen/assets/aoi.jpg)

We used GRASS GIS (7.8.5 for MacOS) for the processing of the two layers of data, the CHaMP points and the MFJD Watershed tif file. [A model](https://github.com/sanjana-roy/RE-rosgen/blob/main/procedure/code/visualize.gxm) was used to create buffer zones around the CHaMP survey points, as Rosgen (1994) suggests analyzing a distance of 20 channel widths, applied in the distance settings. The model also uses the LiDAR MFJD image to create a Digital Elevation Model (DEM) with colors and hillshade.

![Image of Model1](Rosgen/Images/visualize_model.png)
![Image of Map Study Site Elevation](Rosgen/assets/map_elevation.png)
![Image of Map Study Site Slope](Rosgen/assets/map_slope2.png)

The stream banks and valley edges were manually digitized with respect to the buffer at a scale of 1:1500. This digitization was done three times for both the banks and valley edges. [A second model](https://github.com/sanjana-roy/RE-rosgen/blob/main/procedure/code/center_line_length_no_clip.gxm) was then used to find the averages of each set of lines as well as the “average of the average,” providing us with a final banks line and valley line.

![Image of Model2](Rosgen/Images/center_line_length_model.png)
![Image of Map Study Site Banks](Rosgen/assets/map_banks.png)
![Image of Map Study Site Valley](Rosgen/assets/map_valley.png)


The longitudinal and cross-sectional profiles of the reach were then extracted using the averaged banks and valley lines. Each profile consisted of a set of points spaced 1 m apart. This data was then exported and visualized in graphs in RStudio (v 1.4.1103 for MacOS) using [this code](https://github.com/sanjana-roy/RE-rosgen/blob/main/procedure/code/2-ProfileViewer.Rmd). Analysis using the R code allows us to determine the Slope of the stream as well as the Valley width (Table 1).

![Image of Cross-Section](Rosgen/Images/figures/CrossSecProf.png)
![Image of Long Prof](Rosgen/assets/figures/LongProf.png)
![Image of LongProf Slope](Rosgen/assets/figures/SlopePer.png)
![Image of Cross-Sec Zoom](Rosgen/assets/figures/ZoomBfDepth.png)


# Differences in Method
1. The computational environments that were used in these two studies were different, possibly introducing many uncertainties in how the analysis was carried out. Kasprak et al. (2016) used RBT and the CHaMP Topo Toolbar with ESRI ArcGIS to process and analyze data, while this study used a combination of GRASS GIS and RStudio.
2. Although we are not aware of whether Kasprak et al. (2016) used LiDAR in their analysis, the DEM files were of a resolution of 0.1m, allowing a finer digitization of stream and valley edges. DEM resolution in this study was 1m.
3. Finally, Kasprak et al. (2016) were able to conduct field observations, which would have largely influenced the accuracy of their digitazation as well as general understanding of the landscape.


# Unplanned Deviations from the Protocol
1.
> Use of no_clip
> MacOS downloading XCode and something else
> Difference in calculating slope in R


## Results

Table 1. Site Measurements

| Variable | Value | Source |
| :-: | :-: | :-: |
| Bankfull Width | 6.1004 | CHaMP data BfWdth_Avg |
| Bankfull Depth Maximum | 1.4275 | CHaMP data DpthBf_Max |
| Bankfull Depth Mean | 0.3212 | CHaMP data DpthBf_Avg |
| Valley Width | 60(m) | Terrain Cross-Section |
| Valley Depth | 2.855 | Bankfull Depth * 2|
| Stream/River Length | 154.46(m) | Mean Stream Centerline from GRASS|
| Valley Length | 167.83(m) | Mean Valley Centerline from GRASS|
| Median Channel Material Particle Diameter | 152 | CHaMP data SubD50 |

Table 2. Rosgen Level I Classification

| Criteria | Value | Formula |
| :-: | :-: |
| Entrenchment Ratio | 9.835 | (Valley Width at Bankfull Depth * 2) / Bankfull Width |
| Width / Depth Ratio | 18.99 | Bankfull Width / Bankfull Depth Mean|
| Sinuosity | 0.920 | Stream Length / Valley Length |
| Level I Stream Type | Either E or C |

Table 3. Rosgen Level II Classification

| Criteria | Value |
| :-: | :-: |
| Slope | 0.086 |
| Channel Material | Gravel |
| Level II Stream Type | Unclear |

## Discussion

## Conclusion

## References
