#!/bin/bash
mkdir -p vendor/bundle
docker build \
  --build-arg BASE_TAG=base-case-reports-$(uname -m) \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --cache-from $IMAGE_NAME:develop \
  -t $IMAGE_NAME:$IMAGE_TAG .
