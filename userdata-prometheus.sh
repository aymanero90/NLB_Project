#!/bin/bash

set -e

apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

apt-key fingerprint 0EBFCD88
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io



sudo mkdir -p /srv/prometheus/
sudo chmod a+rwx /srv/prometheus/

sudo mkdir -p /srv/service-discovery/
sudo chmod a+rwx /srv/service-discovery/

## Run the exoscale service discovery generator 
## from the public docker image  "janoszen/prometheus-sd-exoscale-instance-pools"
sudo docker run \
    -d \
	-v /srv/service-discovery:/var/run/prometheus-sd-exoscale-instance-pools \
	janoszen/prometheus-sd-exoscale-instance-pools:1.0.0 \
	--exoscale-api-key ${exoscale_key} \
	--exoscale-api-secret ${exoscale_secret} \
	--exoscale-zone-id 4da1b188-dcd6-4ff5-b7fd-bde984055548 \
	--instance-pool-id ${exoscale_instancepool_id}

## Create the prometheus configuration file
touch /srv/prometheus/prometheus.yml
cat <<EOCF >/srv/prometheus/prometheus.yml
${prometheus_config}
EOCF

## Run prometheus from the public docker image "prom/prometheus"
sudo docker run -d \
    -p 9090:9090\
	-v /srv/service-discovery/:/srv/service-discovery/ \
    -v /srv/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
