#!/bin/bash

# N is the node number of hadoop cluster
N=$1

if [ $# = 0 ]
then
	echo "Please specify the node number of hadoop cluster!"
	exit 1
fi

# change slaves file
i=1
rm config/slaves
echo "services:" > docker-compose.slaves.yaml

while [ $i -lt $N ]
do
	echo "hadoop-slave$i" >> config/slaves
	
	# Add slave to docker-compose.slaves.yaml
	echo "  hadoop-slave$i:" >> docker-compose.slaves.yaml
	echo "    build:" >> docker-compose.slaves.yaml
  echo "      context: ." >> docker-compose.slaves.yaml
	echo "    image: kiwenlau/hadoop:1.0" >> docker-compose.slaves.yaml
	echo "    container_name: hadoop-slave$i" >> docker-compose.slaves.yaml
	echo "    hostname: hadoop-slave$i" >> docker-compose.slaves.yaml
	echo "    networks:" >> docker-compose.slaves.yaml
	echo "      - hadoop" >> docker-compose.slaves.yaml
	echo "    tty: true" >> docker-compose.slaves.yaml
	echo "    stdin_open: true" >> docker-compose.slaves.yaml
	
	((i++))
done 

echo ""

echo "Cluster resized. Run 'docker compose up -d' to start the new containers."

