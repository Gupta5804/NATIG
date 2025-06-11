#!/bin/bash

#################################################################
#           FINAL DEBUGGING & BUILD SCRIPT
#
# This script builds a minimal test case in the 'scratch'
# directory to prove the 'modbus' module is working correctly.
#################################################################

set -e # Exit immediately if a command exits.

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

echo "=== 2. CREATING MINIMAL TEST CASE IN 'scratch' ==="
# Create a simple C++ file in the scratch directory
cat > "${SCRATCH_DIR}/modbus-test.cc" << EOF
#include "ns3/core-module.h"
#include "ns3/modbus-helper.h" // Include our module's header

int main (int argc, char *argv[])
{
  // If this program compiles, the module and its dependencies are correct.
  ns3::modbus::ModbusMasterHelper masterHelper;
  ns3::LogComponentEnable("ModbusMasterApp", ns3::LOG_LEVEL_INFO);
  NS_LOG_UNCOND ("Minimal test program compiled and linked successfully!");
  return 0;
}
EOF

# Create the wscript to build our test program
cat > "${SCRATCH_DIR}/wscript" << EOF
# wscript for the scratch directory
def build(bld):
    # This builds modbus-test.cc and links it against the core ns-3
    # modules and, most importantly, our custom 'modbus' module.
    bld.create_ns3_program('modbus-test',
                           ['core', 'network', 'internet', 'point-to-point', 'modbus'])
    bld.source = 'modbus-test.cc'
EOF

echo "Test case created successfully."
echo ""


echo "=== 3. CLEANING AND COMPILING NS-3 ==="
cd ${RD2C_DIR}/ns-3-dev

echo "Cleaning previous build..."
./waf distclean

echo "Configuring new build..."
CXXFLAGS="-I/usr/local/include" ./waf configure --enable-examples --enable-tests --with-helics=/usr/local

echo "Building ns-3..."
./waf

if [ $? -ne 0 ]; then
    echo "ERROR: NS-3 compilation failed." >&2
    exit 1
fi
echo ""

echo "=== 4. RUNNING MINIMAL TEST ==="
echo "Build successful! Running the minimal test program..."
./build/scratch/modbus-test

echo ""
echo "=== TEST COMPLETE! ==="
