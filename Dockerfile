# Local Stata version
ARG SRCVERSION=16

# Matching Stata version tag from https://hub.docker.com/u/dataeditors
ARG SRCTAG=2022-10-14

FROM dataeditors/stata${SRCVERSION}:${SRCTAG}

# Lazy but easy for now
USER root

# Timezone
ENV TZ=Europe/Paris
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime \
    && echo $TZ > /etc/timezone

# Install R
RUN apt-get update \ 
    && apt-get install -y --no-install-recommends \
        software-properties-common \
        gnupg \
    && apt-key adv \
        --keyserver keyserver.ubuntu.com \
        --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu focal-cran40/' 

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        littler \
        #r-base \
        r-base-core \
        r-base-dev \
    && echo 'options(repos = c(CRAN = "https://cran.rstudio.com/"), download.file.method = "libcurl")' >> /etc/R/Rprofile.site \
    && ln -s /usr/lib/R/site-library/littler/examples/install.r /usr/local/bin/install.r \
    && ln -s /usr/lib/R/site-library/littler/examples/install2.r /usr/local/bin/install2.r \
    && ln -s /usr/lib/R/site-library/littler/examples/installGithub.r /usr/local/bin/installGithub.r \
    && ln -s /usr/lib/R/site-library/littler/examples/testInstalled.r /usr/local/bin/testInstalled.r \
    && install.r docopt \
    && rm -rf /tmp/downloaded_packages/ /tmp/*.rds \
    && rm -rf /var/lib/apt/lists/*

# Additional R packages
RUN install2.r --error --deps TRUE haven
RUN install2.r --error --deps TRUE readr
RUN install2.r --error --deps TRUE magrittr
RUN install2.r --error --deps TRUE dplyr
RUN install2.r --error --deps TRUE glue

# Copy Stata license 
RUN --mount=type=secret,id=statalic \
    cp /run/secrets/statalic /usr/local/stata/stata.lic \
    && chmod a+r /usr/local/stata/stata.lic

# Set up `wid-world` and install Stata requirements
COPY ./wid-world /wid-world
RUN stata -q do /wid-world/stata-do/install | tee /var/log/install.log

# Working directory
WORKDIR /wid-world
ENTRYPOINT []