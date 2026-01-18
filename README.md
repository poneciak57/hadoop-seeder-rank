## Run Hadoop Cluster within Docker Containers (fork explanation)

- Blog: [Run Hadoop Cluster in Docker Update](http://kiwenlau.com/2016/06/26/hadoop-cluster-docker-update-english/)
- 博客: [基于Docker搭建Hadoop集群之升级版](http://kiwenlau.com/2016/06/12/160612-hadoop-cluster-docker-update/)


![alt tag](https://raw.githubusercontent.com/kiwenlau/hadoop-cluster-docker/master/hadoop-cluster-docker.png)

## Docker
Install docker desktop use desktop app if you have never worked with docker as it is very easy.
If you want to connect to terminal of some container just click on the working container name and then click 'exec' tab;

## Explanation
Ok so first things first i don't know the author but my professor might know the author of the original repository and i really could not care less. I am supposed to use this and it might have worked in the past or on different machine but i required some changes and just sharing this to my colleagues so they can use it too.

Really apprieciate the work of the author as docker is designed for such a thing :heart:

## How to run

### 1. Clone this repo
obviously

### 2. Run docker-compose
```bash
docker compose up -d --build
```
easy so far

### 3. Access Hadoop Master Web UI
Open your web browser and navigate to `http://localhost:50070` to access the Hadoop NameNode Web UI.

### Voila :)

## Resizing
I modified resizing script so you can just run
```bash
./resize-cluster.sh <number_of_slaves>
docker compose up -d
```
and it will resize the cluster to the desired number of slaves.
I think it should work fine for sure you don't need to rebuild the images again unless you change something in the Dockerfile or config files (besides slaves file as it is mounted as volume).
