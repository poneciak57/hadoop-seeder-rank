# Raport from tests


## Test Environment
- Hadoop version: 2.7.2
- OS: macOS Sequoia 15.7.3 (24G419) arm64
- CPU: Apple M4 Pro (14) @ 4.51 GHz
- GPU: Apple M4 Pro (20) @ 1.58 GHz [Integrated]
- Memory: 11.47 GiB / 24.00 GiB (48%)
- Docker version 28.3.3

## 1.7GB Test File
The test file disk size is 1.7GB. It has 100,000,000 lines that contain at most 10,000 unique ips.
Generated using:
```bash
./generator.py 10000 100000000 > ./data/1GB_test.csv
```

| Property               | Value          |
|------------------------|----------------|
| File Size              | 1.7GB          |
| Number of Lines        | 100,000,000    |
| Unique IPs             | 10,000         |
| Hadoop-slaves count    | 4              |
| Mappers count          | 4              |
| Reducers count         | 4              |

### Test Results
The test consists of 2 phases.
1. Summing up bytes for each ip (MapReduce job)
2. Sorting the ips by total bytes (MapReduce job)

#### Job 1: Aggregation (Summing up bytes)
> **Duration:** ~41 seconds
| Metric | Value |
|--------|-------|
| **Map Input Records** | 100,000,000 |
| **Map Output Records** | 100,000,000 |
| **Reduce Output Records** (Unique IPs) | 10,000 |
| **Data Read (File System)** | ~1.82 GB (1,816,829,083 bytes) |
| **Bytes Written** | 222,764 |
| **Launched Map Tasks** | 15 |
| **Launched Reduce Tasks** | 4 |
| **Total CPU Time (Maps)** | 300,954 ms (~5 min) |
| **Total CPU Time (Reduces)** | 85,412 ms (~1.4 min) |

#### Job 2: Sorting (Rank by Bytes)
> **Duration:** ~9 seconds

| Metric | Value |
|--------|-------|
| **Map Input Records** | 10,000 |
| **Map Output Records** | 10,000 |
| **Reduce Output Records** | 10,000 |
| **Launched Map Tasks** | 4 |
| **Launched Reduce Tasks** | 1 |
| **Total CPU Time (Maps)** | 3,640 ms |
| **Total CPU Time (Reduces)** | 707 ms |

## 17GB Test File
The test file disk size is 17GB. It has 1,000,000,000 lines that contain at most 1,000,000 unique ips.
Generated using:
```bash
./generator.py 1000000 1000000000 > ./data/10GB_test.csv
```
> Be carefull it takes 10 minutes to generate the file. (using the python generator)

### Multithreaded cpp generator
I created another more robust generator in C++ that uses multithreading without locks to speed up the generation process.
```bash
g++ -o generator_cpp multithreaded_generator.cpp -O3 -std=c++20 -pthread
./generator_cpp
```
It generates test for 1,000,000 unique IPs and 10,000,000,000 lines, it can be changed in the source code.

## 50GB Test File
The test file disk size is 50GB. It has 3,000,000,000 lines that contain at most 100,000 unique ips.
Generated using the multithreaded cpp generator.
> Be carefull it takes around 8 minutes to generate the file.
> At some point the filesystem speed becomes the bottleneck.

This test is special because i wanted to have a huge file that will not fit in memory. And i wanted to see how my macbook will handle it, and later run it on my home network of 3 computers as hadoop slaves and see how it scales.

### One Machine Test Results (Docker on Mac)
The result below is from running the pipeline on the single machine environment described above (Docker on Mac).

#### Job 1: Aggregation (Sum bytes per IP)
> **Duration:** 25m 50s (19:24:22 - 19:50:12)

| Metric | Value |
|--------|-------|
| **Map Input Records** | 3,000,000,000 |
| **Map Output Records** | 3,000,000,000 |
| **Reduce Output Records** (Unique IPs) | 100,000 |
| **Data Read (HDFS)** | ~50.7 GB (54,449,052,754 bytes) |
| **Bytes Written** | 2,284,727 (~2.2 MB) |
| **Launched Map Tasks** | 407 |
| **Launched Reduce Tasks** | 4 |
| **Total CPU Time (Maps)** | 6,908,249 ms (~115 min) |
| **Total CPU Time (Reduces)** | 3,643,091 ms (~60 min) |

#### Job 2: Sorting (Rank by Bytes)
> **Duration:** 15s

| Metric | Value |
|--------|-------|
| **Map Input Records** | 100,000 |
| **Map Output Records** | 100,000 |
| **Reduce Output Records** | 100,000 |
| **Launched Map Tasks** | 4 |
| **Launched Reduce Tasks** | 1 |
| **Total CPU Time (Maps)** | 4,536 ms |
| **Total CPU Time (Reduces)** | 822 ms |


### Distributed Test Results (3 Machines Hadoop Cluster)

Testing enviroments:
- Machine 1: MacBook Pro M4 Pro (14 cores, 24GB RAM)
- Machine 2: Windows PC (Intel i7-8700 6 cores, 32GB RAM)
- Machine 3: Lenovo Linux Laptop (Ryzen 7 5700U 8 cores, 16GB RAM)
- Network: One machine (PC) is connected via Ethernet, other two via WiFi.

TBD