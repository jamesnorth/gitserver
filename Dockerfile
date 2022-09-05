###############################################################################
# Dockerfile for a cgit server, a self-hosted git server
###############################################################################

FROM debian:bullseye AS builder

# these settings specify where we fetch the source
# code from.
ARG CGIT_SRC=https://git.zx2c4.com/cgit/

RUN  mkdir -pv /var/src/cgit
WORKDIR /var/src/cgit

# first we install dependencies for building cgit
RUN set -x -e;                                                                  \
    apt-get update;                                                             \
    apt-get install -y --no-install-recommends                                  \
        ca-certificates                                                         \
        git                                                                     \
        gcc                                                                     \
        make                                                                    \
    ;                                                                           \
    apt-get install -y --no-install-recommends                                  \
        libzip-dev openssl libssl-dev liblua5.2-dev                             \
    ;                                                                           \
    rm -r /var/lib/apt/lists/*;                                                 \
    git clone $CGIT_SRC .;                                                      \
    git submodule init;                                                         \
    git submodule update;                                                       \
    make -j$(nproc);                                                            \
    make install;                                                               \
    rm -rf /var/src/cgit/*;                                                     \
    apt-get purge -y --auto-remove                                              \
        ca-certificates gcc make git libzip-dev openssl                         \
        libssl-dev liblua5.2-dev                                                \
    ;

FROM httpd:2.4-bullseye

LABEL maintainer="jamesnorth2104@gmail.com"
LABEL org.opencontainers.image.title="cgit"
LABEL org.opencontainers.image.description="cgit server"
LABEL org.opencontainers.image.url="https://jnorth.net/"
LABEL org.opencontainers.image.source="https://github.com/jamesnorth/cgit"
LABEL org.opencontainers.image.vendor="James North"
LABEL org.opencontainers.image.authors="James North"

COPY --from=builder /var/www/htdocs/cgit /usr/local/apache2/htdocs/
COPY --from=builder /usr/local/lib/cgit /usr/local/lib/cgit
COPY --from=builder /var/www/htdocs/cgit/cgit.cgi /usr/local/lib/cgit/cgit.cgi

RUN set -x -e; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        python3 \
        python3-pygments \
        python3-markdown \
        xz-utils \
        zstd \
    ; \
    rm -rf /var/lib/apt/lists/*; \
    chown -R www-data:www-data /usr/local/apache2/htdocs; \
    rm /usr/local/apache2/htdocs/index.html

VOLUME /repos

COPY ./my-httpd.conf /usr/local/apache2/conf/httpd.conf

COPY ./cgitrc /etc/cgitrc
