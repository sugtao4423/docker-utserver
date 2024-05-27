FROM ubuntu:trusty AS trusty
FROM debian:stable-slim

ENV LD_LIBRARY_PATH="/usr/local/lib"

COPY --from=trusty --chown=root:root --chmod=755 \
    /lib/x86_64-linux-gnu/libssl.so.1.0.0 \
    /lib/x86_64-linux-gnu/libcrypto.so.1.0.0 \
    /usr/local/lib/

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

RUN groupadd -g 1000 utorrent && \
    useradd -s /bin/bash -u 1000 -g 1000 utorrent && \
    \
    apt-get update && \
    apt-get install -y curl locales && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /var/cache/apt/* && \
    \
    sed -E 's/# (en_US.UTF-8)/\1/' -i /etc/locale.gen && \
    locale-gen && \
    \
    mkdir /utorrent \
        /utorrent/server \
        /utorrent/webui \
        /utorrent/settings \
        /utorrent/torrent \
        /utorrent/download && \
    \
    curl -sSfL -o /utorrent/server.tar.gz https://download-hr.utorrent.com/track/beta/endpoint/utserver/os/linux-x64-debian-7-0 && \
    tar xzvf /utorrent/server.tar.gz -C /utorrent/server --exclude=*/docs --strip-components 1 && \
    mv /utorrent/server/webui.zip /utorrent/webui/webui.zip && \
    rm /utorrent/server.tar.gz && \
    \
    echo 'dir_active: /utorrent/download' > /utorrent/server/utserver.conf && \
    echo 'dir_torrent_files: /utorrent/torrent' >> /utorrent/server/utserver.conf && \
    echo 'ut_webui_dir: /utorrent/webui' >> /utorrent/server/utserver.conf && \
    \
    chown -R utorrent:utorrent /utorrent

USER utorrent
VOLUME ["/utorrent/settings", "/utorrent/torrent", "/utorrent/download"]
EXPOSE 8080 6881

WORKDIR /utorrent/server

CMD ["/utorrent/server/utserver", "-settingspath", "/utorrent/settings", "-configfile", "/utorrent/server/utserver.conf", "-logfile", "/dev/stdout"]
