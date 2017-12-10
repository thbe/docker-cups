#! /bin/sh
#
# Author:       Thomas Bendler <project@bendler-net.de>
# Date:         Thu Dec  7 11:41:44 CET 2017
#
# Release:      0.1.0
#
# Prerequisite: This release needs a shell which could handle functions.
#               If shell is not able to handle functions, remove the
#               error section.
#
# Note:         For debugging reason change shebang to: /bin/bash -vx
#
# ChangeLog:    v0.1.0 - Initial release
#

### Error handling ###
error_handling() {
  if [ "${RETURN}" -eq 0 ]; then
    echo "${SCRIPT} successfull!"
  else
    echo "${SCRIPT} aborted, reason: ${REASON}"
  fi
  exit "${RETURN}"
}
trap "error_handling" EXIT HUP INT QUIT TERM
RETURN=0
REASON="Finished!"

### Default values ###
export PATH=/usr/sbin:/usr/bin:/sbin:/bin
export LC_ALL=C
export LANG=C
SCRIPT=$(basename ${0})

### Check prerequisite ###
if [ ! -f /.dockerenv ]; then RETURN=1; REASON="Not executed inside a Docker container, aborting!"; exit; fi
if [ ! -d /opt/cups ]; then RETURN=1; REASON="CUPS configuration dirctory not found, aborting!"; exit; fi

### Configure CUPS for remote administration ###
cupsctl --remote-any
/etc/init.d/cupsd restart

### Copy CUPS docker env variable to script ###
if [ -z ${CUPS_ENV_PASSWORD} ]; then
  CUPS_PASSWORD="pass"
else
  CUPS_PASSWORD=${CUPS_ENV_PASSWORD}
fi

### Main logic to create an admin user for CUPS ###
if printf '%s' "${CUPS_PASSWORD}" | LC_ALL=C grep -q '[^ -~]\+'; then
  RETURN=1; REASON="CUPS password contain illegal non-ASCII characters, aborting!"; exit;
fi

### set password for root user ###
echo root:${CUPS_PASSWORD} | /usr/sbin/chpasswd
if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to set password ${CUPS_PASSWORD} for user root, aborting!"; exit; fi

cat <<EOF

===========================================================

The dockerized CUPS instance is now ready for use! The web
interface is available here:

URL:       https://${CUPS_ENV_HOST}:631/
Username:  root
Password:  ${CUPS_PASSWORD}

===========================================================

EOF
