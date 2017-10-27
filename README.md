# DS5110Project

##  Title: 
Property Assessment Visualization for the City of Boston

## Authors:
Tyler Brown , Sicheng Hao, Nischal Mahaveer Chand, Sumedh Sankhe

## Summary:
When we put ourselves in the shoes of potential Greater Boston area
homebuyers, we find they have many informational resources available
to them. As a homebuyer, their major sources of information are the
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
whether a neighborhood has been experiencing various levels of turnover.
Our group is focusing on the problem new Greater Boston area home buyers
face when they want an intuitive way to understand changes within their
potential neighborhoods over time.

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
The dataset we have right now is separated according to year in different
files. We will start by merging the data into a single file and completing
the necessary cleaning and data wrangling steps. We will then build a 
web application which provides the user with a helpful dashboard. This
dashboard will include a selection bar for their home preferences, and
a way to select which changes in the neighboorhood they want to
explore such as assessment changes or remodel status. We plan to improve
exploration of neighborhood changes by applying a clustering model to see
if patterns exists. The dashboard will also include an interactive map to
help users visualize those changes. 


##  Preliminary results:
*See "proposal.pdf" for preliminary results.*

##  References:
https://data.boston.gov/dataset/property-assessment
