# DS5110Project

##  Title: 
Property Assessment Visualization for the city of Boston

## Authors:
Tyler Brown , Sicheng Hao, Nischal Mahaveer Chand, Sumedh Sankhe

## Summary:
When we put ourselves in the shoes of potential homebuyers in the
Greater Boston area, we find that they have many informational resources
available. As a homebuyer, their major sources of information are the
websites Zillow \cite{ZillowRe12:online} and Trulia
\cite{TruliaRe98:online}. These resources provide information such as
home location, price, amenties, and types. Trulia differentiates itself
by providing a ``Local Scoop'', giving the homebuyer maps of crime, school
location, and the relative distribution of home prices in Greater
Boston. However, neither of these websites provide information about how
neighborhoods are changing over time.

Homebuyers want to better understand their potentially new communities.
It's helpful to know if your neighbors have been regularly developing
and maintaining their properties. A homebuyer would also like to know
whether a neighborhood as been experiencing various levels of turnover.
The problem our group is focusing on is how we can help these new
homebuyers by presenting them with an inuitive way to understand how
their potential neighborhoods have been changing over time.

The City of Boston provides an open data platform, Analyze Boston, 
containing information related to our lives in the city. Property 
assessment data from 2014-2017 is one of the resources available on their
 open data platform. Included in the property assessment data is 
``property, or parcel, ownership together with information about value, 
which ensures fair assessment of Boston taxable and non-taxable property 
of all types and classifications'' \cite{Property49:online}. Our team 
has aggregated each available year to create a time series dataset of 
Property Assessments in Boston. This aggregated dataset allows us to 
provide unique insights into property valuations and ownership strategies.


## Proposed plan of research:
The datasets we are having right now are separate yearly. The first step 
we are going to do is merge them into one single file. Then we are going 
to do some necessary cleaning for the data set. 

In the second step, we are going to filter out the data that could 
represent the problem we are trying to solve. Maybe add some data from 
other sources( like Google Maps or Zillow)

To help people understand the data better. In the last step we will make 
an interactive Shiny application to visualize our finding. 


##  Preliminary results:
*See "proposal.pdf" for preliminary results.*

##  References:
https://data.boston.gov/dataset/property-assessmen