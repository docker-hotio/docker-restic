FROM ubuntu:18.04 as builder

ARG DEBIAN_FRONTEND="noninteractive"

# install
RUN apt update && \
    apt install -y --no-install-recommends --no-install-suggests \
        ca-certificates curl unzip && \
# clean up
    apt autoremove -y && \
    apt clean && \
    rm -rf /tmp/* /var/lib/apt/lists/* /var/tmp/*

# install restic
ARG RESTIC_VERSION
RUN bz2file="/tmp/restic.bz2" && curl -fsSL -o "${bz2file}" "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_arm64.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

# install rclone
ARG RCLONE_VERSION
RUN zipfile="/tmp/rclone.zip" && curl -fsSL -o "${zipfile}" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm64.zip" && unzip -q "${zipfile}" -d "/tmp" && cp /tmp/rclone-*-linux-arm64/rclone /usr/local/bin/rclone && chmod 755 /usr/local/bin/rclone


FROM ubuntu@sha256:03e4a3b262fd97281d7290c366cae028e194ae90931bc907991444d026d6392a
LABEL maintainer="hotio"
ENTRYPOINT ["restic"]
COPY --from=builder /usr/local/bin/restic /usr/local/bin/restic
COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone
