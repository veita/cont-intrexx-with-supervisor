#!/bin/bash

set -ex

cd "${0%/*}"

# build parameters
IX_SETUP_ARCHIVE=$(ls intrexx-21.03*.tar.gz || : 2>/dev/null)
DOWNLOAD_URL="https://download.unitedplanet.com/intrexx/100000/intrexx-21.03-linux-x86_64.tar.gz"

SUITE=${1:-bullseye}
IX_VERSION="10.0"
TCP_PORTS="10079 10080 10081 10082 10083 10084"

# build the image
[ -f build-image.sh ] || exit 1

/bin/bash ./build-image.sh  \
  "$SUITE"                  \
  "$IX_VERSION"             \
  "$IX_SETUP_ARCHIVE"       \
  "$DOWNLOAD_URL"           \
  "$TCP_PORTS"

exit $?
