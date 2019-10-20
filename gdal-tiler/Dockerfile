
FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        python-gdal \
        imagemagick \
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*

ADD tile_map.sh /tile_map.sh

