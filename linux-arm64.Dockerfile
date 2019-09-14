ARG BRANCH
FROM hotio/base:${BRANCH}

ARG DEBIAN_FRONTEND="noninteractive"

HEALTHCHECK --interval=60s CMD pidof cron || exit 1

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        cron && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

COPY root/ /

# install app
RUN version=$(sed -n '1p' /versions/restic) && \
    curl -fsSL "https://github.com/restic/restic/releases/download/v${version}/restic_${version}_linux_arm64.bz2" | bunzip2 | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic
