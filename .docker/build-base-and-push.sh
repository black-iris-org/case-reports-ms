#!/bin/bash
docker build -t trekmedics/case-reports-ms:base-case-reports-$(uname -m) -f .docker/Dockerfile.base .
docker push trekmedics/case-reports-ms:base-case-reports-$(uname -m)