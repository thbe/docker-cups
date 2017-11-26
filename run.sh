#!/bin/sh
#
# Script to create an admin user for CUPS exceuted by systemd
#

export PATH="/usr/sbin:/usr/bin:/sbin:/bin"

exit_on_error() { echo "Error: ${1}" >&2; exit 1; }
remove_spaces() { printf '%s' "${1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'; }
remove_quotes() { printf '%s' "${1}" | sed -e 's/^"\(.*\)"$/\1/' -e "s/^'\(.*\)'$/\1/"; }

if [ ! -f /.dockerenv ]; then
  exit_on_error "This script is intend to run in a Docker container only!"
fi

if [ ! -d /opt/cups ]; then
  exit_on_error "Configuration directory does not exist!"
fi

. /opt/cups/user.env

if [ -z ${CUPS_USER} ] && [ -z ${CUPS_PASSWORD} ]; then
  if [ -f /opt/cups/user-gen.env ]; then
    echo
    echo "Retrieving previously generated CUPS credentials..."
    . /opt/cups/user-gen.env
  else
    echo
    echo "CUPS credentials not set by user. Generating random password..."
    CUPS_USER=cupsadm
    CUPS_PASSWORD="$(LC_CTYPE=C tr -dc 'A-HJ-NPR-Za-km-z2-9' < /dev/urandom | head -c 16)"
    echo CUPS_USER=${CUPS_USER} > /opt/cups/user-gen.env
    echo CUPS_PASSWORD=${CUPS_PASSWORD} >> /opt/cups/user-gen.env
  fi
fi

# Remove whitespace and quotes around CUPS variables, if any
CUPS_USER=$(remove_spaces ${CUPS_USER})
CUPS_USER=$(remove_quotes ${CUPS_USER})
CUPS_PASSWORD=$(remove_spaces ${CUPS_PASSWORD})
CUPS_PASSWORD=$(remove_quotes ${CUPS_PASSWORD})

if [ -z ${CUPS_USER} ] || [ -z ${CUPS_PASSWORD} ]; then
  exiterr "All CUPS variables must be specified. Edit your 'env' file and re-enter them."
fi

if printf '%s' "${CUPS_USER} ${CUPS_PASSWORD}" | LC_ALL=C grep -q '[^ -~]\+'; then
  exiterr "CUPS credentials must not contain non-ASCII characters."
fi

if [ ${CUPS_USER} != cupsadm ]; then
  /usr/sbin/groupadd cupdadm
fi
/sbin/useradd -m ${CUPS_USER}
[ $? -eq 0 ] && echo "User ${CUPS_USER} has been added to system!" \
             || echo "Failed to add user ${CUPS_USER}!"
echo ${CUPS_USER}:${CUPS_PASSWORD} | /usr/sbin/chpasswd
[ $? -eq 0 ] && echo "Password ${CUPS_PASSWORD} has been set for ${CUPS_USER}!" \
             || echo "Failed to set password ${CUPS_PASSWORD} for user $CUPS_USER!"
/usr/sbin/usermod -aG cupsadm ${CUPS_USER}

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

exit 0
