#!/bin/bash

WORKING_TIME_START=7
WORKING_TIME_END=17
###
# Usage
# 
# ./isworkingtime.sh || echo "It's working time"
# ./isworkingtime.sh && echo "It's lazy time"

# If it's not a weekday..
[ "$(date '+%u')" -gt 5 ] && exit 0
# And is not in the working time
[ "$(date '+%H')" -lt "$WORKING_TIME_START" ] && exit 0
[ "$(date '+%H')" -gt "$WORKING_TIME_END" ] && exit 0
# it's work time!
exit 1
