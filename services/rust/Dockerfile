FROM ubuntu:20.04
RUN apt-get update && apt-get upgrade -y && apt-get install curl wget -y
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -y| bash -
RUN curl -sSfL https://release.solana.com/v1.9.2/install | bash -
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - 
RUN source $HOME/.cargo/env
RUN rustup component add rustfmt
RUN apt-get install nodejs -y
RUN npm i -g @project-serum/anchor-cli
RUN npm i -g yarn -y
RUN anchor init app