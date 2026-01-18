#!/usr/bin/env python3

import argparse
import os
import random


def generate_random_ip():
  return ".".join(str(random.randint(0, 255)) for _ in range(4))



parser = argparse.ArgumentParser()
parser.add_argument("unique_ips", type=int, help="Max number of unique IPs in the dataset")
parser.add_argument("test_length", type=int, help="Length of the test")
args = parser.parse_args()

unique_ips = set()
while len(unique_ips) < args.unique_ips:
  unique_ips.add(generate_random_ip())

unique_ips = list(unique_ips)

for i in range(args.test_length):
  print(random.choice(unique_ips), random.randint(0, 1000) ,sep=",", end="\n")