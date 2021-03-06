#!/bin/sh
set -e    # exit on first failed command
set -x    # print all executed commands to the log

sed -e "s/\$API_KEY/$API_KEY/" android/app/src/main/AndroidManifestNoKey.xml > android/app/src/main/AndroidManifest.xml
HAVERSINE_BASE=../programs/flutter/.pub-cache/hosted/pub.dartlang.org/haversine-1.0.2/lib/src/haversine_base.dart
sed -i -e "s/PI/pi/" $HAVERSINE_BASE
cat $HAVERSINE_BASE
echo Done