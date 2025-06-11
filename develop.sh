#!/bin/bash

#################################################################
#           FINAL DEVELOPMENT WORKFLOW SCRIPT
#
# This version creates and uses a new, clean `modbus` module
# to eliminate all legacy dependency errors.
#################################################################

set -e # Exit immediately if a command exits.

echo "=== 1. SETTING UP BUILD ENVIRONMENT ==="
# Set the library path for the linker
export LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64:$LD_LIBRARY_PATH
# Set the include path for the compiler
export CXXFLAGS="-I/usr/local/include"
echo "Environment configured."
echo ""

# Define key directories
RD2C_DIR="/rd2c"
NS3_SRC_DIR="${RD2C_DIR}/ns-3-dev/src"
PATCH_DIR="${RD2C_DIR}/patch"
MODBUS_MODULE_DIR="${NS3_SRC_DIR}/modbus"
OLD_DNP3_DIR="${NS3_SRC_DIR}/dnp3"
# Set up HELICS module
echo "Setting up HELICS module..."
bash "${RD2C_DIR}/PUSH/NATIG/build_helics.sh"


echo "=== 2. CREATING CLEAN 'modbus' MODULE STRUCTURE ==="
# Remove any legacy 'dnp3' module to avoid build conflicts
if [ -d "${OLD_DNP3_DIR}" ]; then
    echo "Removing legacy dnp3 module..."
    rm -rf "${OLD_DNP3_DIR}"
fi
# Create the new directory structure for our clean module

# Ensure the base directory exists
mkdir -p "${MODBUS_MODULE_DIR}"
# Create the required subdirectories
mkdir -p "${MODBUS_MODULE_DIR}/model"
mkdir -p "${MODBUS_MODULE_DIR}/helper"


# Copy your patched files into the NEW modbus module directory
echo "Copying patched files..."
# Copy entire dnplib and crypto directories
cp -r "${PATCH_DIR}/modbus/dnplib" "${MODBUS_MODULE_DIR}/"
cp -r "${PATCH_DIR}/modbus/crypto" "${MODBUS_MODULE_DIR}/"
# Copy all model and helper source files
cp -v "${PATCH_DIR}/modbus/model"/* "${MODBUS_MODULE_DIR}/model/"
cp -v "${PATCH_DIR}/modbus/helper"/* "${MODBUS_MODULE_DIR}/helper/"
# Copy the module wscript
cp -v "${PATCH_DIR}/modbus/wscript" "${MODBUS_MODULE_DIR}/"
echo ""

echo "=== 3. CLEANING AND COMPILING NS-3 ==="
cd ${RD2C_DIR}/ns-3-dev

# First, perform a deep clean to remove any old configuration caches.
echo "Cleaning previous build..."
./waf distclean

# THIS IS THE FINAL FIX: Pass CXXFLAGS directly to configure
echo "Configuring new build..."
CXXFLAGS="-I/usr/local/include" ./waf configure --enable-examples --enable-tests --with-helics=/usr/local --disable-fncs

echo "Building ns-3..."
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
