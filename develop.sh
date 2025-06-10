#!/bin/bash

#################################################################
#           DEVELOPMENT WORKFLOW SCRIPT FOR NATIG
#
# This script simplifies the workflow to:
#   1. Patch: Copy your custom files to the right locations.
#   2. Compile: Rebuild the ns-3 simulator.
#   3. Run: Execute the simulation.
#
#################################################################

set -e # Exit immediately if a command exits with a non-zero status.

echo "=== 1. APPLYING CUSTOM PATCHES FROM 'patch/' DIRECTORY ==="

# Define key directories
RD2C_DIR="/rd2c"
PATCH_DIR="${RD2C_DIR}/patch"
NS3_SRC_DIR="${RD2C_DIR}/ns-3-dev/src"

# --- Add your custom file copy commands here ---
# This section copies files from your 'patch' directory to the ns-3
# source, overwriting the originals before compilation.
# The structure inside 'patch/' should mirror the destination in 'ns-3-dev/src/'.

# Example for your Modbus applications:
cp -v "${PATCH_DIR}/dnp3/model/modbus-master-app.cc" "${NS3_SRC_DIR}/dnp3/model/"
cp -v "${PATCH_DIR}/dnp3/model/modbus-master-app.h"  "${NS3_SRC_DIR}/dnp3/model/"
cp -v "${PATCH_DIR}/dnp3/model/modbus-slave-app.cc"  "${NS3_SRC_DIR}/dnp3/model/"
cp -v "${PATCH_DIR}/dnp3/model/modbus-slave-app.h"   "${NS3_SRC_DIR}/dnp3/model/"

# Example for the wscript build file, if you modify it:
# cp -v "${PATCH_DIR}/dnp3/wscript" "${NS3_SRC_DIR}/dnp3/"

echo ""
echo "=== 2. COMPILING NS-3 ==="

# We use the existing ns-3 build script.
# This is the only essential step to apply your C++ changes.
cd ${RD2C_DIR}/ns-3-dev
./waf

# Check if the compilation was successful
if [ $? -ne 0 ]; then
    echo "ERROR: NS-3 compilation failed." >&2
    exit 1
fi

echo ""
echo "=== 3. RUNNING SIMULATION ==="
echo "Compilation successful. Executing run_ns3_only.sh..."

cd ${RD2C_DIR}/integration/control
bash ./run_ns3_only.sh

echo ""
echo "=== WORKFLOW COMPLETE ==="

