#!/bin/bash
clear
merah="\e[31m"
kuning="\e[33m"
hijau="\e[32m"
biru="\e[34m"
UL="\e[4m"
bold="\e[1m"
italic="\e[3m"
reset="\e[m"

# Env Vars
cd $HOME
source .bash_profile 2> /dev/null
invalid_input=""$bold""$merah"Invalid input "$REPLY". Tolong pilih yes atau no\n"$reset""
invalid_format=""$bold""$merah"Format salah$reset\n"
format=""$bold""$UL""$hijau""
continue=""$hijau""$bold"Tekan enter untuk melanjutkan"$reset""
bline="======================================================================="
script_config='--max-clients 100 \\\n--sync-fetch-span 100 \\\n--p2p-peer-address dev-test2.inery.network:9010 \\\n--p2p-peer-address dev-test3.inery.network:9010 \\\n--p2p-peer-address dev-test4.inery.network:9010 \\\n--p2p-peer-address dev-test5.inery.network:9010 \\\n--p2p-peer-address bis.blockchain-servers.world:9010 \\\n--p2p-peer-address sys.blockchain-servers.world:9010 \\'

if ! [[ $(type nodine 2> /dev/null) ]]; then
    echo -e 'export PATH="$PATH":"$HOME"/inery-node/inery/bin' >> $HOME/.bash_profile
fi

if [[ ! $inerylog ]]; then
    echo -e 'export inerylog="$HOME"/inery-node/inery.setup/master.node/blockchain/nodine.log' >> $HOME/.bash_profile
fi
source .bash_profile

# Function set_account_name

set_account(){

accname=""$hijau"account name"$reset""
accID="Masukan $accname: $reset"
while true; do
echo "$bline"
read -p "$(printf "$accID""$reset")" name
echo -e "$bline\n"
get_account=`curl -sS -L -X POST 'http://bis.blockchain-servers.world:8888/v1/chain/get_account' -H 'Content-Type: application/json' -H 'Accept: application/json' -d '{"account_name":"'"$name"'"}'| jq -r '.account_name' 2> /dev/null`
get_pubkey=`curl -sS -L -X POST 'http://bis.blockchain-servers.world:8888/v1/chain/get_account' -H 'Content-Type: application/json' -H 'Accept: application/json' -d '{"account_name":"'"$name"'"}'| jq -r '.permissions[0].required_auth.keys[].key' 2> /dev/null`
get_balance=`curl -sS -L -X POST 'http://bis.blockchain-servers.world:8888/v1/chain/get_account' -H 'Content-Type: application/json' -H 'Accept: application/json' -d '{"account_name":"'"$name"'"}'| jq -r ."core_liquid_balance" 2> /dev/null`
pubkey="$hijau"$bold"$get_pubkey"
sleep 0.1
    if [[ $get_account = $name ]];then
	account="Akun name: $hijau"$bold"$get_account"$reset"\n"
	pubkey="Pubkey: $hijau"$bold"$get_pubkey"$reset"\n"
	balance="Balance: $hijau"$bold"$get_balance"$reset"\n"
        acc_info=("$account" "$pubkey" "$balance")
        for acc in ${acc_info[@]}; do
        echo -e -n $acc
        done
	while true; do
        echo -e -n "Tolong cek apakah sudah sama dengan yang didashboard?"$reset"[Y/n]"
        read yn
        case $yn in
            [Yy]* ) printf "\n"; ACC=true; break;;
            [Nn]* ) printf "\n"; ACC=false; break;;
            * ) echo -e "$invalid_input"; echo -e "$bline\n";;
        esac
        done
        if [[ $ACC = true ]]; then
            echo -e "export IneryAccname="$name"" >> $HOME/.bash_profile
            echo -e "export IneryPubkey="$get_pubkey"" >> $HOME/.bash_profile
            source $HOME/.bash_profile
            break
        else
            accID="Tolong masukan $accname lagi: "
        fi
    else
        echo -e "Uh tidack ditemukan $accname dengan nama $name 😱\n"$reset""
	accID="Tolong masukan $accname yg benar: "
    fi
