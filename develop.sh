#!/bin/bash

#################################################################
#           FINAL DEVELOPMENT WORKFLOW SCRIPT
#
# This version creates and uses a new, clean `modbus` module
# to eliminate all legacy dependency errors.
#################################################################

set -e # Exit immediately if a command exits.

echo "=== 1. SETTING UP BUILD ENVIRONMENT ==="
# Set the correct library path for HELICS, ZMQ, etc.
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
echo "Library path set."
echo ""

# Define key directories
RD2C_DIR="/rd2c"
NS3_SRC_DIR="${RD2C_DIR}/ns-3-dev/src"
PATCH_DIR="${RD2C_DIR}/patch"
MODBUS_MODULE_DIR="${NS3_SRC_DIR}/modbus"

echo "=== 2. CREATING CLEAN 'modbus' MODULE STRUCTURE ==="
# Create the new directory structure for our clean module
mkdir -p "${MODBUS_MODULE_DIR}/model"
mkdir -p "${MODBUS_MODULE_DIR}/helper"

# Copy your patched files into the NEW modbus module directory
echo "Copying patched files..."
cp -v "${PATCH_DIR}/modbus/model/modbus-master-app.cc" "${MODBUS_MODULE_DIR}/model/"
cp -v "${PATCH_DIR}/modbus/model/modbus-master-app.h"  "${MODBUS_MODULE_DIR}/model/"
cp -v "${PATCH_DIR}/modbus/model/modbus-slave-app.cc"  "${MODBUS_MODULE_DIR}/model/"
cp -v "${PATCH_DIR}/modbus/model/modbus-slave-app.h"   "${MODBUS_MODULE_DIR}/model/"
cp -v "${PATCH_DIR}/modbus/helper/modbus-helper.cc"    "${MODBUS_MODULE_DIR}/helper/"
cp -v "${PATCH_DIR}/modbus/helper/modbus-helper.h"     "${MODBUS_MODULE_DIR}/helper/"
cp -v "${PATCH_DIR}/modbus/wscript"                    "${MODBUS_MODULE_DIR}/"
echo ""

echo "=== 3. COMPILING NS-3 WITH THE NEW 'modbus' MODULE ==="
cd ${RD2C_DIR}/ns-3-dev
./waf configure --enable-examples --enable-tests
./waf

if [ $? -ne 0 ]; then
    echo "ERROR: NS-3 compilation failed." >&2
    exit 1
fi
echo ""

echo "=== 4. RUNNING SIMULATION ==="
cd ${RD2C_DIR}/integration/control
# We will use a temporary run script to avoid any lingering issues
# in the old run_ns3_only.sh.
echo "Starting ns-3 simulation..."
./build/ns3-helics-grid-dnp3 --conf="config/grid.json" --ns_config="config/ns_config.json"

echo ""
echo "=== BUILD AND RUN COMPLETE! ==="
