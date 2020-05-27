FROM alpine:3.11 as builder

# install
RUN apk add --no-cache ca-certificates curl unzip

# install restic
ARG RESTIC_VERSION
RUN bz2file="/tmp/restic.bz2" && curl -fsSL -o "${bz2file}" "https://github.com/restic/restic/releases/download/v${RESTIC_VERSION}/restic_${RESTIC_VERSION}_linux_arm.bz2" && bunzip2 -c "${bz2file}" | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

# install rclone
ARG RCLONE_VERSION
RUN zipfile="/tmp/rclone.zip" && curl -fsSL -o "${zipfile}" "https://downloads.rclone.org/v${RCLONE_VERSION}/rclone-v${RCLONE_VERSION}-linux-arm.zip" && unzip -q "${zipfile}" -d "/tmp" && cp /tmp/rclone-*-linux-arm/rclone /usr/local/bin/rclone && chmod 755 /usr/local/bin/rclone


FROM alpine@sha256:19c4e520fa84832d6deab48cd911067e6d8b0a9fa73fc054c7b9031f1d89e4cf
LABEL maintainer="hotio"
ENTRYPOINT ["restic"]

# install packages
RUN apk add --no-cache ca-certificates

COPY --from=builder /usr/local/bin/restic /usr/local/bin/restic
COPY --from=builder /usr/local/bin/rclone /usr/local/bin/rclone
