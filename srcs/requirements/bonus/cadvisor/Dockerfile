FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    wget 

# The URL here has been updated to use "cadvisor-v0.47.0-linux-amd64"
RUN wget https://github.com/google/cadvisor/releases/download/v0.47.0/cadvisor-v0.47.0-linux-amd64 -O /usr/bin/cadvisor \
    && chmod +x /usr/bin/cadvisor

EXPOSE 8080

CMD ["/usr/bin/cadvisor", "-logtostderr", "--url_base_prefix=/cadvisor"]