#
# BUILD:
#   docker build --rm --no-cache -t thbe/cups .
#
# USAGE:
#   ./start_cups.sh
#
FROM alpine:3.21

# Set metadata
LABEL maintainer="Thomas Bendler <project@bendler-net.de>" \
      version="1.3" \
      description="Creates an Alpine container serving a CUPS instance accessible through airplay as well"

# Set environment
ENV LANG=en_US.UTF-8 \
    TERM=xterm

# Set workdir
WORKDIR /opt/cups

# Install CUPS/AVAHI
RUN apk add --no-cache \
      cups \
      cups-filters \
      avahi \
      inotify-tools

# Copy configuration files and set permissions
COPY --chmod=755 root /

# Expose ports:
# - 137/udp, 139/tcp, 445/tcp: SMB printer sharing
# - 631/tcp: IPP printer sharing
# - 5353/udp: Avahi advertisement
EXPOSE 137/udp 139/tcp 445/tcp 631/tcp 5353/udp

# Start CUPS instance
CMD ["/srv/run.sh"]
