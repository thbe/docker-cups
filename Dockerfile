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

# Install CUPS
RUN apk add --no-cache cups

# Prepare CUPS start script
COPY ./run.sh /opt/cups/run.sh
RUN chmod 755 /opt/cups/run.sh

# Expose CUPS adminstrative web interface
EXPOSE 631/tcp

# Reconfigure and start CUPS instance
CMD ["/opt/cups/run.sh"]
