#!/bin/bash

VERSION="1.21.11"
LOADER="fabric"
COLLECTIONID="j1vbZc9Y"

MODIDS=$(curl -s https://api.modrinth.com/v3/collection/$COLLECTIONID | \
jq -r '.projects | @sh' | tr -d "'")

mkdir mods

for MODID in $MODIDS
do  
    echo $MODID
    curl -s https://api.modrinth.com/v2/project/$MODID/version | \
    jq --arg VERSION $VERSION --arg LOADER $LOADER \
        '[.[] | select(.game_versions.[]==$VERSION) | select(.loaders.[]==$LOADER)]' | \
    jq '.[0].files.[0].url' | \
    xargs wget -P mods/
done