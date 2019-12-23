FROM hotio/base@sha256:1608b55cadb6d665d04a4568ab8855b2e8d75a572ef4d659ecd049a9302c2228

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
RUN curl -fsSL "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_arm.bz2" | bunzip2 | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic && \
# install rclone
    debfile="/tmp/rclone.deb" && curl -fsSL -o "${debfile}" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm.deb" && dpkg --install "${debfile}" && rm "${debfile}"

COPY root/ /
