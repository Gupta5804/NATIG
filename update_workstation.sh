#!/bin/bash

git pull
RD2C=${RD2C:-/rd2c}
# Path to the NATIG source (defaults to $RD2C/PUSH/NATIG)
NATIG_SRC="${NATIG_SRC:-${RD2C}/PUSH/NATIG}"

read -p "Do you want to save your current setup? [y/n] " answer

echo "Input 1: ${answer}"

if [[ $answer == [yY] || $answer == [yY][eE][sS] ]]
then
	    dt=$(date '+%d-%m-%Y-%H:%M:%S')
	    echo "Saving setup in $dt"
	    mkdir $dt
            cp ${RD2C}/integration/control/*.cc $dt
            cp ${RD2C}/integration/control/config/grid.json $dt
            cp ${RD2C}/integration/control/config/gridlabd_config.json $dt
            cp ${RD2C}/integration/control/config/topology.json $dt
            cp ${RD2C}/integration/control/*.glm $dt
fi

# Move the existing directory to a backup location instead of deleting
if [ -d "${RD2C}/integration" ]; then
    mv ${RD2C}/integration ${RD2C}/integration.bak-$(date +%F-%T)
fi
cp -r integration ${RD2C}
cp -r RC/code/run.sh ${RD2C}/integration/control 
cp -r RC/code/ns3-helics-grid-dnp3-4G-Docker.cc ${RD2C}/integration/control/ns3-helics-grid-modbus-4G.cc
cp -r RC/code/ns3-helics-grid-dnp3-5G-Docker.cc ${RD2C}/integration/control/ns3-helics-grid-modbus-5G.cc
cp -r RC/code/ns3-helics-grid-modbus.cc "${RD2C}"/integration/control/ns3-helics-grid-modbus.cc
rm -rf ${RD2C}/ns-3-dev/src/dnp3
mkdir -p ${RD2C}/ns-3-dev/src/dnp3
cp -r RC/code/dnp3/crypto ${RD2C}/ns-3-dev/src/dnp3  
cp -r RC/code/dnp3/dnplib ${RD2C}/ns-3-dev/src/dnp3  
cp -r RC/code/dnp3/examples ${RD2C}/ns-3-dev/src/dnp3 
cp -r RC/code/dnp3/helper ${RD2C}/ns-3-dev/src/dnp3 
mkdir ${RD2C}/ns-3-dev/src/dnp3/model 
cp -r RC/code/dnp3/wscript ${RD2C}/ns-3-dev/src/dnp3/ 
cp -r RC/code/dnp3/model/dnp3-application.h ${RD2C}/ns-3-dev/src/dnp3/model/ 
cp -r RC/code/dnp3/model/dnp3-simulator-impl.* ${RD2C}/ns-3-dev/src/dnp3/model/ 
cp -r RC/code/dnp3/model/tcptest* ${RD2C}/ns-3-dev/src/dnp3/model/ 
cp -r RC/code/dnp3/model/dnp3-mim-* ${RD2C}/ns-3-dev/src/dnp3/model/ 
#&& cp -r RC/code/applications/model/fncs-application.* ${RD2C}/ns-3-dev/src/applications/model/ 
cp -r RC/code/internet/* ${RD2C}/ns-3-dev/src/internet/ 
cp -r RC/code/lte/* ${RD2C}/ns-3-dev/src/lte/ 
cp -r RC/code/gridlabd/* ${RD2C}/gridlab-d/tape_file/ 
cp -r RC/code/trigger.player ${RD2C}/integration/control/
cd ${NATIG_SRC}
./build_helics.sh
cd ${RD2C}/ns-3-dev
cp -r ${NATIG_SRC}/RC/code/helics/helics-helper* ${RD2C}/ns-3-dev/contrib/helics/helper/
cp -r ${NATIG_SRC}/RC/code/helics/dnp3-application-helper-new.* ${RD2C}/ns-3-dev/contrib/helics/helper/
cp -r ${NATIG_SRC}/RC/code/helics/dnp3-application-new* ${RD2C}/ns-3-dev/contrib/helics/model/
cp -r ${NATIG_SRC}/RC/code/helics/wscript ${RD2C}/ns-3-dev/contrib/helics/


#if [ -d "${RD2C}/gridlab-d/third_party/xerces-c-3.2.0" ]; then
#    XERCES_DIR="${RD2C}/gridlab-d/third_party/xerces-c-3.2.0"
#elif [ -d "/usr/local/gridlab-d/third_party/xerces-c-3.2.0" ]; then
#    XERCES_DIR="/usr/local/gridlab-d/third_party/xerces-c-3.2.0"
#else
#    echo "Error: Xerces-C directory not found in '${RD2C}' or '/usr/local/gridlab-d'." >&2
#    exit 1
#fi
#cd "$XERCES_DIR"
#./configure
#make
#make install
#cd ${RD2C}/gridlab-d 
#autoreconf -if 
#./configure --with-helics=/usr/local --prefix=${RD2C} --enable-silent-rules 'CFLAGS=-g -O2 -w' 'CXXFLAGS=-g -O2 -w -std=c++14' 'LDFLAGS=-g -O2 -w' 
#make 
#make install
## ** NEW: Add this cleanup command for GridLAB-D **
#echo "==== Cleaning up GridLAB-D build files ===="
#make clean
#
## Export linker flags so ns-3 picks them up during the build
#export LDFLAGS="-ljsoncpp -L/usr/local/include/jsoncpp/"
#cd $RD${NATIG_SRC}
#./build_ns3.sh "$1" ${RD2C}
#
## Remove ns-3 build directory to save disk space
#cd ${RD2C}/ns-3-dev
#./waf distclean
#
## ** NEW: Add this cleanup command for ns-3 **
#echo "==== Cleaning up ns-3 build files ===="
#cd $RD2C/ns-3-dev
#./waf clean
#
#echo "==== Update and build process complete! ===="
