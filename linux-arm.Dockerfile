FROM ubuntu@sha256:214d66c966334f0223b036c1e56d9794bc18b71dd20d90abb28d838a5e7fe7f1

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
RUN bz2file="/tmp/restic.bz2" && curl -fsSL -o "${bz2file}" "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_arm.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

# install rclone
ARG RCLONE_VERSION
RUN zipfile="/tmp/rclone.zip" && curl -fsSL -o "${zipfile}" "https://github.com/ncw/rclone/releases/download/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm.zip" && unzip -q "${zipfile}" -d "/tmp" && cp /tmp/rclone-*-linux-arm/rclone /usr/local/bin/rclone && chmod 755 /usr/local/bin/rclone


FROM ubuntu@sha256:214d66c966334f0223b036c1e56d9794bc18b71dd20d90abb28d838a5e7fe7f1
LABEL maintainer="hotio"
ENTRYPOINT ["restic"]
COPY --from=builder /usr/local/bin/restic /usr/local/bin/restic
COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone
