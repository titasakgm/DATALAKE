#!/usr/bin/ruby

# RUN this script every 01:00 via nodered

dow = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat']
yesterday = Time.now - 24*60*60
wday = yesterday.wday
path = "/data/backup/#{dow[wday]}"

cmd = "mongodump -h mongodb -u backup -p datalake \
--authenticationDatabase admin \
--authenticationMechanism SCRAM-SHA-256 \
-d trang -o #{path}"

system("docker exec mongodb #{cmd}")
