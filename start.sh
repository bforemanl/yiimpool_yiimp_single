#!/usr/bin/env bash

#####################################################
# This is the entry point for configuring the system.
# Source https://mailinabox.email/ https://github.com/mail-in-a-box/mailinabox
# Updated by afiniel for crypto use...
#####################################################

source /etc/functions.sh
source /etc/yiimpool.conf

# Ensure Python reads/writes files in UTF-8. If the machine
# triggers some other locale in Python, like ASCII encoding,
# Python may not be able to read/write files. This is also
# in the management daemon startup script and the cron script.

if ! locale -a | grep en_US.utf8 > /dev/null; then
# Generate locale if not exists
hide_output locale-gen en_US.UTF-8
fi

export LANGUAGE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8
export LC_TYPE=en_US.UTF-8

# Fix so line drawing characters are shown correctly in Putty on Windows. See #744.
export NCURSES_NO_UTF8_ACS=1

# Create the temporary installation directory if it doesn't already exist.
echo -e "$YELLOW Creating the temporary YiiMP installation folder...$COL_RESET"
if [ ! -d $STORAGE_ROOT/yiimp/yiimp_setup ]; then
sudo mkdir -p $STORAGE_ROOT/{wallets,yiimp/{yiimp_setup/log,site/{web,stratum,configuration,crons,log},starts}}
sudo touch $STORAGE_ROOT/yiimp/yiimp_setup/log/installer.log
fi
echo -e "$GREEN Folders created...$COL_RESET"

# Start the installation.
source menu.sh
source questions.sh
source $HOME/yiimpool/yiimp_single/.wireguard.install.cnf
if [[ ("$wireguard" == "true") ]]; then
  source wireguard.sh
fi
source system.sh
source self_ssl.sh
source db.sh
source nginx_upgrade.sh
source web.sh
source stratum.sh
source daemon.sh
if [[ ("$UsingDomain" == "yes") ]]; then
source send_mail.sh
fi
source server_cleanup.sh
source motd.sh
source server_harden.sh
source $STORAGE_ROOT/yiimp/.yiimp.conf

clear

if [[ ("$UsingDomain" == "yes") ]]; then
  echo -e "$YELLOW Installation of your Yiimp is now$GREEN completed."
  echo -e "$YELLOW You $RED*MUST REBOOT*$YELLOW the machine to finalize the machine updates and folder permissions! $MAGENTA YiiMP will not function until a$RED reboot$YELLOW is performed!$COL_RESET"
  echo
  echo -e "$YELLOW Important! After first$RED reboot$YELLOW it may take up to 1 minute for the$GREEN main$YELLOW|$GREEN loop2$YELLOW|$GREEN blocks$YELLOW|$GREEN debug$YELLOW screens to start!$COL_RESET"
  echo -e "$YELLOW If they show$RED stopped,$YELLOW after 1 minute, type$GREEN motd$YELLOW to$GREEN refresh$YELLOW the screen.$COL_RESET"
  echo
  echo -e "$YELLOW You can access your$GREEN $AdminPanel $YELLOW at,$BLUE http://${DomainName}/site/${AdminPanel} $COL_RESET"
  echo
  echo -e "$RED By default all stratum ports are blocked by the firewall.$YELLOW To allow a port through, from the command prompt type $GREEN sudo ufw allow port number.$COL_RESET"
  echo -e "$GREEN Database user names and passwords$YELLOW can be found in$RED $STORAGE_ROOT/yiimp_setup/.my.cnf$COL_RESET"
else
  echo -e "$YELLOW Installation of your Yiimp is now$GREEN completed."
  echo -e "$YELLOW You $RED*MUST REBOOT*$YELLOW the machine to finalize the machine updates and folder permissions! $MAGENTA YiiMP will not function until a$RED reboot$YELLOW is performed!$COL_RESET"
  echo
  echo -e "$YELLOW Important! After first$RED reboot$YELLOW it may take up to 1 minute for the$GREEN main$YELLOW|$GREEN loop2$YELLOW|$GREEN blocks$YELLOW|$GREEN debug$YELLOW screens to start!$COL_RESET"
  echo -e "$YELLOW If they show$RED stopped,$YELLOW after 1 minute, type$GREEN motd$YELLOW to$GREEN refresh$YELLOW the screen.$COL_RESET"
  echo
  echo -e "$YELLOW You can access your$GREEN $AdminPanel $YELLOW at,$BLUE http://${DomainName}/site/${AdminPanel} $COL_RESET"
  echo
  echo -e "$RED By default all stratum ports are blocked by the firewall.$YELLOW To allow a port through, from the command prompt type $GREEN sudo ufw allow port number.$COL_RESET"
  echo -e "$GREEN Database user names and passwords$YELLOW can be found in$RED $STORAGE_ROOT/yiimp_setup/.my.cnf$COL_RESET"
fi

echo
last_words

