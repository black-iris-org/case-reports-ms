#!/bin/bash -e
docker run -d --name temporary_for_caching --entrypoint /bin/bash $IMAGE_NAME:$IMAGE_TAG sleep infinity
docker cp temporary_for_caching:/app/vendor/bundle ./vendor/
docker rm temporary_for_caching
