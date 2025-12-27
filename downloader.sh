#!/bin/bash

if [ -d  mods ]
then
    rm -r mods
fi

mkdir mods

for MODID in $(curl -s https://api.modrinth.com/v3/collection/$(jq -r '.collection_id' config.json) | \
    jq -r '.projects | @sh' | tr -d "'")
do  
    curl -s https://api.modrinth.com/v3/project/$MODID/version | \
    jq \
        --arg VERSION $(jq -r '.version' config.json) \
        --arg LOADER $(jq -r '.loader' config.json) \
        '[.[] | select(.game_versions.[]==$VERSION) | select(.loaders.[]==$LOADER)] | .[0].files.[0].url' | \
    xargs wget -P mods/
done