#!/bin/bash

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}')
MEM=$(free | awk '/Mem/{print $3/$2 * 100.0}')
DISK=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "CPU: $CPU% | MEM: $MEM% | DISK: $DISK%"

if (( ${CPU%.*} > 80 )); then
  echo "ALERT: CPU usage is above limit please check: $CPU%"
fi

if (( ${MEM%.*} > 80 )); then
  echo "ALERT: Memory usage is above limit please check: $MEM%"
fi

if (( DISK > 80 )); then
  echo "ALERT: Disk space running low: $DISK%"
fi
