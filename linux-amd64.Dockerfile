FROM hotio/base

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
ARG RESTIC_VERSION=0.9.5
ARG RCLONE_VERSION=1.50.1

# install restic
RUN curl -fsSL "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_amd64.bz2" | bunzip2 | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic && \
# install rclone
    curl -fsSL -o "/tmp/rclone.deb" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.deb" && dpkg --install "/tmp/rclone.deb"

COPY root/ /
