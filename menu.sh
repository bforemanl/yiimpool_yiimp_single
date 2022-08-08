#!/usr/bin/env bash

#####################################################
# Source code https://github.com/end222/pacmenu
# Updated by afiniel for crypto use...
#####################################################

source /etc/functions.sh

RESULT=$(dialog --stdout --default-item 1 --title "Yiimpool Yiimp installer v3.0" --menu "Choose one" -1 60 6 \
' ' "- Without wireguard installed use the following option -" \
1 "YiiMP - server without wireguard installed" \
' ' "- If you plan on adding more servers later use the following option -" \
2 "YiiMP - Server with WireGuard installed" \
3 Exit)
if [ $RESULT = ]
then
bash $(basename $0) && exit;
fi

if [ $RESULT = 1 ]
then
clear;
echo '
wireguard=false
' | sudo -E tee $HOME/yiimpool/yiimp_single/.wireguard.install.cnf >/dev/null 2>&1;
fi

if [ $RESULT = 2 ]
then
clear;
echo '
wireguard=true
' | sudo -E tee $HOME/yiimpool/yiimp_single/.wireguard.install.cnf >/dev/null 2>&1;
echo 'server_type='db'
DBInternalIP='10.0.0.2'
' | sudo -E tee $STORAGE_ROOT/yiimp/.wireguard.conf >/dev/null 2>&1;
fi

if [ $RESULT = 3 ]
then
clear;
exit;
fi
