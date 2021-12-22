
## Solana - Cluster node service
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
##### 10. Terminology
The following terms are used throughout the guide and are officially part of the documentation provided by Solana, in case that a term is not properly listed, you can take a look [here](https://docs.solana.com/terminology).

##### [account](https://docs.solana.com/terminology#account "Direct link to heading") - *A record in the Solana ledger that either holds data or is an executable program.*

##### [account owner](https://docs.solana.com/terminology#account-owner "Direct link to heading") - *The address of the program that owns the account. Only the owning program is capable of modifying the account.*

##### [bank state](https://docs.solana.com/terminology#bank-state "Direct link to heading") - *The result of interpreting all programs on the ledger at a given [tick height](https://docs.solana.com/terminology#tick-height). It includes at least the set of all [accounts](https://docs.solana.com/terminology#account) holding nonzero [native tokens](https://docs.solana.com/terminology#native-token).*

##### [block](https://docs.solana.com/terminology#block "Direct link to heading") - *A contiguous set of [entries](https://docs.solana.com/terminology#entry) on the ledger covered by a [vote](https://docs.solana.com/terminology#ledger-vote). A [leader](https://docs.solana.com/terminology#leader) produces at most one block per [slot](https://docs.solana.com/terminology#slot).*

##### [blockhash](https://docs.solana.com/terminology#blockhash "Direct link to heading") - *A unique value ([hash](https://docs.solana.com/terminology#hash)) that identifies a record (block). Solana computes a blockhash from the last [entry id](https://docs.solana.com/terminology#entry-id) of the block.*

##### [block height](https://docs.solana.com/terminology#block-height "Direct link to heading") - *The number of [blocks](https://docs.solana.com/terminology#block) beneath the current block. The first block after the [genesis block](https://docs.solana.com/terminology#genesis-block) has height one.*

##### [bootstrap validator](https://docs.solana.com/terminology#bootstrap-validator "Direct link to heading") - *The [validator](https://docs.solana.com/terminology#validator) that produces the genesis (first) [block](https://docs.solana.com/terminology#block) of a block chain.*

##### [BPF loader](https://docs.solana.com/terminology#bpf-loader "Direct link to heading") - *The Solana program that owns and loads [BPF](https://docs.solana.com/developing/on-chain-programs/overview#berkeley-packet-filter-bpf) smart contract programs, allowing the program to interface with the runtime.*

##### [client](https://docs.solana.com/terminology#client "Direct link to heading") - *A computer program that accesses the Solana server network [cluster](https://docs.solana.com/terminology#cluster).*

##### [cluster](https://docs.solana.com/terminology#cluster "Direct link to heading") - *A set of [validators](https://docs.solana.com/terminology#validator) maintaining a single [ledger](https://docs.solana.com/terminology#ledger).*

##### [confirmation time](https://docs.solana.com/terminology#confirmation-time "Direct link to heading") - *The wallclock duration between a [leader](https://docs.solana.com/terminology#leader) creating a [tick entry](https://docs.solana.com/terminology#tick) and creating a [confirmed block](https://docs.solana.com/terminology#confirmed-block).*

##### [confirmed block](https://docs.solana.com/terminology#confirmed-block "Direct link to heading") - *A [block](https://docs.solana.com/terminology#block) that has received a [supermajority](https://docs.solana.com/terminology#supermajority) of [ledger votes]*(https://docs.solana.com/terminology#ledger-vote).

##### [control plane](https://docs.solana.com/terminology#control-plane "Direct link to heading") - *A gossip network connecting all [nodes](https://docs.solana.com/terminology#node) of a [cluster](https://docs.solana.com/terminology#cluster).*

##### [cooldown period](https://docs.solana.com/terminology#cooldown-period "Direct link to heading") - *Some number of [epochs](https://docs.solana.com/terminology#epoch) after [stake](https://docs.solana.com/terminology#stake) has been deactivated while it progressively becomes available for withdrawal. During this period, the stake is considered to be "deactivating". More info about: [warmup and cooldown](https://docs.solana.com/implemented-proposals/staking-rewards#stake-warmup-cooldown-withdrawal)*

##### [credit](https://docs.solana.com/terminology#credit "Direct link to heading") - *See [vote credit](https://docs.solana.com/terminology#vote-credit).*

##### [cross-program invocation (CPI)](https://docs.solana.com/terminology#cross-program-invocation-cpi "Direct link to heading") - *A call from one smart contract program to another. For more information, see [calling between programs](https://docs.solana.com/developing/programming-model/calling-between-programs).*

##### [data plane](https://docs.solana.com/terminology#data-plane "Direct link to heading") - *A multicast network used to efficiently validate [entries](https://docs.solana.com/terminology#entry) and gain consensus.*

##### [drone](https://docs.solana.com/terminology#drone "Direct link to heading") - *An off-chain service that acts as a custodian for a user's private key. It typically serves to validate and sign transactions.*

##### [entry](https://docs.solana.com/terminology#entry "Direct link to heading") - *An entry on the [ledger](https://docs.solana.com/terminology#ledger) either a [tick](https://docs.solana.com/terminology#tick) or a [transactions entry](https://docs.solana.com/terminology#transactions-entry).*

##### [entry id](https://docs.solana.com/terminology#entry-id "Direct link to heading") - *A preimage resistant [hash](https://docs.solana.com/terminology#hash) over the final contents of an entry, which acts as the [entry's](https://docs.solana.com/terminology#entry) globally unique identifier.*

##### [epoch](https://docs.solana.com/terminology#epoch "Direct link to heading") - *The time, i.e. number of [slots](https://docs.solana.com/terminology#slot), for which a [leader schedule](https://docs.solana.com/terminology#leader-schedule) is valid.*

##### [fee account](https://docs.solana.com/terminology#fee-account "Direct link to heading") - *The fee account in the transaction is the account that pays for the cost of including the transaction in the ledger. This is the first account in the transaction. This account must be declared as Read-Write (writable) in the transaction since paying for the transaction reduces the account balance.*

##### [finality](https://docs.solana.com/terminology#finality "Direct link to heading") - *When nodes representing 2/3rd of the [stake](https://docs.solana.com/terminology#stake) have a common [root](https://docs.solana.com/terminology#root).*

##### [fork](https://docs.solana.com/terminology#fork "Direct link to heading") - *A [ledger](https://docs.solana.com/terminology#ledger) derived from common entries but then diverged.*

##### [genesis block](https://docs.solana.com/terminology#genesis-block "Direct link to heading") - *The first [block](https://docs.solana.com/terminology#block) in the chain.*

##### [genesis config](https://docs.solana.com/terminology#genesis-config "Direct link to heading") - *The configuration file that prepares the [ledger](https://docs.solana.com/terminology#ledger) for the [genesis block](https://docs.solana.com/terminology#genesis-block).*

##### [hash](https://docs.solana.com/terminology#hash "Direct link to heading") - *A digital fingerprint of a sequence of bytes.*

##### [inflation](https://docs.solana.com/terminology#inflation "Direct link to heading") - *An increase in token supply over time used to fund rewards for validation and to fund continued development of Solana.*

##### [instruction](https://docs.solana.com/terminology#instruction "Direct link to heading") - *The smallest contiguous unit of execution logic in a [program](https://docs.solana.com/terminology#program). An instruction specifies which program it is calling, which accounts it wants to read or modify, and additional data that serves as auxiliary input to the program. A [client](https://docs.solana.com/terminology#client) can include one or multiple instructions in a [transaction](https://docs.solana.com/terminology#transaction). An instruction may contain one or more [cross-program invocations](https://docs.solana.com/terminology#cross-program-invocation-cpi).*

##### [keypair](https://docs.solana.com/terminology#keypair "Direct link to heading") - *A [public key](https://docs.solana.com/terminology#public-key-pubkey) and corresponding [private key](https://docs.solana.com/terminology#private-key) for accessing an account.*

##### [lamport](https://docs.solana.com/terminology#lamport "Direct link to heading") - *A fractional [native token](https://docs.solana.com/terminology#native-token) with the value of 0.000000001 [sol](https://docs.solana.com/terminology#sol).*

##### [leader](https://docs.solana.com/terminology#leader "Direct link to heading") - *The role of a [validator](https://docs.solana.com/terminology#validator) when it is appending [entries](https://docs.solana.com/terminology#entry) to the [ledger](https://docs.solana.com/terminology#ledger).*

##### [leader schedule](https://docs.solana.com/terminology#leader-schedule "Direct link to heading") - *A sequence of [validator](https://docs.solana.com/terminology#validator) [public keys](https://docs.solana.com/terminology#public-key-pubkey) mapped to [slots](https://docs.solana.com/terminology#slot). The cluster uses the leader schedule to determine which validator is the [leader](https://docs.solana.com/terminology#leader) at any moment in time.*

##### [ledger](https://docs.solana.com/terminology#ledger "Direct link to heading") - *A list of [entries](https://docs.solana.com/terminology#entry) containing [transactions](https://docs.solana.com/terminology#transaction) signed by [clients](https://docs.solana.com/terminology#client). Conceptually, this can be traced back to the [genesis block](https://docs.solana.com/terminology#genesis-block), but an actual [validator](https://docs.solana.com/terminology#validator)'s ledger may have only newer [blocks](https://docs.solana.com/terminology#block) to reduce storage, as older ones are not needed for validation of future blocks by design.*

##### [ledger vote](https://docs.solana.com/terminology#ledger-vote "Direct link to heading") - *A [hash](https://docs.solana.com/terminology#hash) of the [validator's state](https://docs.solana.com/terminology#bank-state) at a given [tick height](https://docs.solana.com/terminology#tick-height). It comprises a [validator's](https://docs.solana.com/terminology#validator) affirmation that a [block](https://docs.solana.com/terminology#block) it has received has been verified, as well as a promise not to vote for a conflicting [block](https://docs.solana.com/terminology#block) (i.e. [fork](https://docs.solana.com/terminology#fork)) for a specific amount of time, the [lockout](https://docs.solana.com/terminology#lockout) period.*

##### [light client](https://docs.solana.com/terminology#light-client "Direct link to heading") - *A type of [client](https://docs.solana.com/terminology#client) that can verify it's pointing to a valid [cluster](https://docs.solana.com/terminology#cluster). It performs more ledger verification than a [thin client](https://docs.solana.com/terminology#thin-client) and less than a [validator](https://docs.solana.com/terminology#validator).*

##### [loader](https://docs.solana.com/terminology#loader "Direct link to heading") - *A [program](https://docs.solana.com/terminology#program) with the ability to interpret the binary encoding of other on-chain programs.*

##### [lockout](https://docs.solana.com/terminology#lockout "Direct link to heading") - *The duration of time for which a [validator](https://docs.solana.com/terminology#validator) is unable to [vote](https://docs.solana.com/terminology#ledger-vote) on another [fork](https://docs.solana.com/terminology#fork).*

##### [native token](https://docs.solana.com/terminology#native-token "Direct link to heading") - *The [token](https://docs.solana.com/terminology#token) used to track work done by [nodes](https://docs.solana.com/terminology#node) in a cluster.*

##### [node](https://docs.solana.com/terminology#node "Direct link to heading") - *A computer participating in a [cluster](https://docs.solana.com/terminology#cluster).*

##### [node count](https://docs.solana.com/terminology#node-count "Direct link to heading") - *The number of [validators](https://docs.solana.com/terminology#validator) participating in a [cluster](https://docs.solana.com/terminology#cluster).*

##### [point](https://docs.solana.com/terminology#point "Direct link to heading") - *A weighted [credit](https://docs.solana.com/terminology#credit) in a rewards regime. In the [validator](https://docs.solana.com/terminology#validator) [rewards regime](https://docs.solana.com/cluster/stake-delegation-and-rewards), the number of points owed to a [stake](https://docs.solana.com/terminology#stake) during redemption is the product of the [vote credits](https://docs.solana.com/terminology#vote-credit) earned and the number of **lamports** staked.*

##### [private key](https://docs.solana.com/terminology#private-key "Direct link to heading") - *The private key of a [keypair](https://docs.solana.com/terminology#keypair).*

##### [program](https://docs.solana.com/terminology#program "Direct link to heading") - *The code that interprets [instructions](https://docs.solana.com/terminology#instruction).*

##### [program derived account (PDA)](https://docs.solana.com/terminology#program-derived-account-pda "Direct link to heading") - *An account whose owner is a program and thus is not controlled by a private key like other accounts.*

##### [program id](https://docs.solana.com/terminology#program-id "Direct link to heading") - *The public key of the [account](https://docs.solana.com/terminology#account) containing a [program](https://docs.solana.com/terminology#program).*

##### [proof of history (PoH)](https://docs.solana.com/terminology#proof-of-history-poh "Direct link to heading") - *A stack of proofs, each which proves that some data existed before the proof was created and that a precise duration of time passed before the previous proof. Like a [VDF](https://docs.solana.com/terminology#verifiable-delay-function-vdf), a Proof of History can be verified in less time than it took to produce.*

##### [public key (pubkey)](https://docs.solana.com/terminology#public-key-pubkey "Direct link to heading") - *The public key of a [keypair](https://docs.solana.com/terminology#keypair).*

##### [root](https://docs.solana.com/terminology#root "Direct link to heading") - *A [block](https://docs.solana.com/terminology#block) or [slot](https://docs.solana.com/terminology#slot) that has reached maximum [lockout](https://docs.solana.com/terminology#lockout) on a [validator](https://docs.solana.com/terminology#validator). The root is the highest block that is an ancestor of all active forks on a validator. All ancestor blocks of a root are also transitively a root. Blocks that are not an ancestor and not a descendant of the root are excluded from consideration for consensus and can be discarded.*

##### [Sealevel](https://docs.solana.com/terminology#sealevel "Direct link to heading") - *Solana's parallel smart contracts run-time.*

##### [shred](https://docs.solana.com/terminology#shred "Direct link to heading") - *A fraction of a [block](https://docs.solana.com/terminology#block); the smallest unit sent between [validators](https://docs.solana.com/terminology#validator).*

##### [signature](https://docs.solana.com/terminology#signature "Direct link to heading") - *A 64-byte ed25519 signature of R (32-bytes) and S (32-bytes). With the requirement that R is a packed Edwards point not of small order and S is a scalar in the range of 0 <= S < L. This requirement ensures no signature malleability. Each transaction must have at least one signature for [fee account](https://docs.solana.com/terminology#fee-account). Thus, the first signature in transaction can be treated as [transacton id](https://docs.solana.com/terminology#transaction-id)*

##### [skipped slot](https://docs.solana.com/terminology#skipped-slot "Direct link to heading") - *A past [slot](https://docs.solana.com/terminology#slot) that did not produce a [block](https://docs.solana.com/terminology#block), because the leader was offline or the [fork](https://docs.solana.com/terminology#fork) containing the slot was abandoned for a better alternative by cluster consensus. A skipped slot will not appear as an ancestor for blocks at subsequent slots, nor increment the [block height](https://docs.solana.com/terminology#block-height), nor expire the oldest `recent_blockhash`.*

##### [slot](https://docs.solana.com/terminology#slot "Direct link to heading") - *The period of time for which each [leader](https://docs.solana.com/terminology#leader) ingests transactions and produces a [block](https://docs.solana.com/terminology#block).*

##### [smart contract](https://docs.solana.com/terminology#smart-contract "Direct link to heading") - *A program on a blockchain that can read and modify accounts over which it has control.*

##### [sol](https://docs.solana.com/terminology#sol "Direct link to heading") - *The [native token](https://docs.solana.com/terminology#native-token) of a Solana [cluster](https://docs.solana.com/terminology#cluster).*

##### [Solana Program Library (SPL)](https://docs.solana.com/terminology#solana-program-library-spl "Direct link to heading") - *A library of programs on Solana such as spl-token that facilitates tasks such as creating and using tokens*

##### [stake](https://docs.solana.com/terminology#stake "Direct link to heading") - *Tokens forfeit to the [cluster](https://docs.solana.com/terminology#cluster) if malicious [validator](https://docs.solana.com/terminology#validator) behavior can be proven.*

##### [sysvar](https://docs.solana.com/terminology#sysvar "Direct link to heading") - *A system [account](https://docs.solana.com/terminology#account). [Sysvars](https://docs.solana.com/developing/runtime-facilities/sysvars) provide cluster state information such as current tick height, rewards [points](https://docs.solana.com/terminology#point) values, etc. Programs can access Sysvars via a Sysvar account (pubkey) or by querying via a syscall.*

##### [thin client](https://docs.solana.com/terminology#thin-client "Direct link to heading") - *A type of [client](https://docs.solana.com/terminology#client) that trusts it is communicating with a valid [cluster](https://docs.solana.com/terminology#cluster).*

##### [tick](https://docs.solana.com/terminology#tick "Direct link to heading") - *A ledger [entry](https://docs.solana.com/terminology#entry) that estimates wallclock duration.*

##### [tick height](https://docs.solana.com/terminology#tick-height "Direct link to heading") - *The Nth [tick](https://docs.solana.com/terminology#tick) in the [ledger](https://docs.solana.com/terminology#ledger).*

##### [token](https://docs.solana.com/terminology#token "Direct link to heading") - *A digitally transferable asset.*

##### [tps](https://docs.solana.com/terminology#tps "Direct link to heading") - *[Transactions](https://docs.solana.com/terminology#transaction) per second.*

##### [transaction](https://docs.solana.com/terminology#transaction "Direct link to heading") - *One or more [instructions](https://docs.solana.com/terminology#instruction) signed by a [client](https://docs.solana.com/terminology#client) using one or more [keypairs](https://docs.solana.com/terminology#keypair) and executed atomically with only two possible outcomes: success or failure.*

##### [transaction id](https://docs.solana.com/terminology#transaction-id "Direct link to heading") - *The first [signature](https://docs.solana.com/terminology#signature) in a [transaction](https://docs.solana.com/terminology#transaction), which can be used to uniquely identify the transaction across the complete [ledger](https://docs.solana.com/terminology#ledger).*

##### [transaction confirmations](https://docs.solana.com/terminology#transaction-confirmations "Direct link to heading") - *The number of [confirmed blocks](https://docs.solana.com/terminology#confirmed-block) since the transaction was accepted onto the [ledger](https://docs.solana.com/terminology#ledger). A transaction is finalized when its block becomes a [root](https://docs.solana.com/terminology#root).*

##### [transactions entry](https://docs.solana.com/terminology#transactions-entry "Direct link to heading") - *A set of [transactions](https://docs.solana.com/terminology#transaction) that may be executed in parallel.*

##### [validator](https://docs.solana.com/terminology#validator "Direct link to heading") - *A full participant in a Solana network [cluster](https://docs.solana.com/terminology#cluster) that produces new [blocks](https://docs.solana.com/terminology#block). A validator validates the transactions added to the [ledger](https://docs.solana.com/terminology#ledger)*

##### [verifiable delay function (VDF)](https://docs.solana.com/terminology#verifiable-delay-function-vdf "Direct link to heading") - *A function that takes a fixed amount of time to execute that produces a proof that it ran, which can then be verified in less time than it took to produce.*

##### [vote](https://docs.solana.com/terminology#vote "Direct link to heading") - *See [ledger vote](https://docs.solana.com/terminology#ledger-vote).*

##### [vote credit](https://docs.solana.com/terminology#vote-credit "Direct link to heading") - *A reward tally for [validators](https://docs.solana.com/terminology#validator). A vote credit is awarded to a validator in its vote account when the validator reaches a [root](https://docs.solana.com/terminology#root).*

##### [wallet](https://docs.solana.com/terminology#wallet "Direct link to heading") - *A collection of [keypairs](https://docs.solana.com/terminology#keypair) that allows users to manage their funds.*

##### 11. References
The following links contains information that can be useful for developers that want to dig into the details of the framework and related workshops to secure applications:

##### *[Solana Program Library](https://github.com/solana-labs/solana-program-library)* - Collection of on-chain programs targeting Sealevel.

##### *[Anchor - Project Serum](https://project-serum.github.io/anchor/getting-started)* - Introductory guide for Anchor.

##### *[Ethereum comparison](https://solana.wiki/zh-cn/docs/ethereum-comparison/)* - Detailed comparison between the main features of Solana and Ethereum.

##### *[Sealevel](https://medium.com/solana-labs/sealevel-parallel-processing-thousands-of-smart-contracts-d814b378192)* - Briefly explanation about the concept behind Sealevel provided by Solana's core team.

##### *[Sealevel Runtime Account Rules](https://solana.wiki/zh-cn/docs/account-model/#sealevel-runtime-account-rules)* - Account Level Model for Solana.

##### *[Turbine](https://medium.com/solana-labs/turbine-solanas-block-propagation-protocol-solves-the-scalability-trilemma-2ddba46a51db)* - Introductory concept behind Turbine as a core feature of Solana.

##### *[Turbine - Block Propagation](https://docs.solana.com/cluster/turbine-block-propagation)* - Multilayer Block Propagation Mechanism.

##### *[Gulf-Stream](https://medium.com/solana-labs/gulf-stream-solanas-mempool-less-transaction-forwarding-protocol-d342e72186ad)* - Introductory concept behind Gulf-Stream as a core feature of Solana.

##### *[Pipelining](https://medium.com/solana-labs/pipelining-in-solana-the-transaction-processing-unit-2bb01dbd2d8f)* - General overview to understand the transaction processing unit in Solana.

##### *[Cloudbreak](https://medium.com/solana-labs/cloudbreak-solanas-horizontally-scaled-state-architecture-9a86679dcbb1)* - Introductory concept behind Cloudbreak as a core feature of Solana

##### *[Cluster Benchmarking](https://docs.solana.com/cluster/bench-tps)* - Benchmark a Solana Cluster.

##### *[Solana Common Pitfalls](https://blog.neodyme.io/posts/solana_common_pitfalls)* - Common pitfalls in development practices.

*If you want to take a look to some detailed information about the protocol used take a look at these links:*
##### *[PoH](https://medium.com/solana-labs/proof-of-history-a-clock-for-blockchain-cf47a61a9274)* - Proof of History / Introductory information.

##### *[Tower BFT](https://medium.com/solana-labs/tower-bft-solanas-high-performance-implementation-of-pbft-464725911e79)* - Introductory concept behind TBFT as a core feature of Solana.

##### *[Solana Proof of Stake](https://www.shinobi-systems.com/primer.html)* - Primer on PoH / PoS.

*Links of interest:*
##### *[Features Removal](https://github.com/solana-labs/solana/pull/9992)* - Remove Archiver and storage program.

##### 12. Tutorials
A selection of tutorials and guides to learn about Solana development:

##### *[Solana Development Tutorial Environment Setup](https://solongwallet.medium.com/solana-development-tutorial-environment-setup-2649cb81305)* - Solana Environment Setup Reference.

##### *[How to build in Solana](https://www.brianfriel.xyz/learning-how-to-build-on-solana/)* - An introductory tour to writing applications in Solana.

##### *[A brief tour of programming in Anchor](https://2501babe.github.io/posts/anchor101.html)* - Anchor 101

##### *[An introduction to the Solana blockchain](https://2501babe.github.io/posts/solana101.html)* - Solana 101

##### *[Program Deploys](https://jstarry.notion.site/Program-deploys-29780c48794c47308d5f138074dd9838)* - How to get you SOL back from a deployed program.

##### *[Understanding Program derived addresses](https://www.brianfriel.xyz/understanding-program-derived-addresses/)* - A practical overview of how Solana programs read and write data.

#####  *[Transaction Fees](https://jstarry.notion.site/Transaction-Fees-f09387e6a8d84287aa16a34ecb58e239)* - How fees are calculated?.

##### *[Using PDAs and SPL Token in Anchor](https://medium.com/@pirosb3/using-pdas-and-spl-token-in-anchor-and-solana-df05c57ccd04)* - Let's build a Safe Token transfer app.

##### *[Anchor tutorials](https://project-serum.github.io/anchor/tutorials/)* - Anchor tutorials.

##### 13. Workshops
##### *[Solana Security Workshop](https://workshop.neodyme.io/index.html)* - Learn and exploit different types of flags in Solana.

##### *[Solend Auditing Workshop](https://docs.google.com/presentation/d/1jZ9kVo6hnhBsz3D2sywqpMojqLE5VTZtaXna7OHL1Uk/edit?pli=1#slide=id.ge292ecb5c9_0_60)* - Solend Auditing Workshop Slides.

 
