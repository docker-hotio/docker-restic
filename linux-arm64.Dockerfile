FROM hotio/base@sha256:f1629f6864be54d0d4ed469bbc5fc20f8f7a92121fbc536368c9279e262065d1

ARG DEBIAN_FRONTEND="noninteractive"

ARG APPRISE_VERSION=0.8.5

# install packages
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        cron \
        msmtp msmtp-mta \
        python3-pip python3-setuptools && \
    pip3 install --no-cache-dir --upgrade apprise==${APPRISE_VERSION} && \
# aim msmtp configuration files to outer config directory
    ln -s /config/app/msmtprc /etc/msmtprc \
    ln -s /config/app/aliases /etc/aliases \
# clean up
    apt purge -y python3-pip python3-setuptools && \
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# https://github.com/restic/restic/releases
# https://github.com/ncw/rclone/releases
ARG RESTIC_VERSION=0.9.6
ARG RCLONE_VERSION=1.51.0

# install restic
RUN bz2file="/tmp/restic.bz2" && curl -fsSL -o "${bz2file}" "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_arm64.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic && rm "${bz2file}" && \
# install rclone
    debfile="/tmp/rclone.deb" && curl -fsSL -o "${debfile}" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm64.deb" && dpkg --install "${debfile}" && rm "${debfile}"

COPY root/ /
