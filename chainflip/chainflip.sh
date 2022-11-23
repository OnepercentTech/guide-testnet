#!/bin/bash
# Get logo
curl -s https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash
# Check root user
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "\e[31;1mAborting\e[m: Please run as root user!"
    sleep 1
    exit 1
else
    cd ~
fi

# Check port
if [[ $(lsof -i :8078,30333 | grep LISTEN) ]]; then
    echo -e "\e[31;1mAborting\e[m: Port 8078 and 30333 already in use!"
    sleep 1
    exit 1
fi

echo -e "\e[1;32m\tChainflip node validator installation with infura and alchemi api by jambulmerah\e[m"
sleep 2
# [1/7] update upgrade
clear
echo -e "\e[1;7;32m[1/7]: Update upgrade packages\e[m"
sleep 1
apt update >/dev/null 2>&1
DEBIAN_FRONTEND=noninteractive \
  apt-get upgrade \
  -o Dpkg::Options::=--force-confold \
  -o Dpkg::Options::=--force-confdef \
  -y --allow-downgrades --allow-remove-essential --allow-change-held-packages >/dev/null 2>&1
clear

# [2/7] install software
echo -e "\e[1;7;32m[2/7]: Installing software\e[m"
sleep 1
mkdir -p /etc/apt/keyrings >/dev/null 2>&1
curl -fsSL repo.chainflip.io/keys/gpg | gpg --dearmor -o /etc/apt/keyrings/chainflip.gpg >/dev/null 2>&1
gpg --show-keys /etc/apt/keyrings/chainflip.gpg >/dev/null 2>&1

echo "deb [signed-by=/etc/apt/keyrings/chainflip.gpg] https://repo.chainflip.io/perseverance/ focal main" | tee /etc/apt/sources.list.d/chainflip.list >/dev/null 2>&1
apt-get update >/dev/null 2>&1
apt-get install -y chainflip-cli chainflip-node chainflip-engine jq ufw curl >/dev/null 2>&1
  ver="1.19.3"
  wget "https://golang.org/dl/go$ver.linux-amd64.tar.gz" >/dev/null 2>&1
  rm -rf $(type go >/dev/null 2>&1)8
  sudo rm -rf /usr/local/go >/dev/null 2>&1
  sudo tar -C /usr/local -xzf "go$ver.linux-amd64.tar.gz" >/dev/null 2>&1
  rm "go$ver.linux-amd64.tar.gz" >/dev/null 2>&1
  echo "export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin" >> ~/.bash_profile
  echo "export GOROOT=/usr/local/go" >> ~/.bash_profile
  source ~/.bash_profile >/dev/null 2>&1
go install github.com/hashrocket/ws@latest > /dev/null 2>&1
clear

# [3/7] generating keys
echo -e "\e[1;7;32m[3/7]: Setting keys\e[m"
sleep 1
mkdir /etc/chainflip/keys >/dev/null 2>&1
echo -e "\e[1;32m1. Set validator key\e[m"
sleep 1
echo "=========================================================="
echo -e "\e[33;1mNOTE\e[0;32m: You must ensure that the public address administered by the private has at least 0.1 gETH. Make sure you send 0.1 gETH to this account's address before trying to stake\e[m"
echo "=========================================================="
enterpk="Enter your private key: "
while true; do
read -p "$(printf "$enterpk")" pk

