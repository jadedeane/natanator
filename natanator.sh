#!/bin/sh

while true
do
    # identify MASQUERADE jump target in UBIOS_POSTROUTING_USER_HOOK chain
    # which will be added per default for UBIOS_ADDRv4_ethX (eth8/eth9) to
    # manage NAT throught WAN
    rules=$(/usr/sbin/iptables -t nat -L UBIOS_POSTROUTING_USER_HOOK --line-numbers | \
                grep "MASQUERADE .* UBIOS_ADDRv4_eth. src" | \
                cut -d' ' -f1)

    # for each rule identified we issue a delete operation in reverse
    # order so that UBIOS_POSTROUTINE_USER_HOOK will really only contain
    # NAT rules a user manually defined in the Network UI.
    for rulenum in $(echo ${rules} | rev); do
        /usr/sbin/iptables -t nat -D UBIOS_POSTROUTING_USER_HOOK ${rulenum}
    done

    # sleep for one minute and then
    # re-evaluate because changed in the Network UI
    # could reintroduce the NAT/MASQUERADE rules
    sleep 60
done
