#!/bin/bash

# Start ssh server
service ssh start

# If ENV_DATANODE_HOSTNAME is not set, default to hostname
if [ -z "$ENV_DATANODE_HOSTNAME" ]; then
    export ENV_DATANODE_HOSTNAME=$(hostname)
fi
echo "Using DataNode Hostname: $ENV_DATANODE_HOSTNAME"

# CRITICAL: Wipe DataNode identity to prevent StorageID collisions with cloned slaves
echo "Wiping old DataNode storage to ensure unique ID..."
rm -rf /root/hdfs/datanode/*

# Set default ports if not provided
DN_PORT=${ENV_DATANODE_PORT:-50010}
DN_IPC_PORT=${ENV_DATANODE_IPC_PORT:-50020}
DN_HTTP_PORT=${ENV_DATANODE_HTTP_PORT:-50075}
echo "Using Ports -> Transfer: $DN_PORT, IPC: $DN_IPC_PORT, HTTP: $DN_HTTP_PORT"

# Inject settings into hdfs-site.xml manually because Hadoop 2.7.2 does not support env var substitution in XML
CONF_FILE=$HADOOP_HOME/etc/hadoop/hdfs-site.xml
if ! grep -q "dfs.datanode.hostname" $CONF_FILE; then
    echo "Injecting dfs.datanode.hostname and ports into config..."
    sed -i "/<\/configuration>/d" $CONF_FILE
    
    echo "    <property>" >> $CONF_FILE
    echo "        <name>dfs.datanode.hostname</name>" >> $CONF_FILE
    echo "        <value>$ENV_DATANODE_HOSTNAME</value>" >> $CONF_FILE
    echo "    </property>" >> $CONF_FILE

    echo "    <property>" >> $CONF_FILE
    echo "        <name>dfs.datanode.address</name>" >> $CONF_FILE
    echo "        <value>0.0.0.0:$DN_PORT</value>" >> $CONF_FILE
    echo "    </property>" >> $CONF_FILE

    echo "    <property>" >> $CONF_FILE
    echo "        <name>dfs.datanode.ipc.address</name>" >> $CONF_FILE
    echo "        <value>0.0.0.0:$DN_IPC_PORT</value>" >> $CONF_FILE
    echo "    </property>" >> $CONF_FILE

    echo "    <property>" >> $CONF_FILE
    echo "        <name>dfs.datanode.http.address</name>" >> $CONF_FILE
    echo "        <value>0.0.0.0:$DN_HTTP_PORT</value>" >> $CONF_FILE
    echo "    </property>" >> $CONF_FILE

    echo "</configuration>" >> $CONF_FILE
fi


# Start NodeManager (YARN) in background
echo "Starting NodeManager..."
$HADOOP_HOME/sbin/yarn-daemon.sh start nodemanager

# Start DataNode (HDFS) in FOREGROUND to keep container alive and show logs
echo "Starting DataNode (Foreground)..."
$HADOOP_HOME/bin/hdfs datanode
