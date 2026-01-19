#!/bin/bash

# Start ssh server (optional, but good for debugging)
service ssh start

echo "Starting DataNode..."
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

echo "Starting NodeManager..."
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

echo "Worker services started. Tailing logs..."
# Keep container alive and show logs
tail -f $HADOOP_HOME/logs/hadoop-root-datanode*.log
