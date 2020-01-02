FROM hotio/base@sha256:cc6a5540d7a891e295c3af6e85d268d9f3b6660d3ba9614ee0fc7cab2c080947

ARG DEBIAN_FRONTEND="noninteractive"

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        cron && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# https://github.com/restic/restic/releases
# https://github.com/ncw/rclone/releases
ARG RESTIC_VERSION=0.9.6
ARG RCLONE_VERSION=1.50.2

# install restic
RUN curl -fsSL "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2" | bunzip2 | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic && \
# install rclone
    debfile="/tmp/rclone.deb" && curl -fsSL -o "${debfile}" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.deb" && dpkg --install "${debfile}" && rm "${debfile}"

COPY root/ /
