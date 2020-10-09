#!/bin/bash

cd /opt/TRANG/HOS-PCU
docker-compose down
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
