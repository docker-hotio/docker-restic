# [Restic](https://github.com/restic/restic)

[![badge](https://images.microbadger.com/badges/image/hotio/restic.svg)](https://microbadger.com/images/hotio/restic "Get your own image badge on microbadger.com")
[![badge](https://images.microbadger.com/badges/version/hotio/restic.svg)](https://microbadger.com/images/hotio/restic "Get your own version badge on microbadger.com")
[![badge](https://images.microbadger.com/badges/commit/hotio/restic.svg)](https://microbadger.com/images/hotio/restic "Get your own commit badge on microbadger.com")

## Donations

NANO: `xrb_1bxqm6nsm55s64rgf8f5k9m795hda535to6y15ik496goatakpupjfqzokfc`  
BTC: `39W6dcaG3uuF5mZTRL4h6Ghem74kUBHrmz`  
LTC: `MMUFcGLiK6DnnHGFnN2MJLyTfANXw57bDY`

## Starting the container

Just the basics to get the container running:

```shell
docker run --rm --name restic --hostname backupcontainer -v /tmp/restic:/config -e TZ=Etc/UTC hotio/restic
```

The environment variables `PUID`, `PGID`, `UMASK` and `BACKUP` are all optional, the values you see below are the default values.

```shell
-e PUID=1000
-e PGID=1000
-e UMASK=022
-e BACKUP=yes
```

## Configuration

Create the file `/config/app/crontab` (see example below) and put your restic backup script along with other required files in `/config/app/`. Rclone configuration can be placed in `/config/.config/rclone/rclone.conf`. When the container starts, the crontab file will be installed. A container restart is needed when you've modified your crontab file, for the changes to apply.

Example crontab file `/config/app/crontab`:

```shell
* * * * * /config/app/backup-every-minute.sh
@hourly /config/app/backup-hourly.sh
```

Example backup script `/config/app/backup-hourly.sh`:

```shell
#!/bin/bash

echo "Creating backup..."
restic --repo rclone:amazon:backup --password-file /config/app/encryption.key backup --exclude-caches /documents
restic --repo rclone:amazon:backup --password-file /config/app/encryption.key backup --exclude-caches /pictures
```

Additional docker volumes:

```shell
-v /storage/documents:/documents:ro
-v /storage/pictures:/pictures:ro
```

## Backing up the configuration

By default on every docker container shutdown a backup is created from the configuration files. You can change this behaviour.

```shell
-e BACKUP=no
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
