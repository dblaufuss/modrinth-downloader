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
    PROJECT=$(curl -s $MODRINTH_API/project/$MOD_ID/version)
    MOD_VERSION=$(jq -r --arg VERSION $VERSION --arg LOADER $LOADER \
        '[.[] | select(.game_versions.[]==$VERSION and .loaders.[]==$LOADER)] | .[0]' <<< $PROJECT
    )
    URL=$(jq -r '.files.[0].url' <<< $MOD_VERSION)

    if [ $URL == null ]
    then
        echo "WARNING: No valid version found for mod $MOD_NAME"
    else
        wget -q -P mods/ $URL
        VERSION_NUMBER=$(jq -r '.version_number' <<< $MOD_VERSION)
        DATE_PUBLISHED=$(jq -r '.date_published[:10]' <<< $MOD_VERSION)
        printf "Name: $MOD_NAME\nVersion Number: $VERSION_NUMBER\nDate Published: $DATE_PUBLISHED\n\n"
        ((DOWNLOAD_COUNT++))
    fi
done

echo "FINISHED: Downloaded [$DOWNLOAD_COUNT/$MOD_COUNT] mods"