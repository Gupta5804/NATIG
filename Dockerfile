# ==============================================================================
#           FINAL & COMPLETE DOCKERFILE FOR NATIG DEVELOPMENT
#
# This version ensures all necessary build tools and developer libraries
# (gcc, git, pkg-config, boost, pybindgen, libxml) are present in the
# final image, resolving all known configuration errors.
#
# ==============================================================================

#-------------------------------------------------------------------------------
# STAGE 1: The Builder
# Compiles C++ dependencies (HELICS, GridLAB-D) from source.
#-------------------------------------------------------------------------------
FROM debian:buster AS builder

ARG DEBIAN_FRONTEND=noninteractive

# --- 1. Install all necessary build tools and developer libraries ---
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
    python3-setuptools \
    vim \
    sudo && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Build and install HELICS from source ---
RUN cd /opt && \
    git clone https://github.com/GMLC-TDC/HELICS -b v2.7.1 && \
    cd HELICS && \
    mkdir build && cd build && \
    cmake -DHELICS_BUILD_CXX_SHARED_LIB=ON -DCMAKE_INSTALL_PREFIX=/usr/local ../ && \
    make -j$(nproc) && \
    make install

# --- 3. Build and install GridLAB-D from source ---
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
# Starts from a lightweight base and copies in only what's needed.
#-------------------------------------------------------------------------------
FROM python:3.6-slim

ARG DEBIAN_FRONTEND=noninteractive

# --- 1. Install runtime packages AND ALL ESSENTIAL BUILD TOOLS ---
# This corrected section includes everything needed to configure and compile ns-3.
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    vim \
    procps \
    git \
    build-essential \
    pkg-config \
    libboost-all-dev \
    libzmq5 \
    libjsoncpp-dev \
    libxml2-dev \
    libsqlite3-dev \
    libpcap-dev \
    python3-setuptools \
    openmpi-bin \
    openmpi-common \
    libopenmpi-dev && \
    rm -rf /var/lib/apt/lists/*

# --- 2. Copy compiled artifacts from the builder stage ---
COPY --from=builder /usr/local/ /usr/local/

# --- 3. Install Python dependencies (including pybindgen) ---
RUN pip3 install --no-cache-dir helics==2.7.1 helics-apps==2.7.1 pybindgen==0.22.1

# --- 4. Prepare the working directory ---
# The ns-3-dev directory will be provided by your bind mount.
RUN mkdir -p /rd2c
WORKDIR /rd2c

# --- 5. Set up the final environment ---
ENV PATH=/usr/local/bin:$PATH
ENV LD_LIBRARY_PATH=/usr/local/lib:/usr/local/lib64

# Set the container to stay running
CMD sleep infinity
