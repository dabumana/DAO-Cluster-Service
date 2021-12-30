# Docker image to generate deterministic, verifiable builds of Anchor programs. This must be 
# run *after* a given ANCHOR_CLI version is published and a git tag is released on GitHub.
#

FROM ubuntu:18.04

ARG DEBIAN_FRONTEND=noninteractive

ENV NODE_VERSION="v17.0.1"
ENV HOME="/root"
ENV PATH="${HOME}/.cargo/bin:${PATH}"
ENV PATH="${HOME}/.local/share/solana/install/active_release/bin:${PATH}"
ENV PATH="${HOME}/.nvm/versions/node/${NODE_VERSION}/bin:${PATH}"

# Install base utilities.
RUN mkdir -p /workdir && mkdir -p /tmp && \
    apt-get update -qq && apt-get upgrade -qq && apt-get install -qq \
    build-essential git curl wget jq pkg-config python3-pip \
    libssl-dev libudev-dev apt-utils

# Install rust.
RUN curl "https://sh.rustup.rs" -sfo rustup.sh && \
    sh rustup.sh -y && \
    rustup component add rustfmt clippy

# Install node / npm / yarn.
RUN curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash
ENV NVM_DIR="${HOME}/.nvm"
RUN . $NVM_DIR/nvm.sh && \
    nvm install ${NODE_VERSION} && \
    nvm use ${NODE_VERSION} && \
    nvm alias default node && \
    npm install -g yarn @project-serum/anchor-cli npm@8.3.0

# Install Solana tools.
RUN curl -sSfL https://release.solana.com/v1.9.2/install | bash -

COPY ./src /workdir

WORKDIR /workdir
