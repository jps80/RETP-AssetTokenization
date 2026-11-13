FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
    && apt-get install -y --no-install-recommends softhsm2 ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY softhsm2.conf /etc/softhsm2.conf
ENV SOFTHSM2_CONF=/etc/softhsm2.conf

CMD ["bash", "-lc", "sleep infinity"]
