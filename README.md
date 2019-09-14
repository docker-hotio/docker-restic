# restic

[![GitHub](https://img.shields.io/badge/source-github-lightgrey?style=flat-square)](https://github.com/hotio/docker-restic)
[![Docker Pulls](https://img.shields.io/docker/pulls/hotio/restic?style=flat-square)](https://hub.docker.com/r/hotio/restic)
[![Drone (cloud)](https://img.shields.io/drone/build/hotio/docker-restic?style=flat-square)](https://cloud.drone.io/hotio/docker-restic)

## Starting the container

Just the basics to get the container running:

```shell
docker run --rm --name restic --hostname backupcontainer -v /tmp/restic:/config -e TZ=Etc/UTC hotio/restic
```

The environment variables below are all optional, the values you see are the defaults.

```shell
-e PUID=1000
-e PGID=1000
-e UMASK=022
```

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

## Using a rclone mount

Mounting a remote filesystem using `rclone` can be done with the environment variable `RCLONE`. Use `docker exec -it --user hotio CONTAINERNAME rclone config` to configure your remote when the container is running. Configuration files for `rclone` are stored in `/config/.config/rclone`.

```shell
-e RCLONE="remote1:path/to/files,/localmount1|remote2:path/to/files,/localmount2"
```

## Using a rar2fs mount

Mounting a filesystem using `rar2fs` can be done with the environment variable `RAR2FS`. The new mount will be read-only. Using a `rar2fs` mount makes the use of an unrar script obsolete. You can mount a `rar2fs` mount on top of an `rclone` mount, `rclone` mounts are mounted first.

```shell
-e RAR2FS="/folder1-rar,/folder1-unrar|/folder2-rar,/folder2-unrar"
```

## Extra docker privileges

In most cases you will need some or all of the following flags added to your command to get the required docker privileges when using a rclone or rar2fs mount.

```shell
--security-opt apparmor:unconfined --cap-add SYS_ADMIN --device /dev/fuse
```

## Executing your own scripts

If you have a need to do additional stuff when the container starts or stops, you can mount your script with `-v /docker/host/my-script.sh:/etc/cont-init.d/99-my-script` to execute your script on container start or `-v /docker/host/my-script.sh:/etc/cont-finish.d/99-my-script` to execute it when the container stops. An example script can be seen below.

```shell
#!/usr/bin/with-contenv bash

echo "Hello, this is me, your script."
```
