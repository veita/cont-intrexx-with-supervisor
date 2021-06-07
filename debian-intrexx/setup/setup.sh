#!/bin/bash

set -ex

DOWNLOAD_URL=$1

IX_INSTALL_DIR="/opt/intrexx"

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy

# install Git
apt-get install -qy git

# services
systemctl disable cron.service

# cleanup
apt-get clean -qy
apt-get autoremove -qy


# install and configure Intrexx
mkdir /setup/tmp
cd /setup/tmp

if [ $(ls -1 /setup/*.tar.gz 2>/dev/null | wc -l) = 1 ]
then
  $(cat /setup/*.tar.gz | tar -xz) || exit 1
  INSTALL_INTREXX=true
elif [ -n "$DOWNLOAD_URL" ]
then
  $(curl "$DOWNLOAD_URL?container-build=true" | tar -xz) || exit 1
  INSTALL_INTREXX=true
else
  printf "Neither a file nor a download URL have been provided\n" >&2
  INSTALL_INTREXX=true
fi

if [ "$INSTALL_INTREXX" = true ]
then
  mv "/setup/tmp/$(ls)" /setup/tmp/intrexx-setup
  cd /setup/tmp/intrexx-setup

  # setup Intrexx
  ./setup.sh -t --configFile="/setup/configuration.properties"

  # copy license file if one exists
  if [ -f "/setup/license.cfg" ]
  then
    cp /setup/license.cfg /opt/intrexx/cfg/license.cfg
  fi
fi

# cleanup
rm -rf /setup/tmp
rm -rf /tmp/* /var/tmp/*
