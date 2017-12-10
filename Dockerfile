FROM alpine

# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-cups/master/Dockerfile
#   docker build --rm --no-cache -t thbe/cups .
#
# USAGE:
#   wget https://raw.githubusercontent.com/thbe/docker-cups/master/start_cups.sh
#   ./start_cups.sh
#
# DEBUG:
#   yum -y install vim-common vim-enhanced curl wget net-tools gpm-libs perl-libs tar

# Set metadata
LABEL maintainer="Thomas Bendler <project@bendler-net.de>"
LABEL version="1.0"
LABEL description="Creates an Apline container serving a CUPS instance"

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

# Set workdir
WORKDIR /opt/cups

# Install, configure and start CUPS
RUN apk add --no-cache cups && \
    apk add --no-cache openrc && \
    touch /run/openrc/softlevel && \
    rc-update add cupsd && \
    /etc/init.d/cupsd start && \
    cupsctl --remote-admin

# Set initial root password
RUN echo root:pass | chpasswd

# Configure CUPS
# COPY ./run.sh /opt/cups/run.sh
# RUN chmod 755 /opt/cups/run.sh

# Start CUPS
# RUN systemctl enable create_admin_user
# RUN systemctl enable cups

# Expose CUPS adminstrative web interface
EXPOSE 631/tcp

# Start systemd
# CMD ["/usr/sbin/init"]
