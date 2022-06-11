#!/bin/bash

ipv6=$(sysctl net.ipv6.conf.all.disable_ipv6 | awk '{print $NF}')
[[ $ipv6 == 1 ]] && sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0 || sysctl -w net.ipv6.conf.all.disable_ipv6=1
#echo $ipv
