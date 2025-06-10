#!/bin/bash

#################################################################
#           DEVELOPMENT WORKFLOW SCRIPT FOR NATIG
#
# This script simplifies the workflow to:
#   1. Setup Environment
#   2. Patch: Copy your custom files to the right locations.
#   3. Compile: Rebuild the ns-3 simulator.
#   4. Run: Execute the simulation.
#
#################################################################

set -e # Exit immediately if a command exits with a non-zero status.

echo "=== 1. SETTING UP BUILD ENVIRONMENT ==="
source /rd2c/RC/environmental.sh
echo "Environment variables set."
echo ""

echo "=== 2. APPLYING CUSTOM PATCHES FROM 'patch/' DIRECTORY ==="

# Define key directories
RD2C_DIR="${RD2C:-/rd2c}"
# Location of this repository
REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
# Patches live inside the repo
PATCH_DIR="${REPO_DIR}/patch"
NS3_DIR="${RD2C_DIR}/ns-3-dev"
NS3_SRC_DIR="${NS3_DIR}/src"
NS3_CONTRIB_DIR="${NS3_DIR}/contrib"

sync_dir() {
    local src="$1" dest="$2"
    if [ -d "$src" ]; then
        mkdir -p "$dest"
        cp -rv "$src"/* "$dest/"
    fi
}

# Synchronise patched modules with the ns-3 tree
sync_dir "${PATCH_DIR}/applications"            "${NS3_SRC_DIR}/applications"
sync_dir "${PATCH_DIR}/dnp3"                     "${NS3_SRC_DIR}/dnp3"
cp -v "${PATCH_DIR}/dnp3/wscript" "${NS3_SRC_DIR}/dnp3/"
sync_dir "${PATCH_DIR}/fncs"                     "${NS3_SRC_DIR}/fncs"
sync_dir "${PATCH_DIR}/internet"                 "${NS3_SRC_DIR}/internet"
sync_dir "${PATCH_DIR}/lte"                      "${NS3_SRC_DIR}/lte"
sync_dir "${PATCH_DIR}/point-to-point-layout"    "${NS3_SRC_DIR}/point-to-point-layout"

# Contrib modules
sync_dir "${PATCH_DIR}/helics-backup"            "${NS3_CONTRIB_DIR}/helics"
sync_dir "${PATCH_DIR}/nr"                       "${NS3_CONTRIB_DIR}/nr"

# Copy patched build helper and other top-level files
if [ -f "${PATCH_DIR}/make.sh" ]; then
    cp -v "${PATCH_DIR}/make.sh" "${NS3_DIR}/"
fi

echo ""
echo "=== 3. COMPILING NS-3 ==="

cd ${NS3_DIR}

if [ -f "make.sh" ]; then
    bash ./make.sh
else
    ./waf
fi

# Check if the compilation was successful
if [ $? -ne 0 ]; then
    echo "ERROR: NS-3 compilation failed." >&2
    exit 1
fi

echo ""
echo "=== 4. RUNNING SIMULATION ==="
echo "Compilation successful. Executing run_ns3_only.sh..."

cd ${RD2C_DIR}/integration/control
bash ./run_ns3_only.sh

echo ""
echo "=== WORKFLOW COMPLETE ==="

