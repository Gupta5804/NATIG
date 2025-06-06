#!/bin/bash
#
# This script runs the NATIG Docker container with a proper bind mount.
# It must be run from the root directory of your NATIG repository.

# We will use $(pwd) to get the current directory path.
HOST_PATH="$(pwd)"

# The "MSYS_NO_PATHCONV=1" prefix is the key.
# It temporarily disables the automatic path conversion that Git Bash
# performs on arguments with colons, which corrupts the -v flag.
# This ensures a path like "/c/My/Path:/container/path" is passed to Docker correctly.
MSYS_NO_PATHCONV=1 docker run -it -d --name=natigbase_container \
    -v "${HOST_PATH}:/rd2c" \
    pnnl/natig:natigbase bash