#!/usr/bin/env bash

# Evitar erro com o uso de video
xhost +local:docker

## Buildando o docker
# docker buildx build . -f docker/vsss.Dockerfile -t fbot/vsss-nvidia:latest

# Build sem cache
docker buildx build . -f docker/vsss.Dockerfile -t fbot/vsss-nvidia:latest --no-cache
