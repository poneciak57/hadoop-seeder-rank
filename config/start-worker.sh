#!/bin/bash

# Start ssh server
service ssh start

# If ENV_DATANODE_HOSTNAME is not set, default to hostname
if [ -z "$ENV_DATANODE_HOSTNAME" ]; then
    export ENV_DATANODE_HOSTNAME=$(hostname)
fi
echo "Using DataNode Hostname: $ENV_DATANODE_HOSTNAME"

# Start NodeManager (YARN) in background
echo "Starting NodeManager..."
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

# Start DataNode (HDFS) in FOREGROUND to keep container alive and show logs
echo "Starting DataNode (Foreground)..."
$HADOOP_HOME/bin/hdfs datanode
