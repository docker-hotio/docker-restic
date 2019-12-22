#!/bin/bash

if [[ ${1} == "checkpackages" ]]; then
    docker run --rm --privileged multiarch/qemu-user-static --reset -p yes
    docker run --rm -v "${GITHUB_WORKSPACE}":/github -t hotio/base:stable-linux-arm64 bash -c 'apt list --installed > /github/upstream_packages.arm64.txt'
    docker run --rm -v "${GITHUB_WORKSPACE}":/github -t hotio/base:stable-linux-arm   bash -c 'apt list --installed > /github/upstream_packages.arm.txt'
    docker run --rm -v "${GITHUB_WORKSPACE}":/github -t hotio/base:stable-linux-amd64 bash -c 'apt list --installed > /github/upstream_packages.amd64.txt'
else
    version=$(curl -fsSL "https://api.github.com/repos/restic/restic/releases/latest" | jq -r .tag_name | sed s/v//g)
    [[ -z ${version} ]] && exit
    find . -type f -name '*.Dockerfile' -exec sed -i "s/ARG RESTIC_VERSION=.*$/ARG RESTIC_VERSION=${version}/g" {} \;
    sed -i "s/{TAG_VERSION=.*}$/{TAG_VERSION=${version}}/g" .drone.yml

    version_rclone=$(curl -fsSL "https://api.github.com/repos/ncw/rclone/releases/latest" | jq -r .tag_name | sed s/v//g)
    [[ -z ${version_rclone} ]] && exit
    find . -type f -name '*.Dockerfile' -exec sed -i "s/ARG RCLONE_VERSION=.*$/ARG RCLONE_VERSION=${version_rclone}/g" {} \;

    version="${version}/${version_rclone}"

    echo "##[set-output name=version;]${version}"
fi
