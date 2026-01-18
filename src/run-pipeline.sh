#!/bin/bash

# Configuration variables
HADOOP_STREAMING_JAR=$HADOOP_HOME/share/hadoop/tools/lib/hadoop-streaming-2.7.2.jar

# Compile C++ files
echo "Compiling C++ files..."
g++ -O3 -std=c++11 -o ./bin/mapper mapper.cpp
g++ -O3 -std=c++11 -o ./bin/reducer reducer.cpp
g++ -O3 -std=c++11 -o ./bin/mapper_sort mapper_sort.cpp
g++ -O3 -std=c++11 -o ./bin/reducer_sort reducer_sort.cpp

if [ ! -f ./bin/mapper ] || [ ! -f ./bin/reducer ] || [ ! -f ./bin/mapper_sort ] || [ ! -f ./bin/reducer_sort ]; then
    echo "Compilation failed. Ensure g++ is installed."
    exit 1
fi
echo "Compilation successful."

# Setup HDFS binaries
NAMENODE=$(hdfs getconf -confKey fs.defaultFS)
NAMENODE=${NAMENODE%/}
HDFS_BIN_DIR="/user/$(whoami)/bin-cpp"
HDFS_BIN_URI="${NAMENODE}${HDFS_BIN_DIR}"

echo "Uploading binaries to HDFS ($HDFS_BIN_URI)..."
hdfs dfs -mkdir -p $HDFS_BIN_DIR
hdfs dfs -put -f ./bin/mapper $HDFS_BIN_DIR/
hdfs dfs -put -f ./bin/reducer $HDFS_BIN_DIR/
hdfs dfs -put -f ./bin/mapper_sort $HDFS_BIN_DIR/
hdfs dfs -put -f ./bin/reducer_sort $HDFS_BIN_DIR/

# Configuration with command line arguments (defaults if not provided)
# Usage: ./run-pipeline-cpp.sh [Job1_Reducers] [Job2_Reducers] [HDFS_Input_Path]

JOB1_REDUCERS=${1:-3}
JOB1_MAPPERS=${2:-3}
JOB2_REDUCERS=1
JOB2_MAPPERS=1
DATA_PATH=${3:-"input/data.csv"} # Local input data path
JOB1_INPUT="input/data.csv" # HDFS input path


JOB1_OUTPUT="output_intermediate_cpp"
JOB2_INPUT=$JOB1_OUTPUT
JOB2_OUTPUT="output_final_cpp"

echo "------------------------------------------------"
echo "Pipeline Configuration"
echo "Job 1 Reducers: $JOB1_REDUCERS"
echo "Job 2 Reducers: $JOB2_REDUCERS"
echo "Input Path:     $JOB1_INPUT"
echo "------------------------------------------------"

# Cleanup previous runs
echo "Cleaning up HDFS..."
hdfs dfs -rm -r -f $JOB1_INPUT
hdfs dfs -rm -r -f $JOB1_OUTPUT
hdfs dfs -rm -r -f $JOB2_OUTPUT

# Upload input data to HDFS
hdfs dfs -mkdir -p $(dirname $JOB1_INPUT)
hdfs dfs -put $DATA_PATH $JOB1_INPUT

echo "------------------------------------------------"
echo "Starting Job 1: Aggregation (Sum bytes per IP) [C++]"
echo "------------------------------------------------"

hadoop jar $HADOOP_STREAMING_JAR \
    -D mapreduce.job.reduces=$JOB1_REDUCERS \
    -D mapreduce.job.maps=$JOB1_MAPPERS \
    -files "${HDFS_BIN_URI}/mapper,${HDFS_BIN_URI}/reducer" \
    -mapper "./mapper" \
    -reducer "./reducer" \
    -input $JOB1_INPUT \
    -output $JOB1_OUTPUT

if [ $? -ne 0 ]; then
    echo "Job 1 failed!"
    exit 1
fi

echo "------------------------------------------------"
echo "Starting Job 2: Sorting (Rank by Bytes) [C++]"
echo "------------------------------------------------"

hadoop jar $HADOOP_STREAMING_JAR \
    -D mapreduce.job.reduces=$JOB2_REDUCERS \
    -D mapreduce.job.maps=$JOB2_MAPPERS \
    -files "${HDFS_BIN_URI}/mapper_sort,${HDFS_BIN_URI}/reducer_sort" \
    -mapper "./mapper_sort" \
    -reducer "./reducer_sort" \
    -input $JOB2_INPUT \
    -output $JOB2_OUTPUT

if [ $? -ne 0 ]; then
    echo "Job 2 failed!"
    exit 1
fi

echo "------------------------------------------------"
echo "Pipeline Finished Successfully."
echo "Here are the top 10 results:"
hdfs dfs -cat $JOB2_OUTPUT/part-* | head -n 10
