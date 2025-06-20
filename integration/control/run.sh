#!/bin/bash

#SBATCH --time=64:15:00
# ==== set root and output
export RD2C=$1
NATIG_SRC="${NATIG_SRC:-${RD2C}/PUSH/NATIG}"
export FNCS_INSTALL=${RD2C}
export PATH=$PATH:${FNCS_INSTALL}/bin
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${FNCS_INSTALL}/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${FNCS_INSTALL}/lib64
export PATH=$PATH:${FNCS_INSTALL}/include
export GLPATH=${RD2C}/lib/gridlabd:${RD2C}/lib


export OMPI_ALLOW_RUN_AS_ROOT=1
export OMPI_ALLOW_RUN_AS_ROOT_CONFIRM=1



ROOT_PATH="${PWD}" # "/rd2c/integration/control"
OUT_DIR="${ROOT_PATH}/output"


if test ! -d "${OUT_DIR}"
then
  echo "==== Simulation output folder does not exist yet. Creating ... ===="
  mkdir "${OUT_DIR}"
else
  echo "==== Simulation output folder already exists. ===="
fi

# ===== starting HELICS broker =====
helicsLOGlevel=1
helicsOutFile="${OUT_DIR}/helics_broker.log"
if test -e "$helicsOutFile"
then
  echo "$helicsOutFile exists. Deleting..."
  rm "$helicsOutFile"
fi

if [[ "$5" == "conf" ]]
then
cp ${NATIG_SRC}/RC/code/points-${4}/* config/
fi

if [[ "$2" == "4G" ]]
then
if [[ "$5" == "conf" ]]
then
    cp -r "${NATIG_SRC}/RC/code/4G-conf-${4}"/*.json config/
    cp -r "${NATIG_SRC}/RC/code/4G-conf-${4}"/*.glm .
fi
modelName="ns3-helics-grid-modbus-4G"
fi
if [[ "$2" == "5G" ]]
then
if [[ "$5" == "conf" ]]
then
    cp -r "${NATIG_SRC}/RC/code/5G-conf-${4}"/*.json config/
    cp -r "${NATIG_SRC}/RC/code/5G-conf-${4}"/*.glm .
fi
modelName="ns3-helics-grid-modbus-5G"
fi
if [[ "$2" == "3G" ]]
then
if [[ "$5" == "conf" ]]
then
    cp -r "${NATIG_SRC}/RC/code/3G-conf-${4}"/*.json config/
    cp -r "${NATIG_SRC}/RC/code/3G-conf-${4}"/*.glm .
fi
modelName="ns3-helics-grid-modbus"
fi

#sbatch run-helics.sh ${helicsLOGlevel} ${helicsOutFile}
v2=$( grep 'brokerPort' ${PWD}/config/gridlabd_config.json | sed -r 's/^[^:]*:(.*)$/\1/' | sed 's/,//' | sed 's/ //' )

cd ${ROOT_PATH} && \
#if [[ "$6" == "v2" ]]
#then
helics_broker --slowresponding --federates=2 --port=$v2 --loglevel=${helicsLOGlevel} >> ${helicsOutFile} 2>&1 & \
#else
#helics_broker --slowresponding --federates=2 --port=9000 --loglevel=${helicsLOGlevel} >> ${helicsOutFile} 2>&1 & \
#fi
 #helics_app tracer test.txt --config-file endpoints.txt --loglevel 7 --timedelta 1 >> tracer.txt 2>&1 & \
cd -

# ===== starting GridLAB-D ===== 
gldDir="${ROOT_PATH}"
gldOutFile="${OUT_DIR}/gridlabd.log"
if [[ "$4" == "9500" ]]
then
  gldModelFile="${gldDir}/ieee8500.glm"
fi
if [[ "$4" == "123" ]]
then
  gldModelFile="${gldDir}/IEEE_123_Dynamic.glm"
fi
if test -e $gldOutFile
then
  echo "$gldOutFile exists. Deleting..."
  rm $gldOutFile
fi
#sbatch run-gridlabd.sh ${OUT_DIR} ${gldModelFile} ${gldOutFile}
cd ${gldDir} && \
   gridlabd -D OUT_FOLDER=${OUT_DIR} ${gldModelFile} >> ${gldOutFile} 2>&1 & \
   cd -


# ccDir="${ROOT_PATH}"
# ccOutFile="${OUT_DIR}/ctrlCenter.log"
# if test -e $ccOutFile
# then
#   echo "$ccOutFile exists. Deleting..."
#   rm $ccOutFile
# fi

# cd ${ccDir} && \
#    python control_test.py >> ${ccOutFile} 2>&1 & \
#    cd -

#cd ${ROOT_PATH} && \
#sbatch run-ns3.sh "/people/belo700/RD2C/workspace/"\
#cd -

# ===== setting up ns-3 configurations =====
ns3Dir="/${PWD}/../../ns-3-dev"
ns3Scratch="${ns3Dir}/scratch"

ns3Model="${ns3Scratch}/${modelName}"
configDir="${ROOT_PATH}/config/"
helicsConfig="${configDir}/gridlabd_config.json" 
# ns_config.json"
microGridConfig="${configDir}/grid.json"
topologyConfig="${configDir}/topology.json"
pcapFileDir="${OUT_DIR}/"
ns3OutFile="${OUT_DIR}/${modelName}.log"

if test -e $ns3OutFile
  then
    echo "$ns3OutFile exists. Deleting..."
    rm $ns3OutFile
  fi

cd ${ns3Dir} && \
cp ${ROOT_PATH}/${modelName}.cc ${ns3Model}.cc && \
./make.sh "$1" && \
  ./waf --run "scratch/${modelName} --helicsConfig=${helicsConfig} --microGridConfig=${microGridConfig} --topologyConfig=${topologyConfig} --pointFileDir=${configDir} --pcapFileDir=$pcapFileDir" >> ${ns3OutFile} 2>&1 & \
  cd -

if [[ "$3" == "RC" ]]
then
wait
fi

exit 0
