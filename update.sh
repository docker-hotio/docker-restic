#!/bin/bash

if [[ ${1} == "checkdigests" ]]; then
    export DOCKER_CLI_EXPERIMENTAL=enabled
    image="alpine"
    tag="3.13"
    manifest=$(docker manifest inspect ${image}:${tag})
    [[ -z ${manifest} ]] && exit 1
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "amd64" and .platform.os == "linux").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-amd64.Dockerfile  && echo "${digest}"
    digest=$(echo "${manifest}" | jq -r '.manifests[] | select (.platform.architecture == "arm" and .platform.os == "linux" and .platform.variant == "v7").digest') && sed -i "s#FROM ${image}@.*\$#FROM ${image}@${digest}#g" ./linux-arm-v7.Dockerfile && echo "${digest}"
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
    old_version=$(jq -r '.version' < VERSION.json)
    changelog=$(jq -r '.changelog' < VERSION.json)
    [[ "${old_version}" != "${version_restic}" ]] && changelog="https://github.com/restic/restic/compare/v${old_version}...v${version_restic}"
    echo '{"version":"'"${version_restic}"'","rclone_version":"'"${version_rclone}"'","changelog":"'"${changelog}"'"}' | jq . > VERSION.json
fi
