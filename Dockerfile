FROM trestletech/plumber

LABEL Irene Liampa <irini.liampa@.gmail.com>
LABEL Pantelis Karatzas <pantelispanka@gmail.com>

RUN apt-get update --fix-missing && apt-get -y upgrade
RUN apt-get -y install libxml2-dev libcairo2-dev libxt-dev libx11-dev xvfb xauth xfonts-base

RUN R -e "install.packages(c('RCurl' ,'png' ,'jsonlite' ,'assertive', 'gWidgets', 'hwriter', 'Cairo'), repos='http://cran.cc.uoc.gr/mirrors/CRAN/')"

RUN mkdir -p /app/
RUN chown root:staff /app/

COPY proast61.5_0.0_R_x86_64-pc-linux-gnu.tar.gz /app/
COPY proasttest2.R /app/
COPY change_variables.txt /app/
COPY trial1.RData /app/

RUN R CMD INSTALL ./app/proast61.5_0.0_R_x86_64-pc-linux-gnu.tar.gz --library=/usr/local/lib/R/site-library

RUN echo 'Xvfb :1 -screen 0 1960x2000x24 &' >> /root/.bashrc
ENV DISPLAY=:1.0

WORKDIR /app/

CMD ["/app/proast.R"]
