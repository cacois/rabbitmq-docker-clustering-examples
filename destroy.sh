#!/bin/sh

docker rm -f rabbitmq1
docker rm -f rabbitmq2
docker rm -f rabbitmq3

docker network remove rabbit