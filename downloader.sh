#!/bin/bash

if [ -d  mods ]
then
    rm -r mods
fi

mkdir mods

for MODID in $(curl -s https://api.modrinth.com/v3/collection/$(jq -r '.collection_id' config.json) | \
    jq -r '.projects | @sh' | tr -d "'")
do  
    URL=$(curl -s https://api.modrinth.com/v3/project/$MODID/version | \
        jq \
            --arg VERSION $(jq -r '.version' config.json) \
            --arg LOADER $(jq -r '.loader' config.json) \
            '[.[] | select(.game_versions.[]==$VERSION) | select(.loaders.[]==$LOADER)] | .[0].files.[0].url' |
        tr -d '"'
    )

    if [ $URL == null ]
    then
        MODNAME=$(curl -s https://api.modrinth.com/v3/project/$MODID | jq '.name' | tr -d '"')
        echo "WARNING: No valid version found for mod "$MODNAME""
    else
        wget -nv -P mods/ $URL
    fi
done