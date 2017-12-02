# A very useful website
https://rstudio.github.io/shinydashboard/structure.html#background-shiny-and-html

# Using Docker

You don't have to use Docker. But if the app is giving you installation
problems, this is a good approach.

# Building and running a Docker Container

1. Install docker
2. Build the docker container: `$ docker build -t boston .`
3. Run the docker container: `$ docker run --rm -p 3838:80 boston`
4. You should see the app at `localhost:3838`
5. Get your the process number of the docker container:
   `docker ps`
6. Open a different terminal & connect to the Docker container:
   `docker exec -it <mycontainer_process_id> bash`

# Editing code with Shiny Server and Docker

1. Connect to Docker container
2. The code is located in `/srv/shiny-server/`
3. Edit code with `vim`, `emacs`, or `nano`.
4. Save the `app.R` file and referesh, changes should flow through
5. Clone this repo somewhere in the docker container and copy your
   changes to the appropriate place in this repo before committing.
6. Make sure to reference the issue number in your commit (`see #7`).


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



## Outline:

# Part one:selection bar(sidebar of properity information selection)

# Part two:tabs(models)
(After select properity type)
Model_1: Remodeled properities and prediction

Visualize TR_BUILD and YR_REMOD within each zipcode

Predict how much properties are likely to be remodeled (by each zip code region)

and then visualize density

Model_2: Interior detail

Bath style, kitchen style, heat, AC, interior finish, interior condition, view

Visualize each part of each zipcode

Model_3:Assessment value change(need wide format)

The year 2014-2017, find the key to merge our data into a wide format DataFrameCallback

find assessment value change(not necessarily everything)

visualize the change and prediction of the future years(two or three years)



# Part three: map






