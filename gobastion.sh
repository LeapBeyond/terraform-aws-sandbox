#!/bin/bash

cd $(dirname $0)/platform-scripts
CONNECT=$(terraform output bastion_connect_string | sed 's/^.* = //')
cd ../data
exec $CONNECT
