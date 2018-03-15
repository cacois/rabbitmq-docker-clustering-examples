#!/bin/sh

# cluster rabbitmq.two
docker exec -it rabbitmq2 rabbitmqctl stop_app
docker exec -it rabbitmq2 rabbitmqctl join_cluster rabbitmq1@rabbitmq1
docker exec -it rabbitmq2 rabbitmqctl start_app

# cluster rabbitmq.three
docker exec -it rabbitmq3 rabbitmqctl stop_app
docker exec -it rabbitmq3 rabbitmqctl join_cluster rabbitmq1@rabbitmq1
docker exec -it rabbitmq3 rabbitmqctl start_app

# check cluster status
docker exec -it rabbitmq1 rabbitmqctl cluster_status