done

}


# Funtion Set privkey

set_privkey(){

privkeyname="$bold""$hijau"private-key"$reset"
privatekey="Masukan"$hijau" $privkeyname: "
while true; do
echo -e "$bline"
read -p "$(printf "$privatekey""$reset")" privkey
echo -e "$bline\n"
    if [[ ! $privkey =~ ^[5]{1}[a-zA-Z1-9]{50}$ ]]; then
        echo -e "$bold$privkeyname $privkey" "$invalid_format"
        privatekey="Tolong masukan yang benar $privkeyname: $reset"
    else
	while true; do
        echo -e -n "Apakah $privkeyname "$format""$privkey"$reset sudah benar? [Y/n]"
        read yn
        case $yn in
            [Yy]* ) printf "\n"; PRIV=true; break;;
            [Nn]* ) printf "\n"; PRIV=false; break;;
            * ) echo -e "$invalid_input"; echo -e "$bline\n";;
        esac
        done
        if [[ $PRIV = true ]]; then
            break
	else
	    privatekey="Masukan $privkeyname lagi: "
        fi
    fi
done

}

set_peers(){

default_ip=$(curl -s ifconfig.me)
ipaddress="$bold""$hijau"ip-address"$reset"
enter_ip="Masukan public "$hijau" $ipaddress: "
while true; do
echo -e "$bline\n"
echo -e "$bold""$kuning"INFO: "$reset"Your IP in this machine is: "$bold""$hijau""$default_ip$reset\n"
echo -e "$bline"
read -p "$(printf "$enter_ip""$reset")" address
echo -e "$bline\n"
    if [[ ! $address =~ ^[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}[.]{1}[0-9]{1,3}$ ]]; then
        echo -e "$bold$ipaddress $address" "$invalid_format"
        enter_ip="Tolong masukan yang benar public $ipaddress: $reset"
    else
	while true; do
        echo -e -n "Apakah $ipaddress "$format""$address"$reset sudah benar? [Y/n]"
        read yn
        case $yn in
            [Yy]* ) printf "\n"; ADDR=true; break;;
            [Nn]* ) printf "\n"; ADDR=false; break;;
            * ) echo -e "$invalid_input"; echo -e "$bline\n";;
        esac
        done
        if [[ $ADDR = true ]]; then
            break
	else
	    enter_ip="Masukan public $ipaddress lagi: "
        fi
    fi
done

}
# Import wallet

import_wallet(){
    rm -rf $HOME/inery-wallet
    cd; cline wallet create -n $name --file $HOME/$name.txt
    cline wallet import -n $name --private-key $privkey
}

# reg_producer

reg_producer(){
    cline wallet unlock -n $IneryAccname --password $(cat $HOME/$IneryAccname.txt)
    cline system regproducer $IneryAccname $IneryPubkey 0.0.0.0:9010
    echo -e ""$kuning""$bold"Reg producer success $reset"
    sleep 0.5
    cline system makeprod approve $IneryAccname $IneryAccname
    echo -e ""$kuning""$bold"Approve producer success $reset"
    sleep 0.5
}

# Set account

