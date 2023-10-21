#!/bin/bash

./chia.bin start ${CHIA_SERVICES}

trap "echo Shutting down ...; ./chia.bin stop all -d; exit 0" SIGINT SIGTERM

tail -F /dev/null
