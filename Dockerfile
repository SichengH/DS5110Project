FROM r-base:latest

MAINTAINER Tyler Brown "tylers.pile@gmail.com"

RUN apt-get update && apt-get install -y \
    sudo \
    gdebi-core \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libxt-dev \
    libssl-dev \
    libgeos-dev \
    libv8-dev \
    gdal-bin \
    libgdal-dev \
    libprotobuf-dev \
    protobuf-compiler \
    libjq-dev \
    git \
    vim \
    neovim \
    nano

# Download and install shiny server
RUN wget --no-verbose https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/VERSION -O "version.txt" && \
    VERSION=$(cat version.txt)  && \
    wget --no-verbose "https://s3.amazonaws.com/rstudio-shiny-server-os-build/ubuntu-12.04/x86_64/shiny-server-$VERSION-amd64.deb" -O ss-latest.deb && \
    gdebi -n ss-latest.deb && \
    rm -f version.txt ss-latest.deb

RUN R -e "install.packages(c('shiny', 'rmarkdown', 'shinydashboard','dplyr', 'geojsonio', 'leaflet','purrr','readr','highcharter','DT','htmltools','nycflights13'), repos='http://cran.rstudio.com/')"

COPY shiny-server.conf  /etc/shiny-server/shiny-server.conf
COPY /app /srv/shiny-server/
CMD mkdir /srv/shiny-server/data/
COPY /data /srv/shiny-server/data/

EXPOSE 80

COPY shiny-server.sh /usr/bin/shiny-server.sh

CMD ["/usr/bin/shiny-server.sh"]
