#!/bin/bash

if [[ -n "${TZ}" ]]; then
  echo "Setting timezone to ${TZ}"
fi

if [[ ${CHIA_RECOMPUTE_PROXY} == "true" ]]; then
  if [[ -n ${CHIA_RECOMPUTE_NODES} ]]; then
    nodes=""
    for n in ${CHIA_RECOMPUTE_NODES//,/ }; do
      nodes+=" -n ${n}"
    done
    ./chia_recompute_proxy -p ${CHIA_RECOMPUTE_PORT} ${nodes}
  else
    echo "At least one compute server must be specified to run the proxy"
    exit
  fi
else
  ./chia_recompute_server -p ${CHIA_RECOMPUTE_PORT}
fi