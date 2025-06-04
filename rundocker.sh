docker run -it -d --name=natigbase_container \
    -v "$(pwd)://rd2c/" \
    pnnl/natig:natigbase bash