---
layout: page
title: Replication of Spatial Accessibility of COVID-19 Health Resources
---

**Replication of Spatial Accessibility of COVID-19 Healthcare Resources**

Original study *by* Kang, J. Y., A. Michels, F. Lyu, Shaohua Wang, N. Agbodo, V. L. Freeman, and Shaowen Wang. 2020. Rapidly measuring spatial accessibility of COVID-19 healthcare resources: a case study of Illinois, USA. *International Journal of Health Geographics* 19 (1):1–17. DOI: [10.1186/s12942-020-00229-x](https://ij-healthgeographics.biomedcentral.com/articles/10.1186/s12942-020-00229-x)

Replication Author: Sanjana Roy and the OpenSource GIScience students of Spring 2021

Replication Materials Available at: [github repository name](github repository link)

Created: `19 May 2021`
Revised: `25 May 2021`


## Introduction
Explaining the interest and purpose in reproducing the Kang et al (2020) study, and very briefly introducing what the study was about.

The onset of the COVID-19 pandemic fueled a global need for accessible healthcare resources. The constant and exponential increase in patients has put immense pressure on hospitals and healthcare providers to cater to as many people as possible. However, these resources are often unavailable to many, both in terms of their spatial locations and financial constraints, creating vast inequalities in how people are treated for the virus as well as other illnesses. Kang et al. (2020) attempts to understand the spatial accessibility of COVID-19 healthcare resources in Illinois, USA. This study was conducted using CyberGISX in order to compute this analysis and produce outcomes that could be available for decision-making. The code behind this analysis was made available through Jupyter Notebooks, allowing for easy replication and reproduction of the study by other researchers, such as ourselves. This contribution by Kang et al. (2020) takes a large step in making research available in the OpenSource world, where analyses concerning such important and relevant topics can be critiqued and enhanced through testing and editing by other researchers, making for a more robust methodology that can be applied to other contexts.


## Materials and Methods
Briefly explaining and citing what data sources and computational resources were used for the study. The length/depth of this explanation may be similar to your review of the Twitter for Wildfire Hazards paper (Wang et al 2016). Explain any changes you made to the original python notebook / repository.

Kang et al. (2020) utilized four different data sources for this analysis:
1. **Hospital dataset** including number of beds in ICUs and number of ventilator units per hospital - provided by the [Illinois Department of Public Health (IDPH)](https://hifld-geoplatform.opendata.arcgis.com/datasets/hospitals/explore)
2. **COVID-19 confirmed cases dataset** at the zip code level - provided by IDPH
3. **Residential dataset** by census tract in Illinois - accessed using API to pull from the [US Census Bureau American Community Survey (2018 - 5-year detail)](https://data.census.gov/cedsci/deeplinks?url=https%3A%2F%2Ffactfinder.census.gov%2F&tid=GOVSTIMESERIES.CG00ORG01)
4. **Road network dataset** - retrieved using [OSMnx](https://github.com/gboeing/osmnx) python package from OpenStreetMap


Hospitals that were military, children, psychiatric, or rehabilitation facilities were excluded and hospitals within a 15 miles of the Chicago boundary were included. The CDCs Social Vulnerability Index (SVI) was used to acquire the number of people aged 50 and older to examine vulnerability characteristics in relation to low and high accessibility of hospital resources. Kang et al. (2020) used the roads network and hospitals to identify nodes in the network that were closest to hospitals, attaching hospitals along with their data to the nearest network node. Nodes with zero outdegree or under 10 nodes were removed to prevent the formation of smaller egocentric networks. The max driving speed for the roads was set at 35 miles per hour. Population centroids and hosptial catchment areas are then created. The conventional two-step floating catchement area method (2SFCA) was used and further developed into a Parallel enhanced 2SFCA (P-E2SFCA) in order to calculate the service-to-population (ICU beds/ventilators to population) ratio of a hospital zone while accounting for distance decay by allowing for multiple travel time zones, creating a convex hull with subdivisions around each node: 0-10, 10-20, 20-30 mins. These travel time zones were weighted (1, 0.68, and 0.22 respectively) and overlapping zones in residential locations were summed together. These accessibility measurements are then aggregated into hexagon grids (to reduce edge effects).

### Changes made to Original Code

A major inaccuracy in the code stemmed from the boundary effects of this analysis. Nodes that were created near the edges of Chicago had hospitals outside of Chicago (but within 15 miles) attach to these nodes, overestimating the number of beds or ventilators that would be accessible to people in that area. Since the road network only extended to the boundaries of Chicago, travel-time distance was not accounted for. Therefore, the first change that was made in the code was to extend the road network around 30 km (larger than 15 miles), using a buffer, outside of Chicago so that hospitals would not be unevenly spatially distributed. Here are the changes out class collaboratively made to the code:

``` python
if not os.path.exists("data/Chicago_Network_Buffer.graphml"):
    #ambiguous place names but would need to look into OSM connection with API
    G = ox.graph_from_place('Chicago', network_type='drive', buffer_dist = 30000) # pulling the drive network the first time will take a while
    ox.save_graphml(G, 'Chicago_Network_Buffer.graphml')
else:
    G = ox.load_graphml('Chicago_Network_Buffer.graphml', node_type=str)
ox.plot_graph(G)
```

Other adjustments to the code involved changing the colour ramp of the final output raster map. The original map was created with a orange to red (OrRd) colour gradient with red being areas indicated greater accessibility to hospitals. This visual relationship is confusing as red is often associated with 'danger' or a warning. Therefore, the colour ramp was changed to the 'RdPu' or red to purple colour map from the Colour Brewer palettes. This created a better visual correlation between the colours and the accessibility spectrum.


## Results and Discussion:
Include images of findings (maps, graphs) and link to your final repository for the reproduction. Discuss what you learned from the reproduction attempt, especially any knowledge, insight, or uncertainty that was encoded in the repository or discovered in the reproduction but not explained in the published paper.

### Original Map from the Kang et al. (2020) code
![Original Map](assets/original_map.png)

### Replicated Map
![Replicated Map](assets/replicated_map.png)





*Conclusions:* With emphasis on the significance of the reproduction study you just completed. Was the study reproducible, and has the reproduction study increased, decreased, or otherwise refined your belief in the validity of the original study? Conclude with any insights, priorities, or questions for future research.

*Note on Style:* Remember that the primary motivation for reproduction and replication studies is not punitive. Frame your discussions in this report and previous reports in the constructive motivation for improving scientific knowledge through peer review. Project like CyberGISX generally, and the Kang et al 2020 publication specifically, are very new in geography, and our engagement with them should be both encouraging and constructive while emphasizing the value of open science.

## References

Include any referenced studies or materials in the [AAG Style of author-date referencing](https://www.tandf.co.uk//journals/authors/style/reference/tf_USChicagoB.pdf).

####  Report Template References & License

This template was developed by Peter Kedron and Joseph Holler with funding support from HEGS-2049837. This template is an adaptation of the ReScience Article Template Developed by N.P Rougier, released under a GPL version 3 license and available here: https://github.com/ReScience/template. Copyright © Nicolas Rougier and coauthors. It also draws inspiration from the pre-registration protocol of the Open Science Framework and the replication studies of Camerer et al. (2016, 2018). See https://osf.io/pfdyw/ and https://osf.io/bzm54/

Camerer, C. F., A. Dreber, E. Forsell, T.-H. Ho, J. Huber, M. Johannesson, M. Kirchler, J. Almenberg, A. Altmejd, T. Chan, E. Heikensten, F. Holzmeister, T. Imai, S. Isaksson, G. Nave, T. Pfeiffer, M. Razen, and H. Wu. 2016. Evaluating replicability of laboratory experiments in economics. Science 351 (6280):1433–1436. https://www.sciencemag.org/lookup/doi/10.1126/science.aaf0918.

Camerer, C. F., A. Dreber, F. Holzmeister, T.-H. Ho, J. Huber, M. Johannesson, M. Kirchler, G. Nave, B. A. Nosek, T. Pfeiffer, A. Altmejd, N. Buttrick, T. Chan, Y. Chen, E. Forsell, A. Gampa, E. Heikensten, L. Hummer, T. Imai, S. Isaksson, D. Manfredi, J. Rose, E.-J. Wagenmakers, and H. Wu. 2018. Evaluating the replicability of social science experiments in Nature and Science between 2010 and 2015. Nature Human Behaviour 2 (9):637–644. http://www.nature.com/articles/s41562-018-0399-z.
