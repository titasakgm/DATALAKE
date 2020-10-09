#!/bin/bash

echo "Please input CCAATTMM:"
read catm

echo "Please input Office Type:  [dho hos pcu]"
read otype

echo "Please input Office Type:  [dho hos pcu]"
export user="${otype}-${catm}"

echo "Please input HosXP IP Address:  [A.B.C.D]"
read db_ip

echo "Please input HosXP Port:  [3306]"
read db_port

echo "Please input HosXP Database Name:"
read db_name

# extract hos-pcu-flow.tar.gz
echo "Install nodered flows"
rm -rf /opt/VOLUMES/nodered_data
tar -C /opt/VOLUMES -xzvf hos-pcu-flow.tar.gz
chmod 777 -R /opt/VOLUMES/nodered_data

# replace XCAT#X and XCATX with actual CC/AA/TT
echo "Replace CCAATTMM for your organization"
export cc=${catm:0:2}
export aa=${catm:2:2}
export tt=${catm:4:2}

# replace MQTT topic
export src="XCAT#X"

if [ ${#catm} -eq 6 ]; then
  start-hos-pcu.sh
  export dst="${cc}/${aa}/${tt}/#"
else
  start-hos-pcu.sh
  export dst="${cc}/${aa}/#"
fi
sed -i "s~$src~$dst~g" /opt/VOLUMES/nodered_data/flows.json

export src="XCATX"

if [ ${#catm} -eq 6 ]; then
  export dst="${cc}/${aa}/${tt}"
else
  export dst="${cc}/${aa}"
fi
sed -i "s~$src~$dst~g" /opt/VOLUMES/nodered_data/flows.json

# replace UUUU with $user
echo "Replace user:${user} for MQTT"
sed -i "s~UUUU~$user~g" /opt/VOLUMES/nodered_data/flows.json
sed -i "s~UUUU~$user~g" ./request-mqtt-user.rb

# replace DB_IP with $db_ip
echo "Replace HosXP IP: ${db_ip} for nodered"
sed -i "s~DB_IP~$db_ip~g" /opt/VOLUMES/nodered_data/flows.json

# replace DB_PORT with $db_port
echo "Replace HosXP Port: ${db_port} for nodered"
sed -i "s~DB_PORT~$db_port~g" /opt/VOLUMES/nodered_data/flows.json

# replace DB_NAME with $db_name
echo "Replace HosXP Database Name: ${db_name} for nodered"
sed -i "s~DB_NAME~$db_name~g" /opt/VOLUMES/nodered_data/flows.json

# change mode to world read/write
chmod 777 -R /opt/VOLUMES/nodered_data

# import mongodb from SSJ92 using ${catm}
echo "Initialize mongodb for your organization"
chmod +x /opt/SCRIPTS/HOS-PCU/*
docker exec mongodb /opt/SCRIPTS/initdb-by-ccaatt.sh ${catm}

# send mqtt user request to SSJ92
./request-mqtt-user.rb

echo
echo "Finish customization"
echo
echo "Please inform SSJ92 to add user:${user} to access MQTT!!!"
echo
