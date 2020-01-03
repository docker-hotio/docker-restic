# restic

[![GitHub](https://img.shields.io/badge/source-github-lightgrey)](https://github.com/hotio/docker-restic)
[![Docker Pulls](https://img.shields.io/docker/pulls/hotio/restic)](https://hub.docker.com/r/hotio/restic)
[![Discord](https://img.shields.io/discord/610068305893523457?color=738ad6&label=discord&logo=discord&logoColor=white)](https://discord.gg/3SnkuKp)
[![Upstream](https://img.shields.io/badge/upstream-project-yellow)](https://github.com/restic/restic)

## Starting the container

Just the basics to get the container running:

```shell
docker run --rm --name restic --hostname <your_hostname> -v /<host_folder_config>:/config hotio/restic
```

The environment variables below are all optional, the values you see are the defaults.

```shell
-e PUID=1000
-e PGID=1000
-e UMASK=002
-e TZ="Etc/UTC"
-e ARGS=""
```

## Tags

| Tag      | Description                    | Build Status                                                                                                                                          | Last Updated                                                                                         |
| ---------|--------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------|
| latest   | The same as `stable`           |                                                                                                                                                       |                                                                                                      |
| stable   | Stable version                 | [![Build Status](https://cloud.drone.io/api/badges/hotio/docker-restic/status.svg?ref=refs/heads/stable)](https://cloud.drone.io/hotio/docker-restic) | ![GitHub last commit (branch)](https://img.shields.io/github/last-commit/hotio/docker-restic/stable) |

You can also find tags that reference a commit or version number.

## Configuration

Create the file `/config/app/crontab` (see example below) and put your restic backup script along with other required files in `/config/app/`. Rclone configuration can be placed in `/config/.config/rclone/rclone.conf`. When the container starts, the crontab file will be installed. A container restart is needed when you've modified your crontab file, for the changes to apply.

Example crontab file `/config/app/crontab`:

```shell
* * * * * hotio /config/app/backup-every-minute.sh
@hourly root /config/app/backup-hourly.sh
```

Example backup script `/config/app/backup-hourly.sh`:

```shell
#!/bin/bash

export RCLONE_CONFIG="/config/.config/rclone/rclone.conf"

echo "Creating backup..."
restic --repo rclone:amazon:backup --password-file /config/app/encryption.key --cache-dir /config/.cache/restic backup --exclude-caches /documents
restic --repo rclone:amazon:backup --password-file /config/app/encryption.key --cache-dir /config/.cache/restic backup --exclude-caches /pictures
```

Additional docker volumes:

```shell
-v /storage/documents:/documents:ro
-v /storage/pictures:/pictures:ro
```

## Executing your own scripts

If you have a need to do additional stuff when the container starts or stops, you can mount your script with `-v /docker/host/my-script.sh:/etc/cont-init.d/99-my-script` to execute your script on container start or `-v /docker/host/my-script.sh:/etc/cont-finish.d/99-my-script` to execute it when the container stops. An example script can be seen below.

```shell
#!/usr/bin/with-contenv bash

echo "Hello, this is me, your script."
```
