#!/bin/bash

set -ex

cd "${0%/*}"

# build parameters
IX_SETUP_ARCHIVE=$(ls intrexx-*.tar.gz || : 2>/dev/null)
DOWNLOAD_URL="https://download.unitedplanet.com/intrexx/rolling/steady/intrexx-latest-linux.tar.gz"

SUITE=${1:-bullseye}
IX_VERSION="steady"
TCP_PORTS="10179 10180 10181 10182 10183 10184"

# build the image
[ -f build-image.sh ] || exit 1

/bin/bash ./build-image.sh  \
  "$SUITE"                  \
  "$IX_VERSION"             \
  "$IX_SETUP_ARCHIVE"       \
  "$DOWNLOAD_URL"           \
  "$TCP_PORTS"

exit $?

