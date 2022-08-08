#!/usr/bin/env bash

#####################################################
# Created by Afiniel for Yiimpool use...
#####################################################

source /etc/functions.sh
source $STORAGE_ROOT/yiimp/.yiimp.conf
source $HOME/yiimpool/yiimp_single/.wireguard.install.cnf

# Starting the build progress of the stratum
echo -e "$YELLOW Building blocknotify and stratum...$COL_RESET"

cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/blocknotify

# Create blocknotify password and start to compile it.
blckntifypass=`cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1`
sudo sed -i 's/tu8tu5/'${blckntifypass}'/' blocknotify.cpp
sudo make -j8 # Added -j8 for faster compile "Add back hide output later"

# Compile the iniparser
cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/stratum/iniparser
sudo make -j8 # Added -j8 for faster compile "Add back hide output later"

# If Auto exchange is enabled then compile with auto exchange flag.
cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/stratum

if [[ ("$AutoExchange" == "yes") ]]; then
sudo sed -i 's/CFLAGS += -DNO_EXCHANGE/#CFLAGS += -DNO_EXCHANGE/' $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/stratum/Makefile
fi
sudo make -j8 # Added -j8 for faster compile "Add back hide output later"

# Copy compiled binaries to yiimp STORAGE_ROOT.
echo -e "$YELLOW Building stratum folder structure and copying files...$COL_RESET"
cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/stratum

sudo cp -a config.sample/. $STORAGE_ROOT/yiimp/site/stratum/config
sudo cp -r stratum $STORAGE_ROOT/yiimp/site/stratum
sudo cp -r run.sh $STORAGE_ROOT/yiimp/site/stratum

cd $STORAGE_ROOT/yiimp/yiimp_setup/yiimp
sudo cp -r $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/blocknotify/blocknotify $STORAGE_ROOT/yiimp/site/stratum
sudo cp -r $STORAGE_ROOT/yiimp/yiimp_setup/yiimp/blocknotify/blocknotify /usr/bin

# Recreate the run.sh file.
sudo rm -r $STORAGE_ROOT/yiimp/site/stratum/config/run.sh
echo '#!/usr/bin/env bash
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
ulimit -n 10240
ulimit -u 10240
cd '""''"${STORAGE_ROOT}"''""'/yiimp/site/stratum
while true; do
./stratum config/$1
sleep 2
done
exec bash' | sudo -E tee $STORAGE_ROOT/yiimp/site/stratum/config/run.sh >/dev/null 2>&1
sudo chmod +x $STORAGE_ROOT/yiimp/site/stratum/config/run.sh

# Remove the old run.sh file, and replace with the new one. And copy the values to ./yiimp file
sudo rm -r $STORAGE_ROOT/yiimp/site/stratum/run.sh

echo '#!/usr/bin/env bash
source /etc/yiimpool.conf
source $STORAGE_ROOT/yiimp/.yiimp.conf
cd '""''"${STORAGE_ROOT}"''""'/yiimp/site/stratum/config/ && ./run.sh $*
' | sudo -E tee $STORAGE_ROOT/yiimp/site/stratum/run.sh >/dev/null 2>&1
sudo chmod +x $STORAGE_ROOT/yiimp/site/stratum/run.sh

# Copy the new values to the DataBase.
echo -e " Updating stratum config files with database connection info...$COL_RESET"
cd $STORAGE_ROOT/yiimp/site/stratum/config

sudo sed -i 's/password = tu8tu5/password = '${blckntifypass}'/g' *.conf
sudo sed -i 's/server = yaamp.com/server = '${StratumURL}'/g' *.conf

# If wireguard is enabled.
if [[ ("$wireguard" == "true") ]]; then
  sudo sed -i 's/host = yaampdb/host = '${DBInternalIP}'/g' *.conf
else
sudo sed -i 's/host = yaampdb/host = localhost/g' *.conf
fi
sudo sed -i 's/database = yaamp/database = '${YiiMPDBName}'/g' *.conf
sudo sed -i 's/username = root/username = '${StratumDBUser}'/g' *.conf
sudo sed -i 's/password = patofpaq/password = '${StratumUserDBPassword}'/g' *.conf

#set permissions
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/yiimp/site/stratum/
sudo setfacl -m u:$USER:rwx $STORAGE_ROOT/yiimp/site/stratum/config

echo -e "$GREEN Stratum build complete...$COL_RESET"
cd $HOME/yiimpool/yiimp_single