#!/bin/bash

URL="http://localhost:80"
TIMEOUT=5

STATUS_CODE=$(curl -o /dev/null -s -w "%{http_code}\n" --max-time $TIMEOUT $URL)

if [[ "$STATUS_CODE" -ge 200 && "$STATUS_CODE" -lt 400 ]]; then
    echo "Application is UP (Status Code: $STATUS_CODE)"
else
    echo "Application is DOWN or not responding (Status Code: $STATUS_CODE)"
fi

