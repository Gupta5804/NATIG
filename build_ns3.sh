#!/bin/bash

# Path to the NATIG source (defaults to /rd2c/PUSH/NATIG)
NATIG_SRC="${NATIG_SRC:-${RD2C:-/rd2c}/PUSH/NATIG}"

if [ -d "/rd2c/test" ]
then
    rm -rf /rd2c/test/
fi

if [ -d "/rd2c/ns-3-dev" ]
then
    rm -rf /rd2c/ns-3-dev/
fi

if [ -d "/rd2c/ns-3-dev-git" ]
then
    rm -rf /rd2c/ns-3-dev-git/
fi

cd ../../ || exit
#mkdir test
#cd test
git clone https://github.com/nsnam/ns-3-dev-git.git
mv ns-3-dev-git ns-3-dev
cd ns-3-dev || exit
git checkout ns-3.35
cd "${NATIG_SRC}" || exit
./build_helics.sh
cp -f "${NATIG_SRC}"/RC/code/helics/wscript /rd2c/ns-3-dev/contrib/helics/
cd /rd2c/ns-3-dev || exit
cp -r "${NATIG_SRC}"/RC/code/make.sh .
# The following block copied the DNP3 sources and wscript into ns-3-dev.
# It has been disabled to avoid creating the src/dnp3 directory.
# cp -r "${NATIG_SRC}"/RC/code/dnp3/ src
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/dnp3-application-Docker.cc src/dnp3/model/dnp3-application.cc
cp -r "${NATIG_SRC}"/RC/code/internet/ipv4-l3-protocol* src/internet/model/
cp -r "${NATIG_SRC}"/RC/code/internet/internet-stack-helper-MIM.* src/internet/helper/
cp -r "${NATIG_SRC}"/RC/code/internet/wscript src/internet/
cp -r "${NATIG_SRC}"/RC/code/lte/* src/lte/
cp -r "${NATIG_SRC}"/RC/code/point-to-point-layout/* src/point-to-point-layout/
# mkdir src/dnp3/
# cp -r "${NATIG_SRC}"/RC/code/dnp3/crypto src/dnp3
# cp -r "${NATIG_SRC}"/RC/code/dnp3/dnplib src/dnp3
# cp -r "${NATIG_SRC}"/RC/code/dnp3/examples src/dnp3
# cp -r "${NATIG_SRC}"/RC/code/dnp3/helper src/dnp3
# mkdir src/dnp3/model
# cp -r "${NATIG_SRC}"/RC/code/dnp3/wscript src/dnp3/
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/dnp3-application.h src/dnp3/model/
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/dnp3-application-Docker.cc src/dnp3/model/dnp3-application.cc
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/dnp3-application-Docker.cc src/dnp3/model/dnp3-application.cc
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/dnp3-simulator-impl.* src/dnp3/model/
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/tcptest* src/dnp3/model/
# cp -r "${NATIG_SRC}"/RC/code/dnp3/model/dnp3-mim-* src/dnp3/model/
cp -r "${NATIG_SRC}"/RC/code/internet/* src/internet/
cp -r "${NATIG_SRC}"/RC/code/lte/* src/lte/
cp -r "${NATIG_SRC}"/RC/code/helics/helics-helper* /rd2c/ns-3-dev/contrib/helics/helper/
# Pass linker flags through sudo so that ns-3 builds with the proper libraries
sudo env "LDFLAGS=$LDFLAGS" ./make.sh "$2"
if [ "$1" == "5G" ]; then
    echo "installing 5G"
    cd contrib || exit
    git config --global http.sslverify false
    git clone https://gitlab.com/cttc-lena/nr.git
    cd nr || exit
    git checkout 5g-lena-v1.2.y
    cd ../../
    cp -r "${NATIG_SRC}"/patch/nr/* contrib/nr/
    sudo env "LDFLAGS=$LDFLAGS" ./make.sh "$2"
fi
mkdir "$2"/integration/control/physicalDevOutput
