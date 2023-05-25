#!/bin/bash

./chia.bin init --fix-ssl-permissions && ./chia.bin start ${CHIA_SERVICES}

trap "echo Shutting down ...; ./chia.bin stop all -d; exit 0" SIGINT SIGTERM

while true; do sleep 1; done
