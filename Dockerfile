FROM ubuntu:22.04

RUN  apt-get update && apt-get install -y \
    build-essential
# && apt-get clean \
# && rm -rf /var/lib/apt/lists/*

RUN apt-get install -y git
RUN apt-get install -y default-jre-headless
RUN apt-get install -y bsdextrautils