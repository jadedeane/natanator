#!/bin/sh

while true
do
    iptables -t nat -F POSTROUTING
    sleep 60
done
