#!/bin/bash

set -ex

cd "${0%/*}"

# build parameters
IX_SETUP_ARCHIVE=$(ls intrexx-19.03*.tar.gz)
DOWNLOAD_URL="https://download.unitedplanet.com/intrexx/90200/intrexx-19.03.0-linux-x86_64.tar.gz"

SUITE=${1:-bullseye}
IX_VERSION="9.2"
TCP_PORTS="9279 9280 9281 9282 9283 9284"

# build the image
[ -f build-image.sh ] || exit 1

/bin/bash ./build-image.sh  \
  "$SUITE"                  \
  "$IX_VERSION"             \
  "$IX_SETUP_ARCHIVE"       \
  "$DOWNLOAD_URL"           \
  "$TCP_PORTS"

exit $?
