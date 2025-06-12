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
NS3_CONTRIB_DIR="${RD2C_DIR}/ns-3-dev/contrib"
PATCH_DIR="${RD2C_DIR}/patch"
MODBUS_MODULE_DIR="${NS3_SRC_DIR}/modbus"
OLD_DNP3_DIR="${NS3_SRC_DIR}/dnp3"
CUSTOM_DNP3_DIR="${RD2C_DIR}/RC/code/dnp3"
# Set up HELICS module
echo "Setting up HELICS module..."
bash "${RD2C_DIR}/build_helics.sh"


echo "=== 2. CREATING CLEAN 'modbus' MODULE STRUCTURE ==="
# Remove any legacy 'dnp3' module to avoid build conflicts
if [ -d "${OLD_DNP3_DIR}" ]; then
    echo "Removing legacy dnp3 module..."
    rm -rf "${OLD_DNP3_DIR}"
fi
# Copy customized dnp3 module used by HELICS
if [ -d "${CUSTOM_DNP3_DIR}" ]; then
    echo "Copying custom dnp3 module..."
    cp -rv "${CUSTOM_DNP3_DIR}" "${NS3_SRC_DIR}/"
fi
# Remove any previously copied modbus module to ensure a clean state
if [ -d "${MODBUS_MODULE_DIR}" ]; then
    echo "Removing old modbus module..."
    rm -rf "${MODBUS_MODULE_DIR}"
fi
# Copy the patched modbus module fresh
echo "Copying patched modbus module..."
cp -rv "${PATCH_DIR}/modbus" "${MODBUS_MODULE_DIR}"

# Copy FNCS and applications patches so the build picks up the correct files
cp -v "${PATCH_DIR}/fncs/wscript" "${NS3_SRC_DIR}/fncs/"
mkdir -p "${NS3_SRC_DIR}/applications/model"
cp -v "${PATCH_DIR}/applications/model"/fncs-application.* "${NS3_SRC_DIR}/applications/model/"
cp -v "${PATCH_DIR}/applications/wscript" "${NS3_SRC_DIR}/applications/"

# Overlay patched Internet module files to ensure new headers are used
echo "Applying Internet module patches..."
cp -rv "${PATCH_DIR}/internet"/* "${NS3_SRC_DIR}/internet/"
# Ensure the HELICS build script ignores example programs
cp -v "${RD2C_DIR}/RC/code/helics/wscript" "${NS3_CONTRIB_DIR}/helics/"
echo ""

echo "=== 3. CLEANING AND COMPILING NS-3 ==="
cd ${RD2C_DIR}/ns-3-dev

# First, perform a deep clean to remove any old configuration caches.
#echo "Cleaning previous build..."
#./waf distclean

# THIS IS THE FINAL FIX: Pass CXXFLAGS directly to configure
echo "Configuring new build..."
CXXFLAGS="-I/usr/local/include" ./waf configure --enable-examples --enable-tests --disable-fncs

echo "Building ns-3..."
if ! ./waf; then
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
