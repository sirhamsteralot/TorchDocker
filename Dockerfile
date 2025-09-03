FROM debian:trixie-slim

# Set environment variables for non-interactive installs
ENV DEBIAN_FRONTEND=noninteractive
ENV WINEARCH=win64
ENV DISPLAY=:5.0
ENV WINEPREFIX=/pfx

# Add contrib repo
RUN sed -i 's/main$/main contrib/' /etc/apt/sources.list.d/debian.sources

# Update and install dependencies
RUN dpkg --add-architecture i386
RUN apt-get update -qq && apt-get install -qq -y wget cabextract curl gnupg2 xz-utils unzip wine32 wine64 winetricks xvfb winbind libwbclient0

# Hack to avoid wine32 bother
RUN ln -s /usr/bin/wine /usr/local/bin/wine64

# Remove wine prefix
RUN rm -rf $WINEPREFIX

# Install .NET Framework 4.8 using winetricks
RUN \
    Xvfb :5 -screen 0 1024x768x16 & \
    env WINEARCH=win64 WINEDEBUG=-all WINEDLLOVERRIDES="mscoree=d" wineboot --init /nogui; \
    env WINEARCH=win64 WINEDEBUG=-all wine winecfg /v win10; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks corefonts; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks sound=disabled; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks -q vcrun2019; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks -q --force dotnet48

# Download torch
RUN \
    mkdir -p /torch && \
    wget -O torch-server.zip "https://build.torchapi.com/job/Torch/job/master/lastSuccessfulBuild/artifact/bin/torch-server.zip" && \
    unzip torch-server.zip -d /torch
    
WORKDIR /torch

EXPOSE 27016/udp 8080 5900

# Use a shell script as entrypoint to start Xvfb and then run the server
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]