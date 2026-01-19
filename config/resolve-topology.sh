#!/bin/bash
# Topology script to force disparate rack placement for Docker-on-Mac slaves
# preventing "Same IP" collision issues.

while [ $# -gt 0 ] ; do
  nodeArg=$1
  shift

  # default rack
  rack="/default-rack"

  if [[ "$nodeArg" == *"hadoop-slave1"* ]]; then
    rack="/rack1"
  elif [[ "$nodeArg" == *"hadoop-slave2"* ]]; then
    rack="/rack2"
  elif [[ "$nodeArg" == *"hadoop-master"* ]]; then
    rack="/rack0"
  fi

  echo $rack
done
