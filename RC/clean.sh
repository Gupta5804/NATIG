#!/bin/bash

# Move the output directory to a backup instead of deleting
if [ -d "output" ]; then
    mv output output.bak-$(date +%F-%T)
fi

rm -rf zeromq*
rm -rf bin
rm -rf czmq*
rm -rf fncs
rm -rf include
rm -rf lib*
rm -rf gcc*
rm -rf share
rm -rf boost*
rm -rf HELICS

pkill -9 helics_broker
