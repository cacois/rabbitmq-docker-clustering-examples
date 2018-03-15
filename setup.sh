#!/bin/sh

# TODO: Check what ports are exposed in the containers
docker network create --driver bridge rabbit

docker run -d --name rabbitmq1 \
 --net=rabbit \
 --expose=4369 \
 --hostname=rabbitmq1 \
 -p 15672:15672 \
 -p 15671:15671 \
 -e RABBITMQ_NODENAME=rabbitmq1 \
 -e RABBITMQ_DEFAULT_USER=admin \
 -e RABBITMQ_DEFAULT_PASS=admin \
 -e RABBITMQ_ERLANG_COOKIE=monster \
rabbitmq:3-management

docker run -d --name rabbitmq2 \
 --net=rabbit \
 --expose=4369 \
 --hostname=rabbitmq2 \
 -p 25672:15672 \
 -e RABBITMQ_NODENAME=rabbitmq2 \
 -e RABBITMQ_DEFAULT_USER=admin \
 -e RABBITMQ_DEFAULT_PASS=admin \
 -e RABBITMQ_ERLANG_COOKIE=monster \
rabbitmq:3-management 

docker run -d --name rabbitmq3 \
 --net=rabbit \
 --expose=4369 \
 --hostname=rabbitmq3 \
 -p 35672:15672 \
 -e RABBITMQ_NODENAME=rabbitmq3 \
 -e RABBITMQ_DEFAULT_USER=admin \
 -e RABBITMQ_DEFAULT_PASS=admin \
 -e RABBITMQ_ERLANG_COOKIE=monster \
rabbitmq:3-management 
