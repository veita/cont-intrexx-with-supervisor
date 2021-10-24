#!/bin/bash
  
set -ex

cd "${0%/*}"

# this script requires four parameters
if [ "$#" -ne 5 ]
then
    printf "Illegal number of arguments\n" >&2
    exit 1
fi

SUITE="$1"
IX_VERSION="$2"
IX_SETUP_ARCHIVE="$3"
DOWNLOAD_URL="$4"
TCP_PORTS="$5"

IMAGE="localhost/debian-intrexx-${IX_VERSION}-${SUITE}:latest"

CONT=$(buildah from localhost/debian-systemd-${SUITE})

buildah copy $CONT setup/               /setup
buildah copy $CONT setup-${IX_VERSION}/ /setup

if [ -f "$IX_SETUP_ARCHIVE" ]
then
  buildah copy $CONT "$IX_SETUP_ARCHIVE" "/setup/$IX_SETUP_ARCHIVE"
  buildah run $CONT /bin/bash /setup/setup.sh
  buildah run $CONT rm "/setup/$IX_SETUP_ARCHIVE"
else
  buildah run $CONT /bin/bash /setup/setup.sh $DOWNLOAD_URL
fi

for TCP_PORT in $TCP_PORTS
do
  buildah config --port "${TCP_PORT}/tcp" $CONT
done

buildah commit --rm $CONT $IMAGE

