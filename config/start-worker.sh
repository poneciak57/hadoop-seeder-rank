#!/bin/bash

# Start ssh server
service ssh start

# If ENV_DATANODE_HOSTNAME is not set, default to hostname
if [ -z "$ENV_DATANODE_HOSTNAME" ]; then
    export ENV_DATANODE_HOSTNAME=$(hostname)
fi
echo "Using DataNode Hostname: $ENV_DATANODE_HOSTNAME"

# Inject hostname into hdfs-site.xml manually because Hadoop 2.7.2 does not support env var substitution in XML
CONF_FILE=$HADOOP_HOME/etc/hadoop/hdfs-site.xml
if ! grep -q "dfs.datanode.hostname" $CONF_FILE; then
    echo "Injecting dfs.datanode.hostname into config..."
    sed -i "/<\/configuration>/d" $CONF_FILE
    echo "    <property>" >> $CONF_FILE
    echo "        <name>dfs.datanode.hostname</name>" >> $CONF_FILE
    echo "        <value>$ENV_DATANODE_HOSTNAME</value>" >> $CONF_FILE
    echo "    </property>" >> $CONF_FILE
    echo "</configuration>" >> $CONF_FILE
fi

# Start NodeManager (YARN) in background
echo "Starting NodeManager..."
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

# Start DataNode (HDFS) in FOREGROUND to keep container alive and show logs
echo "Starting DataNode (Foreground)..."
$HADOOP_HOME/bin/hdfs datanode
