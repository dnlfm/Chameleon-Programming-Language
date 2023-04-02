# Execute the following command to build this image and run inside a container: make run_docker
# for Mac M1 Pro, need --platform=linux/amd64
FROM --platform=linux/amd64 ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt-get install git wget zip unzip iptables iputils-ping -y
RUN apt-get install build-essential python3 python-is-python3 libc6 default-jdk -y
RUN apt-get install flex bison byacc clang llvm -y
ARG DEBIAN_FRONTEND=interactive

RUN mkdir -p /usr/chameleon
WORKDIR /usr/chameleon
COPY . .

RUN make

# optional:
RUN make run < input/08_calculo
RUN make llvm
# can run the generated code by running 'make run_native' when inside the container