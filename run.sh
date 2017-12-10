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
if printf '%s' "${CUPS_USER} ${CUPS_PASSWORD}" | LC_ALL=C grep -q '[^ -~]\+'; then
  RETURN=1; REASON="CUPS username or password contain illegal non-ASCII characters, aborting!"; exit;
fi

### Create CUPS admin user ###
if [ "$(grep -ci ${CUPS_USER} /etc/shadow)" -eq 0 ]; then
  /sbin/useradd ${CUPS_USER} --system -G sys,lp -d /tmp -M
  if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to add user ${CUPS_USER}, aborting!"; exit; fi
  echo ${CUPS_USER}:${CUPS_PASSWORD} | /usr/sbin/chpasswd
  if [ ${?} -ne 0 ]; then RETURN=${?}; REASON="Failed to set password ${CUPS_PASSWORD} for user ${CUPS_USER}, aborting!"; exit; fi
else
  RETURN=1; REASON="CUPS username already exist, aborting!"; exit;
fi

cat <<EOF

===========================================================

The dockerized CUPS instance is now ready for use! The web
interface is available here:

URL:       https://<dockerhost>:631/
Username:  ${CUPS_USER}
Password:  ${CUPS_PASSWORD}

===========================================================

EOF
