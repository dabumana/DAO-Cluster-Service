FROM solanalabs/rust-nightly
RUN sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y pkg-config build-essential libudev-dev npm
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
RUN source $HOME/.cargo/env
RUN rustup component add rustfmt
RUN sh -c "$(curl -sSfL https://release.solana.com/v1.8.0/install)"
RUN npm install -g yarn
RUN anchor init /app

