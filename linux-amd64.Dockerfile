FROM alpine:3.11 as builder

# install
RUN apk add --no-cache unzip

# install restic
ARG VERSION
RUN bz2file="/tmp/restic.bz2" && wget -O "${bz2file}" "https://github.com/restic/restic/releases/download/v${VERSION}/restic_${VERSION}_linux_amd64.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

# install rclone
ARG RCLONE_VERSION
RUN zipfile="/tmp/rclone.zip" && wget -O "${zipfile}" "https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-amd64.zip" && unzip -q "${zipfile}" -d "/tmp" && cp /tmp/rclone-*-linux-amd64/rclone /usr/local/bin/rclone && chmod 755 /usr/local/bin/rclone


FROM alpine@sha256:25f5332d060da2c7ea2c8a85d2eac623bd0b5f97d508b165f846c7d172897438
LABEL maintainer="hotio"
ENTRYPOINT ["restic"]

COPY --from=builder /usr/local/bin/restic /usr/local/bin/restic
COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone
