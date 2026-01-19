#!/bin/bash

# Start ssh server (optional, but good for debugging)
service ssh start

# Inject Hostname if provided (Fixes Docker-on-Mac NAT issues)
if [ ! -z "$SLAVE_HOSTNAME" ]; then
    echo "Forcing announced hostname to: $SLAVE_HOSTNAME"
    CONF_FILE=$HADOOP_HOME/etc/hadoop/hdfs-site.xml
    # Remove closing tag
    sed -i "/<\/configuration>/d" $CONF_FILE
    # Append property
    echo "    <property>" >> $CONF_FILE
    echo "        <name>dfs.datanode.hostname</name>" >> $CONF_FILE
    echo "        <value>$SLAVE_HOSTNAME</value>" >> $CONF_FILE
    echo "    </property>" >> $CONF_FILE
    # Restore closing tag
    echo "</configuration>" >> $CONF_FILE
fi

echo "Starting DataNode..."
mkdir -p $HADOOP_HOME/logs
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
