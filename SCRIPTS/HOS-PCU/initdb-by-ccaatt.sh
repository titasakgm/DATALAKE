#!/bin/bash

CC=$1

echo "{\"ccaattmm\": {\"\$gt\": \"${CC}000000\"},\"ccaattmm\": {\"\$lt\": \"${CC}999999\"}})" > query.json

mongodump --host ssj92 --port 27017 --username backup --password datalake \
--authenticationDatabase admin \
--db trang --collection people \
--queryFile query.json --out /tmp/${CC}

mongodump --host ssj92 --port 27017 --username backup --password datalake \
--authenticationDatabase admin \
--db trang --collection phr \
--queryFile query.json --out /tmp/${CC}

mongodump --host ssj92 --port 27017 --username backup --password datalake \
--authenticationDatabase admin \
--db trang --collection alt_hashes \
--queryFile query.json --out /tmp/${CC}

# reset mongodb:trang
./reset-mongodb.rb

mongorestore --host mongodb --port 27017 --username admin --password datalake \
--authenticationDatabase admin \
--nsInclude=trang.people /tmp/${CC}/trang/people.bson

mongorestore --host mongodb --port 27017 --username admin --password datalake \
--authenticationDatabase admin \
--nsInclude=trang.phr /tmp/${CC}/trang/phr.bson

mongorestore --host mongodb --port 27017 --username admin --password datalake \
--authenticationDatabase admin \
--nsInclude=trang.alt_hashes /tmp/${CC}/trang/alt_hashes.bson

# delete query.json
rm -rf query.json
