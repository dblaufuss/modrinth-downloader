#!/bin/bash

if [ -d  mods ]
then
    rm -r mods
fi

mkdir mods

#CONFIG
COLLECTION_ID=$(jq -r '.collection_id' config.json)
VERSION=$(jq -r '.version' config.json)
LOADER=$(jq -r '.loader' config.json)

DOWNLOAD_COUNT=0
MODRINTH_API="https://api.modrinth.com/v3"

COLLECTION=$(curl -s $MODRINTH_API/collection/$COLLECTION_ID)
MOD_COUNT=$(jq -r '.projects | length' <<< $COLLECTION)

for MOD_ID in $(jq -r '.projects | @sh' <<< $COLLECTION | tr -d "'")
do  
    MOD_NAME=$(curl -s $MODRINTH_API/project/$MOD_ID | jq -r '.name')
    MOD_VERSION=$(
        curl -s $MODRINTH_API/project/$MOD_ID/version | \
        jq -r --arg VERSION $VERSION --arg LOADER $LOADER \
        '[.[] | select(.game_versions.[]==$VERSION and .loaders.[]==$LOADER)].[0]'
    )
    URL=$(jq -r '.files.[0].url' <<< $MOD_VERSION)

    if [ $URL == null ]
    then
        printf "\nWARNING: No valid version found for mod $MOD_NAME\n"
    else
        VERSION_NUMBER=$(jq -r '.version_number' <<< $MOD_VERSION)
        DATE_PUBLISHED=$(jq -r '.date_published[:10]' <<< $MOD_VERSION)
        printf "\nName: $MOD_NAME\nVersion Number: $VERSION_NUMBER\nDate Published: $DATE_PUBLISHED\n"
        wget -q --show-progress -P mods/ $URL
        ((DOWNLOAD_COUNT++))
    fi
done

printf "\nFINISHED: Downloaded [$DOWNLOAD_COUNT/$MOD_COUNT] mods"