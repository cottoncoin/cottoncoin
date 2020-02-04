#/bin/bash

cd ~
echo "****************************************************************************"
echo "* Ubuntu Server is the recommended operating system for this install.       *"
echo "*                                                                          *"
echo "* This script will install and configure your Cotton Coin  masternodes.    *"
echo "*                                                                          *"
echo "*        IPv6 will be used if available                                    *"
echo "*                                                                          *"
echo "****************************************************************************"
echo && echo && echo
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo "!                                                 !"
echo "! Make sure you double check before hitting enter !"
echo "!                                                 !"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
echo && echo && echo

echo "Do you want to install all needed dependencies (no if you did it before)? [y/n]"
read DOSETUP

if [ $DOSETUP = "y" ]
then
  sudo apt-get update
  sudo apt-get -y upgrade
  sudo apt-get -y dist-upgrade
  sudo apt-get update
  sudo apt-get install -y zip unzip

  cd /var
  sudo touch swap.img
  sudo chmod 600 swap.img
  sudo dd if=/dev/zero of=/var/swap.img bs=1024k count=2000
  sudo mkswap /var/swap.img
  sudo swapon /var/swap.img
  sudo free
  sudo echo "/var/swap.img none swap sw 0 0" >> /etc/fstab
  cd

  wget https://github.com/mrhappy2018/cottoncoin/files/4142258/v1.5.1.0_Linux.zip
  unzip -d Linux Linux.zip 
  chmod +x Linux/*
  sudo mv  Linux/* /usr/local/bin
  rm -rf Linux.zip Linux

  sudo apt-get install -y ufw
  sudo ufw allow ssh/tcp
  sudo ufw limit ssh/tcp
  sudo ufw logging on
  echo "y" | sudo ufw enable
  sudo ufw status

  mkdir -p ~/bin
  echo 'export PATH=~/bin:$PATH' > ~/.bash_aliases
  source ~/.bashrc
fi

 ## Setup conf
 IP=$(curl -k https://ident.me)
 mkdir -p ~/bin
 echo ""
 echo "Configure your masternodes now!"
 echo "Detecting IP address:$IP"

  echo ""
  echo "Enter alias for new node"
  read ALIAS

  echo ""
  echo "Enter port for node $ALIAS"
  echo "Just press enter"
  DEFAULTPORT=22123
  read -p "Cotton Port: " -i $DEFAULTPORT -e PORT
  : ${PORT:=$DEFAULTCROPCOINPORT}
  
  echo ""
  echo "Enter masternode private key for node $ALIAS"
  read PRIVKEY

  RPCPORT=$(echo "${PORT: -4}")
  echo "The RPC port is $RPCPORT"

  ALIAS=${ALIAS}
  CONF_DIR=~/.cotton_$ALIAS

  # Create scripts
  echo '#!/bin/bash' > ~/bin/cottond_$ALIAS.sh
  echo "cottond -daemon -conf=$CONF_DIR/cotton.conf -datadir=$CONF_DIR "'$*' >> ~/bin/cottond_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/cotton-cli_$ALIAS.sh
  echo "cotton-cli -conf=$CONF_DIR/cotton.conf -datadir=$CONF_DIR "'$*' >> ~/bin/cotton-cli_$ALIAS.sh
  echo '#!/bin/bash' > ~/bin/cotton-tx_$ALIAS.sh
  echo "cotton-tx -conf=$CONF_DIR/cotton.conf -datadir=$CONF_DIR "'$*' >> ~/bin/cotton-tx_$ALIAS.sh
  chmod 755 ~/bin/cotton*.sh

  mkdir -p $CONF_DIR
  echo "rpcuser=user"`shuf -i 100000-10000000 -n 1` >> cotton.conf_TEMP
  echo "rpcpassword=pass"`shuf -i 100000-10000000 -n 1` >> cotton.conf_TEMP
  echo "rpcallowip=127.0.0.1" >> cotton.conf_TEMP
  echo "rpcport=$RPCPORT" >> cotton.conf_TEMP
  echo "listen=1" >> cotton.conf_TEMP
  echo "server=1" >> cotton.conf_TEMP
  echo "daemon=1" >> cotton.conf_TEMP
  echo "logtimestamps=1" >> cotton.conf_TEMP
  echo "maxconnections=256" >> cotton.conf_TEMP
  echo "masternode=1" >> cotton.conf_TEMP
  echo "port=$PORT" >> cotton.conf_TEMP
  echo "masternodeaddr="[$IP]":$PORT" >> cotton.conf_TEMP
  echo "masternodeprivkey=$PRIVKEY" >> cotton.conf_TEMP
  sudo ufw allow $PORT/tcp

  mv cotton.conf_TEMP $CONF_DIR/cotton.conf

  sh ~/bin/cottond_$ALIAS.sh
  
  
 echo
 echo -e "================================================================================================================================"
 echo -e "Cotton coin Masternode is up and running and it is listening on port $PORT."
 echo -e "Please make sure the you use the [] when using IPv6 in the masternode config of local wallet" [$IP]:$PORT
 echo -e "MASTERNODE PRIVATEKEY is: $PRIVKEY"
 echo -e "================================================================================================================================"  
    

