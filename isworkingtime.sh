#!/bin/bash

WORKING_TIME_START=7
WORKING_TIME_END=19
HOLIDAY_API="http://nolaborables.com.ar/api/v2/feriados/$(date '+%Y')"
###
# Usage
# 
# ./isworkingtime.sh && echo "It's working time"
# ./isworkingtime.sh || echo "It's lazy time"

# If it's not a weekday..
[ "$(date '+%u')" -gt 5 ] && exit 0
# And is not in the working time
[ "$(date '+%H')" -gt "$WORKING_TIME_START" ] && [ "$(date '+%H')" -lt "$WORKING_TIME_END" ] && exit 0
# And is not a holiday
holidayFile="$HOME/.holiday.$(date '+%Y').json"
[ ! -f "$holidayFile" ] && wget -q -O "$holidayFile" "$HOLIDAY_API"
test -z $(cat "$holidayFile" | jq -c ".[] | select( .dia == $(date '+%d') and .mes == $(date '+%m'))") || exit 0

# it's work time!
exit 1
