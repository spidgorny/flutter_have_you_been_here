#!/bin/sh
set -e    # exit on first failed command
set -x    # print all executed commands to the log

sed -e "s/\$API_KEY/$API_KEY/" android/app/src/main/AndroidManifestNoKey.xml > android/app/src/main/AndroidManifest.xml