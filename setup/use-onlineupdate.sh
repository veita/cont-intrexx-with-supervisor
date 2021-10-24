#!/bin/sh

CFG="/opt/intrexx/cfg/update.cfg"

[ -f "$CFG"  ] && sed -i 's/\/onlineupdate-test\./\/onlineupdate\./g' "$CFG"

