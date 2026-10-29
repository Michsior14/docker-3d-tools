ARG ubuntu_version=26.04
ARG node_version=26
ARG occt_version=7.8.1
ARG cgal_version=6.0.2
ARG eigen_version=3.4.0
ARG rapidjson_version=1.1.0
ARG asi_version=10013e2b
ARG asi_version_mode=commit
ARG micromamba_version=2.10.0-debian13

# Conditional setup of the asi version based on commit or release
FROM mambaorg/micromamba:$micromamba_version AS build-base

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

USER root

RUN apt-get update -q && \
    apt-get install -q -y --no-install-recommends \
    build-essential \
    ca-certificates \
    cmake \
    libx11-dev \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install conda packages into the (empty) base environment at /opt/conda
RUN micromamba install -y -n base -c conda-forge \
    cgal-cpp=$cgal_version \
    occt=$occt_version \
    eigen=$eigen_version \
    anaconda::rapidjson=$rapidjson_version \
    && micromamba clean -a -y

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
ARG conda_path=/opt/conda

# Install curl and OpenMP
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Install the latest node release of the requested major version
RUN set -eu \
    && arch="$(dpkg --print-architecture)" \
    && case "$arch" in \
    amd64) node_arch=x64 ;; \
    arm64) node_arch=arm64 ;; \
    *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac \
    && dist="https://nodejs.org/dist/latest-v$node_version.x" \
    && cd /tmp \
    && curl -fsSLO "$dist/SHASUMS256.txt" \
    && file="$(grep -oE "node-v[0-9.]+-linux-$node_arch\.tar\.gz$" SHASUMS256.txt)" \
    && curl -fsSLO "$dist/$file" \
    && grep " $file\$" SHASUMS256.txt | sha256sum -c - \
    && tar -xzf "$file" -C /usr/local --strip-components=1 --no-same-owner \
    --exclude='*.md' --exclude=LICENSE \
    && rm "$file" SHASUMS256.txt \
    && node --version \
    && npm --version

# Install yarn
RUN npm i -g yarn && npm cache clean --force

# Copy conda libraries
COPY --from=conda $conda_path/include $conda_path/include
COPY --from=conda $conda_path/lib $conda_path/lib
COPY --from=conda $conda_path/share $conda_path/share

# Register conda libraries with the dynamic linker (after system libraries)
RUN echo "$conda_path/lib" > /etc/ld.so.conf.d/zz-conda.conf \
    && ldconfig 2>/dev/null
