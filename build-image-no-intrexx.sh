#!/bin/bash
  
set -ex

cd "${0%/*}"

SUITE=${1:-bullseye}
TCP_PORTS="10179 10180 10181 10182 10183 10184"

IMAGE="localhost/debian-intrexx-${SUITE}:latest"

CONT=$(buildah from localhost/debian-systemd-${SUITE})

buildah copy $CONT setup/ /setup

buildah run $CONT /bin/bash /setup/setup.sh $DOWNLOAD_URL

for TCP_PORT in $TCP_PORTS
do
  buildah config --port "${TCP_PORT}/tcp" $CONT
done

buildah commit --rm $CONT $IMAGE

