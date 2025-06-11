#!/bin/bash

# Path to the NATIG source (defaults to ${NATIG_SRC})
NATIG_SRC="${NATIG_SRC:-${RD2C:-/rd2c}/PUSH/NATIG}"

echo "WARNING: If you use this script make sure to hardcode the port of helics in run.sh to the same value as the one set by brokerport in gridlabd_config.json"

docker cp RC/code/$2 $1:/rd2c/integration/control/$3
docker cp RC/code/run.sh $1:/rd2c/integration/control/
docker cp RC/code/$4-conf-$5/ $1:${NATIG_SRC}/RC/code/

docker exec -i $1 /bin/sh -c "cd /rd2c/integration/control/;sudo bash run.sh /rd2c/ $4 \"RC\" $5 conf H "
