#!/bin/bash

VV_HOME=$HOME/.varietysh/
WALLPAPERS_JSON_FILE=$VV_HOME/.wall.json
IMAGES_LINKS_FILE=$VV_HOME/.links.json
IMAGES_FOLDER=$VV_HOME/images

FILE_EXPIRATION_TIME=7200
API_URL='https://wallhaven.cc/api/v1/search?sorting=random&atleast'

check_commands() {
    [ ! $(command -v wget) ] && echo "Error: wget not found" && exit 1
    [ ! $(command -v logger) ] && echo "Error: logger not found" && exit 1
    [ ! $(command -v stat) ] && echo "Error: stat not found" && exit 1
}

dowload_json_from_api() {
    if [ -e "$WALLPAPERS_JSON_FILE" ]; then
        local file_creation_time=$(date --date="$(stat "$WALLPAPERS_JSON_FILE" | grep "Birth" | cut -d " " -f3,4)" +%s)
        local now=$(date --date=now +%s)
        local time_delta=$(($now - $file_creation_time))
        if [[ $time_delta -gt $FILE_EXPIRATION_TIME ]]; then
            wget -o $VV_HOME/varietysh.log -O $WALLPAPERS_JSON_FILE $URL 2> /dev/null
            [ $? -ne 0 ] && logger -t varietysh "Error: It was not possible to download wallpapers at $API_URL"
        fi 
    else
        wget -o $VV_HOME/varietysh.log -O $WALLPAPERS_JSON_FILE $API_URL 2> /dev/null
        [ $? -ne 0 ] && logger -t varietysh "Error: It was not possible to download wallpapers at $API_URL"
    fi
}

generate_file_links() {
    if [ -e $WALLPAPERS_JSON_FILE ] && [ ! -e $IMAGES_LINKS_FILE ]; then
        local img_urls=($(grep -P -o '"short_url":".*?"' $WALLPAPERS_JSON_FILE | cut -d '"' -f 4 | tr -d '\\'))
        echo "${img_urls[@]}" | tr " " "\n" > $IMAGES_LINKS_FILE
    fi
}

download_and_set_wallpaper() {
    if [[ -e $IMAGES_LINKS_FILE ]]; then
        mkdir -p $IMAGES_FOLDER
        local links=($(cat $IMAGES_LINKS_FILE))
        local link=${links[0]}
        unset links[0]
        links=("${links[@]}")
        [[ ${#links[@]} -eq 0 ]] && rm -r $IMAGE_LINKS_FILE
        [[ ${#links[@]} -ne 0 ]] && echo "${links[@]}" | tr " " "\n" > $IMAGES_LINKS_FILE
        wget -o $VV_HOME/varietysh.log -O $VV_HOME/.img.html $link 2> /dev/null
        if [[ $? -eq 0 ]]; then
            local image=$(grep -P -o 'id="wallpaper" src=".*?"' $VV_HOME/.img.html | cut -d " " -f 2 | cut -d "\"" -f 2)
            local filename=$(echo $image | rev | cut -d "/" -f 1 | rev)
            wget -o $VV_HOME/varietysh.log -O $IMAGES_FOLDER/$filename $image 2> /dev/null
            gsettings set org.gnome.desktop.background picture-uri "file://$IMAGES_FOLDER/$filename"
        else
            logger -t varietysh "Error: It was not possible to set a new wallpaper"
        fi
    fi
}

varietysh() {
    mkdir -p $HOME/.varietysh
    check_commands
    dowload_json_from_api
    generate_file_links
    download_and_set_wallpaper
}

while true; do
    varietysh
    sleep 300
done

