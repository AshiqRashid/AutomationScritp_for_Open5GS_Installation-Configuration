#!/bin/bash


sudo apt update -y
 
sudo apt install curl -y

sudo apt-get install gnupg -y

curl -fsSL https://pgp.mongodb.com/server-6.0.asc | \
   sudo gpg -o /usr/share/keyrings/mongodb-server-6.0.gpg \
   --dearmor

echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-6.0.gpg ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

sudo apt-get update -y

sudo apt-get install -y mongodb-org

echo "mongodb-org hold" | sudo dpkg --set-selections
echo "mongodb-org-database hold" | sudo dpkg --set-selections
echo "mongodb-org-server hold" | sudo dpkg --set-selections
echo "mongodb-mongosh hold" | sudo dpkg --set-selections
echo "mongodb-org-mongos hold" | sudo dpkg --set-selections
echo "mongodb-org-tools hold" | sudo dpkg --set-selections


sudo systemctl enable mongod
sudo systemctl start mongod

sudo ip tuntap add name ogstun mode tun
sudo ip addr add 10.45.0.1/16 dev ogstun
sudo ip addr add 2001:db8:cafe::1/48 dev ogstun
sudo ip link set ogstun up


sudo add-apt-repository ppa:open5gs/latest
sudo apt update -y

sudo apt install open5gs -y


sudo sysctl -w net.ipv4.ip_forward=1
sudo sysctl -w net.ipv6.conf.all.forwarding=1
sudo iptables -t nat -A POSTROUTING -s 10.45.0.0/16 ! -o ogstun -j MASQUERADE
sudo ip6tables -t nat -A POSTROUTING -s 2001:db8:cafe::/48 ! -o ogstun -j MASQUERADE


cd /etc/open5gs/

sudo cat <<EOF > shortcut.sh
sudo systemctl \$1 open5gs-mmed
sudo systemctl \$1 open5gs-sgwcd
sudo systemctl \$1 open5gs-smfd
sudo systemctl \$1 open5gs-amfd
sudo systemctl \$1 open5gs-sgwud
sudo systemctl \$1 open5gs-upfd
sudo systemctl \$1 open5gs-hssd
sudo systemctl \$1 open5gs-pcrfd
sudo systemctl \$1 open5gs-nrfd
sudo systemctl \$1 open5gs-scpd
sudo systemctl \$1 open5gs-ausfd
sudo systemctl \$1 open5gs-udmd
sudo systemctl \$1 open5gs-pcfd
sudo systemctl \$1 open5gs-nssfd
sudo systemctl \$1 open5gs-bsfd
sudo systemctl \$1 open5gs-udrd
#sudo systemctl \$1 open5gs-webui

EOF

sudo chmod +x shortcut.sh

sudo bash /etc/open5gs/shortcut.sh restart
sudo bash /etc/open5gs/shortcut.sh status


cd /etc/open5gs


sudo cp mme.yaml mme.backup

cat <<EOF > mme.yaml
logger:
    file: /var/log/open5gs/mme.log
mme:
    freeDiameter: /etc/freeDiameter/mme.conf
    s1ap:
      - addr: MACHINE_IP
    gtpc:
      - addr: 127.0.0.2
    metrics:
      - addr: 127.0.0.2
        port: 9090
    gummei:
      plmn_id:
        mcc: M_C_C
        mnc: M_N_C
      mme_gid: 2
      mme_code: 1
    tai:
      plmn_id:
        mcc: M_C_C
        mnc: M_N_C
      tac: T_A_C
    security:
        integrity_order : [ EIA2, EIA1, EIA0 ]
        ciphering_order : [ EEA0, EEA1, EEA2 ]
    network_name:
        full: Open5GS
    mme_name: open5gs-mme0
sgwc:
    gtpc:
      - addr: 127.0.0.3
smf:
    gtpc:
      - addr:
        - 127.0.0.4
        - ::1
parameter:

max:

usrsctp:

time:


EOF


sudo cp sgwu.yaml sgwu.backup

cat <<EOF > sgwu.yaml
logger:
    file: /var/log/open5gs/sgwu.log
sgwu:
    pfcp:
      - addr: 127.0.0.6
    gtpu:
      - addr: MACHINE_IP
sgwc:
parameter:
max:
time:

EOF

source /home/vagrant/.env

find /etc/open5gs/ -type f -exec sudo sed -i "s/MACHINE_IP/$MACHINE_IP/g" {} +
find /etc/open5gs/ -type f -exec sudo sed -i "s/M_C_C/$M_C_C/g" {} +
find /etc/open5gs/ -type f -exec sudo sed -i "s/M_N_C/$M_N_C/g" {} +
find /etc/open5gs/ -type f -exec sudo sed -i "s/T_A_C/$T_A_C/g" {} +

cd /etc/opne5gs/
sudo bash shortcut.sh restart
sudo bash shortcut.sh status

