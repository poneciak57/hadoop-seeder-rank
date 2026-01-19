#!/bin/bash

# Start ssh server (optional, but good for debugging)
service ssh start

echo "Starting DataNode..."
$HADOOP_HOME/sbin/hadoop-daemon.sh start datanode

echo "Starting NodeManager..."
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

echo "Waiting for logs..."
sleep 5
ls -l $HADOOP_HOME/logs/

echo "Worker services started. Tailing logs..."
# Find the latest datanode log file
LOG_FILE=$(find $HADOOP_HOME/logs -name "hadoop-root-datanode*.log" | head -n 1)

if [ -z "$LOG_FILE" ]; then
    echo "Error: Could not find DataNode log file. DataNode might have failed to start."
    echo "Checking .out files..."
    cat $HADOOP_HOME/logs/*.out
else
    tail -f "$LOG_FILE"
fi
