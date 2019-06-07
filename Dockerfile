FROM hotio/base

ARG DEBIAN_FRONTEND="noninteractive"
ARG ARCH_RESTIC="amd64"

ENV APP="Restic"
HEALTHCHECK --interval=60s CMD pidof cron && pidof tail || exit 1

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        cron && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# install app
# https://github.com/restic/restic/releases
RUN curl -fsSL "https://github.com/restic/restic/releases/download/v0.9.5/restic_0.9.5_linux_${ARCH_RESTIC}.bz2" | bunzip2 | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

COPY root/ /
