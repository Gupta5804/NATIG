#!/bin/bash

#################################################################
#           FINAL PRODUCTION BUILD SCRIPT
#
# This script builds your main simulation program now that all
# C++ code and dependencies are correct.
#################################################################

set -e

# Define key directories
RD2C_DIR="/rd2c"
NS3_SRC_DIR="${RD2C_DIR}/ns-3-dev/src"
PATCH_DIR="${RD2C_DIR}/patch"
SCRATCH_DIR="${RD2C_DIR}/ns-3-dev/scratch"
MODBUS_MODULE_DIR="${NS3_SRC_DIR}/modbus"
OLD_DNP3_DIR="${NS3_SRC_DIR}/dnp3"

echo "=== 1. PREPARING SOURCE & PATCHES ==="

# Remove any legacy 'dnp3' module to avoid build conflicts
if [ -d "${OLD_DNP3_DIR}" ]; then
    echo "Removing legacy dnp3 module..."
    rm -rf "${OLD_DNP3_DIR}"
fi

# Create the new directory structure for our clean module
mkdir -p "${MODBUS_MODULE_DIR}"

# Copy your patched files into the NEW modbus module directory
echo "Copying patched files..."
cp -rv "${PATCH_DIR}/modbus/model" "${MODBUS_MODULE_DIR}/"
cp -rv "${PATCH_DIR}/modbus/helper" "${MODBUS_MODULE_DIR}/"
cp -v  "${PATCH_DIR}/modbus/wscript" "${MODBUS_MODULE_DIR}/"
echo ""

# Ensure LTE patches are applied
LTE_MODEL_DIR="${NS3_SRC_DIR}/lte/model"
LTE_HELPER_DIR="${NS3_SRC_DIR}/lte/helper"
mkdir -p "${LTE_MODEL_DIR}" "${LTE_HELPER_DIR}"
cp -v "${PATCH_DIR}/lte/model/epc-pgw-application.cc" "${LTE_MODEL_DIR}/"
cp -v "${PATCH_DIR}/lte/model/epc-pgw-application.h"  "${LTE_MODEL_DIR}/"
cp -v "${PATCH_DIR}/lte/helper/no-backhaul-epc-helper.cc" "${LTE_HELPER_DIR}/"
cp -v "${PATCH_DIR}/lte/helper/no-backhaul-epc-helper.h"  "${LTE_HELPER_DIR}/"
echo ""

echo "=== 2. PREPARING MAIN SCENARIO FILE ==="
# Copy your main C++ file from the integration directory to the scratch
# directory so that the ns-3 build system can compile it.
cp -v "${RD2C_DIR}/integration/control/ns3-helics-grid-dnp3.cc" "${SCRATCH_DIR}/"

# Create the wscript to build the main program. It must link to your modbus module.
cat > "${SCRATCH_DIR}/wscript" << EOF2
def build(bld):
    bld.create_ns3_program('ns3-helics-grid-dnp3',
                           ['core', 'network', 'internet', 'point-to-point', 'csma', 'wifi', 'mobility', 'applications', 'modbus', 'helics'])
    bld.source = 'ns3-helics-grid-dnp3.cc'
EOF2

echo "Main scenario prepared successfully."
echo ""

echo "=== 3. CLEANING AND COMPILING NS-3 ==="
cd ${RD2C_DIR}/ns-3-dev

#echo "Cleaning previous build..."
#./waf distclean

echo "Configuring new build..."
./waf configure --enable-examples --enable-tests

echo "Building ns-3..."
if ! ./waf; then
    echo "ERROR: NS-3 compilation failed." >&2
    exit 1
fi

echo ""

echo "=== 4. RUNNING SIMULATION ==="
cd ${RD2C_DIR}/integration/control

echo "Build successful! Running the main simulation..."
${SCRATCH_DIR}/build/ns3-helics-grid-dnp3 --conf="config/grid.json" --ns_config="config/ns_config.json" --helicsConfig="config/helics_config.json"

echo ""
echo "=== SIMULATION COMPLETE! ==="
