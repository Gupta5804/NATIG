docker build --network=host -f Dockerfile -t pnnl/natig:natigbase --no-cache .
winpty docker run -it --name=natigbase_container pnnl/natig:natigbase bash
