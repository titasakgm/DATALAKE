#!/bin/bash

if [ "$(docker ps -q -f name=portainer)" ]; then
   # cleanup
   docker stop $(docker ps -aq)
   docker rm $(docker ps -aq)
fi

# run your container
cd /opt/TRANG/HOS-PCU
docker-compose down
docker-compose up -d

docker run --name portainer \
-p 9000:9000 \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /opt/VOLUMES/portainer_data/:/data \
-d portainer/portainer
