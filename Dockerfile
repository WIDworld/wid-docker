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
        r-base-core \
        r-base-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Additional R packages
RUN R -e "install.packages('haven', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('readr', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('magrittr', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('dplyr', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('glue', repos = 'http://cran.us.r-project.org')"
RUN R -e "install.packages('janitor', repos = 'http://cran.us.r-project.org')"

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