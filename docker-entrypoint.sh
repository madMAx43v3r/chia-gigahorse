#!/bin/bash

if [[ -n "${TZ}" ]]; then
  echo "Setting timezone to ${TZ}"
  echo "$TZ" > /etc/timezone
fi

./chia.bin init --fix-ssl-permissions

if [[ -n ${CHIA_HOSTNAME} ]]; then
  yq -i '.self_hostname = env(CHIA_HOSTNAME)' "$CHIA_ROOT/config/config.yaml"
else
  yq -i '.self_hostname = "127.0.0.1"' "$CHIA_ROOT/config/config.yaml"
fi

if [[ -n "${CHIA_UPNP}" ]]; then
  ./chia.bin configure --upnp "${CHIA_UPNP}"
fi

if [[ -n "${CHIA_LOG_LEVEL}" ]]; then
  ./chia.bin configure --log-level "${CHIA_LOG_LEVEL}"
fi

for p in ${CHIA_PLOTS//:/ }; do
  mkdir -p "${p}"
  if [[ ! $(ls -A "$p") ]]; then
    echo "Plots directory '${p}' appears to be empty, try mounting a plot directory with the docker -v command"
  fi
  ./chia.bin plots add -d "${p}"
done

## Remote Harvester Support
if [[ ${CHIA_SERVICES} == "harvester" ]]; then
  if [[ -n ${CHIA_FARMER_ADDRESS} || -n ${CHIA_FARMER_PORT} || -n ${CHIA_CA} ]]; then
    ./chia.bin init -c "${CHIA_CA}" && ./chia.bin configure --set-farmer-peer "${CHIA_FARMER_ADDRESS}:${CHIA_FARMER_PORT}"
  else
    echo "A farmer peer address, port, and ca path are required."
    exit
  fi
fi

exec "$@"