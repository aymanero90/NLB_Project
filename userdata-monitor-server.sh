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
cat <<EOCF >/srv/prometheus/prometheus.yml
${prometheus_config}
EOCF

## Run prometheus from the public docker image "prom/prometheus"
sudo docker run -d \
    -p 9090:9090\
	-v /srv/service-discovery/:/srv/service-discovery/ \
    -v /srv/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
    prom/prometheus
	
##### Init Grafana ########
sudo mkdir -p /srv/grafana/datasources/
sudo chmod a+rwx /srv/grafana/datasources/

sudo mkdir -p /srv/grafana/dashboards/
sudo chmod a+rwx /srv/grafana/dashboards/

sudo mkdir -p /srv/grafana/notifiers/
sudo chmod a+rwx /srv/grafana/notifiers/

cat <<EOCF >/srv/grafana/dashboards/config.yml
${grafana_dashboard_config}
EOCF

cat <<EOCF >/srv/grafana/dashboards/dashboard.json
${grafana_dashboard}
EOCF

##retrieving the IP of the monitoring instance for prometheus datasource configs
MONITOR_IP=$(curl http://checkip.amazonaws.com/)

## create datasource config file for grafana
echo 'apiVersion: 1
datasources:
- name: Prometheus
  type: prometheus
  access: proxy
  orgId: 1
  url: http://'$MONITOR_IP':9090
  version: 1
  editable: false
  isDefault: true' >>/srv/grafana/datasources/datasource.yml
  
  
## create notifiers config file
echo 'notifiers:
  - name: Scale up
    type: webhook
    uid: scale-up
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://'$MONITOR_IP':8090/up"
      
  - name: Scale down
    type: webhook
    uid: scale-down
    org_id: 1
    is_default: false
    send_reminder: true
    disable_resolve_message: true
    frequency: "5m"
    settings:
      autoResolve: true
      httpMethod: "POST"
      severity: "critical"
      uploadImage: false
      url: "http://'$MONITOR_IP':8090/down"' >>/srv/grafana/notifiers/notifier.yml
	  
	  
## run grafana 	from the public docker image grafana/grafana  
sudo docker run -d -p 3000:3000 \
 -v /srv/grafana/dashboards/config.yml:/etc/grafana/provisioning/dashboards/config.yml \
 -v /srv/grafana/dashboards/dashboard.json:/etc/grafana/dashboards/dashboard.json \
 -v /srv/grafana/datasources/datasource.yml:/etc/grafana/provisioning/datasources/datasource.yml \
 -v /srv/grafana/notifiers/notifier.yml:/etc/grafana/provisioning/notifiers/notifier.yml \
  grafana/grafana


## run the autoscaler that handles grafana webhooks from the public docker image janoszen/exoscale-grafana-autoscaler
sudo docker run -d \
    -p 8090:8090 \
    janoszen/exoscale-grafana-autoscaler:1.0.2 \
    --exoscale-api-key ${exoscale_key} \
    --exoscale-api-secret ${exoscale_secret} \
    --exoscale-zone-id 4da1b188-dcd6-4ff5-b7fd-bde984055548 \
    --instance-pool-id ${exoscale_instancepool_id}
	