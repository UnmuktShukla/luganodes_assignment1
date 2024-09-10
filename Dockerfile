FROM ubuntu:22.04
LABEL authors="unmuktshukla-21BAI1756"

# installing dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    git \
    libtool \
    autoconf \
    cmake \
    pkg-config \
    libffi-dev \
    libgmp-dev \
    libssl-dev \
    curl \
    libsodium-dev \
    g++ \
    cabal-install \
    jq

#cloning libsodium
RUN git clone https://github.com/intersectmbo/libsodium && \
    cd libsodium && \
    git checkout 66f017f1 && \
    ./autogen.sh && ./configure && make && make install

#set path for libsodium
ENV LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
ENV PKG_CONFIG_PATH="/usr/local/pkgconfig:$PKG_CONFIG_PATH"

# Cloning the cardano-node
RUN git clone https://github.com/IntersectMBO/cardano-node.git && \
    cd cardano-node && \
    git fetch --all --tags && \
    git checkout tags/9.1.1

#building cardano-node
WORKDIR cardano-node
RUN cabal update && cabal build cardano-node cardano-cli

#built binaries to /usr/local/bin for easy access
RUN cp -r dist-newstyle/build/x86_64-linux/ghc-*/cardano-node-*/x/cardano-node/build/cardano-node/cardano-node /usr/local/bin/ && \
    cp -r dist-newstyle/build/x86_64-linux/ghc-*/cardano-cli-*/x/cardano-cli/build/cardano-cli/cardano-cli /usr/local/bin/

CMD ["/bin/bash"]