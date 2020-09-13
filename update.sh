#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    mkdir ~/.docker && echo '{"experimental": "enabled"}' > ~/.docker/config.json
    image="alpine"
    tag="3.12"
    manifest=$(docker manifest inspect ${image}:${tag})
    [[ -z ${manifest} ]] && exit 1
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-amd64.Dockerfile  && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm" and .platform.os == "linux").digest')   && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm-v7.Dockerfile && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm64.Dockerfile  && echo "${digest}"
elif [[ ${1} == "tests" ]]; then
    echo "List installed packages..."
    docker run --rm --entrypoint="" "${2}" apk -vv info | sort
    status=$((status + $?))
    echo "Show rclone version info..."
    docker run --rm --entrypoint="" "${2}" rclone version
    status=$((status + $?))
    echo "Show restic version info..."
    docker run --rm --entrypoint="" "${2}" restic version
    status=$((status + $?))
    echo "Check if app works..."
    echo "mkdir /tmp/restictest && restic init --repo /tmp/restictest && restic -r /tmp/restictest --verbose backup /var/log/ && restic -r /tmp/restictest --verbose forget --keep-last 1 --prune" > "${GITHUB_WORKSPACE}/restictest.sh"
    docker run --rm --entrypoint="" -e RESTIC_PASSWORD=testpassphrase -v "${GITHUB_WORKSPACE}":"${GITHUB_WORKSPACE}" "${2}" sh "${GITHUB_WORKSPACE}/restictest.sh"
    status=$((status + $?))
    exit ${status}
else
    version_restic=$(curl -u "${GITHUB_ACTOR}:${GITHUB_TOKEN}" -fsSL "https://api.github.com/repos/restic/restic/releases/latest" | jq -r .tag_name | sed s/v//g)
    [[ -z ${version_restic} ]] && exit 1
    version_rclone=$(curl -fsSL "https://downloads.rclone.org/version.txt" | sed s/rclone\ v//g)
    [[ -z ${version_rclone} ]] && exit 1
    echo "VERSION=${version_restic}" > VERSION
    echo "RCLONE_VERSION=${version_rclone}" >> VERSION
    version="${version_restic}/${version_rclone}"
    echo "##[set-output name=version;]${version}"
fi
