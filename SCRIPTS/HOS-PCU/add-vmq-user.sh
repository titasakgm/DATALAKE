#!/bin/bash

USER=$1

docker exec -uroot -it vmq0 vmq-passwd /etc/vernemq/vmq.passwd ${USER}

