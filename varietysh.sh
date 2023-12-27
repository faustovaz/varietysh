#!/bin/bash

VV_HOME=$HOME/.varietysh/

check_commands() {
    [ ! $(command -v wget) ] && echo "Error: wget not found" && exit 1
    [ ! $(command -v logger) ] && echo "Error: logger not found" && exit 1
    [ ! $(command -v stat) ] && echo "Error: stat not found" && exit 1
}

download_wallpapers_json() {
    local URL='https://wallhaven.cc/api/v1/search?sorting=random&atleast'
    wget -o $VV_HOME/varietysh.log -O $VV_HOME/walls.json $URL 2> /dev/null
    if [ $? -ne 0 ]; then
        logger "Error: It was not possible to download wallpapers."
    fi
}

download_wallpaper() {
    if [[ -e $VV_HOME/walls.json ]]; then
        local short_url=$(grep -P -o '"short_url":".*?"' $VV_HOME/walls.json | cut -d '"' -f 4 | head -n 1 | tr -d '\\')
        wget -o $VV_HOME/varietysh.log -O $VV_HOME/.img.html $wall_url 2> /dev/null
        if [ $? -eq 0 ]; then
            local image=$(grep -P -o 'id="wallpaper" src=".*?"' $VV_HOME/.img.html | cut -d " " -f 2 | cut -d "\"" -f 2)
            local filename=$(echo $image | rev | cut -d "/" -f 1 | rev)
            wget -o $VV_HOME/varietysh.log -O $VV_HOME/$filename $image 2> /dev/null
            gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.varietysh/$filename"
        fi
    fi
}

varietysh() {
    mkdir -p $HOME/.varietysh
    check_commands
    download_wallpapers_json
}

while true; do
    varietysh
    sleep 600
done

