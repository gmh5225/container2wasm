#!/bin/bash

set -eu -o pipefail

CONTAINER=test-container
TIMEOUT=80m

DOCKER_BUILDKIT=1 docker build --progress=plain -f Dockerfile.test -t $CONTAINER .
docker run --rm -d --privileged -v ${CONTAINER}-cache:/var/lib/docker --name $CONTAINER $CONTAINER
until docker exec $CONTAINER docker version
do
    echo "retrying..."
    sleep 3
done
docker exec -w /test $CONTAINER go test ${GO_TEST_FLAGS:-} -timeout $TIMEOUT -v ./tests/integration
docker kill $CONTAINER
