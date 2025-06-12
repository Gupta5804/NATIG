#!/bin/bash

# Path to the NATIG source. If NATIG_SRC is not provided, default to the
# directory containing this script so we always use the local checkout.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
NATIG_SRC="${NATIG_SRC:-${SCRIPT_DIR}}"

cd /rd2c/ns-3-dev/contrib/ || exit
rm -r helics
git clone --depth 1 --branch HELICS-v2.x-waf https://github.com/GMLC-TDC/helics-ns3.git; mv helics-ns3 helics
cp -r "${NATIG_SRC}"/RC/code/helics/helics-helper* /rd2c/ns-3-dev/contrib/helics/helper/
cp -r "${NATIG_SRC}/RC/code/helics/wscript" /rd2c/ns-3-dev/contrib/helics/
echo "Applied HELICS wscript patch"
cp -r "${NATIG_SRC}"/RC/code/helics/helics-simulator-impl.cc /rd2c/ns-3-dev/contrib/helics/model/
