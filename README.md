
# Hadoop distributed seeder ranking algorithm
Here is the implementation of top-k seeder ranking algorithm using Hadoop MapReduce framework.


## Prerequisites
This project is created from [this](https://github.com/poneciak57/hadoop-cluster-docker) template. Make sure you have Docker and Docker Compose installed on your machine. For more info about the template please visit its repo.

## Test generation
To generate test data, you can use the provided `generate.py` script. Run the script with the desired number of unique IPs and the length of the test data:
```bash
./generate.py <unique_ips> <test_length> > <output_file>
./generate.py 3 10 > test.in
```

### Format
The input data should be in the following format:
```
<IP_ADDRESS>,<SEEDER_COUNT>
<IP_ADDRESS>,<SEEDER_COUNT>
...
```


## Build and run
1. Clone this repository:
  ```bash
  git clone https://github.com/poneciak57/hadoop-seeder-rank.git
  cd hadoop-seeder-rank
  ```
2. Build and start the Hadoop cluster:
  ```bash
  docker-compose up --build -d
  ```
TBD: Add more instructions about how to run the MapReduce job and test it with sample data.