if [ -n "$pk" ]; then
    if [ ${#pk} -eq 64 ];then
	echo -n $pk > /etc/chainflip/keys/ethereum_key_file
	break
    elif [ ${#pk} -eq 66 ] && ([ ${pk:0:2} == "0x" ] || [ ${pk:0:2} == "0X" ]);then
        echo -n ${pk:2:64} > /etc/chainflip/keys/ethereum_key_file
	break
    else
        echo -e "\e[31;1mERROR\e[0;32m: Private key format is not correct please enter private key with 66 bytes including 0x or 64 bytes without 0x\e[m"
	enterpk="Please enter your correct private key again: "
    fi
fi
done


# Set signing key
echo -e "\e[1;32m2. Set signing key\e[m"
sleep 1
while true; do
echo "A. Generate new signing key"
echo "B. Recover existing signing key"
echo -n "Select your option: "
read i
case $i in
[bB] ) recover_sign=true;;
[aA] ) recover_sign=false;;
* ) echo "Invalid option"; clear; continue;;
esac
while true; do
if [[ $recover_sign == "true" ]]; then
  read -p "Input your signing key: " sign_key
if [ -n "$sign_key" ]; then
    if [ ${#pk} -eq 64 ];then
        echo -n $pk > /etc/chainflip/keys/signing_key_file
        recover_sign_key=true
        break
    elif [ ${#pk} -eq 66 ] && ([ ${pk:0:2} == "0x" ] || [ ${pk:0:2} == "0X" ]);then
        echo -n ${pk:2:64} > /etc/chainflip/keys/signing_key_file
        recover_sign_key=true
        break
    else
        echo -e "\e[31;1mERROR\e[0;32m: Signing key format is not correct please enter private key with 66 bytes including 0x or 64 bytes without 0x\e[m"
        break
    fi
fi
else
  echo "Generating new signing key"
  sleep 1
  chainflip-node key generate --output-type json > validator_key.json
  cat validator_key.json | jq -r .secretSeed | sed -z 's/\n//g;s/0x//' > /etc/chainflip/keys/signing_key_file
  new_sign=true
  break
fi
done

if [[ -n $recover_sign_key || -n $new_sign ]]; then
  break
fi
done


# Set node key
echo -e "\e[1;32m3. Set node key\e[m"
sleep 1
while true; do
echo "A. Generate new node key"
echo "B. Recover existing node key"
echo -n "Select your option: "
read i
case $i in
[bB] ) recover_node=true;;
[aA] ) recover_node=false;;
* ) echo "Invalid option"; clear; continue;;
esac
while true; do
if [[ $recover_node == "true" ]]; then
  read -p "Input your node key: " node_key
if [ -n "$sign_key" ]; then
    if [ ${#pk} -eq 64 ];then
        echo -n $pk > /etc/chainflip/keys/node_key_file
        recover_node_key=true
        break
    elif [ ${#pk} -eq 66 ] && ([ ${pk:0:2} == "0x" ] || [ ${pk:0:2} == "0X" ]);then
        echo -n ${pk:2:64} > /etc/chainflip/keys/node_key_file
        recover_node_key=true
        break
    else
        echo -e "\e[31;1mERROR\e[0;32m: Node key format is not correct please enter private key with 66 bytes including 0x or 64 bytes without 0x\e[m"
        break
    fi
fi
else
  echo "Generating new node key"
  sleep 1
  chainflip-node key generate-node-key --file /etc/chainflip/keys/node_key_file >/dev/null 2>&1
  new_node=true
  break
fi
done

if [[ -n $recover_node_key || -n $new_node ]]; then
  break
fi
done


# [4/7] Set configuration file
echo -e "\e[1;7;32m[4/7]: Setting configuration file\e[m"
sleep 1
ufw allow ssh >/dev/null 2>&1
ufw limit ssh >/dev/null 2>&1
ufw allow 8078,30333/tcp >/dev/null 2>&1

mkdir -p /etc/chainflip/config >/dev/null 2>&1
wss="Enter your infura or alchemy api wss: "
while true; do
read -p "$(printf "$wss")" api_wss

if [[ $api_wss == "wss://goerli.infura.io" || "wss://eth-goerli.g.alchemy.com" ]]; then
    echo -e "\e[32mChecking websocket connection\e[m"
    sleep 1
    if [[ $(ws $api_wss 2>&1 < /dev/null) == "EOF" ]];then
        echo -e "\e[32mConnected to $api_wss\e[m"
	sleep 1
        break
    else
        echo -e "\e[31;1mERROR\e[0;32m: Can't connect to infura or alchemy api wss\e[m"
        wss="Please enter your correct infura or alchemy api wss: "
    fi
else
    echo -e "\e[31;1mERROR: \e[0;32mPlease enter your infura or alchemy api wss like wss://goerli.infura.io/v3/your_api_key\e[m"
    wss="Please enter your correct infura or alchemy api wss: "
fi
done
api_https=$(echo -n $api_wss | sed 's/wss/https/')
ip=$(curl -s ifconfig.me | tr -d "\n")

tee /etc/chainflip/config/Default.toml 2>&1 >/dev/null <<EOF
# Default configurations for the CFE
[node_p2p]
node_key_file = "/etc/chainflip/keys/node_key_file"
ip_address="$ip"
port = "8078"

[state_chain]
ws_endpoint = "ws://127.0.0.1:9944"
signing_key_file = "/etc/chainflip/keys/signing_key_file"

[eth]
# Ethereum RPC endpoints (websocket and http for redundancy).
ws_node_endpoint = "$api_wss"
http_node_endpoint = "$api_https"

# Ethereum private key file path. This file should contain a hex-encoded private key.
private_key_file = "/etc/chainflip/keys/ethereum_key_file"

[signing]
db_file = "/etc/chainflip/data.db"
EOF
clear

# [5/7] Start node
echo -e "\e[1;7;32m[5/7]: Start the node\e[m"
sleep 1
systemctl start chainflip-node >/dev/null 2>&1
clear

# [6/7] Cek node status
echo -e "\e[1;7;32m[6/7]: Check the chainflip node status\e[m"
sleep 1
if [[ `systemctl status chainflip-node | grep active` =~ "running" ]]; then
  echo -e "\e[32mYour chainflip node installed and running\e[m!"
else
  echo -e "\e[31;1mERROR\e[0;32mYour chainflip node was not installed correctly, please reinstall.\e[m"
  exit 1
fi
clear

# [7/7] Finished
curl -s https://raw.githubusercontent.com/jambulmerah/guide-testnet/main/script/logo.sh | bash
echo -e "\e[1;7;32m[7/7]: FINISHED \e[m"
sleep 1
echo "================================================="
echo -e "\e[32mYour ethereum validator key in: \e[1m/etc/chainflip/keys/ethereum_key_file\e[m"
echo -e "\e[32mYour signing key in: \e[1m/etc/chainflip/keys/signing_key_file\e[m"
echo -e "\e[32mYour node key in: \e[1m/etc/chainflip/keys/node_key_file\e[m"
echo -e "\e[32mYour signing key fully information in: \e[1m/root/validator_key.json\e[m"
echo -e "\e[1;7;32mPlease copy and backup all\e[m"
echo "================================================="
