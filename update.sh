#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    docker pull hotio/base:stable-linux-arm64
    docker pull hotio/base:stable-linux-arm
    docker pull hotio/base:stable-linux-amd64
    docker inspect --format='{{index .RepoDigests 0}}' hotio/base:stable-linux-arm64 >  upstream_digests.txt
    docker inspect --format='{{index .RepoDigests 0}}' hotio/base:stable-linux-arm   >> upstream_digests.txt
    docker inspect --format='{{index .RepoDigests 0}}' hotio/base:stable-linux-amd64 >> upstream_digests.txt
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
