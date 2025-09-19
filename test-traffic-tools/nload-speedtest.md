### Tools test traffic
```
Tai nload tai cac node network

apt install nload

Tai may ao, tai speedtest ve 

sudo apt-get install curl

curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash

sudo nano /etc/apt/sources.list.d/ookla_speedtest-cli.list

sudo apt update

sudo apt-get install speedtest

chay lenh nload 
chay lenh speedtest -s 2552


ip netns list     
ip a | grep tap 
tcpdump -i tap<id> icmp -n

Do bang phan mem iperf3
```