install_master_node(){
# Update upgrade

echo -e "$bold$hijau 2. Updating packages... $reset"
sleep 1
sudo apt update && sudo apt upgrade -y

# Install dep

echo -e "$bold$hijau 3. Installing dependencies... $reset"
sleep 1
sudo apt install -y make bzip2 automake libbz2-dev libssl-dev doxygen graphviz libgmp3-dev \
autotools-dev libicu-dev python2.7 python2.7-dev python3 python3-dev \
autoconf libtool curl zlib1g-dev sudo ruby libusb-1.0-0-dev \
libcurl4-gnutls-dev pkg-config patch llvm-7-dev clang-7 vim-common jq libncurses5 ccze git screen

echo -e "$bold$hijau 4. Installing node... $reset"
sleep 1

# Clone repo

cd $HOME
pnodine=$(pgrep nodine)
if [[ $pnodine ]]; then
    pkill -9 nodine
fi
rm -rf inery-*
git clone https://github.com/inery-blockchain/inery-node

# Set config
echo -e "$bold$hijau 1. Set account... $reset"
sleep 1

set_account
set_privkey
set_peers

# Print account setting

echo -e "\n$bline"
echo -e "\t\t\tMaster-node configuration$reset"
echo -e "$bline"
echo -e "Your $accname is: $bold$hijau$name$reset"
echo -e "Your $pubkeyname is: $bold$hijau$pubkey$reset"
echo -e "Your $privkeyname is: $bold$hijau$privkey$reset"
echo -e "Your peers is: $bold$hijau$address:9010$reset"
echo -e "$bline\n"
sleep 2

peers="$address:9010"
sed -i "s/accountName/$name/g;s/publicKey/$IneryPubkey/g;s/privateKey/$privkey/g;s/IP:9010/$peers/g" $HOME/inery-node/inery.setup/tools/config.json
cd ~/inery-node/inery.setup/tools/scripts/
script=("start.sh" "genesis_start.sh" "hard_replay.sh")
echo -e $script_config | tee -a ${script[@]} > /dev/null
echo -e "$bold$hijau 5. Running master node... $reset"
sleep 1
run_master
# create wallet

echo -e "$bold$hijau 6. Import wallet to local machine... $reset"
sleep 1
import_wallet

echo -e "$bold$hijau 7. Enable firewall... $reset"
sleep 1

# Enable firewall

sudo ufw allow 8888,9010/tcp
sudo ufw allow ssh
sudo ufw limit ssh

# Print

echo -e "\n========================$bold$biru SETUP FINISHED$reset ============================"
echo -e "Source vars environment:$bold$hijau source $HOME/.bash_profile $reset"
echo -e "Check your account name env vars:$bold$hijau echo \$IneryAccname $reset"
echo -e "Check your public-key env vars:$bold$hijau echo \$IneryPubkey $reset"
echo -e "Your wallet password save to:$bold$hijau cat $HOME/\$IneryAccname.txt $reset"
echo -e "Check logs with command:$bold$hijau tail -f \$inerylog | ccze -A $reset"
echo -e "========================$bold$biru SETUP FINISHED$reset ============================\n"
source $HOME/.bash_profile
sleep 2
}

run_master(){
chmod 777 $HOME/inery-node/inery.setup/ine.py
cd $HOME/inery-node/inery.setup
setsid ./ine.py --master >/dev/null 2>&1 &
}

while true; do
# logo

curl -s https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash

# Menu

PS3='Select an action: '
options=(
"Install master node"
"Check Log"
"Reg/approve as producer TASK I"
"Create test token TASK II"
"Delete and uninstall node"
"Exit"
)
select opt in "${options[@]}"
do
case $opt in

"Install master node") # install Node
clear
install_master_node
sleep 1
clear
break;;

"Check Log") # Checklogs
clear
tail -f $inerylog | ccze -A
clear
continue;;

"Reg/approve as producer TASK I") # Reg as producer
clear
cd $HOME/inery-node/inery.setup/master.node/
./start.sh
if [[ -d $HOME/inery-wallet && $IneryAccname && $IneryPubkey ]]; then
        reg_producer
	echo -e ""$bold""$kuning"\nSuccessfull reg as producer"
	sleep 2
else
        echo -e ""$bold""$merah"No wallet in local machine found"
        echo -e ""$bold""$kuning"First create wallet and set as env vars"
        set_account_name
        set_pubkey
        set_privkey
	import_wallet
	reg_producer
	echo -e ""$bold""$kuning"\nSuccessfull reg as producer"
	sleep 2
fi
echo -e -n $continue
read
clear
break;;

