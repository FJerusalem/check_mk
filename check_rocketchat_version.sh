#!/bin/bash
# check_rocketchat_version.sh
# by Florian Jerusalem
# v1.0 18.12.2018
#
# Local check for check_mk
#
# place into /usr/lib/check_mk_agent/local/300/check_rocketchat_version.sh to check every 5 Minutes
#
# Using get latest release from: https://gist.github.com/lukechilds/a83e1d7127b78fef38c2914c4ececc3c
# bash-versioning function taken from https://stackoverflow.com/questions/16989598/bash-comparing-version-numbers
#
# Make sure to have jq and curl installed

LOCALRCVERSION=$(curl -s localhost:3000/api/info |  jq -r '.version')
# For testing
#LOCALRCVERSION="0.71.3"

# Create temp-file and save result from GitHub - Only check every 6 hours for new version
file="/tmp/GHRCVERSION"

if [ ! -e "$file" ] || [[ $(find "$file" -mmin +360 -print) ]] ; then
    curl --silent "https://api.github.com/repos/RocketChat/Rocket.Chat/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' > $file
fi

GHRCVERSION=$(cat $file)

function version_gt() { test "$(printf '%s\n' "$@" | sort -V | head -n 1)" != "$1"; }

first_version=$GHRCVERSION
second_version=$LOCALRCVERSION

if version_gt $first_version $second_version; then
         echo "2 check_rocketchat_version update_available=1;;1 CRITICAL - An update is available for RocketChat - $first_version is greater than $second_version"
else
     echo "0 check_rocketchat_version update_available=0;;1 OK - No update available for RocketChat - $first_version is not greater than $second_version"
fi
