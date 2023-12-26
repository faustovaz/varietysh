#!/bin/bash

change_wallpaper() {
    [ ! $(command -v wget) ] && echo "Error: command wget not found" && exit 1
    
    local URL='https://wallhaven.cc/api/v1/search?sorting=random&atleast'
    wget -O /tmp/walls.json $URL 2> /dev/null
    
    if [ $? -ne 0 ]; then
        echo "Error: It was not possible to download wallpapers."
        exit 1
    fi
    
    local wall_url=$(grep -P -o '"short_url":".*?"' /tmp/walls.json | cut -d '"' -f 4 | head -n 1 | tr -d '\\')
    
    wget -O /tmp/varietysh.html $wall_url 2> /dev/null
    
    if [ $? -ne 0 ]; then
        echo "Error: It was not possible to get the selected wallpaper."
        exit 1
    fi
    
    local image=$(grep -P -o 'id="wallpaper" src=".*?"' /tmp/varietysh.html | cut -d " " -f 2 | cut -d "\"" -f 2)
    mkdir -p $HOME/.varietysh
    local filename=$(echo $image | rev | cut -d "/" -f 1 | rev)
    wget -O $HOME/.varietysh/$filename $image 2> /dev/null
    
    gsettings set org.gnome.desktop.background picture-uri "file://$HOME/.varietysh/$filename"

}

while true; do
    change_wallpaper
    sleep 120
done

