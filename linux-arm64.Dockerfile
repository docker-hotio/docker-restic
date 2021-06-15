FROM alpine:3.11 as builder

# install
RUN apk add --no-cache unzip

# install restic
ARG VERSION
RUN bz2file="/tmp/restic.bz2" && wget -O "${bz2file}" "https://github.com/restic/restic/releases/download/v${VERSION}/restic_${VERSION}_linux_arm64.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

# install rclone
ARG RCLONE_VERSION
RUN zipfile="/tmp/rclone.zip" && wget -O "${zipfile}" "https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm64.zip" && unzip -q "${zipfile}" -d "/tmp" && cp /tmp/rclone-*-linux-arm64/rclone /usr/local/bin/rclone && chmod 755 /usr/local/bin/rclone


FROM alpine@sha256:55fc95a51d97f7b76b124f3b581a58ebf5555d12574f16087de3971a12724dd4
LABEL maintainer="hotio"
ENTRYPOINT ["restic"]

COPY --from=builder /usr/local/bin/restic /usr/local/bin/restic
COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone
