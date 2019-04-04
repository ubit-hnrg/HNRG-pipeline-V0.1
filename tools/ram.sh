#!/bin/bash -e

echo "      date     time $(free -m | grep total | sed -E 's/^    (.*)/\1/g')"
while true; do
    echo "$(date '+%Y-%m-%d %H:%M:%S') $(free -mh | grep Memoria: | sed 's/Memoria://g')"
    sleep 1
done
