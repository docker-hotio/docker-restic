FROM hotio/base

ARG DEBIAN_FRONTEND="noninteractive"
ARG ARCH_RESTIC="amd64"

ENV APP="Restic"

# install app
# https://github.com/restic/restic/releases
RUN curl -fsSL "https://github.com/restic/restic/releases/download/v0.9.5/restic_0.9.5_linux_${ARCH_RESTIC}.bz2" | bunzip2 | dd of=/usr/local/bin/restic && chmod 755 /usr/local/bin/restic

COPY root/ /
