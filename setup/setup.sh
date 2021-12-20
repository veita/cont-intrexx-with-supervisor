#!/bin/bash

set -ex

DOWNLOAD_URL=$1

SUITE=$(lsb_release -sc)

IX_INSTALL_DIR="/opt/intrexx"

export DEBIAN_FRONTEND=noninteractive

apt-get update -qy
apt-get upgrade -qy

# install Git and ImageMagick
apt-get install -qy git imagemagick

# Postfix is needed to prevent excessive package pulls (Exim etc.) later
debconf-set-selections <<< "postfix postfix/mailname string 'localhost'"
debconf-set-selections <<< "postfix postfix/main_mailer_type string 'Local only'"
apt-get install -qy postfix

# install and configure PostgreSQL
wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
echo "deb http://apt.postgresql.org/pub/repos/apt/ $SUITE-pgdg main" >> /etc/apt/sources.list

apt-get update -qy
apt-get install -qy postgresql

sed -i 's/^port.*$/port = 5432/g' /etc/postgresql/*/main/postgresql.conf
sed -i -r 's/(.*127\.0\.0\.1\/32\s+)md5$/\1trust/g' /etc/postgresql/*/main/pg_hba.conf
sed -i -r 's/(.*::1\/128\s+)md5$/\1trust/g' /etc/postgresql/*/main/pg_hba.conf
sed -i -r 's/(.*127\.0\.0\.1\/32\s+)scram-sha-256$/\1trust/g' /etc/postgresql/*/main/pg_hba.conf
sed -i -r 's/(.*::1\/128\s+)scram-sha-256$/\1trust/g' /etc/postgresql/*/main/pg_hba.conf

$(shopt -s dotglob ; cp /etc/skel/* /var/lib/postgresql/)

# services
systemctl enable postfix
systemctl enable postgresql

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
  INSTALL_INTREXX=false
fi

if [ "$INSTALL_INTREXX" = true ]
then
  mv "/setup/tmp/$(ls)" /setup/tmp/intrexx-setup
  cd /setup/tmp/intrexx-setup

  # setup Intrexx
  ./setup.sh -t --configFile="/setup/configuration.properties"

  # copy license file on container startup if one exists
  mkdir /etc/systemd/system/upixsupervisor.d

  cat << EOF > /etc/systemd/system/upixsupervisor.service.d/copy-license.conf
[Service]
ExecStartPre=/bin/bash /setup/copy-license-file.sh
ExecStartPre=/bin/bash -c '/bin/rm /etc/systemd/system/upixsupervisor.service.d/copy-license.conf'
EOF

  chmod 644 /etc/systemd/system/upixsupervisor.service.d/copy-license.conf
fi


# modify .bashrc for root
cat << EOF >> /root/.bashrc

alias p='cd /opt/intrexx/org/*/'
alias pl='less /opt/intrexx/org/*/log/portal.log'
EOF


# cleanup
rm -rf /setup/tmp
rm -rf /tmp/* /var/tmp/*
