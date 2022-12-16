#!/bin/sh

while true
do
    iptables -t nat -F POSTROUTING
    iptables -t nat -I POSTROUTING 1 -o eth8 -j ACCEPT
    iptables -t nat -I POSTROUTING 1 -o eth9 -j ACCEPT
    sleep 60
done
