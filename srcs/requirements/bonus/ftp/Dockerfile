FROM debian:bullseye

# Install the Very Secure FTP Daemon
RUN apt update && apt-get install -y vsftpd

# Create the empty directory required by vsftpd for secure chrooting
RUN mkdir -p /var/run/vsftpd/empty

# Copy the configuration file
COPY conf/vsftpd.conf /etc/vsftpd.conf

# Copy and grant execution rights to the setup script
COPY tools/setup.sh /usr/local/bin/setup.sh
RUN chmod +x /usr/local/bin/setup.sh

# Expose Port 21 (Control Channel) and Ports 21000-21010 (Passive Data Channel)
EXPOSE 21 21000-21010

# Execute the setup script as PID 1
CMD ["/usr/local/bin/setup.sh"]