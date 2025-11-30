#!/usr/bin/env bash
shutdown-utserver() {
  touch /utorrent/request/sp.utmr
}
trap shutdown-utserver EXIT

/utorrent/server/utserver \
  -settingspath /utorrent/settings \
  -configfile /utorrent/server/utserver.conf \
  -logfile /dev/stdout
