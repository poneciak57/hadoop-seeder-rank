#!/bin/bash

# Start ssh server
service ssh start

echo -e "\n"

$HADOOP_HOME/sbin/start-dfs.sh

echo -e "\n"

$HADOOP_HOME/sbin/start-yarn.sh

echo -e "\n"

# Keep the container running
tail -f /dev/null

