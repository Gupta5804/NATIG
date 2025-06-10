# ==============================================================================
#           OPTIMIZED DOCKERFILE FOR NATIG DEVELOPMENT ENVIRONMENT
#
# This Dockerfile uses a multi-stage build to create a clean, correct,
# and smaller final image for your development work.
#
# Stage 1: The "builder" stage compiles all C++ dependencies.
# Stage 2: The final "runtime" stage copies only the necessary
#          artifacts, resulting in a lean and stable environment.
#
# ==============================================================================

#-------------------------------------------------------------------------------
# STAGE 1: The Builder
#
# We use a full-featured Debian base to install build tools and compile all
# the C++ dependencies (ZMQ, HELICS, GridLAB-D) from source.
#-------------------------------------------------------------------------------
FROM debian:buster AS builder

# Set an argument to avoid interactive prompts during package installation
ARG DEBIAN_FRONTEND=noninteractive

# --- 1. Install all necessary build tools and developer libraries ---
# This single, consolidated command installs all prerequisites.
# It includes the essential '-dev' packages that were missing before.
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    cmake \
    wget \
    autoconf \
    automake \
    libtool \
    m4 \
    ca-certificates \
    libboost-all-dev \
    libzmq3-dev \
    libsqlite3-dev \
    libpcap-dev \
    libxml2-dev \
    libjsoncpp-dev \
    python3-dev \
    python3-pip \
    vim \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Build and install HELICS from source ---
# We compile HELICS and install it to the standard /usr/local directory.
RUN cd /opt && \
    git clone https://github.com/GMLC-TDC/HELICS -b v2.7.1 && \
    cd HELICS && \
    mkdir build && cd build && \
    cmake -DHELICS_BUILD_CXX_SHARED_LIB=ON -DCMAKE_INSTALL_PREFIX=/usr/local ../ && \
    make -j$(nproc) && \
    make install

# --- 3. Build and install GridLAB-D from source ---
# This correctly builds Xerces-C first, then uses it to build GridLAB-D.
# Everything is installed to /usr/local, making it available system-wide.
RUN cd /opt && \
    git clone https://github.com/gridlab-d/gridlab-d.git -b v4.3 --single-branch && \
    cd gridlab-d/third_party && \
    tar -xzf xerces-c-3.2.0.tar.gz && \
    cd xerces-c-3.2.0 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && \
    make install && \
    cd /opt/gridlab-d && \
    autoreconf -if && \
    ./configure --with-helics=/usr/local --prefix=/usr/local --enable-silent-rules 'CXXFLAGS=-std=c++14' && \
    make -j$(nproc) && \
    make install

#-------------------------------------------------------------------------------
# STAGE 2: The Final Runtime Image
#
# We start from your preferred lightweight Python base. We then copy only
# what is strictly necessary from the builder stage.
#-------------------------------------------------------------------------------
FROM python:3.6-slim

# Set an argument to avoid interactive prompts
ARG DEBIAN_FRONTEND=noninteractive

# --- 1. Install only essential RUNTIME packages ---
# We don't need the heavyweight build tools in the final image.
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    vim \
    procps \
    libzmq5 \
    libjsoncpp-dev \
    libxml2 \
    # The GridLAB-D runtime depends on OpenMPI
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Copy compiled artifacts from the builder stage ---
# This copies the compiled binaries and libraries for HELICS and GridLAB-D
# from the builder stage into our final image.
COPY --from=builder /usr/local/ /usr/local/

# --- 3. Install Python dependencies ---
RUN pip3 install --no-cache-dir helics==2.7.1 helics-apps==2.7.1

# --- 4. Prepare the working directory ---
# The ns-3-dev directory will be provided by your bind mount.
RUN mkdir -p /rd2c
WORKDIR /rd2c

# --- 5. Set up the final environment ---
# This ensures that all executables and libraries can be found.
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

# Set the container to stay running
CMD sleep infinity
