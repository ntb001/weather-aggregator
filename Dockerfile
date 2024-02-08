FROM httpd:2.4 AS cgiperl

RUN apt-get update && apt-get install -y \
    perl \
    libapache2-mod-perl2 \
    libcgi-pm-perl \
    && rm -rf /var/lib/apt/lists/*

# turn on printenv
RUN echo -n "#!/usr/bin/env perl\n" | cat - /usr/local/apache2/cgi-bin/printenv > printenv.tmp \
    && mv printenv.tmp /usr/local/apache2/cgi-bin/printenv
RUN chmod +x /usr/local/apache2/cgi-bin/printenv

# enable CGI
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
