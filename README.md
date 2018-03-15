# RabbitMQ Clustering Examples

Clustering can be hard. Here's a small example of a RabbitMQ cluster in a local, isolated environment to help you understand the process.

For the quick demo, run the following commands:

    $ ./setup.sh
    <wait 5-10 seconds for the nodes to fully initialize...>
    $ ./cluster.sh
    Stopping rabbit application on node rabbitmq2@rabbitmq2 ...
    Clustering node rabbitmq2@rabbitmq2 with rabbitmq1@rabbitmq1
    Starting node rabbitmq2@rabbitmq2 ...
    completed with 3 plugins.
    Stopping rabbit application on node rabbitmq3@rabbitmq3 ...
    Clustering node rabbitmq3@rabbitmq3 with rabbitmq1@rabbitmq1
    Starting node rabbitmq3@rabbitmq3 ...
    completed with 3 plugins.
    Cluster status of node rabbitmq1@rabbitmq1 ...
    [{nodes,[{disc,[rabbitmq1@rabbitmq1,rabbitmq2@rabbitmq2,
                    rabbitmq3@rabbitmq3]}]},
    {running_nodes,[rabbitmq3@rabbitmq3,rabbitmq2@rabbitmq2,rabbitmq1@rabbitmq1]},
    {cluster_name,<<"rabbitmq1@rabbitmq1">>},
    {partitions,[]},
    {alarms,[{rabbitmq3@rabbitmq3,[]},
            {rabbitmq2@rabbitmq2,[]},
            {rabbitmq1@rabbitmq1,[]}]}]

We're using rabbitmqctl to run the clustering comands, which must be run on the containers. Hence, we're issuing a series of commands into the comtainer shells using `docker exec`. The last command prints out the status of the cluster, as you see in the above output. 

To tear everything down again, run:

    $ ./destroy

## Testing your cluster

First, to see if your cluster is setup, check its status on any node:

    $ docker exec -it rabbitmq2 rabbitmqctl cluster_status
    Cluster status of node rabbitmq1@rabbitmq1 ...
    [{nodes,[{disc,[rabbitmq1@rabbitmq1,rabbitmq2@rabbitmq2,
                    rabbitmq3@rabbitmq3]}]},
    {running_nodes,[rabbitmq3@rabbitmq3,rabbitmq2@rabbitmq2,rabbitmq1@rabbitmq1]},
    {cluster_name,<<"rabbitmq1@rabbitmq1">>},
    {partitions,[]},
    {alarms,[{rabbitmq3@rabbitmq3,[]},
            {rabbitmq2@rabbitmq2,[]},
            {rabbitmq1@rabbitmq1,[]}]}]

You should see the above output. `nodes` represents the list of nodes that are known to RabbitMQ as part of the cluster. This shows what nodes are known, but not what nodes are connected. `running_nodes` represents the list of nodes actually connected to the cluster and communicating. This is the really important bit.

At this point, if you add a message, you will see it replicated across all three cluster nodes. But you aren't done yet! Your cluster is not really complete until you verify that you can shut down a node and have it automatically reconnect when it comes back up. Until you see this happen, don't assume your cluster is ready. Let's try it:

    $ docker stop rabbitmq2

Now check membership again:

    $ docker exec -it rabbitmq1 rabbitmqctl cluster_status
    Cluster status of node rabbitmq1@rabbitmq1 ...
    [{nodes,[{disc,[rabbitmq1@rabbitmq1,rabbitmq2@rabbitmq2,
                    rabbitmq3@rabbitmq3]}]},
    {running_nodes,[rabbitmq3@rabbitmq3,rabbitmq1@rabbitmq1]},
    {cluster_name,<<"rabbitmq1@rabbitmq1">>},
    {partitions,[]},
    {alarms,[{rabbitmq3@rabbitmq3,[]},{rabbitmq1@rabbitmq1,[]}]}]

Notice that `running_nodes` does not include rabbitmq2. Now, if things are set up right, it will rejoin the cluster when we start up the container:

    $ docker start rabbitmq2

Wait a few seconds for it to connect...

    $ docker exec -it rabbitmq1 rabbitmqctl cluster_status
    Cluster status of node rabbitmq1@rabbitmq1 ...
    [{nodes,[{disc,[rabbitmq1@rabbitmq1,rabbitmq2@rabbitmq2,
                    rabbitmq3@rabbitmq3]}]},
    {running_nodes,[rabbitmq3@rabbitmq3,rabbitmq1@rabbitmq1]},
    {cluster_name,<<"rabbitmq1@rabbitmq1">>},
    {partitions,[]},
    {alarms,[{rabbitmq3@rabbitmq3,[]},{rabbitmq1@rabbitmq1,[]}]}]

Now you can be confident. 

## Secrets of the erlang cookie

The shared erlang cookie is the key to making a cluster resilient to nodes leaving and reconnecting. Without it, your cluster will form and look good, but nodes will not reconnect after disconnection. This is bad. Luckily, the official RabbitMQ Docker image makes this really easy by providing the `RABBITMQ_ERLANG_COOKIE` environment variable.
