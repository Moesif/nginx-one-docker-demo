FROM private-registry.nginx.com/nginx-plus/agent:alpine

COPY nginx-repo.key /etc/apk/cert.key
COPY nginx-repo.crt /etc/apk/cert.pem
COPY license.jwt /etc/nginx/

RUN wget -O /etc/apk/keys/nginx_signing.rsa.pub https://cs.nginx.com/static/keys/nginx_signing.rsa.pub
RUN printf "https://pkgs.nginx.com/plus/alpine/v`egrep -o '^[0-9]+\.[0-9]+' /etc/alpine-release`/main\n" \
| tee -a /etc/apk/repositories

RUN apk update && apk add git unzip wget zlib-dev lua-dev build-base perl-dev

RUN apk add --no-cache nginx-plus-module-ndk
RUN apk add --no-cache nginx-plus-module-lua

RUN wget https://luarocks.org/releases/luarocks-3.11.1.tar.gz \
    && tar -xzvf luarocks-3.11.1.tar.gz \
    && cd luarocks-3.11.1 \
    && ./configure \
    && make build \
    && make install

RUN luarocks path --bin

# Install Lua modules (including resty.core)
RUN luarocks install --server=http://luarocks.org/manifests/moesif lua-resty-moesif && \
    luarocks install lua-resty-core && \
    luarocks install lua-resty-jwt

# Delete default config
RUN rm -r /etc/nginx/conf.d && rm /etc/nginx/nginx.conf

# Create folder for PID file
RUN mkdir -p /run/nginx

# Add our nginx conf
COPY ./nginx.conf /etc/nginx/nginx.conf

# Add our moesif conf
COPY ./nginx.conf.d/ /etc/nginx/conf.d/

# CMD ["nginx"]
