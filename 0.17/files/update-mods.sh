#!/bin/sh

FACTORIO_VERSION=$1
MOD_DIR=$2
USERNAME=$3
TOKEN=$4

MOD_BASE_URL="https://mods.factorio.com"


print_step()
{
  echo $1
}

print_success() 
{
  echo $1
}

print_failure()
{
  echo $1
}

update_mod()
{
  MOD_NAME=$1

  print_step "Trying to update $MOD_NAME"

  MOD_INFO_URL="$MOD_BASE_URL/api/mods/$MOD_NAME"
  MOD_INFO_JSON=$(curl --silent $MOD_INFO_URL)
  
  MOD_INFO=$(curl --silent $MOD_INFO_URL | jq -j --arg version $FACTORIO_VERSION ".releases|reverse|map(select(.info_json.factorio_version as \$mod_version | \$version | startswith(\$mod_version)))[0]|.file_name, \" \", .download_url")

  set -- $MOD_INFO
  MOD_FILENAME=$1
  MOD_URL=$2

  if [ -z "$MOD_URL" ]; then
    return 1
  fi

  if [ "$MOD_FILENAME" = "null" ]; then
    print_failure "  Mod Not compatible with version"
    return 1
  fi

  if [ -f $MOD_DIR/$MOD_FILENAME ]; then
    print_success "Already up-to-date"
    return 0
  fi

  FULL_URL=$MOD_BASE_URL$MOD_URL?username=$USERNAME\&token=$TOKEN 
  HTTP_STATUS=$(curl --silent -w "%{http_code}" -o $MOD_DIR/$MOD_FILENAME $FULL_URL)

  if [ ! $HTTP_STATUS -eq 302 ]; then
    print_failure "  Failed to download, missing your username and token?"
    rm $MOD_DIR/$MOD_FILENAME #Will download a html page instead... so delete it =
    return 1
  fi

  print_success "Downloaded $MOD_NAME"
  for file in $MOD_DIR/$MOD_NAME*.zip; do
    if [ $file != $MOD_DIR/$MOD_FILENAME ]; then
      echo "  Deleting old verion: $file"
      rm $file
    fi
  done

  return 0
}

for mod in $(jq -r ".mods|map(select(.enabled))|.[].name" $MOD_DIR/mod-list.json); do
  if [ $mod != "base" ]; then
    update_mod $mod
  fi
done
