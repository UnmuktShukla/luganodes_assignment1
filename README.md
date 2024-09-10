
```markdown
# Cardano Node Build Toolchain Docker

## Introduction

This repository provides a Dockerfile to create a build environment for the Cardano blockchain node (`cardano-node`) and command-line interface (`cardano-cli`). The Dockerfile sets up all necessary libraries and dependencies, including `libsodium`, and uses Cabal (the build system for Haskell) to compile the binaries within a Docker container.

## Key Components

- **cardano-node**: The core Cardano blockchain node.
- **cardano-cli**: The command-line interface to interact with the Cardano network.
- **libsodium**: A cryptographic library required for building the Cardano node.

## Steps Overview

1. **Base Image Setup**: Use Ubuntu as the base image and install necessary dependencies.
2. **Install Prerequisites**: Update package lists and install tools required for building.
3. **Clone and Build Libsodium**: Fetch and compile the `libsodium` library.
4. **Clone and Build Cardano-Node and Cardano-CLI**: Clone the repositories and build the binaries.
5. **Setup**: Place the built binaries in a directory accessible within the container.
6. **Expose Ports**: Expose ports if needed for communication.

## Dockerfile

The Dockerfile includes the following steps:

```dockerfile
# Step 1: Use Ubuntu as the base image
FROM ubuntu:20.04

# Set environment variables to ensure non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Update the package list and install necessary dependencies for building
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    wget \
    libtool \
    autoconf \
    curl \
    libgmp-dev \
    libssl-dev \
    pkg-config \
    automake \
    python3-pip \
    jq \
    libtinfo-dev \
    libsystemd-dev \
    zlib1g-dev \
    cabal-install-3.6 \
    ghc-8.10.7 \
    netbase \
    tmux

# Step 2: Clone and build the libsodium library
RUN git clone https://github.com/input-output-hk/libsodium && \
    cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && ./configure && make && make install

# Set the library path for libsodium
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"

# Step 3: Clone the cardano-node repository and enter its directory
WORKDIR /cardano-node
RUN git clone https://github.com/input-output-hk/cardano-node.git . && \
    git fetch --all --recurse-submodules --tags && \
    git checkout tags/1.33.0

# Step 4: Build cardano-node and cardano-cli using cabal
RUN cabal update && cabal build cardano-node cardano-cli

# Step 5: Copy the built binaries to /usr/local/bin for easy access
RUN cp -r dist-newstyle/build/x86_64-linux/ghc-*/cardano-node-*/x/cardano-node/build/cardano-node/cardano-node /usr/local/bin/ && \
    cp -r dist-newstyle/build/x86_64-linux/ghc-*/cardano-cli-*/x/cardano-cli/build/cardano-cli/cardano-cli /usr/local/bin/

# Step 6: Expose ports for communication (if needed)
EXPOSE 3001
```

## Usage Instructions

1. **Build the Docker Image**: To build the Docker image, run the following command in the directory where the Dockerfile is located:

    ```bash
    docker build -t cardano-toolchain .
    ```

2. **Run the Docker Container**: To create and run a container from the image:

    ```bash
    docker run -it cardano-toolchain /bin/bash
    ```

3. **Verify Installation**: Inside the container, verify that `cardano-node` and `cardano-cli` were built successfully:

    ```bash
    cardano-node --version
    cardano-cli --version
    ```

4. **Access the Built Binaries**: The binaries for `cardano-node` and `cardano-cli` will be available in `/usr/local/bin/` inside the container.

## Conclusion

This Dockerfile provides a reproducible build environment for `cardano-node` and `cardano-cli`, including all necessary dependencies such as `libsodium`. By using Docker, it simplifies the process of setting up the build environment and ensures consistency across different systems.

For any issues or contributions, please open an issue or pull request in this repository.
```

