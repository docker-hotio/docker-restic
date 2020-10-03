# restic

[<img src="https://hotio.dev/img/restic.png" alt="logo" height="130" width="130">](https://github.com/restic/restic)

![Base](https://img.shields.io/badge/base-alpine-blue)
[![GitHub](https://img.shields.io/badge/source-github-lightgrey)](https://github.com/hotio/docker-restic)
[![Docker Pulls](https://img.shields.io/docker/pulls/hotio/restic)](https://hub.docker.com/r/hotio/restic)
[![GitHub Registry](https://img.shields.io/badge/registry-ghcr.io-blue)](https://github.com/users/hotio/packages/container/package/restic)
[![Discord](https://img.shields.io/discord/610068305893523457?color=738ad6&label=discord&logo=discord&logoColor=white)](https://discord.gg/3SnkuKp)
[![Upstream](https://img.shields.io/badge/upstream-project-yellow)](https://github.com/restic/restic)

## Starting the container

Just the basics to get the container running:

```shell
docker run --rm hotio/restic ...
```

The default `ENTRYPOINT` is `restic`.

## Tags

| Tag                | Upstream        |
| -------------------|-----------------|
| `release` (latest) | GitHub releases |

You can also find tags that reference a commit or version number.
