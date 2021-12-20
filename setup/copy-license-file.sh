#!/bin/sh

if [ -f /run/secrets/license*.cfg ]
then
  cp /run/secrets/license*.cfg /opt/intrexx/cfg/license.cfg
  chown --reference=/opt/intrexx /opt/intrexx/cfg/license.cfg
fi

