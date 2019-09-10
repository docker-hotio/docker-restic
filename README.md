# [docker-restic](https://github.com/hotio/docker-restic)

![Docker Pulls](https://img.shields.io/docker/pulls/hotio/restic?style=flat-square)
![Drone (cloud)](https://img.shields.io/drone/build/hotio/docker-restic?style=flat-square)

## Donations

NANO: `xrb_1bxqm6nsm55s64rgf8f5k9m795hda535to6y15ik496goatakpupjfqzokfc`  
BTC: `39W6dcaG3uuF5mZTRL4h6Ghem74kUBHrmz`  
LTC: `MMUFcGLiK6DnnHGFnN2MJLyTfANXw57bDY`

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

## Execute scripts at startup

If you need additional dependencies for your pp-scripts, you can install these by placing your script in the folder `/config/scripts.d`, an example script can be seen below. This script would install the `sickbeard_mp4_automator` scripts and its dependencies.

```shell
#!/bin/bash

if [[ ! -d /sma ]]; then
  apt update
  apt install -y --no-install-recommends --no-install-suggests python-pip python-setuptools ffmpeg
  pip --no-cache-dir install requests requests[security] requests-cache babelfish stevedore==1.19.1 python-dateutil deluge-client qtfaststart "guessit<2" "subliminal<2"
  mkdir /sma
  curl -fsSL "https://github.com/mdhiggins/sickbeard_mp4_automator/archive/c29bde3b2b4cfc194e5bb3a868b248acd2780d89.tar.gz" | tar xzf - -C "/sma" --strip-components=1
fi
```
