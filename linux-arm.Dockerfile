FROM hotio/base@sha256:9c7833cc31199260454fff82e03c29eea7211ae2bb128b3ba4b620c0d5c2b018

ARG DEBIAN_FRONTEND="noninteractive"

ARG APPRISE_VERSION

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        cron \
        python3-pip python3-setuptools && \
    pip3 install --no-cache-dir --upgrade apprise==${APPRISE_VERSION} && \
# clean up
    apt purge -y python3-pip python3-setuptools && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

ARG RESTIC_VERSION
ARG RCLONE_VERSION

# install restic
RUN bz2file="/tmp/restic.bz2" && curl -fsSL -o "${bz2file}" "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_arm.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic && rm "${bz2file}" && \
# install rclone
    debfile="/tmp/rclone.deb" && curl -fsSL -o "${debfile}" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm.deb" && dpkg --install "${debfile}" && rm "${debfile}"

COPY root/ /
