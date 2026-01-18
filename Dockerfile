FROM debian:trixie-slim

VOLUME torch

# Set environment variables for non-interactive installs
ENV \ 
    DEBIAN_FRONTEND=noninteractive \
    WINEARCH=win64 \
    DISPLAY=:5.0 \
    WINEPREFIX=/pfx

# entrypoint addin
COPY entrypoint.sh /entrypoint.sh

# dependencies and wine management
RUN \ 
    sed -i 's/main$/main contrib/' /etc/apt/sources.list.d/debian.sources && \
    dpkg --add-architecture i386 && \ 
    apt-get update -qq && apt-get install -qq -y wget cabextract curl gnupg2 xz-utils unzip wine32 wine64 winetricks xvfb winbind libwbclient0 && \
    
    # wine hack to prevent 64 bit build errors
    ln -s /usr/bin/wine /usr/local/bin/wine64
    

RUN \
    # dotnet48 managed install 
    rm -rf $WINEPREFIX && \
    Xvfb :5 -screen 0 1024x768x16 & \
    env WINEARCH=win64 WINEDEBUG=-all WINEDLLOVERRIDES="mscoree=d" wineboot --init /nogui; \
    env WINEARCH=win64 WINEDEBUG=-all wine winecfg /v win10; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks corefonts; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks sound=disabled; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks -q vcrun2019; \
    env WINEARCH=win64 WINEDEBUG=-all winetricks -q --force dotnet48 && \
	
    # torch install
    wget -O torch-server.zip "https://build.torchapi.com/job/Torch/job/master/lastSuccessfulBuild/artifact/bin/torch-server.zip" && \
    unzip torch-server.zip -d /torch  && \
    rm torch-server.zip && \
    
    # entrypoint execution permission
    chmod +x /entrypoint.sh
    
WORKDIR /torch

EXPOSE 27016 8080 8443

ENTRYPOINT ["/entrypoint.sh"]
