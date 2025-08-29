judge1 -3
+gQEcJRHavqSxuA/pbFOSFa3T2QEqJZ1ANh0BV/Mlb7RlrRr7FqYqRCvMmgNnLX36wQPIswhilHG9qHwqWFrf4UimD3gE7Jdcdxp

0qr2jDQ/QdlsrR+RpnxGDHTIuxc0acILmvs3H7ZdhFI2gTtZfuQ5HLXNBfqoEexvyDQjzeM3KePjS+c6hVoo+0fWP4s/16booNJx

judge2 -1
kW0mPImRzzVXDEfv6uONDDWIzA36rp+P7xsvu+y50yjQoDuwIyvQkJS0ZX/6WfZOStsDJu/+rNJgdQjcSHFyyAgPsHCPY1bA0Lv9

judge3 -2
X3Go8Kr1slWyhNj6IdrZjbu0FDNzEPxZdnDUjMXeqoMWu70wvykNQ91sImtb+lR5JEDrWNkdyknjLtiAQ5iI4PQqWPGqm9FZZdQN

make judge-tier1
make judge-tier2
make judge-tier3


160.250.247.89/24

docker run \
    --name judge \
    -p "$(ip addr show dev ens34 | perl -ne 'm@inet (.*)/.*@ and print$1 and exit')":9997:9997 \
    -v /home/an/dmoj-docker/dmoj/problems:/problems \
    --cap-add=SYS_PTRACE \
    -d \
    --restart=always \
    dmoj/judge-tier3:latest \
    run -p "9999" -c /problems/judge1.yml \
    "10.10.240.37" "judge1" "+gQEcJRHavqSxuA/pbFOSFa3T2QEqJZ1ANh0BV/Mlb7RlrRr7FqYqRCvMmgNnLX36wQPIswhilHG9qHwqWFrf4UimD3gE7Jdcdxp"


docker run \
    --name judge \
    -p "$(ip addr show dev ens34 | perl -ne 'm@inet (.*)/.*@ and print$1 and exit')":9997:9997 \
    -v /home/an/dmoj-docker/dmoj/problems:/problems \
    --cap-add=SYS_PTRACE \
    -d \
    --restart=always \
    dmoj/judge-tier3:latest \
    run -p "9999" -c /problems/judge.yml \
    "10.10.240.37" "judge1" "+gQEcJRHavqSxuA/pbFOSFa3T2QEqJZ1ANh0BV/Mlb7RlrRr7FqYqRCvMmgNnLX36wQPIswhilHG9qHwqWFrf4UimD3gE7Jdcdxp"


docker run \
    --name judge1 \
    -p "$(ip addr show dev ens160 | perl -ne 'm@inet (.*)/.*@ and print$1 and exit')":9996:9996 \
    -v /root/dmoj-docker/dmoj/problems:/problems \
    --cap-add=SYS_PTRACE \
    -d \
    --restart=always \
    dmoj/judge-tier1:latest \
    run -p "9999" -c /problems/judge.yml \
    "160.250.247.89" "judge1" "h3lzSgdcbTEcp0OEzYGWhS8TkRQjl+K2kZWlPhPt7FWMQ7L0heV+mMBqsf8t2W0hsvDCBGErpIl9lwE8rgZMxo1tG3pvBFXHJhYK"

    
h3lzSgdcbTEcp0OEzYGWhS8TkRQjl+K2kZWlPhPt7FWMQ7L0heV+mMBqsf8t2W0hsvDCBGErpIl9lwE8rgZMxo1tG3pvBFXHJhYK

