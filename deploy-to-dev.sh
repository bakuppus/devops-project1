#!/bin/bash
export NODE_IP=$(kubectl describe svc dev-service | grep  addresses | cut -d '"' -f4)
echo $NODE_IP
curl -v -u admin:admin -T target/javaee7-simple-sample.war 'http://$NODE_IP:30000/manager/text/deploy?path=/dev&update=true'
