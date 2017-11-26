FROM centos/systemd

# BUILD:
#   wget https://raw.githubusercontent.com/thbe/docker-cups/master/Dockerfile
#   docker build --rm --no-cache -t thbe/cups .
#
# USAGE:
#   docker run --detach --restart always --cap-add=SYS_ADMIN -e "container=docker" \
#              --name cups --hostname cups.fritz.box \
#              -P -v /sys/fs/cgroup:/sys/fs/cgroup:ro thbe/cups
#
# DEBUG:
#   yum -y install vim-common vim-enhanced curl wget net-tools gpm-libs perl-libs tar

# Set metadata
LABEL maintainer="Thomas Bendler <project@bendler-net.de>"
LABEL version="1.0"
LABEL description="Creates CentOS Linux 7 docker base image to provide \
an airplay capable CUPS instance"

# Set environment
ENV LANG en_US.UTF-8
ENV TERM xterm

# Set workdir
WORKDIR /opt/cups

# Install CUPS and Apples zeroconf
RUN yum -y install cups avahi avahi-tools && \
    yum clean all && rm -rf /var/cache/yum

# Configure CUPS
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/SystemGroup sys root/SystemGroup sys root cupsadm/' /etc/cups/cups-files.conf

COPY ./create_admin_user.service /etc/systemd/system/create_admin_user.service
COPY ./run.sh /opt/cups/run.sh
RUN chmod 755 /opt/cups/run.sh

# Start CUPS
RUN systemctl enable create_admin_user
RUN systemctl enable cups
RUN systemctl enable avahi-daemon

# Expose zeroconf adminstrative web interface
EXPOSE 631/tcp
EXPOSE 535/udp
EXPOSE 56187/udp

# Start systemd
CMD ["/usr/sbin/init"]
