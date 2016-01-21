FROM debian:jessie

MAINTAINER NGINX Docker Maintainers "docker-maint@nginx.com"

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62
RUN echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list

ENV NGINX_VERSION 1.9.9-1~jessie

RUN apt-get update && \
  apt-get install -y ca-certificates nginx=${NGINX_VERSION} && \
  apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip && \
  rm -rf /var/lib/apt/lists/*

# NGINX
ENV NPS_VERSION=1.10.33.2
RUN \
  wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip -O release-${NPS_VERSION}-beta.zip
unzip release-${NPS_VERSION}-beta.zip \
  && cd ngx_pagespeed-release-${NPS_VERSION}-beta/ \
  && wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz \
  && tar -xzvf ${NPS_VERSION}.tar.gz  # extracts to psol/

ENV NGINX_VERSION=1.8.0
RUN \
  wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
  && tar -xvzf nginx-${NGINX_VERSION}.tar.gz \
  && cd nginx-${NGINX_VERSION}/ \
  && ./configure --add-module=$HOME/ngx_pagespeed-release-${NPS_VERSION}-beta ${PS_NGX_EXTRA_FLAGS} \
  && make \
  && make install

  
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log
RUN ln -sf /dev/stderr /var/log/nginx/error.log

VOLUME ["/var/cache/nginx"]

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
