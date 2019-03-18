#!/bin/sh


if [ -f /run/secrets/username ]; then
  USERNAME=$(cat /run/secrets/username)
fi

if [ -f /run/secrets/username ]; then
  TOKEN=$(cat /run/secrets/token)
fi


./update-mods.sh $VERSION $MODS $USERNAME $TOKEN
