ARG ubuntu_version=22.04
ARG node_version=22
ARG occt_version=7.8.1
ARG cgal_version=6.0.1
ARG eigen_version=3.4.0
ARG nvm_version=0.40.1
ARG rapidjson_version=1.1.0
ARG asi_version=7f854316
ARG asi_version_mode=commit

# Conditional setup of the asi version based on commit or release
FROM continuumio/miniconda3 AS build-base

FROM build-base AS build-release
ARG asi_version
ONBUILD ENV ASI_VERSION=v${asi_version}

FROM build-base AS build-commit
ARG asi_version
ONBUILD ENV ASI_VERSION=${asi_version}

# Conda temporary image
FROM build-${asi_version_mode} AS conda
ARG cgal_version
ARG occt_version
ARG eigen_version
ARG rapidjson_version

ENV PATH=/opt/conda/bin:$PATH

RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
    build-essential \
    cmake \
    libx11-dev \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install conda packages
RUN conda config --add channels conda-forge
RUN conda install -y cgal-cpp=$cgal_version occt=$occt_version eigen=$eigen_version anaconda::rapidjson=$rapidjson_version

RUN mkdir /sources
WORKDIR /sources

# Build Analysis Situs
RUN mkdir /sources/analysis-situs
RUN wget https://gitlab.com/ssv/AnalysisSitus/-/archive/$ASI_VERSION/AnalysisSitus-$ASI_VERSION.tar.gz
RUN tar zxvf AnalysisSitus-$ASI_VERSION.tar.gz --strip-components=1 -C /sources/analysis-situs

WORKDIR /sources/analysis-situs

RUN mkdir -p build

WORKDIR /sources/analysis-situs/build
RUN cmake .. \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=/opt/conda \
    -DCMAKE_INSTALL_RPATH="" \
    -DINSTALL_DIR=/opt/conda \
    -DDISTRIBUTION_TYPE=Algo \
    -D3RDPARTY_DIR=/opt/conda/lib \
    -D3RDPARTY_OCCT_INCLUDE_DIR=/opt/conda/include/opencascade \
    -D3RDPARTY_OCCT_LIBRARY_DIR=/opt/conda/lib \
    -D3RDPARTY_EIGEN_DIR=/opt/conda/include/eigen3 \
    -D3RDPARTY_rapidjson_DIR=/opt/conda/include \
    -DUSE_RAPIDJSON=on \
    -DUSE_MOBIUS=off \
    -DUSE_INSTANT_MESHES=off \
    -DUSE_NETGEN=off \
    -DUSE_THREADING=off
RUN make -j $(nproc)
RUN make -j $(nproc) install

# Target image
FROM "ubuntu:$ubuntu_version"
ARG node_version
ARG nvm_version
ARG conda_path=/opt/conda
ARG local_dir=/usr/local
ARG nvm_dir=$local_dir/nvm
ARG nvm_link_node_modules=$local_dir/nvm-node-modules
ARG nvm_link_path=$local_dir/nvm-path

# Install curl
RUN apt-get update && apt-get install -y curl \
    && rm -rf /var/lib/apt/lists/*

# Install nvm and node
ENV NVM_NODEJS_ORG_MIRROR=https://unencrypted.nodejs.org/download/release
ENV NVM_DIR=$nvm_dir
RUN mkdir $nvm_dir
RUN curl https://raw.githubusercontent.com/nvm-sh/nvm/v$nvm_version/install.sh | bash \
    && . $nvm_dir/nvm.sh \
    && nvm install $node_version \
    && nvm alias default $node_version \
    && nvm use default

# Create symlinks for newly installed node
# with major version only support
RUN . $nvm_dir/nvm.sh \
    && current=$(nvm current) \
    && ln -s $nvm_dir/$current/lib/node_modules $nvm_link_node_modules \
    && ln -s $nvm_dir/versions/node/$current/bin $nvm_link_path

# Set environment variables
ENV NODE_PATH=$nvm_link_node_modules
ENV PATH=$nvm_link_path:$PATH

# Install yarn
RUN npm i -g yarn

# Copy conda libraries
COPY --from=conda $conda_path/include $conda_path/include
COPY --from=conda $conda_path/lib $conda_path/lib
COPY --from=conda $conda_path/share $conda_path/share
