#!/bin/bash 
 
clear 
 
pkill -9 helics_broker
pkill -9 gridlabd
pkill -9 python
pkill -9 ns3-helics-grid-modbus
pkill -9 ns3-helics-grid-modbus-direct-analog
pkill -9 ns3-helics-grid-modbus-direct-binary

exit 0 
