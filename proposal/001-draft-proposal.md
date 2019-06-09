# Heiswap (黑 swap)

## Prelude
This project was inspired by [Vitalik's post](https://hackmd.io/@HWeNw8hNRimMm2m2GH56Cw/rJj9hEJTN?type=view).

Heiswap aims to allow users to __easily__ "wash" their ETH (with ERC-20 tokens support in the future) in a confidential manner.

** Keyword is __easily__. Heiswap wants to have good ETH "washing" UX.

> Users don’t care about decentralization or private keys; they care about using your Dapp to do something important to them.

i.e. Heiswap will mask the identity of the recipients, but will not hide the value of the transaction nor the identity of the sender. This is because author personally thinks that this is a "good enough" level of privacy.

## Introduction
> “Currently, there are no good ways to use blockchain while preserving privacy" - Vitalik.

The goal of this project is not to invent a new privacy protocol or do ground breaking cryptography research, but rather applying what is currently out there and working into the Ethereum ecosystem. Monero [1], a well known privacy-focused cryptocurrency has seen great success with ring signatures [2] and stealth addresses [3] to hide the participants involved (Note: these methods of obfuscating the participants has been battle tested and proven to work on Monero).

As such, Heiswap aims to implement ring signatures and stealth addresses to obfuscate the recipients of the transaction. While a relayer will allow gasless withdrawals (useful when trying to withdraw from a stealth address).

## Implementation

### Smart Contract

The smart contract should the following interface:

`deposit(address stealth_address, address random_pk)` - This should be a payable function.

`withdraw(address destination, bytes signature)` - Withdraws without any fees

`withdrawViaRelayer(address destination, bytes signature)` - Pays the relayer (msg.sender) the gas back and some fees.

### Frontend

#### Sending

Before sending ETH / ERC-20 tokens to the recipient, the *recipient* must first generate a stealth address (basically ETH address prefixed with "hei" so users don't send money into the contract with no way of getting it out).

Once the ETH is sent into the contract, the sender is given a "pool" id. This id needs to be sent to the receiver for them to retrieve the funds.

#### Receiving

Receiver tab allows the receive to generate their one-time stealth address (and their one-time secret key). Receiver sends their staelth address to the sender, and waits till there is enough participants in the pool (for the ring signature to work, otherwise it defeats the purpose). Once there is enough participants in the pool, the receiver can re-enter their secret key and then either:

- a: Withdraw the funds via a relayer (easy method)
- b: Send ETH to the stealth address, and then withdraw it (advance method)


### Relayer

Some python/node.js/Haskell/Go application that relays the tx to the smart contract. Emits an event on completion. (Also have some gas calculation process to inform users how much they'll receive?)

## Pros and Cons

### Pros
1. Validation process is almost entirely on-chain
2. "Good-enough" privacy

### Cons
1. Users can only send fixed amounts of ETH
2. "Good-enough" privacy

## References
1. [Monero](https://ww.getmonero.org/resources/research-lab/)
2. [Ring Confidential Transactions](https://web.getmonero.org/resources/research-lab/pubs/MRL-0005.pdf)
3. [Stealth Addresses](https://monero.stackexchange.com/questions/1500/what-is-a-stealth-address/1506#1506)
4. [Meta Transactions](https://medium.com/@austin_48503/ethereum-meta-transactions-90ccf0859e84)