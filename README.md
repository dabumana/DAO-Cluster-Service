![GitHub license](https://img.shields.io/github/license/dabumana/solana-contributor-resources)
# DAO Cluster Service - Cluster node service with a DAO
#### Developer walk-through :feelsgood:
##### 1. Introduction
The arise of new technologies merged in a context where the documentation and development roadmap should point to the real use case, allowing the simplification of the process and the learning curve, bringing support and stability even through the different types of changes and challenges that will be faced during the development stage of the project, having this in mind, the early adoption of technologies that are not fully tested in a real scenario could lead to significant looses and misdirection, but the development always can be controlled with a constant review about the framework/engine until an stable version can be the standard of the industry to be applied.

Solana is not Ethereum, can be used as a "Ethereum killer" due to the improvements that offers over it, but it doesn't mean that it should be considered the best fit in all the cases, these second generation blockchains are focus in the user necessities and not completely in the over production of computing power to resolve blocks, this is why the protocols behind keeps the sustainability as a main objective, if it is or not effective, should be evaluated through a comparison and application of use cases, basically each framework has their own pros and cons according to the necessities of the project.

This walkthrough it's to evaluate the actual precepts behind Solana and how they are applied in a real case scenario, recreating a production environment locally for it. 

##### 2. Background
Three aspects are the Aquiles heel, when we talk about Blockchain development, completely focus in scalability, performance and concurrence, are the main concern inside the organizations these days, even when it sounds good the idea to have a Hyper-distributed hashed database for a particular application, requires more than a couple of servers to have a proper environment that can fit today's standards and requirements, even when we talk about decentralized systems, the architecture behind still needs a policy protocol to handle the resources according to the growing of the user database, what we should have in mind if we want to provide BaaS, their implications and sustainability trough the time

### How it works?
As an industrial cluster it should integrate the replication concept for further scalability and maintainability , a set of defined parameters and policies to apply according to the necessities of the service.

You will find a composed file that can be deployed through `docker-compose` with an initial scaffold for further development, Anchor tool-set, ELK stack for monitoring and multiple Solana nodes with a limited set of resources, that can be easily changed before the deployment stage, keep in mind that you need to specify the resources in the file before running the cluster, version compatibility tested 3.3 - 3.6.

##### Notes: It can be converted to be used with `kubernetes` with this [tool](https://github.com/kubernetes/kompose).

The objective is to have a environment with a minor implementation of the CPI that can shows the integration and can evaluate the features of Solana as a complement for concurrent tasks in a service mesh.

### What we are going to test?
A basic implementation of a node service that integrates Solana where we can interact with the main features that the SDK provides for the developers.

### Why I need to orchestrate ? 
If your objective it's to simplify and bring agility to the development process with a proper setup of the environment and have a **control** over the resources with a set of metrics **in a single interface**.

**You can extend the nodes and details of the cluster if you want to add some other frameworks.**

##### 3. Solana Architecture
##### General Overview
[Solana Labs](https://github.com/solana-labs) provides a set of tools to develop applications from the client side or on-chain programs that can be consequentially interacting with the cluster,  even some examples related to the application in a real use case, but in some cases the explanation itself it's not fully clear and you need to take a look at the details, the type of details that are a defining factor between security and coding best practices.

Solana promotes 8 conceptual features behind their product that are key values for understanding the actual conformation of modules and rules that handles the replication of nodes and accounts, so everything must be defined as an account model that can be a data account or program account.

***Core Features:***
* Turbine: Comes to solve the scalability Trilemma through a process inspired in BitTorrent called block propagation protocol (BPP) but with a few differences including the fault tolerance, in case that a malicious propagation of a block starts to come, can be easily recreated from a verified chunk of that transaction, and the validators that are an essential component of Solana, in charge of validate the data integrity before replicating, according to their neighborhood and leader.
 
* Gulf Stream: A memory pool caching and forwarding system for the network, allowing the implementation of transactions ahead of time, reduce confirmation values from the unconfirmed transaction pool, it's only possible with a deterministic leader, basically trough the validation of previous confirmed blocks that can integrate an additional block on top of this, can be used with the last 32 blocks in the memory pool.

* Pipelining: Is an apropiate process to optimize the performance and consumption of resources delivering a proper balance for transactions between validators, maximizing their efficiency, developing a four stage transaction processor in software called TPU (Transaction Processing Unit), is the main handler of the transactions and all the process linked to it.

* Cloudbreak: This is one of the main features about Solana, including the possibility of horizontally scale the architecture to the virtual memory stack, and it this distributed in the following:
* 1.  The index of accounts and forks is stored in RAM.
* 2.  Accounts are stored in memory-mapped files up to 4MB in size.
* 3.  Each memory map only stores accounts from a single proposed fork.
* 4.  Maps are randomly distributed across as many SSDs as are available.
* 5.  Copy-on-write semantics are used.
* 6.  Writes are appended to a random memory map for the same fork.
* 7.  The index is updated after each write is completed.

* Sealevel: One of their main features of SVM, is the ability to validate transactions in multiple threads, applying a very simple but effective solution, just added the possibility to "describe all the states a transaction will read or write while executing", Cloudbreak is part of the process, allowing Sealevel Runtime rely on the data vector in the accounts, supported by a set of rules, each instruction already includes the accounts that wants to read and write ahead of time.
* 1.  Sort millions of pending transactions.
* 2.  Schedule all the non-overlapping transactions in parallel.

##### ***State Transition Rules***
1.  Programs can only change the data of accounts they own.
2.  Programs can only debit accounts they own.
3.  Any program can credit any account.
4.  Any program can read any account.

##### ***Global Rules***

1.  System Program is the only program that can assign account ownership.
2.  System Program is the only program that can allocate zero-initialized data.
3.  Assignment of account ownership can only occur once in the lifetime of an account.

##### ***How to load a custom program?***
1.  Create a new public key.
2.  Transfer coin to the key.
3.  Tell System Program to allocate memory.
4.  Tell System Program to assign the account to the Loader.
5.  Upload the bytecode into the memory in pieces.
6.  Tell Loader program to mark the memory as executable.

***In-Progress Core Features:***
* Archivers / Replicators: 
* ***Note***: this ledger replication solution was partially implemented, but not completed. The partial implementation was removed by [https://github.com/solana-labs/solana/pull/9992](https://github.com/solana-labs/solana/pull/9992) in order to prevent the security risk of unused code. The first part of this design document reflects the once-implemented parts of ledger replication. The [second part of this document](https://docs.solana.com/proposals/ledger-replication-to-implement#ledger-replication-not-implemented) describes the parts of the solution never implemented.

***Protocol Features:***
* Proof of History (PoH): Timestamp hash service before consensus to determine the state, input data and count, the verification entirely occurs in the CPU/GPU side to optimize the use of the cores, while the recorded sequence can only be generated on a single CPU core, the output can be verified in parallel. 

* Proof of Replication (PoR): The basic idea to Proof of Replication is encrypting a dataset with a public symmetric key using CBC encryption, then hash the encrypted dataset. The main problem with the naive approach is that a dishonest storage node can stream the encryption and delete the data as it's hashed. The simple solution is to periodically regenerate the hash based on a signed PoH value

* TBFT (Tower Byzantine Fault Tolerance): Their own implementation of the PBFT [Practical Byzantine Fault Tolerance](https://pmg.csail.mit.edu/papers/osdi99.pdf) designed to be used alongside with PoH as a timestamp and verifiable delay function, the basic principle about how PoH is applied during this stage is the following:
* 1.  Sha256 loops as fast as possible, such that each output is the next input.
* 2.  The loop is sampled, and the number of iterations and state are recorded.
The recorded sample that represent the passage of time encoded is a verifiable data structure and can be used to record some events like:
* 1.  Messages that reference any of the samples are guaranteed to have been created after the sample.
* 2.  Messages can be inserted into the loop and hashed together with the state. This guarantees that a message was created before the next insert.
PoH in ledger side: 
* 1. All the nodes that examine this data structure will compute the exact same result, _without requiring any peer-to-peer communication._
* 2. The PoH hash uniquely identifies that fork of the ledger 
* 3. A validation vote message is only valid if the PoH hash that it voted on is present in the ledger.

This brings us to voting and PBFT. Since the ledger itself works as a reliable network clock, we can encode the PBFT time-outs in the ledger itself.

* 1. A vote starts with a time-out of N hashes.

A Validator guarantees (with slashing) that once a vote for a PoH hash has been cast, the Validator will not vote for any PoH hash that is not a child of that vote, for at least N hashes.

* 2. The time-outs for all the predecessor votes double

The network has a potential rollback point, but every subsequent vote doubles the amount of real time that the network would have to stall before it can unroll that vote.

A vast majority of example are already stored in the [solana-program-library](https://github.com/solana-labs/solana-program-library/tree/master/examples), these programs can be developed in Rust or C and tested very easily, just run `make`. 

##### 4. Cluster Design
![alt text](https://github.com/dabumana/Solana-Contributor-Resources/blob/main/images/ClusterDesign.drawio.png)
##### 5. Technological Stack
##### [Solana](https://solana.com/) - *Solana is a decentralized blockchain built to enable scalable apps.*
##### [Rust](https://rustup.rs/) - *Rust Programmin Language Installer*
##### [ElasticSearch](https://www.elastic.co/) - *It provides a distributed, [multitenant](https://en.wikipedia.org/wiki/Multitenancy "Multitenancy")-capable [full-text search](https://en.wikipedia.org/wiki/Full-text_search "Full-text search") engine with an [HTTP](https://en.wikipedia.org/wiki/HTTP "HTTP") web interface and schema-free [JSON](https://en.wikipedia.org/wiki/JSON "JSON") documents*.
##### [Kibana](https://elastic.co/) - *Kibana is a free and open user interface that lets you visualize your Elasticsearch data and navigate the Elastic Stack.*
##### [Logstash](https://elastic.co/) - *Logstash is a free and open server-side data processing pipeline that ingests data from a multitude of sources*.
##### [Nginx](https://www.nginx.com/) - *Advanced Load Balancer, Web Server and Reverse Proxy*.
##### [Docker](https://docs.docker.com/get-docker/) - *Docker is an open platform for developing, shipping, and running applications. Docker enables you to separate your applications from your infrastructure so you can deliver software quickly.*
##### [Docker Compose](https://docs.docker.com/compose/install/) - *`docker-compose` is a tool for defining and running multi-container _Docker_ applications. With _Compose_, you use a YAML file to configure your application's services.*
##### [Minikube](https://minikube.sigs.k8s.io/docs/start/) - *`minikube` is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes*.
##### Toolset:
##### [Anchor](https://github.com/project-serum/anchor) - *Anchor is a framework for Solana's [Sealevel](https://medium.com/solana-labs/sealevel-parallel-processing-thousands-of-smart-contracts-d814b378192) runtime providing several convenient developer tools for writing smart contracts.*
##### 6. Requirements
I really suggest you to deploy a local production environment through a virtualized environment, you can take a look at the options at the market, but as a standard practice you can abstract the environment with a proper cypher in a external Disk (LUKS / BitLocker), just a best practice suggestion, with a proper VPN for further access keeping separated the internal Host from the bridged connection, in case that you have your own security operation protocol, just proceed and install the libraries required for it.
##### Linux
* Update your system library
```
$ sudo apt-get update
$ sudo apt-get upgrade -y
$ sudo apt-get install curl wget git nodejs libssl-dev libudev-dev pkg-config zlib1g-dev llvm clang make
```
* Install `docker` (Optional for testing)
```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ curl -sSL https://get.docker.com/ | sudo sh
```
* Post-Installation `docker`, execute it as a non-root user (Optional for testing)
```
$ sudo groupadd docker
$ sudo usermod -aG docker $USER
$ newgrp docker
$ docker run hello-world
```
* Install `kompose` (Optional for testing)
```
$ curl -L https://github.com/kubernetes/kompose/releases/download/v1.26.0/kompose-linux-amd64 -o kompose
$ chmod +x kompose
$ sudo mv ./kompose /usr/local/bin/kompose
$ sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
* Install `docker-compose` (Optional)
```
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```
* Install `minikube` (Optional)
```
$ curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
$ sudo install minikube-linux-amd64 /usr/local/bin/minikube

```
* Install `cargo`, `rustup`, `rust`
```
$ curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
$ source $HOME/.cargo/env
$ rustup component add rustfmt
$ rustup update
```
##### Windows
In windows you can run a subsystem environment with `WSL2`:
* Install [`WSL2`](https://docs.microsoft.com/en-us/windows/wsl/install-manual)
* Once you have the subsystem installed, follow the same steps used for `linux`
##### 7. Installation
##### **In this stage you will configure the framework for development use.**
#### **Optional Testing steps**
* If you already installed the Optional testing requirements just clone this repository and run it:
```
$ git clone https://github.com/dabumana/Solana-Contributor-Resources
$ docker-compose up
```

#### **Standard Installation**
* Install `Solana`
```
$ sh -c "$(curl -sSfL https://release.solana.com/v1.8.0/install)"
```
* Install `yarn`
```
$ npm install -g yarn
```
* Install `anchor`
```
$ npm i -g @project-serum/anchor-cli
```
* Any other operative system use this
```
$ cargo install --git https://github.com/project-serum/anchor --tag v0.19.0 anchor-cli --locked
```
* If `cargo install` fails install the following dependencies
```
$ sudo apt-get update && sudo apt-get upgrade && sudo apt-get install -y pkg-config build-essential libudev-dev
```
* Now verify the installation
```
$ anchor --version
```
#### **Solana first steps**

The following commands can hep you to generate your keys and validate the general attributes of an account.

```
solana --help / Receive information from any particular command

solana config get / Receive information about your current node linked to the environment
solana config set --url <URL> / You can assign a particular node to be used with the cli tool, 
				in case that you don't have one, use this test net htps://api.devnet.solana.com 

solana --version / Get solana version
solana cluster-version / Get cluster version

solana address / Get current account address

solana-keygen new -o <PATH>/id.json / Generate a new account wallet

solana account <ADDRESS> / Get full details about the addressed account
solana-test-validator / Deploy a local solana validator node (used just for Development purposes)

solana confirm -v / Get transanction block explorer

solana balance / Check the current balance in your account

solana airdrop <AMOUNT> / Use test token for development purposes

solana program deploy <BINARY_PATH> / After you generate the build with anchor an binary it will be generated, 
				      you can run that program with this command
```

#### **Want to know more?**
Take a look at the official documentation provided by `Solana-Labs`
* 1. Clone the repositories to understand with examples how it works
```
$ git clone https://github.com/solana-labs/solana
$ git clone https://github.com/solana-labs/solana-program-library
$ git clone https://github.com/solana-labs/rbpf
```
##### 8. PoC
You can grab a copy of the content used directly with this [link](https://github.com/dabumana/solana-contributor-resources).
##### *If you have all the requirements installed in your workstation just run `docker-compose up`*.
##### 9. Developer Best Practices
* Keep an isolated environment for testing, generate your `keys` for accessing remotely in case that you are using a remote server.
* Add a whitelist to receive just the connection just from a determined IP.
* Configure `iptables`.
* Always check `AccountInfo::owner` to validate the current user.
* Verify that the call from an entity has been signed properly `AccountInfo::is_signer`.
* Use [checked math](https://doc.rust-lang.org/book/ch03-02-data-types.html#integer-overflow) and [checked casts](https://doc.rust-lang.org/std/convert/trait.TryFrom.html) whenever possible to avoid unintentional and possibly malicious behavior.
* Always verify the `pubkey` of any program invoked via `invoke_signed()`.
* Ensure that the account data has the type you expect it to have.
