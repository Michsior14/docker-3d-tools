ARG ubuntu_version=22.04
ARG node_version=20
ARG occt_version=7.7.2
ARG cgal_version=5.6
ARG eigen_version=3.4.0
ARG nvm_version=0.39.5

# Conda temporary image
FROM continuumio/miniconda3:latest as conda
ARG cgal_version
ARG occt_version

ENV PATH /opt/conda/bin:$PATH

# Install conda packages
RUN conda install -y cgal-cpp=$cgal_version occt=$occt_version eigen=$eigen_version --channel conda-forge

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
ENV NVM_DIR $nvm_dir
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
ENV NODE_PATH $nvm_link_node_modules
ENV PATH $nvm_link_path:$PATH

# Install yarn
RUN npm i -g yarn

# Copy conda libraries
COPY --from=conda $conda_path/include $conda_path/include
COPY --from=conda $conda_path/lib $conda_path/lib
COPY --from=conda $conda_path/share $conda_path/share