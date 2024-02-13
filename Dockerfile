# Using the latest ubuntu image
FROM ubuntu:latest
RUN apt update

# Setting /home as our working directory
WORKDIR /home

# Download and install all the necessary dependencies for steamcmd
RUN dpkg --add-architecture i386 && \
    apt-get update -y && apt install wget lib32gcc-s1 lib32stdc++6 \
    curl libstdc++6:i386 lib32z1 -y

# Presetting Values for liscence agreement keys using debconf-set-selections
RUN echo steam steam/question select "I AGREE" | debconf-set-selections 
RUN echo steam steam/license note '' | debconf-set-selections 

# Installing SteamCMD  
RUN mkdir steamcmd && mkdir game_files && apt-get install -y --no-install-recommends steamcmd 

# Create symlink for executable in /bin
RUN ln -s /usr/games/steamcmd /usr/bin/steamcmd && \
    steamcmd +quit

# Add steam user
RUN useradd -m steam
USER steam

# Ajust user ENV
COPY .bashrc /home/steam/.bashrc

RUN steamcmd +force_install_dir '/home/steam/Steam/steamapps/common/steamworks' +login anonymous +app_update 1007 +quit && \
    mkdir -p /home/steam/.steam/sdk64 && \
    cp '/home/steam/Steam/steamapps/common/steamworks/linux64/steamclient.so' /home/steam/.steam/sdk64/

# Install palserver
Run steamcmd +force_install_dir '/home/steam/Steam/steamapps/common/PalServer' +login anonymous +app_update 2394010 validate +quit

# Set our shell script as entrypoint for our container
ENTRYPOINT ["/home/steam/Steam/steamapps/common/PalServer/PalServer.sh"]
