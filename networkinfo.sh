#!/bin/bash
export NODE_IP=$(kubectl describe svc dev-service | grep  addresses | cut -d '"' -f4)
echo $NODE_IP
