#! /bin/bash
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
    echov "${SCRIPT} successfull!"
  else
    echoe "${SCRIPT} aborted, reason: ${REASON}"
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

### Copy CUPS docker env variable to script ###
if [ -z ${CUPS_ENV_USER} ] || [ -z ${CUPS_ENV_PASSWORD} ]; then
  CUPS_USER="cupsadm"
  CUPS_PASSWORD="pass"
fi

### Main logic to create an admin user for CUPS ###
if [ ! -f /opt/cups/user-gen.env ]; then
  echo CUPS_USER=${CUPS_USER} > /opt/cups/user-gen.env
  echo CUPS_PASSWORD=${CUPS_PASSWORD} >> /opt/cups/user-gen.env
else
  echo "Retrieving username and password from previously stored CUPS credentials!"
  . /opt/cups/user-gen.env
fi

### Check if CUPS_USER and CUPS_PASSWORD contain illegal characters ###
if printf '%s' "${CUPS_USER} ${CUPS_PASSWORD}" | LC_ALL=C grep -q '[^ -~]\+'; then
  RETURN=1; REASON="CUPS username or password contain illegal non-ASCII characters!"; exit;
fi

### Create CUPS admin user ###
/sbin/useradd -m ${CUPS_USER}
if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to add user ${CUPS_USER}, aborting!"; exit; fi
echo ${CUPS_USER}:${CUPS_PASSWORD} | /usr/sbin/chpasswd
if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to set password ${CUPS_PASSWORD} for user ${CUPS_USER}, aborting!"; exit; fi
/usr/sbin/usermod -aG sys ${CUPS_USER}
if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to add user ${CUPS_USER} to group sys, aborting!"; exit; fi

cat <<EOF

================================================

The CUPS instance is now ready for use!

Connect to your CUPS web interface with these details:

URL:       https://<dockerhost>:631/
Username:  ${CUPS_USER}
Password:  ${CUPS_PASSWORD}

Write these down. You'll need them to connect!

================================================

EOF
