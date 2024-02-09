FROM httpd:2.4 AS cgiperl

RUN apt-get update && apt-get install -y \
    perl \
    libapache2-mod-perl2 \
    libcgi-pm-perl \
    && rm -rf /var/lib/apt/lists/*

# pass ENV vars
RUN sed -i 's|<Directory "/usr/local/apache2/cgi-bin">|&\n    PassEnv REDIS_SERVER|' \
    /usr/local/apache2/conf/httpd.conf

# turn on printenv
RUN sed -i "1c\\#!/usr/bin/env perl" /usr/local/apache2/cgi-bin/printenv \
    && chmod 755 /usr/local/apache2/cgi-bin/printenv

# run with CGI
CMD httpd-foreground -c "LoadModule cgid_module modules/mod_cgid.so"


FROM cgiperl AS weather-api

RUN apt-get update \
    && apt-get install -y \
    libconfig-tiny-perl \
    libdatetime-perl \
    libfuture-asyncawait-perl \
    libjson-perl \
    libredis-perl \
    && rm -rf /var/lib/apt/lists/*
