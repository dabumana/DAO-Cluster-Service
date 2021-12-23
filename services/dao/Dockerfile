FROM solanalabs/rust-nightly

RUN apt-get update && apt-get upgrade -y && apt-get install curl cmake -y

RUN curl -sSfL https://release.solana.com/v1.9.2/install | bash -
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash - 

RUN apt-get install nodejs -y

RUN npm i -g @project-serum/anchor-cli
RUN npm i -g yarn -y

COPY . /www

RUN npm start

EXPOSE 80