"Create test token TASK II") # Create test token
clear
create_test_token(){

    cd $HOME
    rm -f token.wasm token.abi
    cline get code inery.token -c token.wasm -a token.abi --wasm
    if [[ -f /tmp/acclist ]]; then
        rm -rf /tmp/acclist > /dev/null
    fi
    echo -e "inery\ninery.token\njambul.inery" >/tmp/acclist
    tail -n 1000 $inerylog | grep "signed by" | awk '{printf "\n"$15}' | sed -e 's/2022-*.*//g;/^$/d' | tail -17 >> /tmp/acclist
    mapfile -t acc_list </tmp/acclist
    cline wallet unlock -n $IneryAccname --password $(cat $IneryAccname.txt)
    cline set code $IneryAccname token.wasm
    echo -e ""$kuning""$bold"Set code success$reset"
    sleep 0.5
    cline set abi $IneryAccname token.abi
    echo -e ""$kuning""$bold"Set abi success$reset"
    echo
    symbol_name=""$kuning""$bold"Set your token symbol: $reset"
    while read -p "$(printf "$symbol_name")" symbol; do
        if [[ ! $symbol =~ ^[A-Z]{1,7}$ ]]; then
            echo -e ""$kuning"Symbol only with 1-7 UPPERCASE"
	else
	    break
        fi
    done
while true; do
cline push action inery.token create '["'"$IneryAccname"'", "'"50000.0000 $symbol"'", "creating 50000 max supply"]' -p $IneryAccname
tx_confirmation=$(cline get currency stats inery.token $symbol | jq -r .$symbol.issuer)
    if [ ! $tx_confirmation = $IneryAccname ]; then
        printf "\n$kuning$bold Wait tx confirmation create token symbol $symbol$reset\n"
        sleep 1
    else
        printf "\n$kuning$bold Tx confirmed for create token $symbol$reset\n"
        break
    fi
done

while true; do
cline push action inery.token issue '["'"$IneryAccname"'", "'"10000.0000 $symbol"'", "issuing 1000 in circulating supply"]' -p $IneryAccname
tx_issue_confirmation=$(cline get currency stats inery.token $symbol | jq -r .$symbol.supply | awk '{printf $1}' | sed 's/\.0000//')
    if [ ! $tx_issue_confirmation = 10000 ]; then
        printf "\n$kuning$bold Wait tx confirmation issue supply token $symbol$reset\n"
        sleep 1
    else
        printf "\n$kuning$bold Tx confirmed for create token $symbol$reset\n"
        break
    fi
done
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[0]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[1]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[2]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[3]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[4]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[5]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[6]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[7]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[8]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[9]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[10]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[11]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[12]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[13]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[14]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[15]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[16]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[17]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[18]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
cline push action inery.token transfer '["'"$IneryAccname"'", "'"${acc_list[19]}"'", "'"1.0000 $symbol"'", "Here you go 10 from me 😁"]' -p $IneryAccname
            echo -e "Token succesfully transfered to ${#acc_list[*]} account"
            for list in ${!acc_list[*]}; do
	    printf "%4d: %s\n" $list ${acc_list[$list]}
	    done
}

cd $HOME
if [[ -d $HOME/inery-wallet && $IneryAccname && $IneryPubkey ]]; then
    create_test_token
    sleep 2
else
    echo -e ""$bold""$merah"No wallet in local machine found"$reset""
    echo -e ""$bold""$kuning"First create wallet and set as env vars"$reset""
    set_account_name
    set_pubkey
    set_privkey
    import_wallet
    create_test_token
    sleep 2
fi
echo -e -n $continue
read
clear
break;;

"Exit") clear; echo -e "$biru\t GOOD BY👋$reset"; sleep 1; exit;;

"Delete and uninstall node") # Full delete and uninstall
clear
cd ~/inery-node/inery.setup/master.node
./stop.sh
pnodine=$(pgrep nodine)
if [[ $pnodine ]]; then
    pkill -9 nodine
fi
./clean.sh
rm -rf $HOME/inery-*
rm -rf $HOME/$IneryAccname.txt
echo -e ""$bold""$kuning"Successfull stop and uninstall full node"$reset""
sleep 1
break;;

*) echo -e ""$bold""$merah"invalid option $REPLY $reset";;

esac
done
done
