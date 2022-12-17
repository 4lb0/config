#!/bin/bash

logger "Init work apps"
cd "$(dirname "$0")"
./isworkingtime.sh || ./runworkapps.sh
