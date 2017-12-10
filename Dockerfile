FROM alpine
#
# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-cups/master/Dockerfile
#   docker build --rm --no-cache -t thbe/cups .
#
# USAGE:
#   wget https://raw.githubusercontent.com/thbe/docker-cups/master/start_cups.sh
#   ./start_cups.sh
#

# Set metadata
LABEL maintainer="Thomas Bendler <project@bendler-net.de>"
LABEL version="1.0"
LABEL description="Creates an Alpine container serving a CUPS instance"

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

# Set workdir
WORKDIR /opt/cups

# Install, configure and start CUPS
RUN apk add --no-cache cups && \
    apk add --no-cache openrc && \
    rc-update add cupsd

# Add local CUPS reconfiguration service
COPY ./cups-reconfigure.start /etc/local.d/cups-reconfigure.start
RUN chmod 755 /etc/local.d/cups-reconfigure.start
RUN rc-update add local default

# Configure CUPS
COPY ./configure.sh /opt/cups/configure.sh
RUN chmod 755 /opt/cups/configure.sh

# Enable verbose
COPY ./local /etc/conf.d/local

# Expose CUPS adminstrative web interface
EXPOSE 631/tcp

# Reconfigure CUPS
ENTRYPOINT ["/opt/cups/configure.sh"]

# Start CUPS instance
CMD ["/sbin/init"]
